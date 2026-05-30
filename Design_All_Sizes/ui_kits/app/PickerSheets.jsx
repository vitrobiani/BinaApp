// PickerSheets.jsx — bottom sheets for choosing language, date format, etc.

function PickerSheet({ title, subtitle, options, value, onClose, onPick }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 50,
      background: 'rgba(12, 21, 48, 0.45)',
      display: 'flex', flexDirection: 'column', justifyContent: 'flex-end',
      animation: 'binaScrimIn 200ms ease-out',
    }}>
      <style>{`
        @keyframes binaScrimIn { from { opacity: 0 } to { opacity: 1 } }
        @keyframes binaSheetSlideUp { from { transform: translateY(40px); opacity: 0.4 } to { transform: translateY(0); opacity: 1 } }
      `}</style>
      <div onClick={onClose} style={{ flex: 1 }} />
      <div style={{
        background: 'var(--c-surface)',
        borderTopLeftRadius: 28, borderTopRightRadius: 28,
        boxShadow: 'var(--sh-4)',
        maxHeight: '70%',
        display: 'flex', flexDirection: 'column',
        animation: 'binaSheetSlideUp 280ms cubic-bezier(.2,.7,.2,1)',
        paddingBottom: 16,
      }}>
        <div style={{ display: 'grid', placeItems: 'center', padding: '10px 0 6px' }}>
          <div style={{ width: 44, height: 5, borderRadius: 999, background: 'var(--c-line-strong)' }} />
        </div>
        <div style={{ padding: '6px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <h2 style={{ font: 'var(--t-headline-md)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.005em' }}>
              {title}
            </h2>
            {subtitle && (
              <p style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', margin: '4px 0 0' }}>{subtitle}</p>
            )}
          </div>
          <button onClick={onClose} style={{
            width: 36, height: 36, borderRadius: '50%',
            background: 'var(--c-surface-sunken)', border: 0,
            cursor: 'pointer', display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)',
          }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6 6 18M6 6l12 12"/></svg>
          </button>
        </div>
        <div style={{ padding: '16px 14px 0', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: 4 }}>
          {options.map(opt => (
            <PickerRow key={opt.id} opt={opt} active={value === opt.id} onClick={() => { onPick(opt.id); onClose(); }} />
          ))}
        </div>
      </div>
    </div>
  );
}

function PickerRow({ opt, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: '100%',
      padding: '12px 12px',
      borderRadius: 12,
      border: 0,
      background: active ? 'var(--c-primary-100)' : 'transparent',
      cursor: 'pointer', textAlign: 'left',
      display: 'grid', gridTemplateColumns: opt.glyph ? '36px 1fr auto' : '1fr auto', gap: 12, alignItems: 'center',
    }}>
      {opt.glyph && (
        <div style={{
          width: 36, height: 36, borderRadius: 10,
          background: active ? 'var(--c-surface)' : 'var(--c-surface-sunken)',
          color: active ? 'var(--c-primary-700)' : 'var(--c-ink-2)',
          display: 'grid', placeItems: 'center',
          font: '600 14px/1 Inter',
        }}>{opt.glyph}</div>
      )}
      <div>
        <div style={{
          font: 'var(--t-body-lg)',
          color: active ? 'var(--c-primary-700)' : 'var(--c-ink)',
          fontWeight: active ? 600 : 400,
        }}>{opt.label}</div>
        {opt.subtitle && (
          <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 1 }}>{opt.subtitle}</div>
        )}
      </div>
      <span style={{
        width: 22, height: 22, borderRadius: '50%',
        background: active ? 'var(--c-primary)' : 'transparent',
        border: active ? 0 : '1.5px solid var(--c-line-strong)',
        display: 'grid', placeItems: 'center', color: '#fff',
      }}>
        {active && <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>}
      </span>
    </button>
  );
}

// ───── Pre-baked sheets ─────
const LANGUAGES = [
  { id: 'en',    label: 'English',    subtitle: 'United States',  glyph: 'EN' },
  { id: 'he',    label: 'עברית',     subtitle: 'Hebrew',          glyph: 'HE' },
  { id: 'ar',    label: 'العربية',   subtitle: 'Arabic',          glyph: 'AR' },
  { id: 'es',    label: 'Español',    subtitle: 'Spanish',         glyph: 'ES' },
  { id: 'fr',    label: 'Français',   subtitle: 'French',          glyph: 'FR' },
  { id: 'de',    label: 'Deutsch',    subtitle: 'German',          glyph: 'DE' },
  { id: 'ru',    label: 'Русский',    subtitle: 'Russian',         glyph: 'RU' },
];

const DATE_FORMATS = [
  { id: 'dmy_slash', label: '12/05/2026', subtitle: 'DD/MM/YYYY · Most of Europe' },
  { id: 'mdy_slash', label: '05/12/2026', subtitle: 'MM/DD/YYYY · United States' },
  { id: 'ymd_dash',  label: '2026-05-12', subtitle: 'YYYY-MM-DD · ISO 8601' },
  { id: 'd_mmm_y',   label: '12 May 2026', subtitle: 'D MMM YYYY · long form' },
];

function LanguagePickerSheet({ value, onClose, onPick }) {
  return <PickerSheet title="App language" subtitle="The interface will reload after you choose." options={LANGUAGES} value={value} onClose={onClose} onPick={onPick} />;
}
function DateFormatPickerSheet({ value, onClose, onPick }) {
  return <PickerSheet title="Date format" subtitle="How dates display across the app." options={DATE_FORMATS} value={value} onClose={onClose} onPick={onPick} />;
}

Object.assign(window, { PickerSheet, LanguagePickerSheet, DateFormatPickerSheet, LANGUAGES, DATE_FORMATS });
