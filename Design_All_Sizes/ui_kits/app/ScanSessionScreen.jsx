// ScanSessionScreen.jsx — full capture session.
// Source: lib/pages/other_pages/photo_session/photo_session_widget.dart
//
// Flow: scan target is preset. User captures images via "Camera" button
// (which opens CameraConnection if not yet connected) or "Gallery".
// Each capture runs YOLO inference + async Gemma interpretation.
// Tapping an image opens ImageDetailSheet.

function ScanSessionScreen({ member, onBack, onOpenCamera, onFinish, hintMode }) {
  // Seed with two pre-existing scanned photos so the empty state isn't always shown.
  const seedImages = [
    {
      id: 'img-1',
      capturedAt: '14:02',
      detections: [
        { className: 'tooth_8',  confidence: 0.94, bbox: { x: 0.28, y: 0.35, w: 0.10, h: 0.20 } },
        { className: 'tooth_9',  confidence: 0.91, bbox: { x: 0.40, y: 0.34, w: 0.10, h: 0.21 } },
        { className: 'tooth_10', confidence: 0.89, bbox: { x: 0.52, y: 0.36, w: 0.10, h: 0.20 } },
        { className: 'plaque',   confidence: 0.78, bbox: { x: 0.30, y: 0.50, w: 0.08, h: 0.06 } },
      ],
      interpretation: "Three healthy upper incisors visible. Mild plaque accumulation along the gum line of tooth 8 — likely cosmetic, but a focused brushing pass should clear it.",
    },
    {
      id: 'img-2',
      capturedAt: '14:05',
      detections: [
        { className: 'tooth_3', confidence: 0.92, bbox: { x: 0.22, y: 0.30, w: 0.12, h: 0.25 } },
        { className: 'cavity',  confidence: 0.91, bbox: { x: 0.46, y: 0.42, w: 0.10, h: 0.14 } },
        { className: 'tooth_4', confidence: 0.88, bbox: { x: 0.40, y: 0.32, w: 0.12, h: 0.27 } },
      ],
      interpretation: "Cavity detected on tooth 4 (lower-right molar) with 91% confidence. Surface lesion, moderate severity — bookable, not urgent. Recommend in-person dentist visit within 2 weeks.",
    },
  ];

  const [images, setImages] = React.useState(seedImages);
  const [processing, setProcessing] = React.useState(false);
  const [openImage, setOpenImage] = React.useState(null);
  const [cameraConnected, setCameraConnected] = React.useState(false);

  const capture = () => {
    if (!cameraConnected) { onOpenCamera(() => setCameraConnected(true)); return; }
    setProcessing(true);
    setTimeout(() => {
      const id = `img-${images.length + 1}`;
      setImages(imgs => [...imgs, {
        id,
        capturedAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        detections: [
          { className: 'tooth_14', confidence: 0.90, bbox: { x: 0.30, y: 0.32, w: 0.12, h: 0.28 } },
          { className: 'tooth_15', confidence: 0.87, bbox: { x: 0.44, y: 0.33, w: 0.12, h: 0.27 } },
        ],
        interpretation: "Two clean lower molars visible. No issues detected.",
      }]);
      setProcessing(false);
    }, 900);
  };

  const issuesCount = images.reduce((acc, img) =>
    acc + img.detections.filter(d => !d.className.startsWith('tooth_')).length, 0);
  const teethCount = images.reduce((acc, img) =>
    acc + img.detections.filter(d => d.className.startsWith('tooth_')).length, 0);

  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      {/* Header */}
      <div style={{ padding: '12px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={iconBtnStyle}><IconChevronLeft size={22} /></button>
        <div style={{ textAlign: 'center' }}>
          <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>Scan session</div>
          <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)' }}>{member?.name || 'Avi'}</div>
        </div>
        <Hint show={hintMode} text="Captured photos collect here. Tap one to see details.">
          <div style={{
            background: 'var(--c-primary-100)', color: 'var(--c-primary-700)',
            padding: '6px 12px', borderRadius: 999, font: 'var(--t-label-md)',
            fontWeight: 600,
          }}>
            {images.length} {images.length === 1 ? 'photo' : 'photos'}
          </div>
        </Hint>
      </div>

      {/* Status summary */}
      <div style={{ padding: '16px 20px 0' }}>
        <div style={{
          background: 'var(--c-surface)', borderRadius: 16,
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)',
          padding: 12, display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 4,
        }}>
          <SummaryStat label="Photos" value={images.length} tone="primary" />
          <Divider />
          <SummaryStat label="Teeth" value={teethCount} tone="ink" />
          <Divider />
          <SummaryStat label="Issues" value={issuesCount} tone={issuesCount > 0 ? 'cavity' : 'good'} />
        </div>
      </div>

      {/* Camera connection status banner */}
      <div style={{ padding: '12px 20px 0' }}>
        <Hint show={hintMode} text="Connect to a camera before capturing. The Bina dental cam gives the clearest results.">
          <button onClick={() => onOpenCamera((ok) => setCameraConnected(ok))} style={{
            width: '100%',
            background: cameraConnected ? 'var(--c-success-100)' : 'var(--c-surface)',
            border: cameraConnected ? '1px solid rgba(26,169,113,0.3)' : '1px dashed var(--c-line-strong)',
            borderRadius: 14, padding: '12px 14px', cursor: 'pointer',
            display: 'grid', gridTemplateColumns: '36px 1fr auto', gap: 12, alignItems: 'center',
            textAlign: 'left',
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10,
              background: cameraConnected ? 'var(--c-success)' : 'var(--c-surface-sunken)',
              color: cameraConnected ? '#fff' : 'var(--c-ink-2)',
              display: 'grid', placeItems: 'center',
            }}><IconCamera size={20} /></div>
            <div>
              <div style={{ font: 'var(--t-title-sm)', color: 'var(--c-ink)' }}>
                {cameraConnected ? 'Bina dental cam · connected' : 'Connect a camera'}
              </div>
              <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)' }}>
                {cameraConnected ? 'Live · 30fps · tap to switch source' : 'Phone camera or Bina dental cam'}
              </div>
            </div>
            <IconChevronRight size={18} />
          </button>
        </Hint>
      </div>

      {/* Photo grid or empty state */}
      <div style={{ padding: '20px 20px 0' }}>
        <SectionHeader title="Captured photos" action={images.length > 0 ? 'Sort' : undefined} />
        {images.length === 0 ? (
          <EmptyState />
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10 }}>
            {images.map(img => <PhotoTile key={img.id} img={img} onClick={() => setOpenImage(img)} />)}
            {processing && <PhotoTilePlaceholder />}
          </div>
        )}
      </div>

      {/* Processing strip */}
      {processing && (
        <div style={{ padding: '16px 20px 0' }}>
          <div style={{
            background: 'var(--c-primary-100)', color: 'var(--c-primary-700)',
            borderRadius: 12, padding: '10px 14px',
            display: 'flex', alignItems: 'center', gap: 10,
            font: 'var(--t-body-md)',
          }}>
            <Spinner size={16} />
            Running diagnosis · Gemma is interpreting…
          </div>
        </div>
      )}

      {/* Capture controls */}
      <div style={{ padding: '24px 20px 0' }}>
        <div style={{ display: 'flex', gap: 10 }}>
          <Hint show={hintMode} text="Tap to capture. If no camera is connected, you'll be asked to connect first.">
            <BinaButton variant="primary" fullWidth onClick={capture} icon={<IconCamera size={18} />}>
              {cameraConnected ? 'Capture' : 'Camera'}
            </BinaButton>
          </Hint>
          <BinaButton variant="ghost" fullWidth icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-5-5L5 21"/></svg>}>
            Gallery
          </BinaButton>
        </div>
        <div style={{ marginTop: 10 }}>
          <Hint show={hintMode} text="Wrap up to file this session into the member's history. Disabled until you have at least one photo.">
            <BinaButton variant={images.length > 0 ? 'coral' : 'ghost'} fullWidth
              onClick={() => images.length > 0 && onFinish({ member, images, issuesCount })}
              icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>}
            >
              Finish session
            </BinaButton>
          </Hint>
        </div>
      </div>

      {/* Image detail sheet */}
      {openImage && (
        <ImageDetailSheet img={openImage} member={member} onClose={() => setOpenImage(null)} />
      )}
    </div>
  );
}

