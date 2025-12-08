# Canary Server I18N

This folder contains locale packs consumed by the server-side translation system
(`i18n::Translator`). Each locale lives in its own directory (`en`, `pl`, …)
and may contain any number of `.json` files. Every file stores a flat or nested
object of `key -> text` pairs. Nested objects are flattened using dot notation,
so the following structure:

```json
{
  "player": {
    "condition": {
      "poisoned": "You are poisoned."
    }
  }
}
```

is available at runtime under the key `player.condition.poisoned`.

Translation files are loaded from:

1. `<DATA_DIRECTORY>/i18n` (configured via `dataPackDirectory`),
2. `data/i18n`,
3. `i18n` (this directory).

Place locale-specific resources in one of those paths so they are discovered in
all deployment setups.

## Tooling

- `python tools/export_items_translations.py --locale en --locale pl`  
  Synchronises `i18n/<locale>/items.json` with `data/items/items.xml`.

- `python tools/i18n_report.py --locales pl --csv-dir i18n/reports`  
  Generates coverage stats against the base locale (`en`) and exports a CSV
  (`key,en,<locale>,status`) to help tłumaczom uzupełniać wpisy.

- `python tools/i18n_extract_messages.py --roots data-otservbr-global src --out build/i18n/messages.json`  
  Skanuje Lua/C++ w poszukiwaniu literalnych `sendTextMessage`/`setMessage` i
  generuje JSON z propozycją kluczy (`key`, `text`, `file`, `line`), który można
  przerobić na wpisy `en/pl`.

- `python tools/i18n_sync_messages.py --locale pl --filename system.json`  
  Zsynchronizuje `i18n/en/system.json` (baza) oraz `i18n/pl/system.json`
  z najnowszym ekstraktem (`build/i18n/messages.json`), prefillując wartości w PL.
