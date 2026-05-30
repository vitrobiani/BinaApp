// WideScreens.jsx — tablet/desktop layouts for the four core tabs.
// Reuses atoms + sub-components exported from the phone screens:
//   Avatar, DxChip, BinaButton, SectionHeader, ProgressRings, ScanRow,
//   FamilyRow, StatCard, Bubble, DateDivider, HubRow, ProfileThemeSwatch, Icon*
//
// Layout philosophy: phones stack; wide screens spread. A max content width
// keeps line lengths sane on very wide monitors (--layout-max = 1200px).

const RECENT_SCANS = [
  { name: 'Maya', region: 'Lower right molar', kind: 'cavity', when: '9 May · 19:02', tone: 'coral' },
  { name: 'Avi',  region: 'Upper left incisor', kind: 'good',   when: '12 May · 11:24', tone: 'blue' },
  { name: 'Avi',  region: 'Lower front',        kind: 'plaque', when: '6 May · 08:11',  tone: 'blue' },
];

const CONVERSATIONS = [
  { id: 'c1', member: 'Maya', tone: 'coral', title: "Maya's cavity — what's next?", preview: "Here's the plan I'd suggest, kindest-first: book a dentist within 2 weeks…", when: '5m ago', unread: 1 },
  { id: 'c2', member: 'Avi',  tone: 'blue',  title: 'Brushing technique for kids', preview: "Try the 'tooth-by-tooth' game — 2 minutes total, 4 sections of 30 seconds.", when: 'Yesterday', unread: 0 },
  { id: 'c3', member: 'Dad',  tone: 'ink',   title: 'Plaque on lower incisors', preview: 'Plaque buildup on the lower incisors is common after coffee. Floss + a soft-bristle brush will…', when: '12 May', unread: 0 },
  { id: 'c4', member: 'Avi',  tone: 'blue',  title: 'When should we re-scan?', preview: "I'd recommend a quick re-scan in 5 days for Avi's upper-left region, just to confirm…", when: '6 May', unread: 0 },
];

// shared page wrapper — caps width + adds desktop padding
function WidePage({ children, max = 1180, pad = 32 }) {
  return (
    <div style={{ padding: pad, minHeight: '100%', boxSizing: 'border-box' }}>
      <div style={{ maxWidth: max, margin: '0 auto' }}>{children}</div>
    </div>
  );
}

function WideSectionCard({ children, style }) {
  return (
    <div style={{
      background: 'var(--c-surface)', borderRadius: 20,
      border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)',
      padding: 20, ...style,
    }}>{children}</div>
  );
}

