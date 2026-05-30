// Responsive.jsx — adaptive shell for the Bina app.
// Provides: ViewportCtx + useViewport, BinaMark, SideRail, ResizableStage,
// ModalShell (overlay wrapper), and ResponsiveHost (the orchestrator).
//
// Breakpoints (driven by the APP CONTAINER width, not the browser window):
//   phone   : < 720   → bottom nav, single column (reuses the original screens)
//   tablet  : 720–1099 → icon side-rail, roomy centered column, 2-up where it fits
//   desktop : ≥ 1100  → labelled side-rail, master–detail + multi-column dashboard

const ViewportCtx = React.createContext({ w: 1180, bp: 'desktop' });
const useViewport = () => React.useContext(ViewportCtx);
const bpOf = (w) => (w < 720 ? 'phone' : w < 1100 ? 'tablet' : 'desktop');

// ───────── Brand mark — camera-with-tooth lens, on the hero gradient ─────────
function BinaMark({ size = 40, radius = 12 }) {
  return (
    <div style={{
      width: size, height: size, borderRadius: radius,
      background: 'var(--g-hero)', color: '#fff',
      display: 'grid', placeItems: 'center', boxShadow: 'var(--sh-hero)',
      flexShrink: 0,
    }}>
      <IconTooth size={Math.round(size * 0.56)} />
    </div>
  );
}

// ───────── Side rail (tablet = icons only, desktop = icons + labels) ─────────
function SideRail({ active, onNavigate, onScan, compact, theme, setTheme }) {
  const items = [
    { id: 'home',    label: 'Home',    icon: IconHome },
    { id: 'family',  label: 'Family',  icon: IconUsers },
    { id: 'chat',    label: 'Chat',    icon: IconChat },
    { id: 'profile', label: 'Profile', icon: IconUser },
  ];
  const THEME_DOTS = [
    { id: 'light', grad: 'linear-gradient(135deg, #fbfaf6, #1f5bff)' },
    { id: 'dark',  grad: 'linear-gradient(135deg, #0c0f1a, #5b8bff)' },
    { id: 'warm',  grad: 'linear-gradient(135deg, #fff8e1, #ef8b1a)' },
    { id: 'cool',  grad: 'linear-gradient(135deg, #e3f2fd, #0099b3)' },
    { id: 'deuteranopia', grad: 'linear-gradient(135deg, #ffffff, #0077bb)' },
  ];
  const width = compact ? 80 : 236;
  const navBtn = (it) => {
    const isActive = active === it.id;
    return (
      <button key={it.id} onClick={() => onNavigate(it.id)} title={it.label} style={{
        display: 'flex', alignItems: 'center', gap: 14,
        justifyContent: compact ? 'center' : 'flex-start',
        width: '100%', height: 48, padding: compact ? 0 : '0 14px',
        borderRadius: 14, border: 0, cursor: 'pointer',
        background: isActive ? 'var(--c-primary-100)' : 'transparent',
        color: isActive ? 'var(--c-primary-700)' : 'var(--c-ink-2)',
        font: 'var(--t-label-lg)', transition: 'background 160ms, color 160ms',
      }}>
        <it.icon size={22} />
        {!compact && <span>{it.label}</span>}
      </button>
    );
  };
  return (
    <nav style={{
      width, flexShrink: 0, height: '100%', boxSizing: 'border-box',
      background: 'var(--c-surface)', borderRight: '1px solid var(--c-line)',
      display: 'flex', flexDirection: 'column',
      padding: compact ? '20px 12px' : '24px 16px',
      gap: 4,
    }}>
      {/* brand */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 12,
        justifyContent: compact ? 'center' : 'flex-start',
        padding: compact ? '0 0 8px' : '0 6px 8px', marginBottom: 8,
      }}>
        <BinaMark size={compact ? 40 : 38} />
        {!compact && <div style={{ font: 'var(--t-headline-sm)', color: 'var(--c-ink)', letterSpacing: '-0.01em' }}>Bina</div>}
      </div>

      {items.slice(0, 2).map(navBtn)}

      {/* Scan — accent action */}
      <button onClick={onScan} title="Scan now" style={{
        display: 'flex', alignItems: 'center', gap: 12,
        justifyContent: 'center',
        width: '100%', height: 48, margin: '6px 0',
        borderRadius: 14, border: 0, cursor: 'pointer',
        background: 'var(--g-hero)', color: '#fff', boxShadow: 'var(--sh-hero)',
        font: 'var(--t-label-lg)',
      }}>
        <IconCamera size={22} />
        {!compact && <span>Scan now</span>}
      </button>

      {items.slice(2).map(navBtn)}

      <div style={{ flex: 1 }} />

      {/* Help (the README's 5th wide-screen nav item) */}
      <button onClick={() => onNavigate('help')} title="Help & support" style={{
        display: 'flex', alignItems: 'center', gap: 14,
        justifyContent: compact ? 'center' : 'flex-start',
        width: '100%', height: 44, padding: compact ? 0 : '0 14px',
        borderRadius: 14, border: 0, cursor: 'pointer',
        background: 'transparent', color: 'var(--c-ink-2)', font: 'var(--t-label-lg)',
      }}>
        <IconHelp size={21} />
        {!compact && <span>Help</span>}
      </button>

      {/* Theme dots */}
      <div style={{
        display: 'flex', flexWrap: 'wrap', gap: 8, justifyContent: 'center',
        marginTop: 10, paddingTop: 14, borderTop: '1px solid var(--c-line)',
      }}>
        {THEME_DOTS.map(t => (
          <button key={t.id} title={t.id} onClick={() => setTheme(t.id)} style={{
            width: compact ? 22 : 26, height: compact ? 22 : 26, borderRadius: 999,
            background: t.grad, cursor: 'pointer', padding: 0,
            border: theme === t.id ? '2px solid var(--c-ink)' : '2px solid transparent',
            boxShadow: theme === t.id ? '0 0 0 2px var(--c-primary-300)' : 'var(--sh-1)',
          }} />
        ))}
      </div>
    </nav>
  );
}

