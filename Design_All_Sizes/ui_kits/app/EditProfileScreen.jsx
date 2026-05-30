// EditProfileScreen.jsx — edit personal info (account owner OR family member).
// Source: lib/pages/account_profile_creation/edit_profile_auth_2/edit_profile_auth2_widget.dart
// + lib/pages/family/family_member/family_member_widget.dart

function EditProfileScreen({ subject, onCancel, onSave }) {
  // `subject` may be {id, name, age, tone, ...} (family member) OR the account owner (Sarah).
  const isOwner = !subject || subject.isMe || subject.id === 0;
  const [name, setName] = React.useState(subject?.name || 'Sarah Levin');
  const [age, setAge] = React.useState(subject?.age ?? 41);
  const [tone, setTone] = React.useState(subject?.tone || 'blue');
  const [email, setEmail] = React.useState(isOwner ? 'sarah@levinfamily.com' : '');
  const [reminders, setReminders] = React.useState(true);

  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      {/* Header */}
      <div style={{ padding: '12px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onCancel} style={{
          background: 'transparent', border: 0, color: 'var(--c-ink-2)',
          font: 'var(--t-label-lg)', cursor: 'pointer', padding: '8px 4px',
        }}>Cancel</button>
        <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>
          {isOwner ? 'Edit profile' : `Edit ${subject?.name || 'member'}`}
        </div>
        <button onClick={() => onSave({ name, age, tone, email, reminders })} style={{
          background: 'transparent', border: 0, color: 'var(--c-primary)',
          font: 'var(--t-label-lg)', fontWeight: 600, cursor: 'pointer', padding: '8px 4px',
        }}>Save</button>
      </div>

      {/* Avatar + tone picker */}
      <div style={{ padding: '24px 20px 0', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
        <div style={{ position: 'relative' }}>
          <Avatar name={name} size={96} tone={tone} />
          <button style={{
            position: 'absolute', bottom: -4, right: -4,
            width: 32, height: 32, borderRadius: '50%',
            background: 'var(--c-primary)', color: '#fff',
            border: '3px solid var(--c-surface-alt)',
            display: 'grid', placeItems: 'center', cursor: 'pointer',
          }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 5a2 2 0 0 1 2-2h3l2-2h4l2 2h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2Z"/><circle cx="12" cy="12" r="4"/></svg>
          </button>
        </div>
        <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>Avatar tone</div>
        <div style={{ display: 'flex', gap: 8 }}>
          {['blue', 'coral', 'aqua', 'ink'].map(t => (
            <button key={t} onClick={() => setTone(t)} style={{
              width: 40, height: 40, borderRadius: '50%',
              background: `var(--c-${t === 'blue' ? 'primary' : t === 'coral' ? 'coral' : t === 'aqua' ? 'aqua' : 'ink'})`,
              border: tone === t ? '3px solid var(--c-ink)' : '3px solid transparent',
              cursor: 'pointer',
              boxShadow: 'var(--sh-1)',
            }} aria-label={t} />
          ))}
        </div>
      </div>

      {/* Form fields */}
      <div style={{ padding: '24px 20px 0', display: 'flex', flexDirection: 'column', gap: 18 }}>
        <Field label="Name">
          <input value={name} onChange={(e) => setName(e.target.value)} style={inputStyle} />
        </Field>

        {isOwner ? (
          <Field label="Email" hint="Used for sign-in and reminders.">
            <input value={email} onChange={(e) => setEmail(e.target.value)} style={inputStyle} />
          </Field>
        ) : (
          <Field label="Age">
            <input type="number" value={age} onChange={(e) => setAge(parseInt(e.target.value) || 0)} style={inputStyle} />
          </Field>
        )}

        {!isOwner && (
          <Field label="Relationship">
            <RelationshipPicker />
          </Field>
        )}

        <Field label="">
          <div style={{
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            background: 'var(--c-surface)', border: '1px solid var(--c-line)',
            borderRadius: 14, padding: '14px 16px',
          }}>
            <div>
              <div style={{ font: 'var(--t-body-lg)', color: 'var(--c-ink)' }}>Weekly scan reminders</div>
              <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 2 }}>
                A gentle nudge every Sunday at 18:00.
              </div>
            </div>
            <button onClick={() => setReminders(!reminders)} style={{
              width: 44, height: 26, borderRadius: 999,
              background: reminders ? 'var(--c-primary)' : 'var(--c-line-strong)',
              position: 'relative', transition: 'background 200ms',
              border: 0, cursor: 'pointer',
            }}>
              <div style={{
                position: 'absolute', top: 2, left: reminders ? 20 : 2,
                width: 22, height: 22, borderRadius: '50%', background: '#fff',
                boxShadow: '0 1px 3px rgba(0,0,0,0.2)', transition: 'left 200ms',
              }} />
            </button>
          </div>
        </Field>

        {!isOwner && (
          <button style={{
            marginTop: 8, padding: '14px',
            background: 'transparent', color: 'var(--c-error)',
            border: '1px solid var(--c-line)', borderRadius: 14,
            font: 'var(--t-label-lg)', cursor: 'pointer',
          }}>
            Remove {subject?.name || 'member'} from family
          </button>
        )}
      </div>
    </div>
  );
}

const inputStyle = {
  height: 50,
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

function Field({ label, hint, children }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      {label && <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)', padding: '0 4px' }}>{label}</div>}
      {children}
      {hint && <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', padding: '0 4px' }}>{hint}</div>}
    </div>
  );
}

function RelationshipPicker() {
  const [picked, setPicked] = React.useState('child');
  const opts = [
    { id: 'child', label: 'Child' },
    { id: 'partner', label: 'Partner' },
    { id: 'parent', label: 'Parent' },
    { id: 'other', label: 'Other' },
  ];
  return (
    <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
      {opts.map(o => (
        <button key={o.id} onClick={() => setPicked(o.id)} style={{
          padding: '10px 16px', borderRadius: 999,
          background: picked === o.id ? 'var(--c-primary)' : 'var(--c-surface)',
          color: picked === o.id ? '#fff' : 'var(--c-ink)',
          border: picked === o.id ? 'none' : '1px solid var(--c-line)',
          font: 'var(--t-label-lg)', cursor: 'pointer',
        }}>{o.label}</button>
      ))}
    </div>
  );
}

Object.assign(window, { EditProfileScreen });
