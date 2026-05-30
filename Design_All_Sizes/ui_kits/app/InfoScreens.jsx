// InfoScreens.jsx — About Bina and Privacy Policy screens.
// Both intentionally generic — content for legal team / product to fill in.

function AboutScreen({ onBack }) {
  return (
    <SettingsPage title="About Bina" onBack={onBack}>
      {/* Hero */}
      <div style={{
        background: 'var(--g-hero)', borderRadius: 22, padding: 24,
        color: '#fff', boxShadow: 'var(--sh-hero)',
        textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12,
      }}>
        <div style={{
          width: 64, height: 64, borderRadius: 20,
          background: 'rgba(255,255,255,0.18)', display: 'grid', placeItems: 'center',
          border: '1px solid rgba(255,255,255,0.25)',
        }}>
          <IconTooth size={36} />
        </div>
        <div style={{ font: 'var(--t-display-sm)', color: '#fff', letterSpacing: '-0.01em' }}>Bina</div>
        <div style={{ font: 'var(--t-body-md)', color: 'rgba(255,255,255,0.88)', maxWidth: 260, lineHeight: 1.4 }}>
          On-device AI dental scanning for the whole family.
        </div>
        <span style={{
          background: 'rgba(255,255,255,0.18)', padding: '5px 12px', borderRadius: 999,
          font: 'var(--t-label-md)', marginTop: 2,
        }}>Version 1.0.0 · Build 42</span>
      </div>

      {/* Mission */}
      <div style={{ marginTop: 20 }}>
        <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px 8px' }}>
          Our mission
        </div>
        <Card padding={16}>
          <p style={{ font: 'var(--t-body-lg)', color: 'var(--c-ink)', margin: 0, lineHeight: 1.55 }}>
            We believe everyone deserves to understand what's happening in their mouth — without anxiety, without jargon, and without waiting six months for a check-up. Bina puts a calm, accurate, on-device AI in your pocket so you can catch problems early and treat them gently.
          </p>
        </Card>
      </div>

      {/* What's new */}
      <div style={{ marginTop: 20 }}>
        <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px 8px' }}>
          What's new in 1.0
        </div>
        <Card padding={0}>
          <ReleaseRow icon="✦" title="Refined visual system" body="Warmer surfaces, softer corners, and a new colored-glow hero card on the home dashboard." />
          <ReleaseRow icon="◎" title="Family-aware scan flow" body="Pick who you're scanning before you capture — every photo files itself into the right history." />
          <ReleaseRow icon="◔" title="Gemma-powered overviews" body="Tap any captured photo for a plain-English summary of what the AI found." isLast />
        </Card>
      </div>

      {/* Credits */}
      <div style={{ marginTop: 20 }}>
        <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px 8px' }}>
          Credits
        </div>
        <Card padding={0}>
          <CreditRow label="On-device AI" value="Gemma 3 1B · YOLO TFLite" />
          <CreditRow label="Backend" value="Supabase" />
          <CreditRow label="Made by" value="The Bina team" isLast />
        </Card>
      </div>

      {/* Links */}
      <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', gap: 10 }}>
        <BinaButton variant="ghost" fullWidth icon={<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>}>
          Open in browser
        </BinaButton>
        <div style={{
          font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', textAlign: 'center', padding: '12px 0',
        }}>
          © 2026 Bina System. All rights reserved.
        </div>
      </div>
    </SettingsPage>
  );
}

function ReleaseRow({ icon, title, body, isLast }) {
  return (
    <div style={{
      display: 'grid', gridTemplateColumns: '40px 1fr', gap: 12,
      padding: 14, alignItems: 'flex-start',
      borderBottom: isLast ? 'none' : '1px solid var(--c-line)',
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 12,
        background: 'var(--c-primary-100)', color: 'var(--c-primary-700)',
        display: 'grid', placeItems: 'center',
        font: '600 18px/1 Inter',
      }}>{icon}</div>
      <div>
        <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{title}</div>
        <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', marginTop: 3, lineHeight: 1.45 }}>{body}</div>
      </div>
    </div>
  );
}

function CreditRow({ label, value, isLast }) {
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '14px', borderBottom: isLast ? 'none' : '1px solid var(--c-line)',
    }}>
      <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>{label}</div>
      <div style={{ font: 'var(--t-body-md)', color: 'var(--c-ink)', fontWeight: 500 }}>{value}</div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// PrivacyScreen
// ═══════════════════════════════════════════════════════════════
function PrivacyScreen({ onBack }) {
  return (
    <SettingsPage title="Privacy policy" onBack={onBack}>
      {/* Summary card */}
      <Card padding={16}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 10 }}>
          <div style={{
            width: 40, height: 40, borderRadius: 12,
            background: 'var(--c-success-100)', color: 'var(--c-success)',
            display: 'grid', placeItems: 'center',
          }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
          </div>
          <div>
            <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>Your scans stay on your device.</div>
            <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)' }}>Last updated · 18 May 2026</div>
          </div>
        </div>
        <p style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', margin: 0, lineHeight: 1.55 }}>
          We've designed Bina so that the AI runs entirely on your phone. Scanned photos and diagnosis results don't leave your device unless you explicitly choose to share or back them up.
        </p>
      </Card>

      <PolicySection title="1. Information we collect" body="When you create an account, we collect your email address and a chosen display name. When you add family members, we store their names, ages, and avatar preferences on your device. Scan photos and AI results are stored locally; we never see them." />

      <PolicySection title="2. How we use it" body="Account information is used solely to let you sign in and recover access. Family data and scans are used to power the app's features — tracking history, generating reminders, providing AI overviews. We do not sell, rent, or share your data with advertisers." />

      <PolicySection title="3. On-device AI" body="The diagnosis model (Gemma 3 + YOLO) runs entirely on your phone. No photo is uploaded for inference. The model is downloaded once during onboarding and runs offline thereafter." />

      <PolicySection title="4. Optional cloud backup" body="If you turn on cloud backup, your scan history and family data are encrypted on your device, then synced to our Supabase storage so you can restore on a new phone. We hold the encrypted blob; we cannot decrypt it without your password." />

      <PolicySection title="5. Your rights" body="You can export all your data at any time from Account → Export my data. You can delete your account permanently from Account → Delete account. Deletion is irreversible and removes all family records." />

      <PolicySection title="6. Children's privacy" body="Bina is intended for adults to manage their family's dental health. When you add a child as a family member, you are acting as the data controller for that child. Bina never communicates directly with children's accounts." />

      <PolicySection title="7. Contact" body="Questions? Email privacy@bina-system.com." isLast />

      <div style={{ marginTop: 16, font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', textAlign: 'center', padding: '12px 0 4px' }}>
        This is a placeholder policy. The published version is governed by our legal team.
      </div>
    </SettingsPage>
  );
}

function PolicySection({ title, body, isLast }) {
  return (
    <div style={{ marginTop: 20 }}>
      <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)', padding: '0 4px 6px' }}>{title}</div>
      <Card padding={16}>
        <p style={{ font: 'var(--t-body-md)', color: 'var(--c-ink-2)', margin: 0, lineHeight: 1.55 }}>{body}</p>
      </Card>
    </div>
  );
}

Object.assign(window, { AboutScreen, PrivacyScreen });
