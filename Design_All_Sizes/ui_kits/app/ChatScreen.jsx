// ChatScreen.jsx — Gemma-backed AI chat.
// Source: lib/pages/chatbot_pages/chat_room/chat_room_widget.dart

function ChatScreen({ conversation, onBack }) {
  const title = conversation?.title || "Bina";
  const memberName = conversation?.member;
  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <div style={{ padding: '12px 16px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 8 }}>
        {onBack && (
          <button onClick={onBack} style={{
            width: 40, height: 40, borderRadius: '50%', background: 'var(--c-surface)',
            border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
            display: 'grid', placeItems: 'center', color: 'var(--c-ink)', padding: 0,
          }}><IconChevronLeft size={22} /></button>
        )}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, flex: 1, minWidth: 0 }}>
          <div style={{
            width: 40, height: 40, borderRadius: 12, background: 'var(--g-hero)',
            color: '#fff', display: 'grid', placeItems: 'center', boxShadow: 'var(--sh-hero)',
          }}><IconSparkle size={20} /></div>
          <div style={{ minWidth: 0 }}>
            <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</div>
            <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-success)', display: 'flex', alignItems: 'center', gap: 5 }}>
              <span style={{ width: 6, height: 6, borderRadius: 999, background: 'var(--c-success)' }} />
              {memberName ? `${memberName} · On device` : 'On device · Gemma'}
            </div>
          </div>
        </div>
        <button style={{
          width: 40, height: 40, borderRadius: '50%', background: 'var(--c-surface)',
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
          display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)', padding: 0,
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg>
        </button>
      </div>

      {/* Messages */}
      <div style={{ padding: '20px 20px 0', display: 'flex', flexDirection: 'column', gap: 12, flex: 1 }}>
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

      {/* Composer */}
      <div style={{ padding: '12px 16px 16px' }}>
        <div style={{
          display: 'flex', gap: 8, alignItems: 'center',
          background: 'var(--c-surface)', borderRadius: 999,
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)',
          padding: '6px 6px 6px 16px',
        }}>
          <input
            placeholder="Ask Bina anything…"
            style={{
              flex: 1, border: 0, outline: 0, background: 'transparent',
              font: 'var(--t-body-md)', color: 'var(--c-ink)',
              height: 36,
            }}
          />
          <button style={{
            width: 36, height: 36, borderRadius: '50%', background: 'var(--c-primary)',
            color: '#fff', border: 0, cursor: 'pointer', display: 'grid', placeItems: 'center',
          }} aria-label="Send">
            <IconSend size={16} />
          </button>
        </div>
      </div>
    </div>
  );
}

function DateDivider({ label }) {
  return (
    <div style={{ alignSelf: 'center', font: 'var(--t-label-sm)', color: 'var(--c-ink-3)', padding: '2px 12px', background: 'var(--c-surface-sunken)', borderRadius: 999 }}>{label}</div>
  );
}

function Bubble({ from, children, suggestions, typing }) {
  const isMe = from === 'me';
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: isMe ? 'flex-end' : 'flex-start', gap: 8, width: '100%' }}>
      <div style={{
        maxWidth: '85%',
        width: 'fit-content',
        background: isMe ? 'var(--c-primary)' : 'var(--c-surface)',
        color: isMe ? '#fff' : 'var(--c-ink)',
        border: isMe ? 0 : '1px solid var(--c-line)',
        boxShadow: isMe ? 'var(--sh-2)' : 'var(--sh-1)',
        borderRadius: isMe ? '20px 20px 6px 20px' : '20px 20px 20px 6px',
        padding: '10px 14px',
        font: 'var(--t-body-md)',
        lineHeight: 1.5,
        overflowWrap: 'break-word',
      }}>
        {typing ? <TypingDots /> : children}
      </div>
      {suggestions && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
          {suggestions.map(s => (
            <button key={s} style={{
              background: 'var(--c-surface)', border: '1px solid var(--c-primary-300)',
              color: 'var(--c-primary-700)', padding: '6px 12px', borderRadius: 999,
              font: 'var(--t-label-md)', cursor: 'pointer',
            }}>{s}</button>
          ))}
        </div>
      )}
    </div>
  );
}

function TypingDots() {
  const dot = (delay) => ({
    width: 6, height: 6, borderRadius: 999, background: 'var(--c-ink-3)',
    animation: `binaPulse 1.2s infinite ${delay}`,
  });
  return (
    <div style={{ display: 'inline-flex', gap: 4, padding: '4px 0' }}>
      <span style={dot('0s')} /><span style={dot('0.2s')} /><span style={dot('0.4s')} />
      <style>{`@keyframes binaPulse { 0%,80%,100% { opacity:0.3 } 40% { opacity:1 } }`}</style>
    </div>
  );
}

Object.assign(window, { ChatScreen, Bubble, DateDivider });
