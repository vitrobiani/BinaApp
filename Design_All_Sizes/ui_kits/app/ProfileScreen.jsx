// ProfileScreen.jsx — hub that links to Account, Accessibility, Help & support.
// Top-level Profile tab in the bottom nav.

function ProfileScreen({ theme, setTheme, hintMode, onOpenAccount, onOpenAccessibility, onOpenHelp, onEditProfile, onOpenAbout }) {
  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      {/* Title */}
      <div style={{ padding: '12px 20px 0' }}>
        <h1 style={{ font: 'var(--t-display-sm)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.01em' }}>Profile</h1>
      </div>

      {/* Identity card */}
      <div style={{ padding: '16px 20px 0' }}>
        <button onClick={onOpenAccount} style={{
          width: '100%',
          background: 'var(--c-surface)', borderRadius: 22,
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)',
          padding: 18, display: 'flex', alignItems: 'center', gap: 14,
          cursor: 'pointer', textAlign: 'left',
        }}>
          <Avatar name="Sarah Levin" size={62} tone="blue" />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ font: 'var(--t-title-lg)', color: 'var(--c-ink)' }}>Sarah Levin</div>
            <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)' }}>sarah@levinfamily.com</div>
            <div style={{ font: 'var(--t-label-sm)', color: 'var(--c-primary)', marginTop: 6 }}>View account →</div>
          </div>
        </button>
      </div>

      {/* Theme quick-picker */}
      <ProfileGroup title="Appearance">
        <div style={{ padding: '14px 14px 12px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
            <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>Theme</div>
            <button onClick={onOpenAccessibility} style={{
              font: 'var(--t-label-sm)', color: 'var(--c-primary)', fontWeight: 600,
              background: 'transparent', border: 0, cursor: 'pointer', padding: 0,
            }}>More options →</button>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 8 }}>
            <ProfileThemeSwatch label="Light" id="light" active={theme === 'light'} onClick={() => setTheme('light')} grad="linear-gradient(135deg, #fbfaf6, #1f5bff)" />
            <ProfileThemeSwatch label="Dark"  id="dark"  active={theme === 'dark'}  onClick={() => setTheme('dark')}  grad="linear-gradient(135deg, #0c0f1a, #5b8bff)" />
            <ProfileThemeSwatch label="Warm"  id="warm"  active={theme === 'warm'}  onClick={() => setTheme('warm')}  grad="linear-gradient(135deg, #fff8e1, #ef8b1a)" />
            <ProfileThemeSwatch label="Cool"  id="cool"  active={theme === 'cool'}  onClick={() => setTheme('cool')}  grad="linear-gradient(135deg, #e3f2fd, #0099b3)" />
            <ProfileThemeSwatch label="A11y"  id="deuteranopia" active={theme === 'deuteranopia'} onClick={() => setTheme('deuteranopia')} grad="linear-gradient(135deg, #ffffff, #0077bb)" />
          </div>
        </div>
      </ProfileGroup>

      {/* Settings hub */}
      <ProfileGroup title="Settings">
        <HubRow
          icon={<IconUser size={20} />}
          label="Account"
          subtitle="Personal info, password, data"
          tone="blue"
          onClick={onOpenAccount}
        />
        <HubRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>}
          label="Accessibility"
          subtitle={`Theme · text size${hintMode ? ' · hints on' : ''}`}
          tone="aqua"
          onClick={onOpenAccessibility}
        />
        <HubRow
          icon={<IconChat size={20} />}
          label="Help & support"
          subtitle="FAQ, contact, send feedback"
          tone="coral"
          onClick={onOpenHelp}
          isLast
        />
      </ProfileGroup>

      <ProfileGroup title="About">
        <HubRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>}
          label="About Bina"
          subtitle="Version 1.0.0"
          tone="blue"
          onClick={onOpenAbout}
          isLast
        />
      </ProfileGroup>

      <div style={{ padding: '20px' }}>
        <button style={{
          width: '100%', height: 48, borderRadius: 999,
          background: 'transparent', color: 'var(--c-error)',
          border: '1px solid var(--c-line)', font: 'var(--t-label-lg)', cursor: 'pointer',
        }}>Sign out</button>
      </div>
    </div>
  );
}

function ProfileGroup({ title, children }) {
  return (
    <div style={{ padding: '24px 20px 0' }}>
      <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px 8px' }}>{title}</div>
      <div style={{
        background: 'var(--c-surface)', borderRadius: 18,
        border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)',
        overflow: 'hidden',
      }}>{children}</div>
    </div>
  );
}

function HubRow({ icon, label, subtitle, tone = 'blue', onClick, isLast }) {
  const tones = {
    blue:  { bg: 'var(--c-primary-100)', fg: 'var(--c-primary-700)' },
    coral: { bg: 'var(--c-coral-100)',   fg: 'var(--c-coral-700)' },
    aqua:  { bg: 'var(--c-aqua-100)',    fg: 'var(--c-aqua-700)' },
  };
  const t = tones[tone] || tones.blue;
  return (
    <button onClick={onClick} style={{
      width: '100%',
      display: 'grid', gridTemplateColumns: '40px 1fr auto', gap: 14,
      alignItems: 'center', padding: '14px',
      borderBottom: isLast ? 'none' : '1px solid var(--c-line)',
      background: 'transparent', border: 'none', cursor: 'pointer', textAlign: 'left',
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 12,
        background: t.bg, color: t.fg,
        display: 'grid', placeItems: 'center',
      }}>{icon}</div>
      <div style={{ minWidth: 0 }}>
        <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{label}</div>
        {subtitle && <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 2 }}>{subtitle}</div>}
      </div>
      <IconChevronRight size={18} />
    </button>
  );
}

function ProfileThemeSwatch({ label, id, grad, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
      cursor: 'pointer', background: 'transparent', border: 0, padding: 0,
    }}>
      <div style={{
        width: '100%', aspectRatio: 1, borderRadius: 14,
        background: grad,
        boxShadow: active ? '0 0 0 3px var(--c-primary)' : 'var(--sh-1)',
      }} />
      <div style={{ font: 'var(--t-label-sm)', color: active ? 'var(--c-primary)' : 'var(--c-ink-2)', fontWeight: active ? 600 : 500 }}>{label}</div>
    </button>
  );
}

// Toggle component reused from previous version
function Toggle({ on, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: 38, height: 22, borderRadius: 999,
      background: on ? 'var(--c-primary)' : 'var(--c-line-strong)',
      position: 'relative', transition: 'background 200ms',
      border: 0, cursor: 'pointer', padding: 0,
    }}>
      <div style={{
        position: 'absolute', top: 2, left: on ? 18 : 2,
        width: 18, height: 18, borderRadius: '50%', background: '#fff',
        boxShadow: '0 1px 3px rgba(0,0,0,0.15)', transition: 'left 200ms',
      }} />
    </button>
  );
}

Object.assign(window, { ProfileScreen, Toggle, ProfileGroup, HubRow, ProfileThemeSwatch });
