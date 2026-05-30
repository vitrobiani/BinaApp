// AuthModeSwitch.jsx — refined Cloud / Local mode switch used on login + signup.
// Replaces the current Flutter Switch.adaptive that just says "Cloud" or "Local".
// Two segments with icons + descriptive copy. Compact, accessible, glanceable.

function AuthModeSwitch({ mode, setMode, dark = false }) {
  const onColor = dark ? '#fff' : 'var(--c-ink)';
  const offColor = dark ? 'rgba(255,255,255,0.55)' : 'var(--c-ink-3)';
  const trackBg = dark ? 'rgba(255,255,255,0.15)' : 'var(--c-surface-sunken)';
  const activeBg = dark ? '#fff' : 'var(--c-surface)';
  const activeFg = dark ? 'var(--c-primary-700)' : 'var(--c-ink)';

  const options = [
    {
      id: 'cloud',
      label: 'Cloud',
      sub: 'Sync across devices',
      icon: (
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
          <path d="M17.5 19a4.5 4.5 0 1 0-1.5-8.74A6.5 6.5 0 0 0 4.5 14.5a4.5 4.5 0 0 0 1 4.5h12z"/>
        </svg>
      ),
    },
    {
      id: 'local',
      label: 'On device',
      sub: 'Stays on this phone',
      icon: (
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
          <rect x="5" y="2" width="14" height="20" rx="3"/>
          <line x1="12" y1="18" x2="12" y2="18.01"/>
        </svg>
      ),
    },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div style={{
        display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 4,
        background: trackBg, borderRadius: 14,
        padding: 4,
        border: dark ? '1px solid rgba(255,255,255,0.18)' : '1px solid var(--c-line)',
      }}>
        {options.map(opt => {
          const active = mode === opt.id;
          return (
            <button key={opt.id} onClick={() => setMode(opt.id)} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
              padding: '10px 8px',
              background: active ? activeBg : 'transparent',
              color: active ? activeFg : (dark ? 'rgba(255,255,255,0.7)' : 'var(--c-ink-2)'),
              border: 0, borderRadius: 10, cursor: 'pointer',
              boxShadow: active ? 'var(--sh-1)' : 'none',
              transition: 'background 180ms, color 180ms, box-shadow 180ms',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                {opt.icon}
                <span style={{ font: 'var(--t-label-lg)', fontWeight: 600 }}>{opt.label}</span>
              </div>
              <span style={{
                font: 'var(--t-label-sm)',
                color: active ? (dark ? 'rgba(31,91,255,0.85)' : 'var(--c-ink-2)') : 'inherit',
                opacity: active ? 1 : 0.85,
              }}>{opt.sub}</span>
            </button>
          );
        })}
      </div>
      <div style={{
        font: 'var(--t-body-sm)',
        color: dark ? 'rgba(255,255,255,0.65)' : 'var(--c-ink-3)',
        textAlign: 'center', padding: '0 4px',
      }}>
        {mode === 'cloud'
          ? "Scans are encrypted and synced via Bina's secure cloud."
          : "Scans never leave this device. No internet required."}
      </div>
    </div>
  );
}

Object.assign(window, { AuthModeSwitch });
