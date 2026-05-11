{
  description = "Flutter development environment";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        
        # FHS environment with Flutter but mutable Android SDK
        fhs = pkgs.buildFHSEnv {
          name = "flutter-env";
          targetPkgs = p: with p; [
            # Don't include flutter from nixpkgs - use local mutable installation
            jdk17
            gradle
            android-tools  # Just adb/fastboot
            git
            curl
            unzip
            which
            glibc
            zlib
            stdenv.cc.cc.lib
          ];
          multiPkgs = p: with p; [ zlib ];
          runScript = "bash";
          profile = ''
            # Use mutable Flutter in home directory (not Nix store - needs write access)
            export FLUTTER_HOME="$HOME/flutter"
            export ANDROID_HOME="$HOME/Android/Sdk"
            export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
            export JAVA_HOME="${pkgs.jdk17}"
            export GRADLE_USER_HOME="$HOME/.gradle"
            export PATH="$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

            mkdir -p "$GRADLE_USER_HOME"
            mkdir -p "$ANDROID_HOME"

            echo "Flutter FHS environment ready!"
            echo ""
            if [ ! -d "$FLUTTER_HOME/bin" ]; then
              echo "⚠️  Flutter not found at $FLUTTER_HOME"
              echo "Install it by running:"
              echo "  install-flutter"
            else
              echo "✓ Flutter: $FLUTTER_HOME"
            fi
            if [ ! -d "$ANDROID_HOME/platform-tools" ]; then
              echo "⚠️  Android SDK not found at $ANDROID_HOME"
              echo "Install it through Android Studio or run:"
              echo "  install-android-sdk"
            else
              echo "✓ Android SDK: $ANDROID_HOME"
            fi
          '';
        };
        
        # Helper script to install Flutter
        install-flutter-script = pkgs.writeShellScriptBin "install-flutter" ''
          FLUTTER_HOME="$HOME/flutter"

          if [ -d "$FLUTTER_HOME" ]; then
            echo "Flutter already exists at $FLUTTER_HOME"
            echo "To update, run: cd $FLUTTER_HOME && git pull"
            exit 0
          fi

          echo "Installing Flutter to $FLUTTER_HOME..."
          ${pkgs.git}/bin/git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"

          export PATH="$FLUTTER_HOME/bin:$PATH"
          echo "Running flutter doctor..."
          "$FLUTTER_HOME/bin/flutter" doctor

          echo ""
          echo "✓ Flutter installed successfully!"
          echo "Restart flutter-env to use it."
        '';

        # Helper script to install Android SDK
        install-sdk-script = pkgs.writeShellScriptBin "install-android-sdk" ''
          ANDROID_HOME="$HOME/Android/Sdk"
          CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
          
          echo "Installing Android SDK to $ANDROID_HOME..."
          mkdir -p "$ANDROID_HOME/cmdline-tools"
          
          cd /tmp
          ${pkgs.curl}/bin/curl -o cmdline-tools.zip "$CMDLINE_TOOLS_URL"
          ${pkgs.unzip}/bin/unzip -q cmdline-tools.zip
          mv cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
          rm cmdline-tools.zip
          
          echo "Installing SDK components..."
          yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses
          "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" \
            "platform-tools" \
            "platforms;android-34" \
            "platforms;android-35" \
            "build-tools;34.0.0" \
            "build-tools;28.0.3" \
            "ndk;28.2.13676358"
          
          echo "✓ Android SDK installed successfully!"
          echo "Run 'flutter doctor' to verify"
        '';
        
      in {
        packages.default = fhs;
        packages.flutter-env = fhs;
        
        apps.default = {
          type = "app";
          program = "${fhs}/bin/flutter-env";
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = [
            fhs
            pkgs.android-studio
            install-flutter-script
            install-sdk-script
          ];

          shellHook = ''
            echo "Flutter development environment"
            echo "Run 'flutter-env' to enter FHS shell"
            echo ""
            echo "First time setup:"
            echo "  1. Run 'flutter-env'"
            echo "  2. Run 'install-flutter' (installs to ~/flutter)"
            echo "  3. Run 'install-android-sdk' (or install through Android Studio)"
            echo "  4. Run 'flutter doctor'"
            zsh
          '';
        };
      }
    );
}
