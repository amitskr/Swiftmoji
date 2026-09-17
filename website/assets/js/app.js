// Swiftmoji Interactive Website Logic
document.addEventListener('DOMContentLoaded', () => {
  initScreenshotTabs();
  initLightbox();
  initSimulator();
  initClipboard();
});

// 1. Screenshot Showcase Tabs
function initScreenshotTabs() {
  const tabs = document.querySelectorAll('.screenshot-tab');
  const screenshotImg = document.getElementById('active-screenshot-img');
  const screenshotTitle = document.getElementById('screenshot-title');
  const screenshotDesc = document.getElementById('screenshot-desc');
  const screenshotBadges = document.getElementById('screenshot-badges');

  const screenshotData = {
    hud: {
      src: 'assets/images/hud_autocomplete.jpg',
      alt: 'Swiftmoji Floating HUD Autocomplete Panel',
      title: 'Glassmorphic Floating Caret HUD',
      desc: 'Monitors keystroke events globally and floats right at your text cursor. Configured as an NSPanel at .statusBar level so it never steals keyboard focus from your active document or editor.',
      badges: ['Non-Activating NSPanel', 'Zero Latency', 'Caret Tracking', 'Mouse & Keyboard Nav']
    },
    browser: {
      src: 'assets/images/emoji_browser.png',
      alt: 'Swiftmoji 3-Column Split View Browser',
      title: '3-Column Split-View Browser',
      desc: 'A comprehensive explorer for Emojis, trending GIFs, ASCII emoticons, and special typography glyphs. Can be bound to replace the macOS default Ctrl+Cmd+Space shortcut globally.',
      badges: ['Emojis & GIFs', 'ASCII Emoticons', 'Symbol & Glyphs', 'Ctrl+Cmd+Space Intercept']
    },
    snippets: {
      src: 'assets/images/snippets_browser.png',
      alt: 'Swiftmoji Custom Snippets & Templates',
      title: 'Custom Shortcodes & Snippet Library',
      desc: 'Map any personalized keyword (e.g. :shrug: or :signature:) to complex boilerplate text, email signatures, or multi-character ASCII expressions with instant in-place backspace expansion.',
      badges: ['Text Expansion', 'Custom Trigger Mapping', 'Instant Replacement', 'Rich Snippets']
    },
    preferences: {
      src: 'assets/images/preferences.png',
      alt: 'Swiftmoji Preferences Panel',
      title: 'Aesthetic Preferences & Modifiers',
      desc: 'Personalize activation behaviors, toggle double-tap trigger keys (e.g. \\\\ or ::), pick default Fitzpatrick skin tones, customize audio feedback, and manage login startup items.',
      badges: ['Fitzpatrick Skin Tones', 'Double-Key Trigger', 'Sound Effects', 'Launch at Login']
    }
  };

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => {
        t.classList.remove('bg-purple-600/20', 'border-purple-500/50', 'text-white');
        t.classList.add('text-slate-400', 'border-white/5');
      });

      tab.classList.remove('text-slate-400', 'border-white/5');
      tab.classList.add('bg-purple-600/20', 'border-purple-500/50', 'text-white');

      const key = tab.getAttribute('data-tab');
      const data = screenshotData[key];

      if (data && screenshotImg) {
        screenshotImg.style.opacity = '0';
        setTimeout(() => {
          screenshotImg.src = data.src;
          screenshotImg.alt = data.alt;
          if (screenshotTitle) screenshotTitle.textContent = data.title;
          if (screenshotDesc) screenshotDesc.textContent = data.desc;
          if (screenshotBadges) {
            screenshotBadges.innerHTML = data.badges.map(b => 
              `<span class="px-2.5 py-1 text-xs font-medium rounded-full bg-purple-500/10 text-purple-300 border border-purple-500/20">${b}</span>`
            ).join('');
          }
          screenshotImg.style.opacity = '1';
        }, 150);
      }
    });
  });
}

