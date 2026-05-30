// LoginScreen.jsx — refined login under new design system.
// Source: lib/pages/account_profile_creation/auth_2_login/auth2_login_widget.dart

function LoginScreen({ onLogin, onSignUp }) {
  const [mode, setMode] = React.useState('cloud');
  const [email, setEmail] = React.useState('sarah@levinfamily.com');
  const [password, setPassword] = React.useState('•••••••••');
  const [showPw, setShowPw] = React.useState(false);

  return (
    <div style={{
      position: 'absolute', inset: 0,
      background: 'var(--g-hero)',
      overflow: 'hidden', display: 'flex', flexDirection: 'column',
    }}>
      {/* Decorative orbs */}
      <div style={{
        position: 'absolute', top: '-15%', right: '-25%',
        width: 380, height: 380, borderRadius: '50%',
        background: 'rgba(255,255,255,0.10)', filter: 'blur(2px)',
      }} />
      <div style={{
        position: 'absolute', bottom: '20%', left: '-30%',
        width: 320, height: 320, borderRadius: '50%',
        background: 'rgba(255,255,255,0.06)', filter: 'blur(2px)',
      }} />

      {/* Top — logo + tagline */}
      <div style={{
        position: 'relative', zIndex: 1,
        flex: '0 0 auto', paddingTop: 110,
        display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14,
      }}>
        <div style={{
          width: 72, height: 72, borderRadius: 22,
          background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(20px)',
          display: 'grid', placeItems: 'center', color: '#fff',
          border: '1px solid rgba(255,255,255,0.25)',
        }}>
          <IconTooth size={42} />
        </div>
        <div style={{ font: 'var(--t-display-md)', color: '#fff', letterSpacing: '-0.01em' }}>Bina</div>
        <div style={{
          font: 'var(--t-body-lg)', color: 'rgba(255,255,255,0.85)',
          textAlign: 'center', maxWidth: 280, lineHeight: 1.4,
        }}>
          A caring dental scan,<br/>in the family pocket.
        </div>
      </div>

      {/* Bottom — sheet with form */}
      <div style={{ flex: 1 }} />
      <div style={{
        position: 'relative', zIndex: 1,
        background: 'var(--c-surface)',
        borderTopLeftRadius: 32, borderTopRightRadius: 32,
        padding: '28px 22px 36px',
        boxShadow: '0 -8px 30px rgba(0,0,0,0.15)',
      }}>
        <div style={{ font: 'var(--t-headline-md)', color: 'var(--c-ink)', letterSpacing: '-0.005em' }}>Welcome back</div>
        <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', marginTop: 4 }}>
          Sign in to continue your scan history.
        </div>

        {/* Mode switch */}
        <div style={{ marginTop: 18 }}>
          <AuthModeSwitch mode={mode} setMode={setMode} />
        </div>

        <div style={{ marginTop: 18, display: 'flex', flexDirection: 'column', gap: 14 }}>
          {mode === 'cloud' ? (
            <>
              <FieldGroup label="Email">
                <div style={inputWithIcon}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round" style={{ color: 'var(--c-ink-3)' }}><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                  <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} style={loginInputStyle} />
                </div>
              </FieldGroup>
              <FieldGroup label="Password" trailingAction="Forgot?">
                <div style={inputWithIcon}>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round" style={{ color: 'var(--c-ink-3)' }}><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                  <input type={showPw ? 'text' : 'password'} value={password} onChange={(e) => setPassword(e.target.value)} style={loginInputStyle} />
                  <button onClick={() => setShowPw(!showPw)} style={{
                    position: 'absolute', right: 14, top: '50%', transform: 'translateY(-50%)',
                    background: 'transparent', border: 0, cursor: 'pointer', color: 'var(--c-ink-3)',
                    padding: 4,
                  }}>
                    {showPw ? (
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
                    ) : (
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                    )}
                  </button>
                </div>
              </FieldGroup>
            </>
          ) : (
            <div style={{
              padding: 14, background: 'var(--c-surface-alt)',
              borderRadius: 12, font: 'var(--t-body-md)', color: 'var(--c-ink-2)',
              lineHeight: 1.5,
            }}>
              No account needed for on-device mode. Tap below to start — your scans never leave this phone.
            </div>
          )}
        </div>

        <div style={{ marginTop: 20 }}>
          <BinaButton variant="primary" fullWidth onClick={onLogin}
            icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>}>
            {mode === 'cloud' ? 'Sign in' : 'Continue on this device'}
          </BinaButton>
        </div>

        {mode === 'cloud' && (
          <>
            {/* Divider */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '20px 0 14px' }}>
              <div style={{ flex: 1, height: 1, background: 'var(--c-line)' }} />
              <span style={{ font: 'var(--t-label-sm)', color: 'var(--c-ink-3)' }}>OR</span>
              <div style={{ flex: 1, height: 1, background: 'var(--c-line)' }} />
            </div>

            {/* Social */}
            <div style={{ display: 'flex', gap: 8 }}>
              <SocialButton label="Apple" />
              <SocialButton label="Google" />
            </div>
          </>
        )}

        <div style={{ marginTop: 20, textAlign: 'center', font: 'var(--t-body-md)', color: 'var(--c-ink-2)' }}>
          New to Bina? <button onClick={onSignUp} style={{ background: 'transparent', border: 0, color: 'var(--c-primary)', fontWeight: 600, cursor: 'pointer', padding: 0, font: 'inherit' }}>Create an account</button>
        </div>
      </div>
    </div>
  );
}

function FieldGroup({ label, trailingAction, children }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0 4px' }}>
        <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>{label}</div>
        {trailingAction && <button style={{ background: 'transparent', border: 0, color: 'var(--c-primary)', font: 'var(--t-label-sm)', fontWeight: 600, cursor: 'pointer', padding: 0 }}>{trailingAction}</button>}
      </div>
      {children}
    </div>
  );
}

const inputWithIcon = {
  display: 'grid',
  gridTemplateColumns: '38px 1fr',
  alignItems: 'center',
  height: 50,
  background: 'var(--c-surface)',
  border: '1px solid var(--c-line-strong)',
  borderRadius: 12,
  paddingLeft: 14,
  position: 'relative',
};

const loginInputStyle = {
  height: 48,
  border: 0,
  background: 'transparent',
  outline: 'none',
  font: 'var(--t-body-lg)',
  color: 'var(--c-ink)',
  width: '100%',
  paddingRight: 40,
  fontFamily: 'Inter, system-ui, sans-serif',
};

function SocialButton({ label }) {
  return (
    <button style={{
      flex: 1, height: 48, borderRadius: 12,
      background: 'var(--c-surface)', border: '1px solid var(--c-line-strong)',
      cursor: 'pointer', font: 'var(--t-label-lg)', color: 'var(--c-ink)',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
    }}>
      {label}
    </button>
  );
}

Object.assign(window, { LoginScreen });
