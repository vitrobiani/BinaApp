// SettingsScreens.jsx — Account, Accessibility, and Help & Support full pages.
// Source:
//   lib/pages/account_profile_creation/edit_profile_auth_2/edit_profile_auth2_widget.dart
//   lib/pages/accessibility_pages/theme_settings/theme_settings_widget.dart
//   lib/pages/accessibility_pages/text_settings/text_settings_widget.dart
//   lib/pages/accessibility_pages/language_settings/language_settings_widget.dart
//   lib/pages/accessibility_pages/help_support/help_support_widget.dart

// ═══════════════════════════════════════════════════════════════
// AccountScreen
// ═══════════════════════════════════════════════════════════════
function AccountScreen({ onBack, onEditPersonal, onChangePassword, onSignOut, onDeleteAccount, onOpenPrivacy, onExportData, language, dateFormat, onPickLanguage, onPickDateFormat }) {
  const langLabel = (LANGUAGES.find(l => l.id === language) || LANGUAGES[0]).label;
  const dateLabel = (DATE_FORMATS.find(d => d.id === dateFormat) || DATE_FORMATS[0]).label;
  return (
    <SettingsPage title="Account" onBack={onBack}>
      {/* Identity card */}
      <div style={{
        background: 'var(--c-surface)', borderRadius: 20,
        border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)',
        padding: 18, display: 'flex', alignItems: 'center', gap: 14,
      }}>
        <Avatar name="Sarah Levin" size={62} tone="blue" />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ font: 'var(--t-title-lg)', color: 'var(--c-ink)' }}>Sarah Levin</div>
          <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-2)', marginTop: 2 }}>sarah@levinfamily.com</div>
        </div>
        <button onClick={onEditPersonal} style={{
          padding: '8px 14px', background: 'var(--c-primary-100)', color: 'var(--c-primary-700)',
          border: 0, borderRadius: 999, font: 'var(--t-label-md)', cursor: 'pointer',
        }}>Edit</button>
      </div>

      <SettingsGroup title="Personal info">
        <SettingsRow icon={<IconUser size={20} />} label="Edit profile" tone="blue" onClick={onEditPersonal} />
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>}
          label="Email"
          right={<span style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)' }}>sarah@levinfamily.com</span>}
          tone="aqua"
        />
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>}
          label="Change password"
          tone="coral"
          onClick={onChangePassword}
          isLast
        />
      </SettingsGroup>

      <SettingsGroup title="Language & region">
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M2 12h20"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>}
          label="App language"
          right={<span style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)' }}>{langLabel}</span>}
          tone="aqua"
          onClick={onPickLanguage}
        />
        <SettingsRow
          icon={<IconCalendar size={20} />}
          label="Date format"
          right={<span style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)' }}>{dateLabel}</span>}
          tone="blue"
          onClick={onPickDateFormat}
          isLast
        />
      </SettingsGroup>

      <SettingsGroup title="Data & privacy">
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M9 12l2 2 4-4"/><path d="M21 12c0 4.97-4.03 9-9 9s-9-4.03-9-9 4.03-9 9-9 9 4.03 9 9z"/></svg>}
          label="Privacy policy" tone="blue" onClick={onOpenPrivacy}
        />
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>}
          label="Export my data" tone="aqua" onClick={onExportData}
        />
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>}
          label="Delete account" tone="cavity" onClick={onDeleteAccount} isLast
        />
      </SettingsGroup>

      <div style={{ marginTop: 20 }}>
        <button onClick={onSignOut} style={{
          width: '100%', height: 48, borderRadius: 999,
          background: 'transparent', color: 'var(--c-error)',
          border: '1px solid var(--c-line)', font: 'var(--t-label-lg)', cursor: 'pointer',
        }}>Sign out</button>
      </div>
    </SettingsPage>
  );
}

