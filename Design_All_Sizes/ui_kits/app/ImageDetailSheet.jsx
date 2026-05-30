// ImageDetailSheet.jsx — bottom sheet that opens when a captured photo is tapped.
// Source: lib/components/photo_session/image_detail_sheet/image_detail_sheet_widget.dart
//
// Shows: photo with toggleable original/diagnosed view, bounding-box overlays,
// flat detections list (chips), and Gemma's LLM interpretation text.

function ImageDetailSheet({ img, member, onClose }) {
  const [view, setView] = React.useState('diagnosed'); // 'diagnosed' | 'original'

  const issues = img.detections.filter(d => !d.className.startsWith('tooth_'));
  const teeth  = img.detections.filter(d => d.className.startsWith('tooth_'));

  const overallTone = issues.some(d => d.className === 'cavity') ? 'cavity'
                    : issues.some(d => d.className === 'plaque') ? 'plaque'
                    : 'good';

  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 40,
      background: 'rgba(12, 21, 48, 0.45)',
      display: 'flex', flexDirection: 'column', justifyContent: 'flex-end',
      animation: 'binaScrimIn 200ms ease-out',
    }}>
      <style>{`
        @keyframes binaScrimIn { from { opacity: 0 } to { opacity: 1 } }
        @keyframes binaSheetSlideUp { from { transform: translateY(40px); opacity: 0.4 } to { transform: translateY(0); opacity: 1 } }
      `}</style>

      {/* tap-out */}
      <div onClick={onClose} style={{ flex: 1 }} />

      <div style={{
        background: 'var(--c-surface)',
        borderTopLeftRadius: 28, borderTopRightRadius: 28,
        boxShadow: 'var(--sh-4)',
        maxHeight: '85%',
        display: 'flex', flexDirection: 'column',
        animation: 'binaSheetSlideUp 280ms cubic-bezier(.2,.7,.2,1)',
      }}>
        {/* drag handle */}
        <div style={{ display: 'grid', placeItems: 'center', padding: '10px 0 6px' }}>
          <div style={{ width: 44, height: 5, borderRadius: 999, background: 'var(--c-line-strong)' }} />
        </div>

        {/* Scrollable content */}
        <div style={{ overflowY: 'auto', flex: 1, padding: '0 20px 24px' }}>
          {/* Header */}
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
            <div>
              <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase' }}>
                {member?.name || 'Avi'} · {img.capturedAt}
              </div>
              <div style={{ font: 'var(--t-headline-sm)', color: 'var(--c-ink)', marginTop: 4, letterSpacing: '-0.005em' }}>
                {overallTone === 'cavity' ? 'Cavity detected' : overallTone === 'plaque' ? 'Mild plaque' : 'Looks clean'}
              </div>
            </div>
            <button onClick={onClose} style={{
              width: 36, height: 36, borderRadius: '50%',
              background: 'var(--c-surface-sunken)', border: 0,
              cursor: 'pointer', display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)',
            }} aria-label="Close">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6 6 18M6 6l12 12"/></svg>
            </button>
          </div>

          {/* Photo with toggleable view */}
          <div style={{ marginTop: 14, position: 'relative' }}>
            <div style={{
              aspectRatio: '1', borderRadius: 18, overflow: 'hidden',
              background: 'radial-gradient(ellipse at 50% 55%, #5b3133 0%, #2a1517 80%)',
              boxShadow: 'var(--sh-2)', position: 'relative',
            }}>
              <FakeTeethRow />
              {view === 'diagnosed' && img.detections.map((d, i) => (
                <DetectionOverlay key={i} d={d} />
              ))}
            </div>
            {/* Toggle */}
            <div style={{
              position: 'absolute', top: 10, right: 10,
              background: 'rgba(0,0,0,0.55)', borderRadius: 999, padding: 3, display: 'flex',
            }}>
              {[['diagnosed','Diagnosed'],['original','Original']].map(([id, label]) => (
                <button key={id} onClick={() => setView(id)} style={{
                  background: view === id ? '#fff' : 'transparent',
                  color: view === id ? 'var(--c-ink)' : '#fff',
                  border: 0, padding: '5px 10px', borderRadius: 999,
                  font: '500 11px/1.2 Inter', cursor: 'pointer',
                }}>{label}</button>
              ))}
            </div>
          </div>

          {/* Gemma interpretation */}
          <div style={{
            marginTop: 16,
            background: 'var(--g-hero-soft)', borderRadius: 16,
            padding: 14, display: 'flex', gap: 12, alignItems: 'flex-start',
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10,
              background: 'var(--c-surface)', color: 'var(--c-primary)',
              display: 'grid', placeItems: 'center', flexShrink: 0,
              boxShadow: 'var(--sh-1)',
            }}><IconSparkle size={20} /></div>
            <div style={{ minWidth: 0 }}>
              <div style={{ font: 'var(--t-title-sm)', color: 'var(--c-ink)' }}>Gemma's overview</div>
              <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', marginTop: 4, lineHeight: 1.5 }}>
                {img.interpretation}
              </div>
            </div>
          </div>

          {/* Detections list */}
          <div style={{ marginTop: 20 }}>
            <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px' }}>
              Anomalies · {issues.length}
            </div>
            <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 8 }}>
              {issues.length === 0 && (
                <div style={{
                  padding: 12, background: 'var(--c-success-100)', color: '#0e6b48',
                  borderRadius: 12, font: 'var(--t-body-md)',
                  display: 'flex', alignItems: 'center', gap: 8,
                }}>
                  <span style={{ width: 8, height: 8, borderRadius: 999, background: 'var(--c-dx-good)' }} />
                  No issues detected in this photo.
                </div>
              )}
              {issues.map((d, i) => <DetectionRow key={i} d={d} />)}
            </div>
          </div>

          <div style={{ marginTop: 20 }}>
            <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px' }}>
              Teeth identified · {teeth.length}
            </div>
            <div style={{ marginTop: 8, display: 'flex', gap: 6, flexWrap: 'wrap' }}>
              {teeth.map((d, i) => (
                <span key={i} style={{
                  padding: '5px 10px', borderRadius: 999,
                  background: 'var(--c-surface-sunken)', color: 'var(--c-ink-2)',
                  font: 'var(--t-label-sm)',
                  display: 'inline-flex', alignItems: 'center', gap: 5,
                }}>
                  <span style={{ width: 5, height: 5, borderRadius: 999, background: 'var(--c-ink-3)' }} />
                  {d.className.replace('tooth_', 'Tooth ')} · {Math.round(d.confidence * 100)}%
                </span>
              ))}
            </div>
          </div>

          {/* Actions */}
          <div style={{ display: 'flex', gap: 10, marginTop: 24 }}>
            <BinaButton variant="ghost" fullWidth icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></svg>}>
              Share
            </BinaButton>
            <BinaButton variant="ghost" fullWidth icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>}>
              Delete
            </BinaButton>
          </div>
        </div>
      </div>
    </div>
  );
}

