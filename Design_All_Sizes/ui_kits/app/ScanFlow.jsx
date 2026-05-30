// ScanFlow.jsx — pre-capture screens for the scan flow.
// Source: lib/pages/other_pages/camera_connection/camera_connection_widget.dart
// (target selector is new — implied by the family-aware data model)

// ───────── Step 1: Who are you scanning? ─────────
function ScanTargetScreen({ family, onCancel, onPick }) {
  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      <div style={{ padding: '12px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onCancel} style={{
          width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
          display: 'grid', placeItems: 'center', color: 'var(--c-ink)',
        }}><IconChevronLeft size={22} /></button>
        <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>Step 1 of 2</div>
        <div style={{ width: 44 }} />
      </div>

      <div style={{ padding: '12px 20px 0' }}>
        <h1 style={{ font: 'var(--t-display-sm)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.01em' }}>
          Who are you scanning?
        </h1>
        <p style={{ font: 'var(--t-body-lg)', color: 'var(--c-ink-2)', margin: '8px 0 0', lineHeight: 1.5 }}>
          Pick the family member this scan belongs to. The result will be saved to their history.
        </p>
      </div>

      {/* "Myself" — promoted as a different visual style */}
      <div style={{ padding: '20px 20px 0' }}>
        <button onClick={() => onPick({ id: 0, name: 'Sarah', tone: 'blue', isMe: true })} style={{
          width: '100%',
          background: 'var(--g-hero)', color: '#fff', borderRadius: 18,
          border: 0, boxShadow: 'var(--sh-hero)', cursor: 'pointer',
          padding: 16, display: 'flex', alignItems: 'center', gap: 14, textAlign: 'left',
        }}>
          <div style={{
            width: 48, height: 48, borderRadius: '50%',
            background: 'rgba(255,255,255,0.2)', color: '#fff',
            display: 'grid', placeItems: 'center', font: 'var(--t-title-md)', fontWeight: 600,
          }}>SA</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ font: 'var(--t-title-lg)', color: '#fff' }}>Scan myself</div>
            <div style={{ font: 'var(--t-body-sm)', opacity: 0.85 }}>Sarah · last checked 14 May</div>
          </div>
          <IconChevronRight size={20} />
        </button>
      </div>

      {/* Family list */}
      <div style={{ padding: '20px 20px 0' }}>
        <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px 8px' }}>
          Family members
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {family.map(m => (
            <button key={m.id} onClick={() => onPick(m)} style={{
              background: 'var(--c-surface)', borderRadius: 14,
              border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)',
              padding: 12, cursor: 'pointer',
              display: 'grid', gridTemplateColumns: '44px 1fr auto', gap: 12, alignItems: 'center',
              textAlign: 'left',
            }}>
              <Avatar name={m.name} size={44} tone={m.tone} />
              <div style={{ minWidth: 0 }}>
                <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{m.name}</div>
                <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 1 }}>
                  {m.age} yrs · {m.lastChecked ? `last checked ${m.lastChecked}` : 'never checked'}
                </div>
              </div>
              <IconChevronRight size={18} />
            </button>
          ))}
          <button style={{
            background: 'transparent', border: '2px dashed var(--c-line-strong)',
            borderRadius: 14, padding: 14, cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            color: 'var(--c-primary)', font: 'var(--t-label-lg)',
          }}>
            <IconPlus size={20} /> Add new member
          </button>
        </div>
      </div>
    </div>
  );
}

