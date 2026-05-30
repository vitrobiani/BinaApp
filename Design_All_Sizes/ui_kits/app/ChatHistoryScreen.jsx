// ChatHistoryScreen.jsx — list of past conversations + FAB for new chat.
// Source: lib/pages/chatbot_pages/chat_history/chat_history_widget.dart

function ChatHistoryScreen({ onOpenChat }) {
  const conversations = [
    {
      id: 'c1', member: 'Maya', tone: 'coral',
      title: "Maya's cavity — what's next?",
      preview: "Here's the plan I'd suggest, kindest-first: book a dentist within 2 weeks…",
      when: '5m ago', unread: 1,
    },
    {
      id: 'c2', member: 'Avi', tone: 'blue',
      title: 'Brushing technique for kids',
      preview: "Try the 'tooth-by-tooth' game — 2 minutes total, 4 sections of 30 seconds.",
      when: 'Yesterday', unread: 0,
    },
    {
      id: 'c3', member: 'Dad', tone: 'ink',
      title: 'Plaque on lower incisors',
      preview: "Plaque buildup on the lower incisors is common after coffee. Floss + a soft-bristle brush will…",
      when: '12 May', unread: 0,
    },
    {
      id: 'c4', member: 'Avi', tone: 'blue',
      title: 'When should we re-scan?',
      preview: "I'd recommend a quick re-scan in 5 days for Avi's upper-left region, just to confirm the cavity hasn't…",
      when: '6 May', unread: 0,
    },
  ];

  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      {/* Header */}
      <div style={{ padding: '12px 20px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
          <div>
            <h1 style={{ font: 'var(--t-display-sm)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.01em' }}>Chats</h1>
            <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', marginTop: 2 }}>
              On-device · Gemma 3
            </div>
          </div>
          <button style={{
            width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
            border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
            display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)',
          }}>
            <IconSearch size={20} />
          </button>
        </div>
      </div>

      {/* Member filter chips */}
      <div style={{ padding: '14px 20px 0', display: 'flex', gap: 8, overflowX: 'auto', scrollbarWidth: 'none' }}>
        {['All', 'Avi', 'Maya', 'Ron', 'Dad'].map((t, i) => (
          <span key={t} style={{
            padding: '7px 13px', borderRadius: 999, whiteSpace: 'nowrap',
            background: i === 0 ? 'var(--c-primary)' : 'var(--c-surface)',
            color: i === 0 ? '#fff' : 'var(--c-ink-2)',
            border: i === 0 ? 'none' : '1px solid var(--c-line)',
            font: 'var(--t-label-md)',
          }}>{t}</span>
        ))}
      </div>

      {/* Conversations list */}
      <div style={{ padding: '16px 20px 0', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {conversations.map(c => (
          <button key={c.id} onClick={() => onOpenChat && onOpenChat(c)} style={{
            background: 'var(--c-surface)', borderRadius: 16,
            border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)',
            padding: 14, cursor: 'pointer',
            display: 'grid', gridTemplateColumns: '42px 1fr auto', gap: 12, alignItems: 'center',
            textAlign: 'left',
          }}>
            <Avatar name={c.member} size={42} tone={c.tone} />
            <div style={{ minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', flex: 1 }}>{c.title}</div>
              </div>
              <div style={{
                font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 2,
                overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
              }}>{c.preview}</div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4 }}>
              <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)' }}>{c.when}</div>
              {c.unread > 0 && (
                <span style={{
                  minWidth: 18, height: 18, borderRadius: 999, background: 'var(--c-primary)',
                  color: '#fff', font: '600 11px/18px Inter', padding: '0 6px',
                  display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                }}>{c.unread}</span>
              )}
            </div>
          </button>
        ))}
      </div>

      {/* "Start new chat" FAB-style button */}
      <div style={{ padding: '20px 20px 0' }}>
        <button onClick={() => onOpenChat && onOpenChat(null)} style={{
          width: '100%',
          background: 'var(--g-hero)', color: '#fff', borderRadius: 16,
          border: 0, boxShadow: 'var(--sh-hero)', cursor: 'pointer',
          padding: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          font: 'var(--t-label-lg)',
        }}>
          <IconSparkle size={18} />
          Start a new conversation
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { ChatHistoryScreen });