function DetectionOverlay({ d }) {
  const isTooth = d.className.startsWith('tooth_');
  const stroke = isTooth ? 'rgba(110, 198, 255, 0.6)' :
                 d.className === 'cavity' ? 'var(--c-dx-cavity)' :
                 d.className === 'plaque' ? 'var(--c-dx-plaque)' : 'var(--c-dx-mixed)';
  return (
    <div style={{
      position: 'absolute',
      left: `${d.bbox.x * 100}%`, top: `${d.bbox.y * 100}%`,
      width: `${d.bbox.w * 100}%`, height: `${d.bbox.h * 100}%`,
      border: `2px solid ${stroke}`,
      borderRadius: isTooth ? 4 : 6,
      boxShadow: isTooth ? 'none' : '0 0 0 2px rgba(0,0,0,0.3)',
    }}>
      {!isTooth && (
        <div style={{
          position: 'absolute', top: -22, left: -2,
          background: stroke, color: '#fff',
          padding: '2px 7px', borderRadius: 4,
          font: '600 10px/1.2 Inter', whiteSpace: 'nowrap',
        }}>{d.className} · {Math.round(d.confidence * 100)}%</div>
      )}
    </div>
  );
}

function DetectionRow({ d }) {
  const kind = d.className === 'cavity' ? 'cavity'
            : d.className === 'plaque' ? 'plaque'
            : 'mixed';
  const tones = {
    cavity: { bg: 'var(--c-error-100)', fg: '#8a2727', dot: 'var(--c-dx-cavity)' },
    plaque: { bg: '#fcf0d8', fg: '#7a5a17', dot: 'var(--c-dx-plaque)' },
    mixed:  { bg: '#f8e1ee', fg: '#6a2150', dot: 'var(--c-dx-mixed)' },
  };
  const t = tones[kind];
  const labels = { cavity: 'Cavity', plaque: 'Plaque' };
  return (
    <div style={{
      display: 'grid', gridTemplateColumns: '36px 1fr auto', gap: 12, alignItems: 'center',
      padding: 12, background: 'var(--c-surface)',
      border: '1px solid var(--c-line)', borderRadius: 12,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 10,
        background: t.bg, color: t.fg,
        display: 'grid', placeItems: 'center',
      }}>
        <span style={{ width: 12, height: 12, borderRadius: 999, background: t.dot }} />
      </div>
      <div>
        <div style={{ font: 'var(--t-title-sm)', color: 'var(--c-ink)' }}>{labels[kind] || d.className}</div>
        <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)' }}>
          Region {Math.round(d.bbox.x * 100)},{Math.round(d.bbox.y * 100)} · {Math.round(d.confidence * 100)}% confidence
        </div>
      </div>
      <span style={{
        padding: '4px 10px', borderRadius: 999, background: t.bg, color: t.fg,
        font: 'var(--t-label-sm)',
      }}>{Math.round(d.confidence * 100)}%</span>
    </div>
  );
}

Object.assign(window, { ImageDetailSheet });