// ───────── helpers ─────────
const iconBtnStyle = {
  width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
  border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
  display: 'grid', placeItems: 'center', color: 'var(--c-ink)', padding: 0,
};

function SummaryStat({ label, value, tone }) {
  const colors = {
    primary: 'var(--c-primary)',
    ink: 'var(--c-ink)',
    good: 'var(--c-dx-good)',
    cavity: 'var(--c-dx-cavity)',
  };
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, padding: '4px 0' }}>
      <div style={{ font: 'var(--t-headline-md)', color: colors[tone], letterSpacing: '-0.01em' }}>{value}</div>
      <div style={{ font: 'var(--t-label-sm)', color: 'var(--c-ink-3)', textTransform: 'uppercase', letterSpacing: '0.08em' }}>{label}</div>
    </div>
  );
}

function Divider() {
  return <div style={{ width: 1, background: 'var(--c-line)', margin: '8px 0' }} />;
}

function EmptyState() {
  return (
    <div style={{
      background: 'var(--c-surface)',
      border: '1px dashed var(--c-line-strong)',
      borderRadius: 16, padding: '36px 20px',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
    }}>
      <div style={{
        width: 56, height: 56, borderRadius: 16,
        background: 'var(--c-primary-100)', color: 'var(--c-primary)',
        display: 'grid', placeItems: 'center',
      }}><IconCamera size={28} /></div>
      <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>No photos yet</div>
      <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', textAlign: 'center', maxWidth: 240 }}>
        Capture dental images of the lower and upper rows. We'll diagnose each one and you can review before saving.
      </div>
    </div>
  );
}