// ───────── Modal shell — wraps an overlay entry as a centered card on wide ─────────
function ModalShell({ children, onClose, z = 30, wide }) {
  if (!wide) {
    // phone: full-bleed sheet (matches the original behaviour)
    return (
      <div style={{
        position: 'absolute', inset: 0, zIndex: z,
        background: 'var(--c-surface-alt)',
        animation: 'binaSheetIn 240ms cubic-bezier(.2,.7,.2,1)', overflow: 'hidden',
      }}>
        <div style={{ width: '100%', height: '100%', overflowY: 'auto' }}>{children}</div>
      </div>
    );
  }
  // wide: centered modal card over a scrim
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, zIndex: z,
      background: 'rgba(12,21,48,0.5)',
      display: 'grid', placeItems: 'center', padding: 24,
      animation: 'binaScrimIn 180ms ease-out',
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        width: 440, maxWidth: '100%', maxHeight: '90%',
        background: 'var(--c-surface-alt)', borderRadius: 28, overflow: 'hidden',
        boxShadow: '0 40px 90px rgba(12,21,48,0.35)',
        border: '1px solid var(--c-line)',
        animation: 'binaModalIn 240ms cubic-bezier(.2,.7,.2,1)',
        display: 'flex', flexDirection: 'column',
      }}>
        <div style={{ overflowY: 'auto', minHeight: 0 }}>{children}</div>
      </div>
    </div>
  );
}

