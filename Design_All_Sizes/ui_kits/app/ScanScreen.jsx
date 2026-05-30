// ScanScreen.jsx + DiagnosisScreen.jsx — capture flow and result.
// Source: lib/pages/other_pages/camera, photo_session, diagnosis_*

function ScanScreen({ onBack, onCapture, member }) {
  return (
    <div style={{
      position: 'absolute', inset: 0,
      background: '#0a0d18', color: '#fff',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* Camera viewfinder */}
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden' }}>
        {/* Top bar */}
        <div style={{
          position: 'absolute', top: 56, left: 16, right: 16, zIndex: 5,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <button onClick={onBack} style={{
            width: 40, height: 40, borderRadius: '50%',
            background: 'rgba(0,0,0,0.5)', border: '1px solid rgba(255,255,255,0.15)',
            color: '#fff', cursor: 'pointer', display: 'grid', placeItems: 'center',
            backdropFilter: 'blur(10px)',
          }}><IconChevronLeft size={22} /></button>
          <div style={{
            background: 'rgba(0,0,0,0.5)', padding: '6px 12px', borderRadius: 999,
            font: 'var(--t-label-md)', backdropFilter: 'blur(10px)',
            border: '1px solid rgba(255,255,255,0.15)',
          }}>Scanning {member?.name || 'Avi'}</div>
          <button style={{
            width: 40, height: 40, borderRadius: '50%',
            background: 'rgba(0,0,0,0.5)', border: '1px solid rgba(255,255,255,0.15)',
            color: '#fff', cursor: 'pointer', display: 'grid', placeItems: 'center',
            backdropFilter: 'blur(10px)',
          }}><IconSparkle size={20} /></button>
        </div>

        {/* Fake camera feed: stylized mouth + framing reticle */}
        <div style={{
          position: 'absolute', inset: 0,
          background: 'radial-gradient(ellipse at 50% 55%, #5b3133 0%, #2a1517 50%, #0a0d18 90%)',
        }}>
          {/* Teeth row mockup */}
          <div style={{
            position: 'absolute', left: '15%', right: '15%', top: '45%',
            display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 4,
          }}>
            {Array.from({length: 8}).map((_, i) => (
              <div key={i} style={{
                aspectRatio: '0.7', background: '#f3ead5',
                borderRadius: '6px 6px 4px 4px',
                boxShadow: 'inset 0 -4px 8px rgba(0,0,0,0.15)',
                opacity: 0.92,
              }} />
            ))}
          </div>
        </div>

        {/* Reticle */}
        <div style={{
          position: 'absolute', left: '12%', right: '12%', top: '36%', bottom: '32%',
          border: '2px solid rgba(255,255,255,0.6)', borderRadius: 20,
          boxShadow: '0 0 0 9999px rgba(0,0,0,0.35)',
        }}>
          {/* corner brackets */}
          {[['top:-2','left:-2','top','left'],['top:-2','right:-2','top','right'],['bottom:-2','left:-2','bottom','left'],['bottom:-2','right:-2','bottom','right']].map((_, i) => {
            const v = ['top','top','bottom','bottom'][i];
            const h = ['left','right','left','right'][i];
            return (
              <div key={i} style={{
                position: 'absolute', [v]: -3, [h]: -3, width: 22, height: 22,
                borderTop: v==='top' ? '3px solid var(--c-aqua)' : 0,
                borderBottom: v==='bottom' ? '3px solid var(--c-aqua)' : 0,
                borderLeft: h==='left' ? '3px solid var(--c-aqua)' : 0,
                borderRight: h==='right' ? '3px solid var(--c-aqua)' : 0,
                borderRadius: 4,
              }} />
            );
          })}
        </div>

        {/* Hint */}
        <div style={{
          position: 'absolute', left: 24, right: 24, top: '20%',
          textAlign: 'center', font: 'var(--t-body-md)',
          color: 'rgba(255,255,255,0.85)',
        }}>
          Centre the affected tooth in the frame
        </div>
      </div>

      {/* Capture bar */}
      <div style={{
        padding: '24px 24px 40px',
        display: 'grid', gridTemplateColumns: '60px 1fr 60px', alignItems: 'center',
        gap: 16, background: 'linear-gradient(to top, rgba(0,0,0,0.7), transparent)',
      }}>
        <button style={{
          width: 56, height: 56, borderRadius: 16, background: 'rgba(255,255,255,0.1)',
          border: '1px solid rgba(255,255,255,0.2)', cursor: 'pointer',
          color: '#fff', display: 'grid', placeItems: 'center',
        }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-5-5L5 21"/></svg>
        </button>
        <div style={{ display: 'grid', placeItems: 'center' }}>
          <button onClick={onCapture} aria-label="Capture" style={{
            width: 76, height: 76, borderRadius: '50%',
            border: '4px solid #fff', background: 'rgba(255,255,255,0.15)',
            cursor: 'pointer', position: 'relative',
          }}>
            <div style={{
              position: 'absolute', inset: 6, borderRadius: '50%',
              background: '#fff',
            }} />
          </button>
        </div>
        <button style={{
          width: 56, height: 56, borderRadius: 16, background: 'rgba(255,255,255,0.1)',
          border: '1px solid rgba(255,255,255,0.2)', cursor: 'pointer',
          color: '#fff', display: 'grid', placeItems: 'center',
        }}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M21 8v8a5 5 0 0 1-5 5H8a5 5 0 0 1-5-5V8a5 5 0 0 1 5-5h8a5 5 0 0 1 5 5Z"/><path d="m8 14 4-4 4 4"/><path d="M16 14V8"/></svg>
        </button>
      </div>
    </div>
  );
}

// ───────── Diagnosis result screen ─────────
function DiagnosisScreen({ onBack, onDone, member }) {
  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      {/* Header */}
      <div style={{ padding: '12px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={{
          width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
          display: 'grid', placeItems: 'center', color: 'var(--c-ink)',
        }}><IconChevronLeft size={22} /></button>
        <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>Scan result</div>
        <div style={{ width: 44 }} />
      </div>

      {/* Image with bbox */}
      <div style={{ padding: '16px 20px 0' }}>
        <div style={{
          position: 'relative', aspectRatio: '1.1',
          borderRadius: 20, overflow: 'hidden',
          background: 'radial-gradient(ellipse at 50% 55%, #5b3133 0%, #2a1517 80%)',
          boxShadow: 'var(--sh-3)',
        }}>
          {/* teeth */}
          <div style={{ position: 'absolute', left: '12%', right: '12%', top: '40%', display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 4 }}>
            {Array.from({length: 8}).map((_, i) => (
              <div key={i} style={{
                aspectRatio: '0.7', background: '#f3ead5',
                borderRadius: '6px 6px 4px 4px',
                boxShadow: 'inset 0 -4px 8px rgba(0,0,0,0.15)',
              }} />
            ))}
          </div>
          {/* bbox */}
          <div style={{
            position: 'absolute', left: '46%', top: '44%', width: '14%', height: '22%',
            border: '2.5px solid var(--c-dx-cavity)', borderRadius: 8,
            boxShadow: '0 0 0 9999px rgba(0,0,0,0.35)',
          }}>
            <div style={{
              position: 'absolute', top: -28, left: -2,
              background: 'var(--c-dx-cavity)', color: '#fff',
              padding: '3px 8px', borderRadius: 6,
              font: 'var(--t-label-sm)', whiteSpace: 'nowrap',
            }}>Cavity · 91%</div>
          </div>
        </div>
      </div>

      {/* Diagnosis card */}
      <div style={{ padding: '16px 20px 0' }}>
        <div style={{
          background: 'var(--c-surface)', borderRadius: 20,
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)',
          padding: 18,
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <DxChip kind="cavity" />
              <div style={{ font: 'var(--t-headline-md)', color: 'var(--c-ink)', marginTop: 10, letterSpacing: '-0.005em' }}>
                We spotted a cavity.
              </div>
              <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', marginTop: 4 }}>
                {member?.name || 'Maya'} · Lower right molar
              </div>
            </div>
            <div style={{
              width: 56, height: 56, borderRadius: 14,
              background: 'var(--c-error-100)', color: 'var(--c-dx-cavity)',
              display: 'grid', placeItems: 'center',
            }}><IconTooth size={32} /></div>
          </div>

          <div style={{
            display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8, marginTop: 16,
            padding: 12, background: 'var(--c-surface-alt)', borderRadius: 12,
          }}>
            <Metric label="Confidence" value="91%" />
            <Metric label="Severity" value="Moderate" />
            <Metric label="Region" value="LR-6" />
          </div>

          <div style={{ marginTop: 16, font: 'var(--t-body-md)', color: 'var(--c-ink-2)', lineHeight: 1.55 }}>
            Book a dentist visit in the next 2 weeks. Until then, brush gently around the area and avoid sugary drinks.
          </div>

          <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
            <BinaButton variant="primary" fullWidth icon={<IconCalendar size={18} />}>Book dentist</BinaButton>
            <BinaButton variant="ghost" fullWidth onClick={onDone}>Save & exit</BinaButton>
          </div>
        </div>
      </div>

      {/* Education tip */}
      <div style={{ padding: '16px 20px 0' }}>
        <div style={{
          background: 'var(--g-hero-soft)', borderRadius: 16, padding: 14,
          display: 'flex', gap: 12, alignItems: 'flex-start',
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: 10,
            background: 'var(--c-surface)', color: 'var(--c-primary)',
            display: 'grid', placeItems: 'center', flexShrink: 0,
            boxShadow: 'var(--sh-1)',
          }}><IconSparkle size={20} /></div>
          <div>
            <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>What is a cavity?</div>
            <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', marginTop: 2 }}>
              A small hole in the enamel caused by acid + bacteria. Caught early, your dentist can usually fix it in one visit.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function Metric({ label, value }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
      <div style={{ font: 'var(--t-label-sm)', color: 'var(--c-ink-3)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>{label}</div>
      <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{value}</div>
    </div>
  );
}

Object.assign(window, { ScanScreen, DiagnosisScreen });