// ═══════════════════════ HOME ═══════════════════════
function HomeWide({ family, go, openMember, onAddMember, onScan }) {
  const { bp } = useViewport();
  const desktop = bp === 'desktop';
  const checked = family.filter(f => f.lastChecked).length;
  const pct = Math.round((checked / family.length) * 100);

  const heroCard = (
    <div style={{
      background: 'var(--g-hero)', borderRadius: 24, color: '#fff', padding: 28,
      boxShadow: 'var(--sh-hero)', position: 'relative', overflow: 'hidden',
      display: 'grid', gridTemplateColumns: '1fr 132px', gap: 16, alignItems: 'center',
    }}>
      <div style={{ position: 'absolute', top: '-50%', right: '-8%', width: 280, height: 280, borderRadius: '50%', background: 'rgba(255,255,255,0.12)', pointerEvents: 'none' }} />
      <div style={{ position: 'relative', zIndex: 1 }}>
        <div style={{ font: 'var(--t-overline)', letterSpacing: '0.12em', textTransform: 'uppercase', opacity: 0.78 }}>This week</div>
        <div style={{ font: 'var(--t-display-md)', letterSpacing: '-0.01em', marginTop: 4 }}>{pct}% checked</div>
        <div style={{ font: 'var(--t-body-lg)', opacity: 0.9, marginTop: 6 }}>
          {family.length - checked} {family.length - checked === 1 ? 'member' : 'members'} undiagnosed this week
        </div>
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          <button onClick={() => go('family')} style={{
            background: 'rgba(255,255,255,0.96)', color: 'var(--c-primary-700)', border: 0,
            padding: '11px 18px', borderRadius: 999, font: 'var(--t-label-lg)', cursor: 'pointer',
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>View family <IconArrowRight size={16} /></button>
          <button onClick={onScan} style={{
            background: 'rgba(255,255,255,0.16)', color: '#fff', border: '1px solid rgba(255,255,255,0.5)',
            padding: '11px 18px', borderRadius: 999, font: 'var(--t-label-lg)', cursor: 'pointer',
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}><IconCamera size={16} /> Start a scan</button>
        </div>
      </div>
      <ProgressRings pct={pct} />
    </div>
  );

  const familyList = (
    <WideSectionCard>
      <SectionHeader title="Your family" action="See all" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {family.map(m => <FamilyRow key={m.id} member={m} onClick={() => openMember(m)} />)}
        <button onClick={onAddMember} style={{
          borderRadius: 18, border: '2px dashed var(--c-line-strong)', background: 'transparent',
          color: 'var(--c-primary)', padding: 14, cursor: 'pointer', font: 'var(--t-label-md)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}><IconPlus size={20} /> Add member</button>
      </div>
    </WideSectionCard>
  );

  const recentCard = (
    <WideSectionCard>
      <SectionHeader title="Recent scans" action="History" />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {RECENT_SCANS.map((s, i) => <ScanRow key={i} {...s} />)}
      </div>
    </WideSectionCard>
  );

  const tipCard = (
    <div style={{ background: 'var(--g-hero-soft)', borderRadius: 20, padding: 18, display: 'flex', gap: 14, alignItems: 'flex-start' }}>
      <div style={{ width: 44, height: 44, borderRadius: 12, background: 'var(--c-surface)', color: 'var(--c-primary)', display: 'grid', placeItems: 'center', flexShrink: 0, boxShadow: 'var(--sh-1)' }}><IconSparkle size={22} /></div>
      <div>
        <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>Bina tip</div>
        <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', marginTop: 3, lineHeight: 1.5 }}>
          Plaque on Maya's lower molars showed up twice this month. Try a 2-minute brush + floss after dinner.
        </div>
      </div>
    </div>
  );

  return (
    <WidePage>
      {/* greeting */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24, gap: 16 }}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.1em' }}>Tuesday · May 14</div>
          <h1 style={{ font: 'var(--t-display-md)', color: 'var(--c-ink)', margin: '4px 0 0', letterSpacing: '-0.015em', whiteSpace: 'nowrap' }}>Hello Sarah</h1>
        </div>
        <button style={{ width: 48, height: 48, borderRadius: '50%', background: 'var(--c-surface)', border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer', display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)', position: 'relative', flexShrink: 0 }}>
          <IconBell size={22} />
          <span style={{ position: 'absolute', top: 10, right: 11, width: 8, height: 8, background: 'var(--c-coral)', borderRadius: 999, border: '2px solid var(--c-surface)' }} />
        </button>
      </div>

      {desktop ? (
        <div style={{ display: 'grid', gridTemplateColumns: '1.55fr 1fr', gap: 20, alignItems: 'start' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {heroCard}
            {recentCard}
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {familyList}
            {tipCard}
          </div>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          {heroCard}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, alignItems: 'start' }}>
            {familyList}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
              {recentCard}
              {tipCard}
            </div>
          </div>
        </div>
      )}
    </WidePage>
  );
}

// ═══════════════════════ FAMILY (master–detail) ═══════════════════════
function FamilyWide({ family, onAddMember, onScanMember }) {
  const { bp } = useViewport();
  const [selId, setSelId] = React.useState(family[0] && family[0].id);
  const selected = family.find(f => f.id === selId) || family[0];
  const listW = bp === 'desktop' ? 380 : 312;

  return (
    <div style={{ display: 'flex', height: '100%' }}>
      {/* list pane */}
      <div style={{ width: listW, flexShrink: 0, height: '100%', overflowY: 'auto', borderRight: '1px solid var(--c-line)', padding: 24, boxSizing: 'border-box' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
          <h1 style={{ font: 'var(--t-headline-lg)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.01em' }}>Family</h1>
          <button onClick={onAddMember} style={{ width: 42, height: 42, borderRadius: 999, background: 'var(--c-primary)', color: '#fff', border: 0, cursor: 'pointer', display: 'grid', placeItems: 'center', boxShadow: 'var(--sh-2)' }} aria-label="Add member"><IconPlus size={20} /></button>
        </div>
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none', marginBottom: 16 }}>
          {['All 4', 'Due now 1', 'Adults', 'Kids'].map((t, i) => (
            <span key={t} style={{ padding: '7px 13px', borderRadius: 999, background: i === 0 ? 'var(--c-primary)' : 'var(--c-surface)', color: i === 0 ? '#fff' : 'var(--c-ink-2)', border: i === 0 ? 'none' : '1px solid var(--c-line)', font: 'var(--t-label-md)', whiteSpace: 'nowrap' }}>{t}</span>
          ))}
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {family.map(m => (
            <div key={m.id} onClick={() => setSelId(m.id)} style={{
              display: 'grid', borderRadius: 18, cursor: 'pointer',
              outline: m.id === selId ? '2px solid var(--c-primary)' : 'none',
              outlineOffset: -1,
            }}>
              <FamilyRow member={m} onClick={() => setSelId(m.id)} />
            </div>
          ))}
        </div>
      </div>
      {/* detail pane */}
      <div style={{ flex: 1, minWidth: 0, height: '100%', overflowY: 'auto' }}>
        {selected && <MemberDetailPane member={selected} onScan={() => onScanMember(selected)} />}
      </div>
    </div>
  );
}

function MemberDetailPane({ member, onScan }) {
  const dxKind = member.lastResult || 'due';
  const scans = member.scans || [
    { id: 1, date: '12 May · 11:24', region: 'Upper left incisor', kind: 'good' },
    { id: 2, date: '6 May · 08:11', region: 'Lower front', kind: 'plaque' },
    { id: 3, date: '29 Apr · 20:02', region: 'Upper molar', kind: 'good' },
  ];
  return (
    <WidePage max={760} pad={32}>
      {/* hero */}
      <WideSectionCard style={{ borderRadius: 24, padding: 28, display: 'grid', gridTemplateColumns: 'auto 1fr', gap: 24, alignItems: 'center' }}>
        <Avatar name={member.name} size={92} tone={member.tone} />
        <div>
          <div style={{ font: 'var(--t-display-sm)', color: 'var(--c-ink)', letterSpacing: '-0.01em' }}>{member.name}</div>
          <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', marginTop: 4 }}>{member.age} years · {member.lastChecked ? `last checked ${member.lastChecked}` : 'never checked'}</div>
          <div style={{ marginTop: 12, display: 'flex', gap: 10, alignItems: 'center', flexWrap: 'wrap' }}>
            <DxChip kind={dxKind} />
            <div style={{ display: 'flex', gap: 10 }}>
              <BinaButton variant="primary" onClick={onScan} icon={<IconCamera size={18} />}>Scan now</BinaButton>
              <BinaButton variant="secondary" icon={<IconCalendar size={18} />}>Book</BinaButton>
            </div>
          </div>
        </div>
      </WideSectionCard>

      {/* stats */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12, marginTop: 20 }}>
        <StatCard label="Clean" value={member.statClean ?? 4} tone="good" />
        <StatCard label="Plaque" value={member.statPlaque ?? 2} tone="plaque" />
        <StatCard label="Cavity" value={member.statCavity ?? (dxKind === 'cavity' ? 1 : 0)} tone="cavity" />
      </div>

      {/* history */}
      <div style={{ marginTop: 28 }}>
        <SectionHeader title="History" action="Export" />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {scans.map(s => (
            <div key={s.id} style={{ display: 'grid', gridTemplateColumns: '52px 1fr auto', gap: 12, alignItems: 'center', background: 'var(--c-surface)', borderRadius: 14, border: '1px solid var(--c-line)', padding: 12 }}>
              <div style={{ width: 52, height: 52, borderRadius: 12, background: 'linear-gradient(135deg, #1a1a22, #2c2c38)', display: 'grid', placeItems: 'center', color: 'rgba(255,255,255,0.55)' }}><IconTooth size={28} /></div>
              <div style={{ minWidth: 0 }}>
                <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{s.region}</div>
                <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 2 }}>{s.date}</div>
              </div>
              <DxChip kind={s.kind} size="sm" />
            </div>
          ))}
        </div>
      </div>
    </WidePage>
  );
}

// ═══════════════════════ CHAT (two-pane) ═══════════════════════
function ChatWide() {
  const { bp } = useViewport();
  const [selId, setSelId] = React.useState(CONVERSATIONS[0].id);
  const selected = CONVERSATIONS.find(c => c.id === selId);
  const listW = bp === 'desktop' ? 360 : 300;

  return (
    <div style={{ display: 'flex', height: '100%' }}>
      {/* conversation list */}
      <div style={{ width: listW, flexShrink: 0, height: '100%', overflowY: 'auto', borderRight: '1px solid var(--c-line)', padding: 24, boxSizing: 'border-box' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: 14 }}>
          <div>
            <h1 style={{ font: 'var(--t-headline-lg)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.01em' }}>Chats</h1>
            <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', marginTop: 2 }}>On-device · Gemma 3</div>
          </div>
          <button style={{ width: 40, height: 40, borderRadius: '50%', background: 'var(--c-surface)', border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer', display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)' }}><IconSearch size={20} /></button>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {CONVERSATIONS.map(c => {
            const active = c.id === selId;
            return (
              <button key={c.id} onClick={() => setSelId(c.id)} style={{
                background: active ? 'var(--c-primary-100)' : 'var(--c-surface)', borderRadius: 16,
                border: active ? '1px solid var(--c-primary-300)' : '1px solid var(--c-line)',
                boxShadow: active ? 'none' : 'var(--sh-1)', padding: 13, cursor: 'pointer',
                display: 'grid', gridTemplateColumns: '40px 1fr', gap: 12, alignItems: 'center', textAlign: 'left',
              }}>
                <Avatar name={c.member} size={40} tone={c.tone} />
                <div style={{ minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                    <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', flex: 1 }}>{c.title}</div>
                    {c.unread > 0 && <span style={{ minWidth: 18, height: 18, borderRadius: 999, background: 'var(--c-primary)', color: '#fff', font: '600 11px/18px Inter', padding: '0 6px', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>{c.unread}</span>}
                  </div>
                  <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{c.preview}</div>
                </div>
              </button>
            );
          })}
        </div>
      </div>
      {/* active conversation */}
      <div style={{ flex: 1, minWidth: 0, height: '100%' }}>
        <ChatPane conversation={selected} />
      </div>
    </div>
  );
}

function ChatPane({ conversation }) {
  const title = conversation?.title || 'Bina';
  const memberName = conversation?.member;
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--c-surface-alt)' }}>
      {/* header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '18px 28px', borderBottom: '1px solid var(--c-line)', background: 'var(--c-surface)' }}>
        <div style={{ width: 42, height: 42, borderRadius: 12, background: 'var(--g-hero)', color: '#fff', display: 'grid', placeItems: 'center', boxShadow: 'var(--sh-hero)' }}><IconSparkle size={20} /></div>
        <div style={{ minWidth: 0, flex: 1 }}>
          <div style={{ font: 'var(--t-title-lg)', color: 'var(--c-ink)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</div>
          <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-success)', display: 'flex', alignItems: 'center', gap: 5 }}>
            <span style={{ width: 6, height: 6, borderRadius: 999, background: 'var(--c-success)' }} />
            {memberName ? `${memberName} · On device` : 'On device · Gemma'}
          </div>
        </div>
      </div>
      {/* messages */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '24px 28px' }}>
        <div style={{ maxWidth: 720, margin: '0 auto', display: 'flex', flexDirection: 'column', gap: 12 }}>
          <DateDivider label="Today" />
          <Bubble from="bot">Hello Sarah! I noticed Maya has a new cavity result from this morning. Want me to walk through what's next?</Bubble>
          <Bubble from="me">yes please</Bubble>
          <Bubble from="bot">
            Here's the plan I'd suggest, kindest-first:
            <ul style={{ margin: '8px 0 0', paddingLeft: 18, lineHeight: 1.55 }}>
              <li>Book a dentist within 2 weeks.</li>
              <li>Brush gently around the lower right molar.</li>
              <li>Skip sugary drinks today.</li>
            </ul>
          </Bubble>
          <Bubble from="bot" suggestions={['Find a dentist nearby', 'How serious is this?', 'Re-scan in 1 week']} />
          <Bubble from="me">how serious is this?</Bubble>
          <Bubble from="bot" typing />
        </div>
      </div>
      {/* composer */}
      <div style={{ padding: '14px 28px 22px', borderTop: '1px solid var(--c-line)', background: 'var(--c-surface)' }}>
        <div style={{ maxWidth: 720, margin: '0 auto', display: 'flex', gap: 8, alignItems: 'center', background: 'var(--c-surface-alt)', borderRadius: 999, border: '1px solid var(--c-line)', padding: '6px 6px 6px 18px' }}>
          <input placeholder="Ask Bina anything…" style={{ flex: 1, border: 0, outline: 0, background: 'transparent', font: 'var(--t-body-md)', color: 'var(--c-ink)', height: 40 }} />
          <button style={{ width: 40, height: 40, borderRadius: '50%', background: 'var(--c-primary)', color: '#fff', border: 0, cursor: 'pointer', display: 'grid', placeItems: 'center' }} aria-label="Send"><IconSend size={16} /></button>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════ PROFILE (centered, 2-col on desktop) ═══════════════════════
function ProfileWide({ theme, setTheme, hintMode, onOpenAccount, onOpenAccessibility, onOpenHelp, onOpenAbout }) {
  const { bp } = useViewport();
  const desktop = bp === 'desktop';
  const Group = ({ title, children }) => (
    <div>
      <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px 8px' }}>{title}</div>
      <div style={{ background: 'var(--c-surface)', borderRadius: 18, border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)', overflow: 'hidden' }}>{children}</div>
    </div>
  );
  const swatches = [
    { id: 'light', label: 'Light', grad: 'linear-gradient(135deg, #fbfaf6, #1f5bff)' },
    { id: 'dark', label: 'Dark', grad: 'linear-gradient(135deg, #0c0f1a, #5b8bff)' },
    { id: 'warm', label: 'Warm', grad: 'linear-gradient(135deg, #fff8e1, #ef8b1a)' },
    { id: 'cool', label: 'Cool', grad: 'linear-gradient(135deg, #e3f2fd, #0099b3)' },
    { id: 'deuteranopia', label: 'A11y', grad: 'linear-gradient(135deg, #ffffff, #0077bb)' },
  ];
  return (
    <WidePage max={880} pad={32}>
      <h1 style={{ font: 'var(--t-display-md)', color: 'var(--c-ink)', margin: '0 0 20px', letterSpacing: '-0.015em' }}>Profile</h1>

      {/* identity */}
      <button onClick={onOpenAccount} style={{ width: '100%', background: 'var(--c-surface)', borderRadius: 22, border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)', padding: 20, display: 'flex', alignItems: 'center', gap: 16, cursor: 'pointer', textAlign: 'left', marginBottom: 24 }}>
        <Avatar name="Sarah Levin" size={64} tone="blue" />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ font: 'var(--t-headline-sm)', color: 'var(--c-ink)' }}>Sarah Levin</div>
          <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)' }}>sarah@levinfamily.com</div>
          <div style={{ font: 'var(--t-label-sm)', color: 'var(--c-primary)', marginTop: 6 }}>View account →</div>
        </div>
        <IconChevronRight size={20} />
      </button>

      <div style={{ display: 'grid', gridTemplateColumns: desktop ? '1fr 1fr' : '1fr', gap: 24, alignItems: 'start' }}>
        <Group title="Appearance">
          <div style={{ padding: '16px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
              <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>Theme</div>
              <button onClick={onOpenAccessibility} style={{ font: 'var(--t-label-sm)', color: 'var(--c-primary)', fontWeight: 600, background: 'transparent', border: 0, cursor: 'pointer', padding: 0 }}>More options →</button>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 10 }}>
              {swatches.map(s => <ProfileThemeSwatch key={s.id} label={s.label} id={s.id} grad={s.grad} active={theme === s.id} onClick={() => setTheme(s.id)} />)}
            </div>
          </div>
        </Group>

        <Group title="Settings">
          <HubRow icon={<IconUser size={20} />} label="Account" subtitle="Personal info, password, data" tone="blue" onClick={onOpenAccount} />
          <HubRow icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>} label="Accessibility" subtitle={`Theme · text size${hintMode ? ' · hints on' : ''}`} tone="aqua" onClick={onOpenAccessibility} />
          <HubRow icon={<IconChat size={20} />} label="Help & support" subtitle="FAQ, contact, send feedback" tone="coral" onClick={onOpenHelp} isLast />
        </Group>

        <Group title="About">
          <HubRow icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>} label="About Bina" subtitle="Version 1.0.0" tone="blue" onClick={onOpenAbout} isLast />
        </Group>

        <div style={{ display: 'flex', alignItems: 'flex-end' }}>
          <button style={{ width: '100%', height: 48, borderRadius: 999, background: 'transparent', color: 'var(--c-error)', border: '1px solid var(--c-line)', font: 'var(--t-label-lg)', cursor: 'pointer' }}>Sign out</button>
        </div>
      </div>
    </WidePage>
  );
}

Object.assign(window, { HomeWide, FamilyWide, MemberDetailPane, ChatWide, ChatPane, ProfileWide, WidePage, WideSectionCard });