// ═══════════════════════════════════════════════════════════════
// AccessibilityScreen — incl. Hint mode toggle
// ═══════════════════════════════════════════════════════════════
function AccessibilityScreen({ onBack, theme, setTheme, hintMode, setHintMode, textSize, setTextSize, contrast, setContrast }) {
  const TEXT_SIZES = [
    { id: 'small',  label: 'Small',       scale: 0.88 },
    { id: 'medium', label: 'Medium',      scale: 1.0  },
    { id: 'large',  label: 'Large',       scale: 1.15 },
    { id: 'xl',     label: 'Extra large', scale: 1.32 },
  ];
  const currentTextSize = TEXT_SIZES.find(t => t.id === textSize) || TEXT_SIZES[1];

  return (
    <SettingsPage title="Accessibility" onBack={onBack}>
      {/* Theme */}
      <SettingsGroup title="Appearance">
        <div style={{ padding: '14px 14px 8px' }}>
          <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)', padding: '0 2px 10px' }}>Theme</div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 8 }}>
            <BigThemeSwatch label="Light" id="light" active={theme === 'light'} onClick={() => setTheme('light')} grad="linear-gradient(135deg, #fbfaf6, #1f5bff)" />
            <BigThemeSwatch label="Dark"  id="dark"  active={theme === 'dark'}  onClick={() => setTheme('dark')}  grad="linear-gradient(135deg, #0c0f1a, #5b8bff)" />
            <BigThemeSwatch label="Warm"  id="warm"  active={theme === 'warm'}  onClick={() => setTheme('warm')}  grad="linear-gradient(135deg, #fff8e1, #ef8b1a)" />
            <BigThemeSwatch label="Cool"  id="cool"  active={theme === 'cool'}  onClick={() => setTheme('cool')}  grad="linear-gradient(135deg, #e3f2fd, #0099b3)" />
            <BigThemeSwatch label="A11y"  id="deuteranopia" active={theme === 'deuteranopia'} onClick={() => setTheme('deuteranopia')} grad="linear-gradient(135deg, #ffffff, #0077bb)" />
          </div>
        </div>
        <div style={{ padding: '0 14px 16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
            <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)' }}>Contrast</div>
            <span style={{
              padding: '3px 9px', background: 'var(--c-surface-sunken)',
              color: 'var(--c-ink-2)', borderRadius: 999, font: 'var(--t-label-sm)',
            }}>{contrast === 1 ? 'Default' : contrast > 1 ? `+${Math.round((contrast - 1) * 100)}%` : `-${Math.round((1 - contrast) * 100)}%`}</span>
          </div>
          <input
            type="range" min={0.7} max={1.4} step={0.05}
            value={contrast} onChange={(e) => setContrast(parseFloat(e.target.value))}
            style={{ width: '100%', accentColor: 'var(--c-primary)' }}
          />
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 2, font: 'var(--t-label-sm)', color: 'var(--c-ink-3)' }}>
            <span>Softer</span><span>Stronger</span>
          </div>
        </div>
      </SettingsGroup>

      {/* Text size */}
      <SettingsGroup title="Reading">
        <div style={{ padding: 14 }}>
          <div style={{ font: 'var(--t-label-md)', color: 'var(--c-ink-2)', padding: '0 2px 10px' }}>Text size</div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6 }}>
            {TEXT_SIZES.map((t, i) => (
              <button key={t.id} onClick={() => setTextSize(t.id)} style={{
                background: textSize === t.id ? 'var(--c-primary)' : 'var(--c-surface)',
                color: textSize === t.id ? '#fff' : 'var(--c-ink)',
                border: textSize === t.id ? '1px solid var(--c-primary)' : '1px solid var(--c-line)',
                borderRadius: 12,
                padding: '12px 4px',
                font: 'var(--t-label-md)',
                cursor: 'pointer',
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
              }}>
                <span style={{ fontSize: 11 + i * 3 }}>A</span>
                <span style={{ font: 'var(--t-label-sm)' }}>{t.label}</span>
              </button>
            ))}
          </div>
          <div style={{
            marginTop: 14, padding: 12, background: 'var(--c-surface-alt)',
            borderRadius: 10, font: `400 ${14 * currentTextSize.scale}px/1.5 Inter`, color: 'var(--c-ink-2)',
          }}>
            Preview · Hello Sarah! Maya's scan from this morning needs attention.
          </div>
        </div>
      </SettingsGroup>

      {/* Hints */}
      <SettingsGroup title="Guidance">
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M12 17h.01"/><path d="M9.1 9a3 3 0 1 1 5.8 1c0 2-3 3-3 3"/><circle cx="12" cy="12" r="10"/></svg>}
          label="Hint mode"
          subtitle="Show small tooltips on key buttons"
          right={<Toggle on={hintMode} onClick={() => setHintMode(!hintMode)} />}
          tone="coral"
          isLast
        />
      </SettingsGroup>

      {/* Motion */}
      <SettingsGroup title="Motion & sensory">
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2v8M5 12H2M22 12h-3M16.95 7.05l-2.12 2.12M9.17 14.83l-2.12 2.12M16.95 16.95l-2.12-2.12M9.17 9.17 7.05 7.05"/><circle cx="12" cy="12" r="2"/></svg>}
          label="Reduce motion"
          subtitle="Disable transitions and parallax"
          right={<Toggle />}
          tone="aqua"
        />
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M3 18v-6a9 9 0 0 1 18 0v6"/><path d="M21 19a2 2 0 0 1-2 2h-1v-7h3zM3 19a2 2 0 0 0 2 2h1v-7H3z"/></svg>}
          label="Haptic feedback"
          right={<Toggle on />}
          tone="coral" isLast
        />
      </SettingsGroup>
    </SettingsPage>
  );
}

