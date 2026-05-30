// Dialog.jsx — alert + info + confirm dialogs.
// Used for: sign out, delete account, generic confirmations, success/info notices.
// API: <Dialog kind="alert|info|confirm|success" title=".." body=".." confirmLabel=".." onConfirm onClose />

function Dialog({ kind = 'info', title, body, confirmLabel, cancelLabel, destructive, onConfirm, onClose, icon }) {
  const palettes = {
    info:    { bg: 'var(--c-primary-100)', fg: 'var(--c-primary-700)', icon: <IconSparkle size={24} /> },
    alert:   { bg: 'var(--c-error-100)',   fg: 'var(--c-error)',       icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
    ) },
    confirm: { bg: '#fcf0d8', fg: '#7a5a17', icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
    ) },
    success: { bg: 'var(--c-success-100)', fg: '#0e6b48', icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
    ) },
  };
  const p = palettes[kind] || palettes.info;
  const showCancel = onConfirm !== undefined; // any "do you want to..." has a cancel; pure info has only OK

  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 100,
      background: 'rgba(12, 21, 48, 0.5)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      padding: 28,
      animation: 'binaScrimIn 200ms ease-out',
    }}>
      <style>{`
        @keyframes binaScrimIn { from { opacity: 0 } to { opacity: 1 } }
        @keyframes binaDialogIn {
          from { transform: scale(0.92) translateY(8px); opacity: 0; }
          to   { transform: scale(1) translateY(0); opacity: 1; }
        }
      `}</style>
      <div onClick={(e) => e.stopPropagation()} style={{
        background: 'var(--c-surface)', borderRadius: 22,
        padding: 20, width: '100%', maxWidth: 320,
        boxShadow: 'var(--sh-4)',
        animation: 'binaDialogIn 220ms cubic-bezier(.2,.7,.2,1)',
      }}>
        <div style={{
          width: 48, height: 48, borderRadius: 14,
          background: p.bg, color: p.fg,
          display: 'grid', placeItems: 'center',
          marginBottom: 14,
        }}>{icon || p.icon}</div>
        <div style={{ font: 'var(--t-headline-sm)', color: 'var(--c-ink)', letterSpacing: '-0.005em' }}>{title}</div>
        {body && (
          <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', marginTop: 6, lineHeight: 1.5 }}>{body}</div>
        )}
        <div style={{ display: 'flex', gap: 8, marginTop: 18 }}>
          {showCancel && (
            <BinaButton variant="ghost" fullWidth onClick={onClose}>
              {cancelLabel || 'Cancel'}
            </BinaButton>
          )}
          <BinaButton
            variant={destructive ? 'danger' : 'primary'}
            fullWidth
            onClick={() => { onConfirm ? onConfirm() : onClose(); }}
          >
            {confirmLabel || 'OK'}
          </BinaButton>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { Dialog });
