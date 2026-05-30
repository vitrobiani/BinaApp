// HomeScreen.jsx — refined Bina dashboard.
// Replicates: Hello-greeting + weekly hero progress + family ribbon + recent updates.
// Source: lib/pages/nav_pages/main_home/main_home_widget.dart

function HomeScreen({ family, go, openMember, onAddMember }) {
  const checked = family.filter(f => f.lastChecked).length;
  const pct = Math.round((checked / family.length) * 100);
  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)' }}>
      {/* greeting */}
      <div style={{ padding: '12px 20px 0' }}>
        <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.1em' }}>Tuesday · May 14</div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginTop: 4 }}>
          <h1 style={{
            font: 'var(--t-display-sm)', color: 'var(--c-ink)', margin: 0,
            letterSpacing: '-0.01em',
          }}>Hello Sarah</h1>
          <button style={{
            width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
            border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
            display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)', position: 'relative',
          }}>
            <IconBell size={20} />
            <span style={{
              position: 'absolute', top: 8, right: 9, width: 8, height: 8,
              background: 'var(--c-coral)', borderRadius: 999, border: '2px solid #fff',
            }} />
          </button>
        </div>
      </div>

      {/* Hero progress */}
      <div style={{ padding: '20px 20px 0' }}>
        <div style={{
          background: 'var(--g-hero)',
          borderRadius: 24,
          color: '#fff',
          padding: 20,
          boxShadow: 'var(--sh-hero)',
          display: 'grid',
          gridTemplateColumns: '1fr 132px',
          gap: 12,
          alignItems: 'center',
          position: 'relative',
          overflow: 'hidden',
        }}>
          <div style={{
            position: 'absolute', top: '-60%', right: '-15%',
            width: 240, height: 240, borderRadius: '50%',
            background: 'rgba(255,255,255,0.12)', pointerEvents: 'none',
          }} />
          <div style={{ position: 'relative', zIndex: 1 }}>
            <div style={{ font: 'var(--t-overline)', letterSpacing: '0.12em', textTransform: 'uppercase', opacity: 0.78 }}>This week</div>
            <div style={{ font: 'var(--t-display-sm)', letterSpacing: '-0.01em', marginTop: 2 }}>{pct}% checked</div>
            <div style={{ font: 'var(--t-body-md)', opacity: 0.9, marginTop: 4 }}>
              {family.length - checked} {family.length - checked === 1 ? 'member' : 'members'} undiagnosed
            </div>
            <button onClick={() => go('family')} style={{
              alignSelf: 'flex-start', marginTop: 14,
              background: 'rgba(255,255,255,0.96)', color: 'var(--c-primary-700)',
              border: 0, padding: '9px 16px', borderRadius: 999,
              font: 'var(--t-label-lg)', cursor: 'pointer',
              display: 'inline-flex', alignItems: 'center', gap: 6,
            }}>View family <IconArrowRight size={16} /></button>
          </div>
          <ProgressRings pct={pct} />
        </div>
      </div>

      {/* Family ribbon */}
      <div style={{ padding: '24px 0 0' }}>
        <div style={{ padding: '0 20px' }}>
          <SectionHeader title="Your family" action="See all" />
        </div>
        <div style={{
          display: 'flex', gap: 12,
          overflowX: 'auto', padding: '0 20px 4px',
          scrollbarWidth: 'none',
        }}>
          {family.map(m => <MiniMemberCard key={m.id} member={m} onClick={() => openMember(m)} />)}
          <button onClick={onAddMember} style={{
            flex: '0 0 130px', borderRadius: 18,
            border: '2px dashed var(--c-line-strong)',
            background: 'transparent',
            color: 'var(--c-primary)',
            display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
            gap: 8, padding: 14, cursor: 'pointer',
            font: 'var(--t-label-md)',
          }}>
            <IconPlus size={22} />
            Add member
          </button>
        </div>
      </div>

      {/* Recent updates */}
      <div style={{ padding: '24px 20px 0' }}>
        <SectionHeader title="Recent scans" action="History" />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <ScanRow name="Maya" region="Lower right molar" kind="cavity" when="9 May · 19:02" tone="coral" />
          <ScanRow name="Avi" region="Upper left incisor" kind="good" when="12 May · 11:24" tone="blue" />
          <ScanRow name="Avi" region="Lower front" kind="plaque" when="6 May · 08:11" tone="blue" />
        </div>
      </div>

      {/* Tip card */}
      <div style={{ padding: '24px 20px 0' }}>
        <div style={{
          background: 'var(--g-hero-soft)',
          borderRadius: 18,
          padding: 16,
          display: 'flex', gap: 12, alignItems: 'flex-start',
        }}>
          <div style={{
            width: 40, height: 40, borderRadius: 12,
            background: 'var(--c-surface)', color: 'var(--c-primary)',
            display: 'grid', placeItems: 'center', flexShrink: 0,
            boxShadow: 'var(--sh-1)',
          }}><IconSparkle size={22} /></div>
          <div style={{ minWidth: 0 }}>
            <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>Bina tip</div>
            <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', marginTop: 2 }}>
              Plaque on Maya's lower molars showed up twice this month. Try a 2-minute brush + floss after dinner.
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function ProgressRings({ pct }) {
  const r1 = 56, r2 = 38;
  const c1 = 2 * Math.PI * r1, c2 = 2 * Math.PI * r2;
  const dash1 = c1 * (1 - pct / 100);
  const dash2 = c2 * (1 - (pct - 10) / 100);
  return (
    <div style={{ position: 'relative', width: 132, height: 132, justifySelf: 'end', zIndex: 1 }}>
      <svg width="132" height="132" viewBox="0 0 132 132" style={{ transform: 'rotate(-90deg)' }}>
        <circle cx="66" cy="66" r={r1} stroke="rgba(255,255,255,0.22)" strokeWidth="11" fill="none"/>
        <circle cx="66" cy="66" r={r1} stroke="rgba(255,255,255,0.95)" strokeWidth="11" fill="none" strokeLinecap="round" strokeDasharray={c1} strokeDashoffset={dash1}/>
        <circle cx="66" cy="66" r={r2} stroke="rgba(255,255,255,0.22)" strokeWidth="11" fill="none"/>
        <circle cx="66" cy="66" r={r2} stroke="rgba(255,255,255,0.55)" strokeWidth="11" fill="none" strokeLinecap="round" strokeDasharray={c2} strokeDashoffset={dash2}/>
      </svg>
      <div style={{
        position: 'absolute', inset: 0, display: 'grid', placeItems: 'center',
        font: 'var(--t-headline-lg)', color: '#fff', letterSpacing: '-0.01em', whiteSpace: 'nowrap',
      }}>{`${pct}%`}</div>
    </div>
  );
}