// ───────── Resizable stage — drag the right edge to test breakpoints ─────────
function ResizableStage({ children }) {
  const outerRef = React.useRef(null);
  const [maxW, setMaxW] = React.useState(1200);
  const [w, setW] = React.useState(1180);
  const [h, setH] = React.useState(840);
  const drag = React.useRef(null);

  React.useEffect(() => {
    const measure = () => {
      const ow = outerRef.current ? outerRef.current.clientWidth : 0;
      setH(Math.max(560, Math.min(880, window.innerHeight - 188)));
      // Ignore zero/garbage widths (layout-timing races, hidden mounts).
      // Only clamp w DOWN to the real container width once we actually know it,
      // and never ratchet to 0 — let it recover when the container grows.
      if (ow > 0) {
        setMaxW(ow);
        setW(prev => {
          const base = prev > 0 ? prev : Math.min(1180, ow);
          return Math.max(360, Math.min(base, ow));
        });
      }
    };
    measure();
    const ro = new ResizeObserver(measure);
    if (outerRef.current) ro.observe(outerRef.current);
    window.addEventListener('resize', measure);
    return () => { ro.disconnect(); window.removeEventListener('resize', measure); };
  }, []);

  const onDown = (e) => {
    drag.current = { x: e.clientX, w };
    e.target.setPointerCapture(e.pointerId);
  };
  const onMove = (e) => {
    if (!drag.current) return;
    const next = drag.current.w + (e.clientX - drag.current.x) * 2; // *2 = symmetric (centered)
    setW(Math.max(360, Math.min(maxW, next)));
  };
  const onUp = (e) => { drag.current = null; try { e.target.releasePointerCapture(e.pointerId); } catch (_) {} };

  const bp = bpOf(w);
  const bpLabel = { phone: 'Phone', tablet: 'Tablet', desktop: 'Desktop' }[bp];
  const presets = [
    { label: 'Phone', w: 390 },
    { label: 'Tablet', w: 834 },
    { label: 'Desktop', w: 1280 },
  ];

  return (
    <div ref={outerRef} style={{ width: '100%', display: 'flex', justifyContent: 'center' }}>
      <div style={{
        width: w, maxWidth: '100%', minWidth: 0, position: 'relative',
        transition: drag.current ? 'none' : 'width 220ms cubic-bezier(.2,.7,.2,1)',
      }}>
        {/* window chrome */}
        <div style={{
          borderRadius: 20, overflow: 'hidden',
          border: '1px solid var(--c-line)',
          boxShadow: '0 30px 70px rgba(12,21,48,0.16), 0 2px 0 rgba(255,255,255,0.6) inset',
          background: 'var(--c-surface)',
        }}>
          {/* title bar */}
          <div style={{
            height: 46, display: 'flex', alignItems: 'center', gap: 14,
            padding: '0 14px', background: 'var(--c-surface)',
            borderBottom: '1px solid var(--c-line)',
          }}>
            <div style={{ display: 'flex', gap: 7 }}>
              {['#ff5f57', '#febc2e', '#28c840'].map(c => (
                <span key={c} style={{ width: 11, height: 11, borderRadius: 999, background: c }} />
              ))}
            </div>
            <div style={{
              flex: 1, textAlign: 'center', font: '500 12px/1 var(--f-mono)',
              color: 'var(--c-ink-3)', letterSpacing: '0.02em',
            }}>
              bina.app — {Math.round(w)}px · {bpLabel}
            </div>
            <div style={{ display: 'flex', gap: 4 }}>
              {presets.map(p => (
                <button key={p.label} onClick={() => setW(Math.min(maxW || p.w, p.w))} style={{
                  border: '1px solid var(--c-line)', background: Math.abs(w - p.w) < 2 ? 'var(--c-primary-100)' : 'transparent',
                  color: Math.abs(w - p.w) < 2 ? 'var(--c-primary-700)' : 'var(--c-ink-3)',
                  borderRadius: 8, padding: '4px 9px', cursor: 'pointer',
                  font: '500 11px/1 var(--f-body)',
                }}>{p.label}</button>
              ))}
            </div>
          </div>
          {/* live app viewport */}
          <div style={{ height: h, position: 'relative', overflow: 'hidden', background: 'var(--c-surface-alt)' }}>
            <ViewportCtx.Provider value={{ w, bp }}>
              {children}
            </ViewportCtx.Provider>
          </div>
        </div>

        {/* drag handle (right edge) */}
        <div onPointerDown={onDown} onPointerMove={onMove} onPointerUp={onUp} title="Drag to resize" style={{
          position: 'absolute', top: 0, bottom: 0, right: -16, width: 32,
          cursor: 'ew-resize', display: 'flex', alignItems: 'center', justifyContent: 'center',
          touchAction: 'none',
        }}>
          <div style={{
            width: 6, height: 60, borderRadius: 999,
            background: 'var(--c-line-strong)', boxShadow: 'var(--sh-1)',
          }} />
        </div>
      </div>
    </div>
  );
}