function PhotoTile({ img, onClick }) {
  const hasCavity = img.detections.some(d => d.className === 'cavity');
  const hasPlaque = img.detections.some(d => d.className === 'plaque');
  const tag = hasCavity ? 'cavity' : hasPlaque ? 'plaque' : 'good';
  const tagColors = {
    good:   'var(--c-dx-good)',
    plaque: 'var(--c-dx-plaque)',
    cavity: 'var(--c-dx-cavity)',
  };
  return (
    <button onClick={onClick} style={{
      aspectRatio: 1, borderRadius: 12, overflow: 'hidden',
      border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)',
      padding: 0, cursor: 'pointer', position: 'relative',
      background: 'radial-gradient(ellipse at 50% 55%, #5b3133, #2a1517)',
    }}>
      <FakeTeethRow />
      {/* draw bboxes for non-tooth detections */}
      {img.detections.filter(d => !d.className.startsWith('tooth_')).map((d, i) => (
        <div key={i} style={{
          position: 'absolute',
          left: `${d.bbox.x * 100}%`, top: `${d.bbox.y * 100}%`,
          width: `${d.bbox.w * 100}%`, height: `${d.bbox.h * 100}%`,
          border: `1.5px solid ${d.className === 'cavity' ? 'var(--c-dx-cavity)' : 'var(--c-dx-plaque)'}`,
          borderRadius: 3,
        }} />
      ))}
      <div style={{
        position: 'absolute', top: 6, left: 6,
        background: tagColors[tag], color: '#fff',
        padding: '2px 7px', borderRadius: 999, font: '600 9px/1.2 Inter',
      }}>{tag === 'good' ? 'CLEAN' : tag.toUpperCase()}</div>
      <div style={{
        position: 'absolute', bottom: 4, right: 4,
        background: 'rgba(0,0,0,0.55)', color: '#fff',
        padding: '2px 7px', borderRadius: 4, font: '500 10px/1.2 Inter',
      }}>{img.capturedAt}</div>
    </button>
  );
}

function PhotoTilePlaceholder() {
  return (
    <div style={{
      aspectRatio: 1, borderRadius: 12,
      border: '1px solid var(--c-line)', background: 'var(--c-surface)',
      display: 'grid', placeItems: 'center',
    }}>
      <Spinner size={22} />
    </div>
  );
}

function FakeTeethRow() {
  return (
    <div style={{ position: 'absolute', left: '10%', right: '10%', top: '40%', display: 'grid', gridTemplateColumns: 'repeat(8, 1fr)', gap: 2 }}>
      {Array.from({length: 8}).map((_, i) => (
        <div key={i} style={{
          aspectRatio: '0.7', background: '#f3ead5',
          borderRadius: '4px 4px 2px 2px',
          boxShadow: 'inset 0 -2px 4px rgba(0,0,0,0.18)',
        }} />
      ))}
    </div>
  );
}

// Hint mode tooltip wrapper — renders a small ? badge that, on hover/tap, shows the explainer.
function Hint({ show, text, children }) {
  const [open, setOpen] = React.useState(false);
  if (!show) return children;
  return (
    <div style={{ position: 'relative', display: 'block' }}>
      {children}
      <button
        onClick={(e) => { e.stopPropagation(); setOpen(!open); }}
        style={{
          position: 'absolute', top: -8, right: -8, zIndex: 10,
          width: 22, height: 22, borderRadius: '50%',
          background: 'var(--c-coral)', color: '#fff', border: '2px solid var(--c-surface)',
          font: '700 12px/1 Inter', cursor: 'pointer', padding: 0,
          boxShadow: 'var(--sh-1)',
        }}
        aria-label="Show hint"
      >?</button>
      {open && (
        <div style={{
          position: 'absolute', top: 22, right: -4, zIndex: 30,
          background: 'var(--c-ink)', color: '#fff',
          borderRadius: 12, padding: '10px 12px',
          width: 220, font: 'var(--t-body-sm)', lineHeight: 1.4,
          boxShadow: 'var(--sh-4)',
        }}>{text}</div>
      )}
    </div>
  );
}

Object.assign(window, { ScanSessionScreen, Hint, FakeTeethRow });
