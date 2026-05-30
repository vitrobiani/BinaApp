// AuthScreens.jsx — Sign up flow + in-app change password.
// Source: lib/pages/account_profile_creation/auth_2_create/auth2_create_widget.dart
//
// Note: the source has a Cloud/Local Switch.adaptive that doesn't render well.
// Replaced with the new AuthModeSwitch component.

// ═══════════════════════════════════════════════════════════════
// SignUpScreen
// ═══════════════════════════════════════════════════════════════
function SignUpScreen({ onSignUp, onBackToLogin }) {
  const [mode, setMode] = React.useState('cloud');
  const [name, setName] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [confirmPw, setConfirmPw] = React.useState('');
  const [birthday, setBirthday] = React.useState('');
  const [showPw, setShowPw] = React.useState(false);
  const [agreed, setAgreed] = React.useState(false);

  // Password strength (very simple — length + variety)
  const strength = (() => {
    let s = 0;
    if (password.length >= 8) s++;
    if (/[A-Z]/.test(password) && /[a-z]/.test(password)) s++;
    if (/[0-9]/.test(password)) s++;
    if (/[^A-Za-z0-9]/.test(password)) s++;
    return s; // 0..4
  })();
  const strengthLabel = ['', 'Weak', 'Fair', 'Good', 'Strong'][strength];
  const strengthColor = ['var(--c-line-strong)', 'var(--c-error)', 'var(--c-warning)', 'var(--c-info)', 'var(--c-success)'][strength];

  const canSubmit =
    name.trim().length >= 2 &&
    /^\S+@\S+\.\S+$/.test(email) &&
    password.length >= 8 &&
    password === confirmPw &&
    birthday.length > 0 &&
    agreed;

  return (
    <div style={{ paddingTop: 54, paddingBottom: 30, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      {/* Header */}
      <div style={{ padding: '12px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBackToLogin} style={{
          width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
          display: 'grid', placeItems: 'center', color: 'var(--c-ink)', padding: 0,
        }}><IconChevronLeft size={22} /></button>
        <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>1 of 1</div>
        <div style={{ width: 44 }} />
      </div>

      {/* Title */}
      <div style={{ padding: '16px 24px 0' }}>
        <h1 style={{ font: 'var(--t-display-sm)', color: 'var(--c-ink)', margin: 0, letterSpacing: '-0.01em' }}>
          Get started
        </h1>
        <p style={{ font: 'var(--t-body-lg)', color: 'var(--c-ink-2)', margin: '6px 0 0', lineHeight: 1.5 }}>
          Create a Bina account. Takes about 30 seconds.
        </p>
      </div>

      {/* Mode switch */}
      <div style={{ padding: '20px 22px 0' }}>
        <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)', padding: '0 4px 8px' }}>
          Storage
        </div>
        <AuthModeSwitch mode={mode} setMode={setMode} />
      </div>

      {/* Form */}
      <div style={{ padding: '20px 22px 0', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <SignUpField label="Full name">
          <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Sarah Levin" style={authInputStyle} />
        </SignUpField>

        {mode === 'cloud' && (
          <SignUpField label="Email" hint="Used to sign in and recover your account.">
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="sarah@example.com" style={authInputStyle} />
          </SignUpField>
        )}

        <SignUpField label="Date of birth">
          <input type="text" value={birthday} onChange={(e) => setBirthday(e.target.value)} placeholder="DD/MM/YYYY" style={authInputStyle} />
        </SignUpField>

        {mode === 'cloud' && (
          <>
            <SignUpField label="Password">
              <div style={{ position: 'relative' }}>
                <input
                  type={showPw ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="At least 8 characters"
                  style={{ ...authInputStyle, paddingRight: 44 }}
                />
                <button onClick={() => setShowPw(!showPw)} style={pwToggleStyle} aria-label="Toggle password visibility">
                  {showPw ? (
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                  ) : (
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  )}
                </button>
              </div>
              {password.length > 0 && (
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 8 }}>
                  <div style={{ flex: 1, height: 4, borderRadius: 999, background: 'var(--c-line)' }}>
                    <div style={{
                      width: `${(strength / 4) * 100}%`, height: '100%', background: strengthColor,
                      borderRadius: 999, transition: 'width 200ms, background 200ms',
                    }} />
                  </div>
                  <div style={{ font: 'var(--t-label-sm)', color: strengthColor, fontWeight: 600, width: 50, textAlign: 'right' }}>
                    {strengthLabel}
                  </div>
                </div>
              )}
            </SignUpField>

            <SignUpField label="Confirm password">
              <input
                type={showPw ? 'text' : 'password'}
                value={confirmPw}
                onChange={(e) => setConfirmPw(e.target.value)}
                placeholder="Re-enter password"
                style={authInputStyle}
              />
              {confirmPw.length > 0 && confirmPw !== password && (
                <div style={{ font: 'var(--t-label-sm)', color: 'var(--c-error)', marginTop: 4, padding: '0 4px' }}>
                  Passwords don't match.
                </div>
              )}
            </SignUpField>
          </>
        )}

        {/* Terms */}
        <label style={{
          display: 'grid', gridTemplateColumns: '20px 1fr', gap: 10, alignItems: 'flex-start',
          padding: '6px 4px', cursor: 'pointer',
        }}>
          <input type="checkbox" checked={agreed} onChange={(e) => setAgreed(e.target.checked)}
            style={{ width: 18, height: 18, marginTop: 2, accentColor: 'var(--c-primary)' }} />
          <span style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', lineHeight: 1.5 }}>
            I agree to Bina's <span style={{ color: 'var(--c-primary)', fontWeight: 500 }}>Terms of Service</span> and{' '}
            <span style={{ color: 'var(--c-primary)', fontWeight: 500 }}>Privacy Policy</span>.
          </span>
        </label>
      </div>

      {/* Submit */}
      <div style={{ padding: '20px 22px 0' }}>
        <BinaButton
          variant={canSubmit ? 'primary' : 'ghost'}
          fullWidth
          onClick={canSubmit ? () => onSignUp({ name, email, birthday, mode }) : undefined}
          icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>}
        >
          Create account
        </BinaButton>
      </div>

      {/* Footer */}
      <div style={{
        padding: '20px 24px 0', textAlign: 'center',
        font: 'var(--t-body-md)', color: 'var(--c-ink-2)',
      }}>
        Already have an account?{' '}
        <button onClick={onBackToLogin} style={{
          background: 'transparent', border: 0, color: 'var(--c-primary)', fontWeight: 600,
          cursor: 'pointer', padding: 0, font: 'inherit',
        }}>Sign in</button>
      </div>
    </div>
  );
}

function SignUpField({ label, hint, children }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)', padding: '0 4px' }}>{label}</div>
      {children}
      {hint && <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', padding: '0 4px' }}>{hint}</div>}
    </div>
  );
}