// ───────── Step 2: Connect to camera ─────────
function CameraConnectionScreen({ target, onBack, onConnected }) {
  // Track which source the user picks. We auto-advance once "ready".
  const [picked, setPicked] = React.useState(null);  // 'phone' | 'external'
  const [status, setStatus] = React.useState('idle'); // idle | connecting | ready | error

  const pick = (src) => {
    setPicked(src);
    setStatus('connecting');
    setTimeout(() => setStatus('ready'), 1200);
  };

  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      <div style={{ padding: '12px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={{
          width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
          display: 'grid', placeItems: 'center', color: 'var(--c-ink)',
        }}><IconChevronLeft size={22} /></button>
        <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>Step 2 of 2</div>
        <div style={{ width: 44 }} />
      </div>

      <div style={{ padding: '12px 20px 0' }}>
        <h1 style={{ font: 'var(--t-display-sm)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.01em' }}>
          Connect a camera
        </h1>
        <p style={{ font: 'var(--t-body-lg)', color: 'var(--c-ink-2)', margin: '8px 0 0', lineHeight: 1.5 }}>
          Scanning <strong style={{ color: 'var(--c-ink)', fontWeight: 600 }}>{target?.name || 'Avi'}</strong> · pick a camera source.
        </p>
      </div>

      {/* Source picker */}
      <div style={{ padding: '20px 20px 0', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <SourceCard
          icon={<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"><rect x="5" y="2" width="14" height="20" rx="2"/><path d="M12 18h.01"/></svg>}
          title="Phone camera"
          subtitle="Use the back camera on this device"
          active={picked === 'phone'}
          onClick={() => pick('phone')}
        />
        <SourceCard
          icon={<IconCamera size={28} />}
          title="Bina dental cam"
          subtitle="Wi-Fi intraoral camera (MJPEG)"
          right={picked === 'external' && status === 'connecting' ? <Spinner /> : picked === 'external' && status === 'ready' ? <CheckBadge /> : null}
          active={picked === 'external'}
          onClick={() => pick('external')}
        />
      </div>

      {/* Live preview / status card */}
      <div style={{ padding: '20px 20px 0' }}>
        <div style={{
          background: 'var(--c-surface)', borderRadius: 18,
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)',
          padding: 16,
        }}>
          <div style={{
            aspectRatio: '16/10', borderRadius: 12, overflow: 'hidden',
            background: status === 'ready'
              ? 'radial-gradient(ellipse at 50% 55%, #5b3133 0%, #2a1517 50%, #0a0d18 90%)'
              : 'var(--c-surface-sunken)',
            display: 'grid', placeItems: 'center', color: 'var(--c-ink-3)',
            position: 'relative',
          }}>
            {status === 'idle' && <div style={{ font: 'var(--t-body-md)' }}>Pick a source above to preview</div>}
            {status === 'connecting' && (
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10 }}>
                <Spinner size={28} />
                <div style={{ font: 'var(--t-body-md)' }}>Connecting…</div>
              </div>
            )}
            {status === 'ready' && (
              <>
                <div style={{ position: 'absolute', left: '15%', right: '15%', top: '40%', display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 3 }}>
                  {Array.from({length: 8}).map((_, i) => (
                    <div key={i} style={{ aspectRatio: '0.7', background: '#f3ead5', borderRadius: '5px 5px 3px 3px', opacity: 0.85 }} />
                  ))}
                </div>
                <div style={{
                  position: 'absolute', top: 10, left: 10,
                  background: 'rgba(0,0,0,0.55)', color: '#fff',
                  padding: '4px 10px', borderRadius: 999, font: 'var(--t-label-sm)',
                  display: 'flex', alignItems: 'center', gap: 6,
                }}>
                  <span style={{ width: 7, height: 7, borderRadius: 999, background: 'var(--c-success)' }} />
                  Live · 30fps
                </div>
              </>
            )}
          </div>

          <div style={{ marginTop: 14 }}>
            <BinaButton
              variant={status === 'ready' ? 'primary' : 'ghost'}
              fullWidth
              onClick={status === 'ready' ? () => onConnected(picked) : undefined}
              icon={status === 'ready' ? <IconCamera size={18} /> : null}
            >
              {status === 'ready' ? 'Start scanning' : 'Pick a camera to continue'}
            </BinaButton>
          </div>
        </div>
      </div>

      <div style={{ padding: '14px 20px 0', font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', lineHeight: 1.5 }}>
        Tip: external dental cams give clearer results on molars. Phone camera works well for incisors and quick checks.
      </div>
    </div>
  );
}

function SourceCard({ icon, title, subtitle, right, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      background: 'var(--c-surface)', borderRadius: 16,
      border: active ? '2px solid var(--c-primary)' : '1px solid var(--c-line)',
      boxShadow: active ? 'var(--sh-2)' : 'var(--sh-1)',
      padding: 14, cursor: 'pointer',
      display: 'grid', gridTemplateColumns: '52px 1fr auto', gap: 14, alignItems: 'center',
      textAlign: 'left',
      transition: 'border-color 200ms, box-shadow 200ms',
    }}>
      <div style={{
        width: 52, height: 52, borderRadius: 14,
        background: active ? 'var(--c-primary-100)' : 'var(--c-surface-sunken)',
        color: active ? 'var(--c-primary)' : 'var(--c-ink-2)',
        display: 'grid', placeItems: 'center',
      }}>{icon}</div>
      <div style={{ minWidth: 0 }}>
        <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{title}</div>
        <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', marginTop: 2 }}>{subtitle}</div>
      </div>
      <div>{right}</div>
    </button>
  );
}

function Spinner({ size = 20 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      border: `2px solid var(--c-line)`,
      borderTopColor: 'var(--c-primary)',
      animation: 'binaSpin 700ms linear infinite',
    }}>
      <style>{`@keyframes binaSpin { to { transform: rotate(360deg) } }`}</style>
    </div>
  );
}

function CheckBadge() {
  return (
    <div style={{
      width: 28, height: 28, borderRadius: '50%',
      background: 'var(--c-success)', color: '#fff',
      display: 'grid', placeItems: 'center',
    }}>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
    </div>
  );
}

Object.assign(window, { ScanTargetScreen, CameraConnectionScreen });
