// Components.jsx — atoms used across Bina screens.
// All styles use the design-tokens CSS vars from colors_and_type.css.

// ───────── Pill button ─────────
function BinaButton({ variant = 'primary', children, onClick, icon, fullWidth, size = 'md', style }) {
  const heights = { sm: 36, md: 48, lg: 56 };
  const paddings = { sm: '0 14px', md: '0 20px', lg: '0 24px' };
  const fontSizes = { sm: 13, md: 14, lg: 15 };
  const base = {
    height: heights[size],
    padding: paddings[size],
    borderRadius: 999,
    border: 0,
    cursor: 'pointer',
    fontFamily: 'Inter, system-ui, sans-serif',
    fontWeight: 500,
    fontSize: fontSizes[size],
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    width: fullWidth ? '100%' : undefined,
    transition: 'background 200ms cubic-bezier(.2,.7,.2,1), transform 100ms, box-shadow 200ms',
    ...style,
  };
  const variants = {
    primary: { background: 'var(--c-primary)', color: '#fff', boxShadow: 'var(--sh-2)' },
    secondary: { background: 'var(--c-primary-100)', color: 'var(--c-primary-700)' },
    ghost: { background: 'transparent', color: 'var(--c-primary)', border: '1px solid var(--c-line)' },
    coral: { background: 'var(--c-coral)', color: '#fff', boxShadow: 'var(--sh-2)' },
    danger: { background: 'var(--c-error)', color: '#fff', boxShadow: 'var(--sh-2)' },
    glass: { background: 'rgba(255,255,255,0.96)', color: 'var(--c-primary-700)' },
  };
  return (
    <button style={{ ...base, ...variants[variant] }} onClick={onClick}
      onMouseDown={(e) => { e.currentTarget.style.transform = 'translateY(1px) scale(0.99)'; }}
      onMouseUp={(e) => { e.currentTarget.style.transform = ''; }}
      onMouseLeave={(e) => { e.currentTarget.style.transform = ''; }}>
      {icon}{children}
    </button>
  );
}

// ───────── Avatar — initials w/ colored background ─────────
function Avatar({ name, size = 44, tone = 'blue' }) {
  const tones = {
    blue:  { bg: 'var(--c-primary-100)', fg: 'var(--c-primary-700)' },
    coral: { bg: 'var(--c-coral-100)', fg: 'var(--c-coral-700)' },
    aqua:  { bg: 'var(--c-aqua-100)', fg: 'var(--c-aqua-700)' },
    ink:   { bg: 'var(--c-ink)', fg: '#fff' },
  };
  const t = tones[tone] || tones.blue;
  const initials = (name || '').split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: t.bg, color: t.fg,
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: 'Inter, system-ui, sans-serif', fontWeight: 600,
      fontSize: Math.round(size * 0.36), flexShrink: 0,
    }}>{initials}</div>
  );
}

// ───────── Diagnosis chip ─────────
function DxChip({ kind = 'good', size = 'md' }) {
  const styles = {
    good:   { bg: 'var(--c-success-100)', fg: '#0e6b48', dot: 'var(--c-dx-good)',   label: 'Good' },
    plaque: { bg: '#fcf0d8',              fg: '#7a5a17', dot: 'var(--c-dx-plaque)', label: 'Plaque' },
    cavity: { bg: 'var(--c-error-100)',   fg: '#8a2727', dot: 'var(--c-dx-cavity)', label: 'Cavity' },
    mixed:  { bg: '#f8e1ee',              fg: '#6a2150', dot: 'var(--c-dx-mixed)',  label: 'Plaque + Cavity' },
    due:    { bg: 'var(--c-surface-sunken)', fg: 'var(--c-ink-2)', dot: 'var(--c-ink-3)', label: 'Scan due' },
  };
  const s = styles[kind] || styles.good;
  const fs = size === 'sm' ? 11 : 12;
  const py = size === 'sm' ? 3 : 5;
  const px = size === 'sm' ? 8 : 11;
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      background: s.bg, color: s.fg,
      padding: `${py}px ${px}px`, borderRadius: 999,
      fontFamily: 'Inter, system-ui, sans-serif', fontWeight: 500, fontSize: fs,
    }}>
      <span style={{ width: 7, height: 7, borderRadius: 999, background: s.dot }} />
      {s.label}
    </span>
  );
}

// ───────── Card ─────────
function Card({ children, padding = 16, radius = 14, style }) {
  return (
    <div style={{
      background: 'var(--c-surface)',
      borderRadius: radius,
      border: '1px solid var(--c-line)',
      boxShadow: 'var(--sh-2)',
      padding,
      ...style,
    }}>{children}</div>
  );
}

// ───────── Section header ─────────
function SectionHeader({ title, action }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'baseline', justifyContent: 'space-between',
      padding: '0 4px', marginBottom: 12,
    }}>
      <div style={{
        font: 'var(--t-headline-sm)', color: 'var(--c-ink)',
        letterSpacing: '-0.005em', whiteSpace: 'nowrap',
      }}>{title}</div>
      {action && <div style={{ font: 'var(--t-label-md)', color: 'var(--c-primary)', cursor: 'pointer', flexShrink: 0, marginLeft: 12 }}>{action}</div>}
    </div>
  );
}

// ───────── Bottom nav ─────────
function BottomNav({ active, onChange }) {
  const tabs = [
    { id: 'home', label: 'Home', icon: IconHome },
    { id: 'family', label: 'Family', icon: IconUsers },
    { id: 'scan', label: 'Scan', icon: IconCamera, fab: true },
    { id: 'chat', label: 'Chat', icon: IconChat },
    { id: 'profile', label: 'Profile', icon: IconUser },
  ];
  return (
    <div style={{
      position: 'absolute', left: 12, right: 12, bottom: 22, zIndex: 5,
      background: 'var(--c-surface)',
      borderRadius: 28,
      boxShadow: 'var(--sh-3)',
      border: '1px solid var(--c-line)',
      height: 70,
      display: 'grid',
      gridTemplateColumns: '1fr 1fr 84px 1fr 1fr',
      alignItems: 'center',
      paddingInline: 6,
    }}>
      {tabs.map(t => {
        if (t.fab) return (
          <div key={t.id} style={{ display: 'flex', justifyContent: 'center' }}>
            <button
              aria-label={t.label}
              onClick={() => onChange(t.id)}
              style={{
                width: 58, height: 58, borderRadius: '50%',
                background: 'var(--g-hero)', color: '#fff',
                display: 'grid', placeItems: 'center',
                boxShadow: 'var(--sh-hero)',
                border: '4px solid var(--c-surface)',
                cursor: 'pointer',
                transform: 'translateY(-18px)',
              }}>
              <t.icon size={26} />
            </button>
          </div>
        );
        const isActive = active === t.id;
        return (
          <button key={t.id} onClick={() => onChange(t.id)} style={{
            background: 'transparent', border: 0, cursor: 'pointer',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
            color: isActive ? 'var(--c-primary)' : 'var(--c-ink-3)',
            fontFamily: 'Inter', fontSize: 11, fontWeight: 500,
            padding: '6px 0',
          }}>
            <t.icon size={22} />
            <span>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

Object.assign(window, {
  BinaButton, Avatar, DxChip, Card, SectionHeader, BottomNav,
});
