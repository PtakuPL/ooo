Internationalization (i18n)

Overview
- Client-side translation using data attributes and JSON dictionaries.
- Loader: `resources/i18n/i18n.js` reads `en.json`, `pl.json` based on `localStorage.lang` or browser.

How to instrument templates
- Add `data-i18n="key"` on elements to translate inner text.
- Use `data-i18n-placeholder="key"` for input placeholders.
- Use `data-i18n-title="key"` to set element `title` attribute; set on `<html>` to override `document.title`.
- Fallback: provide default text after `|` in `data-i18n`: `data-i18n="menu.home|Home"`.

Language switcher
- Automatically injected bottom-right; change persists in `localStorage`.

Adding new keys
- Edit `resources/i18n/en.json` and `pl.json`.
- Keep keys flat and descriptive, e.g., `status.online`, `nav.login`.

Notes
- No server-side changes required; purely client-side.
- You can add more languages by creating `<lang>.json` and adding code to `SUPPORTED` in `i18n.js`.
