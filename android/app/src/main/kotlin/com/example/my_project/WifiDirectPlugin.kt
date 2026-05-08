package Bina.System

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.NetworkInfo
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pDeviceList
import android.net.wifi.p2p.WifiP2pGroup
import android.net.wifi.p2p.WifiP2pInfo
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import android.os.Looper
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class WifiDirectPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        private const val TAG = "WifiDirectPlugin"
        private const val METHOD_CHANNEL = "com.bina.system/wifi_direct"
        private const val DEVICE_EVENT_CHANNEL = "com.bina.system/wifi_direct/devices"
        private const val CONNECTION_EVENT_CHANNEL = "com.bina.system/wifi_direct/connection"
    }

    private lateinit var methodChannel: MethodChannel
    private lateinit var deviceEventChannel: EventChannel
    private lateinit var connectionEventChannel: EventChannel
    private lateinit var context: Context

    private var wifiP2pManager: WifiP2pManager? = null
    private var wifiP2pChannel: WifiP2pManager.Channel? = null
    private var broadcastReceiver: BroadcastReceiver? = null

    private var deviceEventSink: EventChannel.EventSink? = null
    private var connectionEventSink: EventChannel.EventSink? = null

    private var isDiscovering = false
    private var connectedDeviceAddress: String? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        deviceEventChannel = EventChannel(binding.binaryMessenger, DEVICE_EVENT_CHANNEL)
        deviceEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                deviceEventSink = events
            }
            override fun onCancel(arguments: Any?) {
                deviceEventSink = null
            }
        })

        connectionEventChannel = EventChannel(binding.binaryMessenger, CONNECTION_EVENT_CHANNEL)
        connectionEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                connectionEventSink = events
            }
            override fun onCancel(arguments: Any?) {
                connectionEventSink = null
            }
        })

        initializeWifiP2p()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        unregisterReceiver()
        wifiP2pChannel?.close()
    }

    private fun initializeWifiP2p() {
        wifiP2pManager = context.getSystemService(Context.WIFI_P2P_SERVICE) as? WifiP2pManager
        wifiP2pChannel = wifiP2pManager?.initialize(context, Looper.getMainLooper(), null)
        registerReceiver()
    }

    private fun registerReceiver() {
        val intentFilter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        }

        broadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                        val state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)
                        val isEnabled = state == WifiP2pManager.WIFI_P2P_STATE_ENABLED
                        Log.d(TAG, "WiFi P2P state changed: enabled=$isEnabled")
                        sendConnectionEvent(mapOf(
                            "type" to "wifi_state",
                            "enabled" to isEnabled
                        ))
                    }

                    WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                        Log.d(TAG, "Peers changed")
                        requestPeers()
                    }

                    WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                        val networkInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO, NetworkInfo::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO)
                        }

                        if (networkInfo?.isConnected == true) {
                            Log.d(TAG, "Connected to P2P network")
                            requestConnectionInfo()
                        } else {
                            Log.d(TAG, "Disconnected from P2P network")
                            connectedDeviceAddress = null
                            sendConnectionEvent(mapOf(
                                "type" to "disconnected"
                            ))
                        }
                    }

                    WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> {
                        val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE, WifiP2pDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE)
                        }
                        Log.d(TAG, "This device changed: ${device?.deviceName}")
                    }
                }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(broadcastReceiver, intentFilter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(broadcastReceiver, intentFilter)
        }
    }

    private fun unregisterReceiver() {
        broadcastReceiver?.let {
            try {
                context.unregisterReceiver(it)
            } catch (e: Exception) {
                Log.e(TAG, "Error unregistering receiver: ${e.message}")
            }
        }
        broadcastReceiver = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> {
                result.success(wifiP2pManager != null)
            }

            "hasPermissions" -> {
                result.success(checkPermissions())
            }

            "startDiscovery" -> {
                startDiscovery(result)
            }

            "stopDiscovery" -> {
                stopDiscovery(result)
            }

            "connect" -> {
                val deviceAddress = call.argument<String>("deviceAddress")
                val pin = call.argument<String>("pin")
                if (deviceAddress != null) {
                    connect(deviceAddress, pin, result)
                } else {
                    result.error("INVALID_ARGUMENT", "deviceAddress is required", null)
                }
            }

            "disconnect" -> {
                disconnect(result)
            }

            "getConnectionInfo" -> {
                requestConnectionInfo(result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun checkPermissions(): Boolean {
        val locationPermission = ContextCompat.checkSelfPermission(
            context, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        val nearbyPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                context, Manifest.permission.NEARBY_WIFI_DEVICES
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }

        return locationPermission && nearbyPermission
    }

    private fun startDiscovery(result: MethodChannel.Result) {
        if (!checkPermissions()) {
            result.error("PERMISSION_DENIED", "Required permissions not granted", null)
            return
        }

        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) {
            result.error("NOT_INITIALIZED", "WiFi P2P not initialized", null)
            return
        }

        try {
            manager.discoverPeers(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    Log.d(TAG, "Discovery started")
                    isDiscovering = true
                    result.success(true)
                }

                override fun onFailure(reason: Int) {
                    Log.e(TAG, "Discovery failed: $reason")
                    isDiscovering = false
                    result.error("DISCOVERY_FAILED", "Failed to start discovery: ${getErrorReason(reason)}", reason)
                }
            })
        } catch (e: SecurityException) {
            result.error("SECURITY_EXCEPTION", e.message, null)
        }
    }

    private fun stopDiscovery(result: MethodChannel.Result) {
        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) {
            result.success(true)
            return
        }

        try {
            manager.stopPeerDiscovery(channel, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    Log.d(TAG, "Discovery stopped")
                    isDiscovering = false
                    result.success(true)
                }

                override fun onFailure(reason: Int) {
                    Log.e(TAG, "Stop discovery failed: $reason")
                    result.success(true) // Still return success, it's not critical
                }
            })
        } catch (e: SecurityException) {
            result.error("SECURITY_EXCEPTION", e.message, null)
        }
    }

    private fun requestPeers() {
        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) return

        try {
            manager.requestPeers(channel) { peers: WifiP2pDeviceList? ->
                val deviceList = peers?.deviceList?.map { device ->
                    mapOf(
                        "deviceName" to device.deviceName,
                        "deviceAddress" to device.deviceAddress,
                        "status" to getDeviceStatus(device.status),
                        "isGroupOwner" to device.isGroupOwner
                    )
                } ?: emptyList()

                Log.d(TAG, "Found ${deviceList.size} peers")
                sendDeviceEvent(deviceList)
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception requesting peers: ${e.message}")
        }
    }

    private fun connect(deviceAddress: String, pin: String?, result: MethodChannel.Result) {
        if (!checkPermissions()) {
            result.error("PERMISSION_DENIED", "Required permissions not granted", null)
            return
        }

        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) {
            result.error("NOT_INITIALIZED", "WiFi P2P not initialized", null)
            return
        }

        // First, cancel any existing connection attempts
        manager.cancelConnect(channel, null)

        val config = WifiP2pConfig().apply {
            this.deviceAddress = deviceAddress
            // Set groupOwnerIntent to 0 - we want to be a client, not the group owner
            // 0 = least inclination to be GO, 15 = highest inclination
            this.groupOwnerIntent = 0

            if (pin != null && pin.isNotEmpty()) {
                // Use KEYPAD when we're providing the PIN to connect to a GO
                wps.setup = WpsInfo.KEYPAD
                wps.pin = pin
                Log.d(TAG, "Connecting with WPS KEYPAD, PIN: $pin")
            } else {
                // Use Push Button Config if no PIN
                wps.setup = WpsInfo.PBC
                Log.d(TAG, "Connecting with WPS PBC (no PIN)")
            }
        }

        Log.d(TAG, "Attempting connection to $deviceAddress with groupOwnerIntent=0")

        try {
            manager.connect(channel, config, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    Log.d(TAG, "Connection initiated successfully to $deviceAddress")
                    connectedDeviceAddress = deviceAddress
                    sendConnectionEvent(mapOf(
                        "type" to "connecting",
                        "deviceAddress" to deviceAddress
                    ))
                    result.success(true)
                }

                override fun onFailure(reason: Int) {
                    Log.e(TAG, "Connection failed with reason: $reason (${getErrorReason(reason)})")

                    // If KEYPAD failed, try with DISPLAY method
                    if (pin != null && reason == WifiP2pManager.ERROR) {
                        Log.d(TAG, "Retrying with WPS DISPLAY method...")
                        tryConnectWithDisplay(deviceAddress, pin, result)
                    } else {
                        sendConnectionEvent(mapOf(
                            "type" to "connection_failed",
                            "reason" to getErrorReason(reason)
                        ))
                        result.error("CONNECTION_FAILED", "Failed to connect: ${getErrorReason(reason)}", reason)
                    }
                }
            })
        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception during connect: ${e.message}")
            result.error("SECURITY_EXCEPTION", e.message, null)
        }
    }

    private fun tryConnectWithDisplay(deviceAddress: String, pin: String, result: MethodChannel.Result) {
        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) {
            result.error("NOT_INITIALIZED", "WiFi P2P not initialized", null)
            return
        }

        val config = WifiP2pConfig().apply {
            this.deviceAddress = deviceAddress
            this.groupOwnerIntent = 0
            // Try DISPLAY method - GO displays PIN, we enter it
            wps.setup = WpsInfo.DISPLAY
            wps.pin = pin
        }

        try {
            manager.connect(channel, config, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    Log.d(TAG, "Connection with DISPLAY initiated to $deviceAddress")
                    connectedDeviceAddress = deviceAddress
                    result.success(true)
                }

                override fun onFailure(reason: Int) {
                    Log.e(TAG, "Connection with DISPLAY also failed: $reason")
                    // Try one more time with PBC
                    tryConnectWithPBC(deviceAddress, result)
                }
            })
        } catch (e: SecurityException) {
            result.error("SECURITY_EXCEPTION", e.message, null)
        }
    }

    private fun tryConnectWithPBC(deviceAddress: String, result: MethodChannel.Result) {
        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) {
            result.error("NOT_INITIALIZED", "WiFi P2P not initialized", null)
            return
        }

        val config = WifiP2pConfig().apply {
            this.deviceAddress = deviceAddress
            this.groupOwnerIntent = 0
            wps.setup = WpsInfo.PBC
        }

        Log.d(TAG, "Final attempt with PBC...")

        try {
            manager.connect(channel, config, object : WifiP2pManager.ActionListener {
                override fun onSuccess() {
                    Log.d(TAG, "Connection with PBC initiated to $deviceAddress")
                    connectedDeviceAddress = deviceAddress
                    result.success(true)
                }

                override fun onFailure(reason: Int) {
                    Log.e(TAG, "All connection methods failed: $reason")
                    sendConnectionEvent(mapOf(
                        "type" to "connection_failed",
                        "reason" to "All WPS methods failed: ${getErrorReason(reason)}"
                    ))
                    result.error("CONNECTION_FAILED", "All connection methods failed: ${getErrorReason(reason)}", reason)
                }
            })
        } catch (e: SecurityException) {
            result.error("SECURITY_EXCEPTION", e.message, null)
        }
    }

    private fun disconnect(result: MethodChannel.Result) {
        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) {
            result.success(true)
            return
        }

        manager.removeGroup(channel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                Log.d(TAG, "Disconnected")
                connectedDeviceAddress = null
                result.success(true)
            }

            override fun onFailure(reason: Int) {
                Log.e(TAG, "Disconnect failed: $reason")
                // Still consider it a success if not in a group
                connectedDeviceAddress = null
                result.success(true)
            }
        })
    }

    private fun requestConnectionInfo(result: MethodChannel.Result? = null) {
        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) {
            result?.error("NOT_INITIALIZED", "WiFi P2P not initialized", null)
            return
        }

        manager.requestConnectionInfo(channel) { info: WifiP2pInfo? ->
            if (info != null && info.groupFormed) {
                val connectionData = mapOf(
                    "type" to "connected",
                    "isGroupOwner" to info.isGroupOwner,
                    "groupOwnerAddress" to info.groupOwnerAddress?.hostAddress,
                    "deviceAddress" to connectedDeviceAddress
                )

                Log.d(TAG, "Connection info: $connectionData")
                sendConnectionEvent(connectionData)
                result?.success(connectionData)

                // Also request group info for more details
                requestGroupInfo()
            } else {
                result?.success(null)
            }
        }
    }

    private fun requestGroupInfo() {
        val manager = wifiP2pManager
        val channel = wifiP2pChannel

        if (manager == null || channel == null) return

        try {
            manager.requestGroupInfo(channel) { group: WifiP2pGroup? ->
                if (group != null) {
                    Log.d(TAG, "Group info - Network name: ${group.networkName}, Passphrase: ${group.passphrase}")
                }
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception requesting group info: ${e.message}")
        }
    }

    private fun sendDeviceEvent(devices: List<Map<String, Any?>>) {
        deviceEventSink?.success(devices)
    }

    private fun sendConnectionEvent(data: Map<String, Any?>) {
        connectionEventSink?.success(data)
    }

    private fun getDeviceStatus(status: Int): String {
        return when (status) {
            WifiP2pDevice.AVAILABLE -> "available"
            WifiP2pDevice.INVITED -> "invited"
            WifiP2pDevice.CONNECTED -> "connected"
            WifiP2pDevice.FAILED -> "failed"
            WifiP2pDevice.UNAVAILABLE -> "unavailable"
            else -> "unknown"
        }
    }

    private fun getErrorReason(reason: Int): String {
        return when (reason) {
            WifiP2pManager.P2P_UNSUPPORTED -> "P2P_UNSUPPORTED"
            WifiP2pManager.ERROR -> "ERROR"
            WifiP2pManager.BUSY -> "BUSY"
            else -> "UNKNOWN ($reason)"
        }
    }
}