// ═══════════════════════════════════════════════════════════════
// HelpSupportScreen
// ═══════════════════════════════════════════════════════════════
function HelpSupportScreen({ onBack }) {
  const faqs = [
    { q: "How do I start a dental scan?", a: "Tap the camera tab at the bottom of any screen, choose who you're scanning, connect a camera, and capture each tooth in the frame." },
    { q: "How accurate are the results?", a: "Bina's on-device AI gives preliminary assessments — for diagnosis, always confirm with your dentist." },
    { q: "Can multiple family members share one account?", a: "Yes! Add each member from the Family tab. Each has their own scan history and chat." },
    { q: "Is my data private?", a: "Scans run entirely on your device — they never leave the phone unless you explicitly share them." },
  ];
  const [openFaq, setOpenFaq] = React.useState(0);

  return (
    <SettingsPage title="Help & support" onBack={onBack}>
      <SettingsGroup title="Contact">
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>}
          label="Email support"
          subtitle="support@bina-system.com"
          tone="blue"
        />
        <SettingsRow
          icon={<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>}
          label="Phone support"
          subtitle="+972 50 123 4567"
          tone="aqua"
          isLast
        />
      </SettingsGroup>

      <SettingsGroup title="FAQ">
        <div style={{ padding: 0 }}>
          {faqs.map((f, i) => (
            <FaqItem key={i} q={f.q} a={f.a} open={openFaq === i} onToggle={() => setOpenFaq(openFaq === i ? -1 : i)} isLast={i === faqs.length - 1} />
          ))}
        </div>
      </SettingsGroup>

      <SettingsGroup title="Send feedback">
        <div style={{ padding: 14, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <textarea
            placeholder="Tell us what you think…"
            rows={4}
            style={{
              width: '100%', border: '1px solid var(--c-line-strong)',
              background: 'var(--c-surface)', borderRadius: 12,
              padding: 12, font: 'var(--t-body-md)', color: 'var(--c-ink)',
              fontFamily: 'Inter, system-ui, sans-serif', resize: 'vertical', outline: 'none',
              boxSizing: 'border-box',
            }}
          />
          <BinaButton variant="primary" fullWidth>Submit feedback</BinaButton>
        </div>
      </SettingsGroup>
    </SettingsPage>
  );
}

// ═══════════════════════════════════════════════════════════════
// Shared settings page chrome + atoms
// ═══════════════════════════════════════════════════════════════
function SettingsPage({ title, onBack, children }) {
  return (
    <div style={{ paddingTop: 54, paddingBottom: 110, background: 'var(--c-surface-alt)', minHeight: '100%' }}>
      <div style={{ padding: '12px 16px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={{
          width: 44, height: 44, borderRadius: '50%', background: 'var(--c-surface)',
          border: '1px solid var(--c-line)', boxShadow: 'var(--sh-1)', cursor: 'pointer',
          display: 'grid', placeItems: 'center', color: 'var(--c-ink)', padding: 0,
        }}><IconChevronLeft size={22} /></button>
        <div style={{ font: 'var(--t-title-md)', color: 'var(--c-ink)' }}>{title}</div>
        <div style={{ width: 44 }} />
      </div>
      <div style={{ padding: '16px 20px 0' }}>
        {children}
      </div>
    </div>
  );
}

function SettingsGroup({ title, children }) {
  return (
    <div style={{ marginTop: 20 }}>
      <div style={{ font: 'var(--t-overline)', color: 'var(--c-ink-3)', letterSpacing: '0.08em', textTransform: 'uppercase', padding: '0 4px 8px' }}>{title}</div>
      <div style={{
        background: 'var(--c-surface)', borderRadius: 18,
        border: '1px solid var(--c-line)', boxShadow: 'var(--sh-2)',
        overflow: 'hidden',
      }}>{children}</div>
    </div>
  );
}

function SettingsRow({ icon, label, subtitle, right, tone = 'blue', isLast, onClick }) {
  const tones = {
    blue:   { bg: 'var(--c-primary-100)', fg: 'var(--c-primary-700)' },
    coral:  { bg: 'var(--c-coral-100)',   fg: 'var(--c-coral-700)' },
    aqua:   { bg: 'var(--c-aqua-100)',    fg: 'var(--c-aqua-700)' },
    cavity: { bg: 'var(--c-error-100)',   fg: 'var(--c-dx-cavity)' },
  };
  const t = tones[tone] || tones.blue;
  return (
    <button onClick={onClick} style={{
      width: '100%',
      display: 'grid', gridTemplateColumns: '36px 1fr auto auto', gap: 12,
      alignItems: 'center', padding: '12px 14px',
      borderBottom: isLast ? 'none' : '1px solid var(--c-line)',
      background: 'transparent', border: 'none', cursor: onClick ? 'pointer' : 'default',
      textAlign: 'left',
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 10,
        background: t.bg, color: t.fg,
        display: 'grid', placeItems: 'center',
      }}>{icon}</div>
      <div style={{ minWidth: 0 }}>
        <div style={{ font: 'var(--t-body-lg)', color: 'var(--c-ink)' }}>{label}</div>
        {subtitle && <div style={{ font: 'var(--t-body-sm)', color: 'var(--c-ink-3)', marginTop: 2 }}>{subtitle}</div>}
      </div>
      <div>{right}</div>
      <IconChevronRight size={18} />
    </button>
  );
}

function FaqItem({ q, a, open, onToggle, isLast }) {
  return (
    <div style={{ borderBottom: isLast ? 'none' : '1px solid var(--c-line)' }}>
      <button onClick={onToggle} style={{
        width: '100%', padding: 14, background: 'transparent', border: 0, cursor: 'pointer',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12,
        textAlign: 'left',
      }}>
        <div style={{ font: 'var(--t-body-lg)', color: 'var(--c-ink)', fontWeight: 500 }}>{q}</div>
        <span style={{
          width: 28, height: 28, borderRadius: '50%',
          background: 'var(--c-surface-sunken)', color: 'var(--c-ink-2)',
          display: 'grid', placeItems: 'center', flexShrink: 0,
          transform: open ? 'rotate(180deg)' : 'rotate(0)',
          transition: 'transform 200ms',
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m6 9 6 6 6-6"/></svg>
        </span>
      </button>
      {open && (
        <div style={{ padding: '0 14px 14px', font: 'var(--t-body-md)', color: 'var(--c-ink-2)', lineHeight: 1.55 }}>{a}</div>
      )}
    </div>
  );
}

function BigThemeSwatch({ label, id, grad, active, onClick }) {
  return (
    <button onClick={onClick} style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
      cursor: 'pointer', background: 'transparent', border: 0, padding: 0,
    }}>
      <div style={{
        width: '100%', aspectRatio: 1, borderRadius: 14,
        background: grad,
        boxShadow: active ? '0 0 0 3px var(--c-primary)' : 'var(--sh-1)',
      }} />
      <div style={{ font: 'var(--t-label-sm)', color: active ? 'var(--c-primary)' : 'var(--c-ink-2)', fontWeight: active ? 600 : 500 }}>{label}</div>
    </button>
  );
}

Object.assign(window, { AccountScreen, AccessibilityScreen, HelpSupportScreen });
