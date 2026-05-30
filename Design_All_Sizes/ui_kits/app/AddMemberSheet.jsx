// AddMemberSheet.jsx — bottom sheet for adding a new family member.
// New screen — not in the original codebase but implied by the data model.

function AddMemberSheet({ onClose, onAdd }) {
  const [name, setName] = React.useState('');
  const [age, setAge] = React.useState('');
  const [relationship, setRelationship] = React.useState('child');
  const [tone, setTone] = React.useState('aqua');

  const submit = () => {
    if (!name.trim()) return;
    onAdd && onAdd({ name: name.trim(), age: parseInt(age) || 0, relationship, tone });
  };

  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 40,
      background: 'rgba(12, 21, 48, 0.45)',
      display: 'flex', flexDirection: 'column', justifyContent: 'flex-end',
      animation: 'binaScrimIn 200ms ease-out',
    }}>
      <div onClick={onClose} style={{ flex: 1 }} />

      <div style={{
        background: 'var(--c-surface)',
        borderTopLeftRadius: 28, borderTopRightRadius: 28,
        boxShadow: 'var(--sh-4)',
        animation: 'binaSheetSlideUp 280ms cubic-bezier(.2,.7,.2,1)',
        paddingBottom: 24,
      }}>
        <div style={{ display: 'grid', placeItems: 'center', padding: '10px 0 6px' }}>
          <div style={{ width: 44, height: 5, borderRadius: 999, background: 'var(--c-line-strong)' }} />
        </div>

        <div style={{ padding: '6px 20px 0' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h2 style={{ font: 'var(--t-headline-md)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.005em' }}>
                Add family member
              </h2>
              <p style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', margin: '4px 0 0' }}>
                Each member gets their own scan history.
              </p>
            </div>
            <button onClick={onClose} style={{
              width: 36, height: 36, borderRadius: '50%',
              background: 'var(--c-surface-sunken)', border: 0,
              cursor: 'pointer', display: 'grid', placeItems: 'center', color: 'var(--c-ink-2)',
            }}>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6 6 18M6 6l12 12"/></svg>
            </button>
          </div>
        </div>

        {/* Avatar preview + tone */}
        <div style={{ padding: '20px 20px 0', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10 }}>
          <Avatar name={name || '??'} size={72} tone={tone} />
          <div style={{ display: 'flex', gap: 8 }}>
            {[['blue','primary'],['coral','coral'],['aqua','aqua'],['ink','ink']].map(([t, v]) => (
              <button key={t} onClick={() => setTone(t)} style={{
                width: 32, height: 32, borderRadius: '50%',
                background: `var(--c-${v})`,
                border: tone === t ? '3px solid var(--c-ink)' : '3px solid transparent',
                cursor: 'pointer', boxShadow: 'var(--sh-1)',
              }} aria-label={t} />
            ))}
          </div>
        </div>

        {/* Form */}
        <div style={{ padding: '20px 20px 0', display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Field label="Name">
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Maya"
              autoFocus
              style={sheetInputStyle}
            />
          </Field>
          <Field label="Age">
            <input
              type="number"
              value={age}
              onChange={(e) => setAge(e.target.value)}
              placeholder="11"
              style={sheetInputStyle}
            />
          </Field>
          <Field label="Relationship">
            <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
              {[
                { id: 'child', label: 'Child' },
                { id: 'partner', label: 'Partner' },
                { id: 'parent', label: 'Parent' },
                { id: 'other', label: 'Other' },
              ].map(o => (
                <button key={o.id} onClick={() => setRelationship(o.id)} style={{
                  padding: '9px 14px', borderRadius: 999,
                  background: relationship === o.id ? 'var(--c-primary)' : 'var(--c-surface)',
                  color: relationship === o.id ? '#fff' : 'var(--c-ink)',
                  border: relationship === o.id ? 'none' : '1px solid var(--c-line)',
                  font: 'var(--t-label-md)', cursor: 'pointer',
                }}>{o.label}</button>
              ))}
            </div>
          </Field>
        </div>

        <div style={{ padding: '20px 20px 0', display: 'flex', gap: 10 }}>
          <BinaButton variant="ghost" fullWidth onClick={onClose}>Cancel</BinaButton>
          <BinaButton variant="primary" fullWidth onClick={submit} icon={<IconPlus size={18} />}>
            Add member
          </BinaButton>
        </div>
      </div>
    </div>
  );
}

const sheetInputStyle = {
  height: 48,
  borderRadius: 12,
  border: '1px solid var(--c-line-strong)',
  background: 'var(--c-surface)',
  padding: '0 14px',
  font: 'var(--t-body-lg)',
  color: 'var(--c-ink)',
  outline: 'none',
  width: '100%',
  boxSizing: 'border-box',
  fontFamily: 'Inter, system-ui, sans-serif',
};

Object.assign(window, { AddMemberSheet });
