// FamilyScreen.jsx — list of family members + member detail with history.
// Source: lib/pages/family/family/family_widget.dart + family_member_widget.dart

function FamilyScreen({ family, openMember, onAddMember }) {
  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)' }}>
      {/* Header */}
      <div style={{ padding: '12px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1 style={{ font: 'var(--t-display-sm)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.01em' }}>Family</h1>
        <button onClick={onAddMember} style={{
          width: 44, height: 44, borderRadius: 999, background: 'var(--c-primary)',
          color: '#fff', border: 0, cursor: 'pointer', display: 'grid', placeItems: 'center',
          boxShadow: 'var(--sh-2)',
        }} aria-label="Add member"><IconPlus size={22} /></button>
      </div>

      {/* Filter chips */}
      <div style={{ padding: '12px 20px 0', display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none' }}>
        {['All 4', 'Due now 1', 'Adults', 'Kids'].map((t, i) => (
          <span key={t} style={{
            padding: '8px 14px', borderRadius: 999,
            background: i === 0 ? 'var(--c-primary)' : 'var(--c-surface)',
            color: i === 0 ? '#fff' : 'var(--c-ink-2)',
            border: i === 0 ? 'none' : '1px solid var(--c-line)',
            font: 'var(--t-label-md)', whiteSpace: 'nowrap',
          }}>{t}</span>
        ))}
      </div>

      {/* List */}
      <div style={{ padding: '20px 20px 0', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {family.map(m => <FamilyRow key={m.id} member={m} onClick={() => openMember(m)} />)}
      </div>
    </div>
  );
}

function FamilyRow({ member, onClick }) {
  const dxKind = member.lastResult || 'due';
  const stat = member.scanCount || 0;
  return (
    <button onClick={onClick} style={{
      background: 'var(--c-surface)', borderRadius: 18,
      border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)',
      padding: 14, cursor: 'pointer',
      display: 'grid', gridTemplateColumns: '52px 1fr auto', gap: 14, alignItems: 'center',
      textAlign: 'left',
    }}>
      <Avatar name={member.name} size={52} tone={member.tone} />
      <div style={{ minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ font: 'var(--t-title-lg)', color: 'var(--c-ink)', whiteSpace: 'nowrap' }}>{member.name}</div>
          <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', whiteSpace: 'nowrap', flexShrink: 0 }}>· {member.age} yrs</div>
        </div>
        <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', marginTop: 2 }}>
          {member.lastChecked ? `Last checked ${member.lastChecked} · ${stat} scans` : 'Never checked'}
        </div>
        <div style={{ marginTop: 8 }}><DxChip kind={dxKind} size="sm" /></div>
      </div>
      <IconChevronRight size={20} />
    </button>
  );
}

// ───────── Member detail (slides in on member tap) ─────────
function MemberDetailScreen({ member, onBack, onScan }) {
  const dxKind = member.lastResult || 'due';
  const scans = member.scans || [
    { id: 1, date: '12 May · 11:24', region: 'Upper left incisor', kind: 'good' },
    { id: 2, date: '6 May · 08:11', region: 'Lower front', kind: 'plaque' },
    { id: 3, date: '29 Apr · 20:02', region: 'Upper molar', kind: 'good' },
  ];
  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      {/* Header w/ back */}
      <div style={{ padding: '12px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={{
          width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
          display: 'grid', placeItems: 'center', color: 'var(--c-ink)',
        }}><IconChevronLeft size={22} /></button>
        <button style={{
          width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
          display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)',
        }}><IconSettings size={20} /></button>
      </div>

      {/* Hero card for member */}
      <div style={{ padding: '12px 20px 0' }}>
        <div style={{
          background: 'var(--c-surface)', borderRadius: 22,
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-3)',
          padding: 20, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10,
        }}>
          <Avatar name={member.name} size={84} tone={member.tone} />
          <div style={{ font: 'var(--t-headline-md)', color: 'var(--c-ink)' }}>{member.name}</div>
          <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)' }}>{member.age} years · {member.lastChecked ? `last checked ${member.lastChecked}` : 'never checked'}</div>
          <div style={{ marginTop: 4 }}><DxChip kind={dxKind} /></div>
          <div style={{ display: 'flex', gap: 10, marginTop: 14, width: '100%' }}>
            <BinaButton variant="primary" fullWidth onClick={onScan} icon={<IconCamera size={18} />}>Scan now</BinaButton>
            <BinaButton variant="secondary" fullWidth icon={<IconCalendar size={18} />}>Book</BinaButton>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div style={{ padding: '20px 20px 0', display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 10 }}>
        <StatCard label="Clean" value={member.statClean ?? 4} tone="good" />
        <StatCard label="Plaque" value={member.statPlaque ?? 2} tone="plaque" />
        <StatCard label="Cavity" value={member.statCavity ?? (dxKind === 'cavity' ? 1 : 0)} tone="cavity" />
      </div>

      {/* History */}
      <div style={{ padding: '24px 20px 0' }}>
        <SectionHeader title="History" action="Export" />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {scans.map(s => (
            <div key={s.id} style={{
              display: 'grid', gridTemplateColumns: '52px 1fr auto', gap: 12, alignItems: 'center',
              background: 'var(--c-surface)', borderRadius: 14, border: '1px solid var(--c-line)', padding: 12,
            }}>
              <div style={{
                width: 52, height: 52, borderRadius: 12,
                background: 'linear-gradient(135deg, #1a1a22, #2c2c38)',
                display: 'grid', placeItems: 'center', color: 'rgba(255,255,255,0.55)',
              }}><IconTooth size={28} /></div>
              <div style={{ minWidth: 0 }}>
                <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{s.region}</div>
                <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 2 }}>{s.date}</div>
              </div>
              <DxChip kind={s.kind} size="sm" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function StatCard({ label, value, tone }) {
  const tones = {
    good:   { color: 'var(--c-dx-good)', bg: 'var(--c-success-100)' },
    plaque: { color: 'var(--c-dx-plaque)', bg: '#fcf0d8' },
    cavity: { color: 'var(--c-dx-cavity)', bg: 'var(--c-error-100)' },
  };
  const t = tones[tone];
  return (
    <div style={{
      background: 'var(--c-surface)', borderRadius: 14,
      border: '1px solid var(--c-line)', padding: 12,
      display: 'flex', flexDirection: 'column', gap: 6,
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span style={{ width: 24, height: 24, borderRadius: 8, background: t.bg, display: 'grid', placeItems: 'center' }}>
          <span style={{ width: 8, height: 8, borderRadius: 999, background: t.color }} />
        </span>
        <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>{label}</div>
      </div>
      <div style={{ font: 'var(--t-display-sm)', fontSize: 26, color: 'var(--c-ink)', letterSpacing: '-0.02em' }}>{value}</div>
    </div>
  );
}

Object.assign(window, { FamilyScreen, MemberDetailScreen, FamilyRow, StatCard });