// ───────── The responsive host (adapted from index.html's Host) ─────────
const R_TEXT_SCALES = { small: 0.88, medium: 1.0, large: 1.15, xl: 1.32 };

function ResponsiveHost({ family: seedFamily }) {
  const { bp } = useViewport();
  const wide = bp !== 'phone';
  const compact = bp === 'tablet';

  const [tab, setTab] = React.useState('home');
  const [stack, setStack] = React.useState([]);
  const [theme, setTheme] = React.useState('light');
  const [hintMode, setHintMode] = React.useState(false);
  const [textSize, setTextSize] = React.useState('medium');
  const [contrast, setContrast] = React.useState(1);
  const [language, setLanguage] = React.useState('en');
  const [dateFormat, setDateFormat] = React.useState('dmy_slash');
  const [family, setFamily] = React.useState(seedFamily);

  const push = (entry) => setStack(s => [...s, entry]);
  const pop  = () => setStack(s => s.slice(0, -1));
  const reset = () => setStack([]);
  const top = stack[stack.length - 1];

  const openMember = (m) => push({ kind: 'member', member: m });
  const addMember = (m) => {
    const id = Math.max(...family.map(f => f.id)) + 1;
    setFamily([...family, { id, ...m, lastChecked: null, lastResult: null, scanCount: 0 }]);
    pop();
  };
  const showDialog = (dialog) => push({ kind: 'dialog', dialog });
  const showSuccess = (title, body) => showDialog({ kind: 'success', title, body, confirmLabel: 'OK' });

  const navigate = (id) => {
    if (id === 'scan') { push({ kind: 'scan-target' }); return; }
    if (id === 'help') { push({ kind: 'help' }); return; }
    reset(); setTab(id);
  };

  const renderTab = () => {
    if (!wide) {
      switch (tab) {
        case 'home':    return <HomeScreen family={family} go={setTab} openMember={openMember} onAddMember={() => push({ kind: 'add-member' })} />;
        case 'family':  return <FamilyScreen family={family} openMember={openMember} onAddMember={() => push({ kind: 'add-member' })} />;
        case 'chat':    return <ChatHistoryScreen onOpenChat={(c) => push({ kind: 'chat', conversation: c })} />;
        case 'profile': return <ProfileScreen theme={theme} setTheme={setTheme} hintMode={hintMode}
          onOpenAccount={() => push({ kind: 'account' })} onOpenAccessibility={() => push({ kind: 'accessibility' })}
          onOpenHelp={() => push({ kind: 'help' })} onEditProfile={() => push({ kind: 'edit-profile' })}
          onOpenAbout={() => push({ kind: 'about' })} />;
        default: return null;
      }
    }
    // wide variants
    switch (tab) {
      case 'home':    return <HomeWide family={family} go={navigate} openMember={openMember} onAddMember={() => push({ kind: 'add-member' })} onScan={() => push({ kind: 'scan-target' })} />;
      case 'family':  return <FamilyWide family={family} onAddMember={() => push({ kind: 'add-member' })} onScanMember={(m) => push({ kind: 'scan-session', member: m })} />;
      case 'chat':    return <ChatWide />;
      case 'profile': return <ProfileWide theme={theme} setTheme={setTheme} hintMode={hintMode}
        onOpenAccount={() => push({ kind: 'account' })} onOpenAccessibility={() => push({ kind: 'accessibility' })}
        onOpenHelp={() => push({ kind: 'help' })} onEditProfile={() => push({ kind: 'edit-profile' })}
        onOpenAbout={() => push({ kind: 'about' })} />;
      default: return null;
    }
  };

  const deviceBg = theme === 'dark' ? '#0c0f1a' : 'var(--c-surface-alt)';
  const showBottomNav = !wide && (!top || !['scan-session'].includes(top.kind));
  const textScale = R_TEXT_SCALES[textSize] || 1.0;

  // overlay entry → element
  const overlayEl = (entry) => (
    <>
      {entry.kind === 'member' && <MemberDetailScreen member={entry.member} onBack={pop} onScan={() => push({ kind: 'scan-session', member: entry.member })} />}
      {entry.kind === 'scan-target' && <ScanTargetScreen family={family} onCancel={pop} onPick={(m) => setStack(s => [...s.slice(0, -1), { kind: 'scan-session', member: m }])} />}
      {entry.kind === 'scan-session' && <ScanSessionScreen member={entry.member} hintMode={hintMode} onBack={pop}
        onOpenCamera={(onConnected) => push({ kind: 'camera', target: entry.member, onConnected })}
        onFinish={() => { showSuccess('Session saved', `${entry.member?.name || 'Avi'}'s scan is filed into their history.`); setTimeout(() => { reset(); setTab('home'); }, 1200); }} />}
      {entry.kind === 'camera' && <CameraConnectionScreen target={entry.target} onBack={pop} onConnected={(src) => { entry.onConnected && entry.onConnected(src); pop(); }} />}
      {entry.kind === 'add-member' && <AddMemberSheet onClose={pop} onAdd={(m) => { addMember(m); showSuccess('Member added', `${m.name} is now in your family.`); }} />}
      {entry.kind === 'chat' && <ChatScreen conversation={entry.conversation} onBack={pop} />}
      {entry.kind === 'edit-profile' && <EditProfileScreen subject={{ id: 0, name: 'Sarah Levin', isMe: true, tone: 'blue' }} onCancel={pop} onSave={() => { pop(); showSuccess('Saved', 'Your profile has been updated.'); }} />}
      {entry.kind === 'account' && <AccountScreen onBack={pop} onEditPersonal={() => push({ kind: 'edit-profile' })} onChangePassword={() => push({ kind: 'change-password' })} onOpenPrivacy={() => push({ kind: 'privacy' })}
        language={language} dateFormat={dateFormat} onPickLanguage={() => push({ kind: 'language-picker' })} onPickDateFormat={() => push({ kind: 'date-format-picker' })}
        onExportData={() => showDialog({ kind: 'info', title: 'Export your data', body: "We'll prepare a ZIP of all your scans, family records, and chats. You'll get an email when it's ready.", confirmLabel: 'Start export', onConfirm: () => { pop(); showSuccess('Export started', "We'll email you within 10 minutes."); } })}
        onSignOut={() => showDialog({ kind: 'confirm', title: 'Sign out of Bina?', body: 'Your local data stays on this device, but you will need to sign in again to access cloud-synced scans.', confirmLabel: 'Sign out', onConfirm: () => { reset(); push({ kind: 'login' }); } })}
        onDeleteAccount={() => showDialog({ kind: 'alert', title: 'Delete account?', body: 'This permanently removes your Bina account, all family records, and every scan. This cannot be undone.', confirmLabel: 'Delete forever', destructive: true, onConfirm: () => { reset(); push({ kind: 'login' }); } })} />}
      {entry.kind === 'change-password' && <ChangePasswordScreen onBack={pop} onChanged={() => { pop(); showSuccess('Password updated', 'Your password has been changed successfully.'); }} />}
      {entry.kind === 'accessibility' && <AccessibilityScreen onBack={pop} theme={theme} setTheme={setTheme} hintMode={hintMode} setHintMode={setHintMode} textSize={textSize} setTextSize={setTextSize} contrast={contrast} setContrast={setContrast} />}
      {entry.kind === 'help' && <HelpSupportScreen onBack={pop} />}
      {entry.kind === 'about' && <AboutScreen onBack={pop} />}
      {entry.kind === 'privacy' && <PrivacyScreen onBack={pop} />}
      {entry.kind === 'language-picker' && <LanguagePickerSheet value={language} onClose={pop} onPick={setLanguage} />}
      {entry.kind === 'date-format-picker' && <DateFormatPickerSheet value={dateFormat} onClose={pop} onPick={setDateFormat} />}
      {entry.kind === 'login' && <LoginScreen onLogin={() => { reset(); setTab('home'); showSuccess('Welcome back', 'Signed in as sarah@levinfamily.com'); }} onSignUp={() => setStack(s => [...s.slice(0, -1), { kind: 'signup' }])} />}
      {entry.kind === 'signup' && <SignUpScreen onBackToLogin={() => setStack(s => [...s.slice(0, -1), { kind: 'login' }])} onSignUp={(profile) => { reset(); setTab('home'); showSuccess('Account created', `Welcome to Bina, ${profile.name.split(' ')[0]}!`); }} />}
      {entry.kind === 'dialog' && <Dialog kind={entry.dialog.kind} title={entry.dialog.title} body={entry.dialog.body} confirmLabel={entry.dialog.confirmLabel} cancelLabel={entry.dialog.cancelLabel} destructive={entry.dialog.destructive} onConfirm={entry.dialog.onConfirm ? () => { pop(); entry.dialog.onConfirm(); } : undefined} onClose={pop} />}
    </>
  );

  // dialogs always render as centered overlays (both phone + wide)
  const dialogKinds = ['dialog', 'language-picker', 'date-format-picker'];

  return (
    <div data-theme={theme} style={{
      position: 'relative', width: '100%', height: '100%', overflow: 'hidden',
      background: deviceBg, fontSize: `${textScale * 100}%`,
      filter: contrast !== 1 ? `contrast(${contrast})` : 'none',
      display: wide ? 'flex' : 'block',
      fontFamily: 'var(--f-body)',
    }}>
      <style>{`
        @keyframes binaSheetIn { from { transform: translateY(16px); opacity: 0 } to { transform: translateY(0); opacity: 1 } }
        @keyframes binaScrimIn { from { opacity: 0 } to { opacity: 1 } }
        @keyframes binaModalIn { from { transform: translateY(18px) scale(.98); opacity: 0 } to { transform: translateY(0) scale(1); opacity: 1 } }
      `}</style>

      {wide && <SideRail active={tab} onNavigate={navigate} onScan={() => push({ kind: 'scan-target' })} compact={compact} theme={theme} setTheme={setTheme} />}

      <div style={{ flex: 1, minWidth: 0, height: '100%', overflowY: 'auto', position: 'relative' }}>
        {renderTab()}
      </div>

      {showBottomNav && (
        <BottomNav active={tab} onChange={(id) => {
          if (id === 'scan') { push({ kind: 'scan-target' }); return; }
          reset(); setTab(id);
        }} />
      )}

      {/* overlay stack */}
      {stack.map((entry, i) => {
        const asDialog = dialogKinds.includes(entry.kind);
        if (asDialog) {
          // dialogs/pickers render their own scrim — render bare, full-bleed
          return <div key={i} style={{ position: 'absolute', inset: 0, zIndex: 40 + i, display: 'grid', placeItems: 'center' }}>{overlayEl(entry)}</div>;
        }
        return <ModalShell key={i} z={30 + i} wide={wide} onClose={pop}>{overlayEl(entry)}</ModalShell>;
      })}
    </div>
  );
}

Object.assign(window, { ViewportCtx, useViewport, bpOf, BinaMark, SideRail, ModalShell, ResizableStage, ResponsiveHost });