function MiniMemberCard({ member, onClick }) {
  const dxKind = member.lastResult || 'due';
  return (
    <button onClick={onClick} style={{
      flex: '0 0 130px',
      background: 'var(--c-surface)',
      borderRadius: 18,
      border: '1px solid var(--c-line)',
      boxShadow: 'var(--sh-1)',
      padding: 14,
      display: 'flex', flexDirection: 'column', gap: 10, alignItems: 'flex-start',
      cursor: 'pointer', textAlign: 'left',
    }}>
      <Avatar name={member.name} size={40} tone={member.tone} />
      <div style={{ minWidth: 0, width: '100%' }}>
        <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{member.name}</div>
        <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 1 }}>
          {member.lastChecked || 'never checked'}
        </div>
      </div>
      <DxChip kind={dxKind} size="sm" />
    </button>
  );
}

function ScanRow({ name, region, kind, when, tone }) {
  return (
    <div style={{
      display: 'grid', gridTemplateColumns: '44px 1fr auto', gap: 12,
      alignItems: 'center',
      background: 'var(--c-surface)', borderRadius: 14,
      border: '1px solid var(--c-line)', padding: 12,
    }}>
      <Avatar name={name} size={40} tone={tone} />
      <div style={{ minWidth: 0 }}>
        <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{name} · <span style={{ color: 'var(--c-ink-2)', fontWeight: 400 }}>{region}</span></div>
        <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 1 }}>{when}</div>
      </div>
      <DxChip kind={kind} size="sm" />
    </div>
  );
}

Object.assign(window, { HomeScreen, ProgressRings, MiniMemberCard, ScanRow });
