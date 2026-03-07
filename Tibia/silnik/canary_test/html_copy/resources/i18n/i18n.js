(() => {
  const DEFAULT_LANG = 'pl';
  const MANIFEST_URL = '/resources/i18n/languages.json';
  const FALLBACK_LANGUAGES = [
    { code: 'en', label: 'English' },
    { code: 'pl', label: 'Polski' },
  ];

  let availableLanguages = [...FALLBACK_LANGUAGES];

  function getCookie(name) {
    const cookie = document.cookie
      .split(';')
      .map(v => v.trim())
      .find(v => v.startsWith(`${name}=`));
    return cookie ? decodeURIComponent(cookie.split('=').slice(1).join('=')) : '';
  }

  function getQueryLanguage() {
    const value = new URLSearchParams(window.location.search).get('lang');
    return value ? value.trim() : '';
  }

  function setServerLocale(lang) {
    const maxAge = 365 * 24 * 60 * 60;
    document.cookie = `locale=${encodeURIComponent(lang)}; path=/; max-age=${maxAge}; SameSite=Lax`;
  }

  function syncServerLanguage(lang) {
    setServerLocale(lang);
    const url = new URL(window.location.href);
    if (url.searchParams.get('lang') !== lang) {
      url.searchParams.set('lang', lang);
      window.location.replace(url.toString());
      return true;
    }
    return false;
  }

  function getLangPreference() {
    const queryLang = getQueryLanguage();
    if (queryLang) {
      return resolveLanguage(queryLang);
    }

    const cookieLang = getCookie('locale');
    if (cookieLang) {
      return resolveLanguage(cookieLang);
    }

    const storedLang = localStorage.getItem('lang');
    if (storedLang) {
      return resolveLanguage(storedLang);
    }

    return DEFAULT_LANG;
  }

  async function loadTranslations(lang) {
    const res = await fetch(`/resources/i18n/${lang}.json`, { cache: 'no-cache' });
    if (!res.ok) throw new Error(`Failed to load translations for ${lang}`);
    return res.json();
  }

  async function ensureManifestLoaded() {
    try {
      const res = await fetch(MANIFEST_URL, { cache: 'no-cache' });
      if (!res.ok) throw new Error('Manifest request failed');
      const payload = await res.json();
      const manifest = Array.isArray(payload) ? payload : payload.languages;
      if (Array.isArray(manifest) && manifest.length) {
        availableLanguages = manifest.map(({ code, label }) => ({ code, label }))
          .filter(lang => lang.code && lang.label)
          .sort((a, b) => a.label.localeCompare(b.label));
      }
    } catch (err) {
      console.warn('i18n manifest missing or invalid, using fallback languages.', err);
      availableLanguages = [...FALLBACK_LANGUAGES];
    }
  }

  function resolveLanguage(candidate) {
    if (!candidate) {
      return 'pl';
    }

    const normalized = candidate.toLowerCase();
    const exact = availableLanguages.find(lang => lang.code.toLowerCase() === normalized);
    if (exact) {
      return exact.code;
    }

    const short = normalized.split(/[-_]/)[0];
    const partial = availableLanguages.find(lang => lang.code.toLowerCase().startsWith(short));
    return partial ? partial.code : 'pl';
  }

  async function loadDictionary(lang) {
    try {
      return await loadTranslations(lang);
    } catch (err) {
      if (lang !== 'pl') {
        console.warn(`Falling back to Polish translations because ${lang} failed.`, err);
        return loadTranslations('pl');
      }
      throw err;
    }
  }

  function applyTranslations(dict) {
    const elements = document.querySelectorAll('[data-i18n]');
    elements.forEach(el => {
      const key = el.getAttribute('data-i18n');
      const attr = el.getAttribute('data-i18n-attr');
      const txt = key.split('|').map(k => k.trim()).reduce((acc, k) => acc || dict[k], null);
      if (!txt) return;
      if (attr) {
        el.setAttribute(attr, txt);
      } else {
        el.textContent = txt;
      }
    });

    const placeholders = document.querySelectorAll('[data-i18n-placeholder]');
    placeholders.forEach(el => {
      const key = el.getAttribute('data-i18n-placeholder');
      const txt = dict[key];
      if (txt) el.setAttribute('placeholder', txt);
    });

    const titles = document.querySelectorAll('[data-i18n-title]');
    titles.forEach(el => {
      const key = el.getAttribute('data-i18n-title');
      const txt = dict[key];
      if (txt) el.setAttribute('title', txt);
    });

    const docTitleKey = document.documentElement.getAttribute('data-i18n-title');
    if (docTitleKey && dict[docTitleKey]) document.title = dict[docTitleKey];
  }

  async function initI18n() {
    await ensureManifestLoaded();
    const lang = getLangPreference();
    localStorage.setItem('lang', lang);
    const cookieLang = resolveLanguage(getCookie('locale'));
    if (cookieLang !== lang) {
      if (syncServerLanguage(lang)) {
        return;
      }
    }
    try {
      const dict = await loadDictionary(lang);
      applyTranslations(dict);
      injectLangSwitcher(lang, dict);
    } catch (e) {
      console.error('Unable to initialize i18n.', e);
    }
  }

  function injectLangSwitcher(currentLang, dict) {
    if (document.querySelector('#lang-switcher')) return;
    if (!availableLanguages || availableLanguages.length <= 1) return;
    const container = document.createElement('div');
    container.id = 'lang-switcher';
    container.style.position = 'fixed';
    container.style.right = '12px';
    container.style.bottom = '12px';
    container.style.zIndex = '9999';
    container.style.background = 'rgba(0,0,0,0.05)';
    container.style.backdropFilter = 'blur(4px)';
    container.style.padding = '6px 8px';
    container.style.borderRadius = '8px';
    container.style.boxShadow = '0 2px 8px rgba(0,0,0,0.1)';

    const select = document.createElement('select');
    select.ariaLabel = dict?.['i18n.language'] || 'Language';
    availableLanguages.forEach(lang => {
      const opt = document.createElement('option');
      opt.value = lang.code;
      opt.textContent = lang.label || lang.code;
      if (lang.code === currentLang) {
        opt.selected = true;
      }
      select.appendChild(opt);
    });
    select.addEventListener('change', () => {
      const selected = resolveLanguage(select.value);
      localStorage.setItem('lang', selected);
      if (!syncServerLanguage(selected)) {
        location.reload();
      }
    });

    container.appendChild(select);
    document.body.appendChild(container);
  }

  document.addEventListener('DOMContentLoaded', initI18n);
})();
