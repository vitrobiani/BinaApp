// App.jsx — Bina UI Kit demo app.
// Hosts an iOS frame with multiple stacked Bina screens and a click-thru router.

const FAMILY = [
  { id: 1, name: 'Avi',  age: 8,  tone: 'blue',  lastChecked: '12 May', lastResult: 'good',   scanCount: 12, statClean: 9, statPlaque: 2, statCavity: 0 },
  { id: 2, name: 'Maya', age: 11, tone: 'coral', lastChecked: '9 May',  lastResult: 'cavity', scanCount: 8,  statClean: 4, statPlaque: 3, statCavity: 1 },
  { id: 3, name: 'Ron',  age: 6,  tone: 'aqua',  lastChecked: null,     lastResult: null,     scanCount: 0 },
  { id: 4, name: 'Dad',  age: 41, tone: 'ink',   lastChecked: '14 May', lastResult: 'plaque', scanCount: 6,  statClean: 4, statPlaque: 2, statCavity: 0 },
];

function App() {
  const [tab, setTab] = React.useState('home');
  // overlay = null | { kind: 'member', member } | { kind: 'scan', member } | { kind: 'dx', member }
  const [overlay, setOverlay] = React.useState(null);

  const openMember = (m) => setOverlay({ kind: 'member', member: m });

  const renderTab = () => {
    switch (tab) {
      case 'home':    return <HomeScreen family={FAMILY} go={setTab} openMember={openMember} />;
      case 'family':  return <FamilyScreen family={FAMILY} openMember={openMember} />;
      case 'chat':    return <ChatScreen />;
      case 'profile': return <ProfileScreen />;
      case 'scan':    return <HomeScreen family={FAMILY} go={setTab} openMember={openMember} />;
      default: return null;
    }
  };

  // When scan tab tapped, open scan overlay
  React.useEffect(() => {
    if (tab === 'scan') {
      setOverlay({ kind: 'scan', member: FAMILY[0] });
      setTab('home');
    }
  }, [tab]);

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%', overflow: 'hidden', background: 'var(--c-surface-alt)' }}>
      {/* Tab content */}
      <div style={{ width: '100%', height: '100%', overflowY: 'auto' }}>
        {renderTab()}
      </div>

      {/* Bottom nav (hidden when overlay covers chrome) */}
      {!(overlay && overlay.kind === 'scan') && (
        <BottomNav active={tab === 'home' ? 'home' : tab} onChange={(id) => {
          if (id === 'scan') { setOverlay({ kind: 'scan', member: FAMILY[0] }); return; }
          setOverlay(null);
          setTab(id);
        }} />
      )}

      {/* Overlays */}
      {overlay && overlay.kind === 'member' && (
        <Sheet onClose={() => setOverlay(null)}>
          <MemberDetailScreen
            member={overlay.member}
            onBack={() => setOverlay(null)}
            onScan={() => setOverlay({ kind: 'scan', member: overlay.member })}
          />
        </Sheet>
      )}
      {overlay && overlay.kind === 'scan' && (
        <Sheet onClose={() => setOverlay(null)} fullscreen>
          <ScanScreen
            member={overlay.member}
            onBack={() => setOverlay(null)}
            onCapture={() => setOverlay({ kind: 'dx', member: overlay.member })}
          />
        </Sheet>
      )}
      {overlay && overlay.kind === 'dx' && (
        <Sheet onClose={() => setOverlay(null)}>
          <DiagnosisScreen
            member={overlay.member}
            onBack={() => setOverlay({ kind: 'scan', member: overlay.member })}
            onDone={() => setOverlay(null)}
          />
        </Sheet>
      )}
    </div>
  );
}

function Sheet({ children, onClose, fullscreen }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 20,
      background: fullscreen ? '#000' : 'var(--c-surface-alt)',
      animation: 'binaSheetIn 320ms cubic-bezier(.2,.7,.2,1)',
      overflow: 'hidden',
    }}>
      <style>{`@keyframes binaSheetIn { from { transform: translateY(24px); opacity: 0 } to { transform: translateY(0); opacity: 1 } }`}</style>
      <div style={{ width: '100%', height: '100%', overflowY: 'auto' }}>
        {children}
      </div>
    </div>
  );
}

Object.assign(window, { App });