const authInputStyle = {
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

const pwToggleStyle = {
  position: 'absolute',
  right: 12, top: '50%', transform: 'translateY(-50%)',
  background: 'transparent', border: 0, cursor: 'pointer',
  color: 'var(--c-ink-3)', padding: 4,
};

// ═══════════════════════════════════════════════════════════════
// ChangePasswordScreen — in-app, no email
// ═══════════════════════════════════════════════════════════════
function ChangePasswordScreen({ onBack, onChanged }) {
  const [current, setCurrent] = React.useState('');
  const [next, setNext] = React.useState('');
  const [confirm, setConfirm] = React.useState('');
  const [showCurrent, setShowCurrent] = React.useState(false);
  const [showNext, setShowNext] = React.useState(false);

  const strength = (() => {
    let s = 0;
    if (next.length >= 8) s++;
    if (/[A-Z]/.test(next) && /[a-z]/.test(next)) s++;
    if (/[0-9]/.test(next)) s++;
    if (/[^A-Za-z0-9]/.test(next)) s++;
    return s;
  })();
  const strengthLabel = ['', 'Weak', 'Fair', 'Good', 'Strong'][strength];
  const strengthColor = ['var(--c-line-strong)', 'var(--c-error)', 'var(--c-warning)', 'var(--c-info)', 'var(--c-success)'][strength];

  const checks = [
    { id: 'len', label: 'At least 8 characters', pass: next.length >= 8 },
    { id: 'mix', label: 'Mix of upper- and lower-case', pass: /[A-Z]/.test(next) && /[a-z]/.test(next) },
    { id: 'num', label: 'At least one number', pass: /[0-9]/.test(next) },
    { id: 'sym', label: 'At least one symbol', pass: /[^A-Za-z0-9]/.test(next) },
    { id: 'new', label: "Different from current", pass: next.length > 0 && next !== current },
  ];

  const canSubmit =
    current.length >= 1 &&
    next.length >= 8 &&
    next === confirm &&
    next !== current;

  return (
    <SettingsPage title="Change password" onBack={onBack}>
      <div style={{
        background: 'var(--c-primary-100)',
        borderRadius: 14, padding: 14,
        display: 'flex', alignItems: 'flex-start', gap: 12,
      }}>
        <div style={{
          width: 32, height: 32, borderRadius: 10,
          background: 'var(--c-surface)', color: 'var(--c-primary-700)',
          display: 'grid', placeItems: 'center', flexShrink: 0,
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
        </div>
        <div>
          <div style={{ font: 'var(--t-title-sm)', color: 'var(--c-ink)' }}>Quick & secure</div>
          <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', marginTop: 2, lineHeight: 1.45 }}>
            Enter your current password to confirm it's you, then choose a new one.
          </div>
        </div>
      </div>

      <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', gap: 14 }}>
        <SignUpField label="Current password">
          <div style={{ position: 'relative' }}>
            <input
              type={showCurrent ? 'text' : 'password'}
              value={current}
              onChange={(e) => setCurrent(e.target.value)}
              style={{ ...authInputStyle, paddingRight: 44 }}
              placeholder="Enter current password"
            />
            <button onClick={() => setShowCurrent(!showCurrent)} style={pwToggleStyle} aria-label="Toggle">
              {showCurrent ? (
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
              ) : (
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
              )}
            </button>
          </div>
        </SignUpField>

        <SignUpField label="New password">
          <div style={{ position: 'relative' }}>
            <input
              type={showNext ? 'text' : 'password'}
              value={next}
              onChange={(e) => setNext(e.target.value)}
              style={{ ...authInputStyle, paddingRight: 44 }}
              placeholder="Choose a strong password"
            />
            <button onClick={() => setShowNext(!showNext)} style={pwToggleStyle} aria-label="Toggle">
              {showNext ? (
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
              ) : (
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
              )}
            </button>
          </div>
          {next.length > 0 && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 8 }}>
              <div style={{ flex: 1, height: 4, borderRadius: 999, background: 'var(--c-line)' }}>
                <div style={{
                  width: `${(strength / 4) * 100}%`, height: '100%', background: strengthColor,
                  borderRadius: 999, transition: 'width 200ms, background 200ms',
                }} />
              </div>
              <div style={{ font: 'var(--t-label-sm)', color: strengthColor, fontWeight: 600, width: 50, textAlign: 'right' }}>
                {strengthLabel}
              </div>
            </div>
          )}
        </SignUpField>

        <SignUpField label="Confirm new password">
          <input
            type={showNext ? 'text' : 'password'}
            value={confirm}
            onChange={(e) => setConfirm(e.target.value)}
            style={authInputStyle}
            placeholder="Re-enter new password"
          />
          {confirm.length > 0 && confirm !== next && (
            <div style={{ font: 'var(--t-label-sm)', color: 'var(--c-error)', marginTop: 4, padding: '0 4px' }}>
              Passwords don't match.
            </div>
          )}
        </SignUpField>

        {/* Live requirements checklist */}
        <div style={{
          background: 'var(--c-surface)', borderRadius: 14,
          border: '1px solid var(--c-line)', padding: 14,
          display: 'flex', flexDirection: 'column', gap: 8,
        }}>
          <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)', paddingBottom: 2 }}>
            Password requirements
          </div>
          {checks.map(c => (
            <div key={c.id} style={{ display: 'flex', alignItems: 'center', gap: 8, font: 'var(--t-body-sm)' }}>
              <div style={{
                width: 18, height: 18, borderRadius: '50%',
                background: c.pass ? 'var(--c-success)' : 'var(--c-surface-sunken)',
                color: '#fff', display: 'grid', placeItems: 'center',
                transition: 'background 200ms',
              }}>
                {c.pass && (
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
                )}
              </div>
              <span style={{ color: c.pass ? 'var(--c-ink)' : 'var(--c-ink-3)' }}>{c.label}</span>
            </div>
          ))}
        </div>
      </div>

      <div style={{ marginTop: 24 }}>
        <BinaButton
          variant={canSubmit ? 'primary' : 'ghost'}
          fullWidth
          onClick={canSubmit ? onChanged : undefined}
        >
          Update password
        </BinaButton>
      </div>
    </SettingsPage>
  );
}

Object.assign(window, { SignUpScreen, ChangePasswordScreen });