// 2. Lightbox Zoom for Real Screenshots
function initLightbox() {
  const lightbox = document.getElementById('lightbox-modal');
  const lightboxImg = document.getElementById('lightbox-target-img');
  const triggers = document.querySelectorAll('.lightbox-trigger');
  const closeBtn = document.getElementById('lightbox-close');

  if (!lightbox || !lightboxImg) return;

  triggers.forEach(el => {
    el.addEventListener('click', () => {
      const src = el.getAttribute('data-src') || el.querySelector('img')?.src;
      if (src) {
        lightboxImg.src = src;
        lightbox.classList.add('active');
        document.body.style.overflow = 'hidden';
      }
    });
  });

  const closeLightbox = () => {
    lightbox.classList.remove('active');
    document.body.style.overflow = '';
  };

  if (closeBtn) closeBtn.addEventListener('click', closeLightbox);
  lightbox.addEventListener('click', (e) => {
    if (e.target === lightbox || e.target === lightboxImg.parentElement) {
      closeLightbox();
    }
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && lightbox.classList.contains('active')) {
      closeLightbox();
    }
  });
}

// 3. Interactive Keystroke & Caret HUD Simulator
function initSimulator() {
  const simInput = document.getElementById('sim-input');
  const hud = document.getElementById('sim-hud');
  const hudItemsContainer = document.getElementById('sim-hud-items');
  const promptPills = document.querySelectorAll('.sim-pill');

  if (!simInput || !hud || !hudItemsContainer) return;

  const demoDatabase = [
    { code: 'thumbsup', emoji: '👍', name: 'Thumbs Up', cat: 'Smileys' },
    { code: 'coffee', emoji: '☕', name: 'Hot Beverage', cat: 'Food' },
    { code: 'fire', emoji: '🔥', name: 'Fire / Lit', cat: 'Nature' },
    { code: 'rocket', emoji: '🚀', name: 'Rocket Launch', cat: 'Travel' },
    { code: 'shrug', emoji: '¯\\_(ツ)_/¯', name: 'ASCII Shrug', cat: 'Emoticons' },
    { code: 'smile', emoji: '😊', name: 'Smiling Face', cat: 'Smileys' },
    { code: 'heart', emoji: '❤️', name: 'Red Heart', cat: 'Smileys' },
    { code: 'tableflip', emoji: '(╯°□°）╯︵ ┻━┻', name: 'Table Flip', cat: 'Emoticons' },
    { code: 'apple', emoji: '', name: 'Apple Glyph', cat: 'Symbols' },
    { code: 'cmd', emoji: '⌘', name: 'Command Key', cat: 'Symbols' },
    { code: 'sig', emoji: 'Best regards,\nAmit Sarkar', name: 'Custom Signature', cat: 'Snippets' }
  ];

  let selectedIdx = 0;
  let activeMatches = [];

  function updateHUD() {
    const text = simInput.value;
    const doubleBackslashIndex = text.lastIndexOf('\\\\');
    const doubleSlashIndex = text.lastIndexOf('//');
    const colonIndex = text.lastIndexOf(':');

    let triggerIndex = -1;
    let triggerPrefix = '';

    if (doubleBackslashIndex !== -1 && doubleBackslashIndex >= doubleSlashIndex && doubleBackslashIndex >= colonIndex) {
      triggerIndex = doubleBackslashIndex;
      triggerPrefix = '\\\\';
    } else if (doubleSlashIndex !== -1 && doubleSlashIndex >= colonIndex) {
      triggerIndex = doubleSlashIndex;
      triggerPrefix = '//';
    } else if (colonIndex !== -1) {
      triggerIndex = colonIndex;
      triggerPrefix = ':';
    }

    if (triggerIndex !== -1 && triggerIndex + triggerPrefix.length === text.length) {
      // Just typed trigger ("\\" or "//" or ":")
      renderMatches(demoDatabase.slice(0, 4), triggerPrefix);
      hud.classList.remove('hidden');
    } else if (triggerIndex !== -1) {
      const query = text.slice(triggerIndex + triggerPrefix.length).toLowerCase();
      
      // If closing trigger typed, complete immediately!
      if (triggerPrefix === ':' && query.endsWith(':') && query.length > 1) {
        const cleanQuery = query.slice(0, -1);
        const exact = demoDatabase.find(d => d.code === cleanQuery);
        if (exact) {
          applyReplacement(exact, triggerIndex);
          return;
        }
      } else if (triggerPrefix === '//' && query.endsWith('/') && query.length > 1) {
        const cleanQuery = query.slice(0, -1);
        const exact = demoDatabase.find(d => d.code === cleanQuery);
        if (exact) {
          applyReplacement(exact, triggerIndex);
          return;
        }
      } else if (triggerPrefix === '\\\\' && query.endsWith('\\') && query.length > 1) {
        const cleanQuery = query.slice(0, -1);
        const exact = demoDatabase.find(d => d.code === cleanQuery);
        if (exact) {
          applyReplacement(exact, triggerIndex);
          return;
        }
      }

      activeMatches = demoDatabase.filter(d => 
        d.code.toLowerCase().includes(query) || d.name.toLowerCase().includes(query)
      ).slice(0, 4);

      if (activeMatches.length > 0) {
        renderMatches(activeMatches, triggerPrefix);
        hud.classList.remove('hidden');
      } else {
        hud.classList.add('hidden');
      }
    } else {
      hud.classList.add('hidden');
    }
  }

  function renderMatches(matches, prefix = '\\\\') {
    activeMatches = matches;
    selectedIdx = 0;
    hudItemsContainer.innerHTML = matches.map((m, idx) => `
      <div class="hud-item ${idx === 0 ? 'active' : ''}" data-idx="${idx}">
        <span class="text-xl font-normal w-7 text-center">${m.emoji.includes('\n') ? '📝' : m.emoji}</span>
        <div class="flex-1 flex items-baseline justify-between">
          <span class="font-medium text-slate-100">${prefix}${m.code}${prefix === ':' ? ':' : ''}</span>
          <span class="text-xs text-slate-400 ml-2">${m.cat}</span>
        </div>
      </div>
    `).join('');

    // Attach click handlers
    hudItemsContainer.querySelectorAll('.hud-item').forEach(item => {
      item.addEventListener('click', () => {
        const idx = parseInt(item.getAttribute('data-idx'), 10);
        if (activeMatches[idx]) {
          applyReplacement(activeMatches[idx]);
        }
      });
    });
  }

  function applyReplacement(item, forcedTriggerIdx) {
    const text = simInput.value;
    const doubleBackslashIndex = text.lastIndexOf('\\\\');
    const doubleSlashIndex = text.lastIndexOf('//');
    const colonIndex = text.lastIndexOf(':');
    const triggerIndex = forcedTriggerIdx !== undefined ? forcedTriggerIdx : Math.max(doubleBackslashIndex, doubleSlashIndex, colonIndex);
    if (triggerIndex !== -1) {
      const before = text.substring(0, triggerIndex);
      simInput.value = before + item.emoji + ' ';
    } else {
      simInput.value += ' ' + item.emoji + ' ';
    }
    hud.classList.add('hidden');
    simInput.focus();
  }

  simInput.addEventListener('input', updateHUD);

  simInput.addEventListener('keydown', (e) => {
    if (hud.classList.contains('hidden')) return;

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      selectedIdx = (selectedIdx + 1) % activeMatches.length;
      highlightItem();
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      selectedIdx = (selectedIdx - 1 + activeMatches.length) % activeMatches.length;
      highlightItem();
    } else if (e.key === 'Enter' || e.key === 'Tab') {
      if (activeMatches[selectedIdx]) {
        e.preventDefault();
        applyReplacement(activeMatches[selectedIdx]);
      }
    } else if (e.key === 'Escape') {
      hud.classList.add('hidden');
    }
  });

  function highlightItem() {
    const items = hudItemsContainer.querySelectorAll('.hud-item');
    items.forEach((it, idx) => {
      if (idx === selectedIdx) {
        it.classList.add('active');
      } else {
        it.classList.remove('active');
      }
    });
  }

  // Pill click triggers
  promptPills.forEach(pill => {
    pill.addEventListener('click', () => {
      const trigger = pill.getAttribute('data-trigger');
      simInput.value = `Hey team, check this out \\\\${trigger}`;
      simInput.focus();
      updateHUD();
    });
  });
}

// 4. One-click Copy Helper
function initClipboard() {
  const copyButtons = document.querySelectorAll('.copy-btn');
  copyButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const textToCopy = btn.getAttribute('data-copy');
      if (textToCopy) {
        navigator.clipboard.writeText(textToCopy).then(() => {
          const originalHTML = btn.innerHTML;
          btn.innerHTML = `
            <svg class="w-4 h-4 text-emerald-400 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-emerald-400">Copied!</span>
          `;
          setTimeout(() => {
            btn.innerHTML = originalHTML;
          }, 2000);
        });
      }
    });
  });
}
