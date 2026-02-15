# PRE_MIGRATION TODO: otclient_tools

- Generated: `2026-02-15T19:44:01.772409Z`
- Files scanned: **8**
- Files with hits: **8**
- Hits: **154**

| File | Line | Pattern | Text |
|---|---:|---|---|
| `testyy/tools/auto_translate_locale.py` | 2 | `tool.literal.double` | Utility to auto-translate missing locale keys via googletrans. |
| `testyy/tools/auto_translate_locale.py` | 39 | `tool.literal.double` | sdifuxXcp% |
| `testyy/tools/auto_translate_locale.py` | 41 | `tool.literal.double` | __PH{token_id}__ |
| `testyy/tools/auto_translate_locale.py` | 53 | `tool.literal.double` | __NL{token_id}__ |
| `testyy/tools/auto_translate_locale.py` | 77 | `tool.literal.double` | Mismatched translation batch length. |
| `testyy/tools/auto_translate_locale.py` | 83 | `tool.literal.double` | unreachable |
| `testyy/tools/auto_translate_locale.py` | 87 | `tool.literal.double` | Auto translate missing locale keys |
| `testyy/tools/auto_translate_locale.py` | 88 | `tool.literal.double` | , type=Path, default=Path( |
| `testyy/tools/auto_translate_locale.py` | 90 | `tool.literal.double` | --dest-lang |
| `testyy/tools/auto_translate_locale.py` | 91 | `tool.literal.double` | --src-lang |
| `testyy/tools/auto_translate_locale.py` | 92 | `tool.literal.double` | --batch-size |
| `testyy/tools/auto_translate_locale.py` | 93 | `tool.literal.double` | store_true |
| `testyy/tools/auto_translate_locale.py` | 101 | `tool.literal.double` | No missing keys detected. Nothing to do. |
| `testyy/tools/auto_translate_locale.py` | 104 | `tool.literal.double` | Translating {len(missing)} keys into '{args.dest_lang}'... |
| `testyy/tools/auto_translate_locale.py` | 104 | `tool.literal.single` | {args.dest_lang} |
| `testyy/tools/auto_translate_locale.py` | 122 | `tool.literal.double` | -> {progress}/{len(missing)} done |
| `testyy/tools/auto_translate_locale.py` | 126 | `tool.literal.double` | {key} => {value} |
| `testyy/tools/auto_translate_locale.py` | 132 | `tool.literal.double` | Unable to find end of translation table. |
| `testyy/tools/auto_translate_locale.py` | 134 | `tool.literal.double` | -- Auto-generated translations |
| `testyy/tools/auto_translate_locale.py` | 137 | `tool.literal.double` | {escape_lua(key)} |
| `testyy/tools/auto_translate_locale.py` | 137 | `tool.literal.double` | {escape_lua(value)} |
| `testyy/tools/auto_translate_locale.py` | 137 | `tool.literal.single` | ["{escape_lua(key)}"] = "{escape_lua(value)}", |
| `testyy/tools/auto_translate_locale.py` | 142 | `tool.literal.double` | Inserted {len(missing)} translations into {args.locale} |
| `testyy/tools/check_locale_coverage.py` | 15 | `tool.literal.double` | Decode a Lua-style string literal fragment. |
| `testyy/tools/check_locale_coverage.py` | 45 | `tool.literal.double` | Read neededtranslations.lua and return the ordered list of keys. |
| `testyy/tools/check_locale_coverage.py` | 52 | `tool.literal.double` | and i + 1 < length and text[i + 1] == |
| `testyy/tools/check_locale_coverage.py` | 81 | `tool.literal.double` | Parse a locale Lua file and return the translation dictionary. |
| `testyy/tools/check_locale_coverage.py` | 84 | `tool.literal.single` | \["((?:\\.\|[^"])*)"]\s*=\s*"((?:\\.\|[^"])*)" |
| `testyy/tools/check_locale_coverage.py` | 95 | `tool.literal.double` | Check locale completeness against needed translations. |
| `testyy/tools/check_locale_coverage.py` | 100 | `tool.literal.double` | Path to neededtranslations.lua (default: %(default)s) |
| `testyy/tools/check_locale_coverage.py` | 105 | `tool.literal.double` | Path to the locale file to verify (e.g., data/locales/pl.lua) |
| `testyy/tools/check_locale_coverage.py` | 108 | `tool.literal.double` | --show-extra |
| `testyy/tools/check_locale_coverage.py` | 109 | `tool.literal.double` | store_true |
| `testyy/tools/check_locale_coverage.py` | 110 | `tool.literal.double` | List translations that exist in the locale but not in neededtranslations. |
| `testyy/tools/check_locale_coverage.py` | 124 | `tool.literal.double` | Locale: {locale_name} |
| `testyy/tools/check_locale_coverage.py` | 125 | `tool.literal.double` | Total required strings : {len(needed)} |
| `testyy/tools/check_locale_coverage.py` | 126 | `tool.literal.double` | Available translations : {len(translations)} |
| `testyy/tools/check_locale_coverage.py` | 127 | `tool.literal.double` | Missing translations : {len(missing)} |
| `testyy/tools/check_locale_coverage.py` | 130 | `tool.literal.double` | Missing keys: |
| `testyy/tools/check_locale_coverage.py` | 135 | `tool.literal.double` | Extra keys (not defined in neededtranslations.lua): |
| `testyy/tools/export_missing_translations.py` | 2 | `tool.literal.double` | Export missing translations for a locale into CSV/JSON, with base references. |
| `testyy/tools/export_missing_translations.py` | 19 | `tool.literal.double` | Nie można załadować check_locale_coverage.py: {exc} |
| `testyy/tools/export_missing_translations.py` | 33 | `tool.literal.double` | base_translation |
| `testyy/tools/export_missing_translations.py` | 34 | `tool.literal.double` | target_translation |
| `testyy/tools/export_missing_translations.py` | 41 | `tool.literal.double` | , encoding= |
| `testyy/tools/export_missing_translations.py` | 41 | `tool.literal.double` | , newline= |
| `testyy/tools/export_missing_translations.py` | 44 | `tool.literal.double` | base_translation |
| `testyy/tools/export_missing_translations.py` | 44 | `tool.literal.double` | target_translation |
| `testyy/tools/export_missing_translations.py` | 49 | `tool.literal.double` | base_translation |
| `testyy/tools/export_missing_translations.py` | 50 | `tool.literal.double` | target_translation |
| `testyy/tools/export_missing_translations.py` | 67 | `tool.literal.double` | Eksportuje brakujące tłumaczenia dla wskazanego języka. |
| `testyy/tools/export_missing_translations.py` | 72 | `tool.literal.double` | Plik docelowy, np. data/locales/de.lua |
| `testyy/tools/export_missing_translations.py` | 78 | `tool.literal.double` | Ścieżka do neededtranslations.lua |
| `testyy/tools/export_missing_translations.py` | 84 | `tool.literal.double` | Plik bazowy z kompletnym tłumaczeniem (domyślnie polski) |
| `testyy/tools/export_missing_translations.py` | 90 | `tool.literal.double` | Format wyjściowy (domyślnie CSV) |
| `testyy/tools/export_missing_translations.py` | 95 | `tool.literal.double` | Plik wyjściowy; gdy brak – wynik trafia na stdout |
| `testyy/tools/gen_lang_template.sh` | 5 | `tool.literal.single` | -- generated by ./tools/gen_lang_template.sh |
| `testyy/tools/gen_lang_template.sh` | 7 | `tool.literal.single` | name="", |
| `testyy/tools/gen_lang_template.sh` | 8 | `tool.literal.single` | languageName="", |
| `testyy/tools/gen_lang_template.sh` | 9 | `tool.literal.single` | translation = { |
| `testyy/tools/gen_lang_template.sh` | 10 | `tool.literal.double` | -o -name |
| `testyy/tools/gen_lang_template.sh` | 10 | `tool.literal.double` | \) -exec grep -oE |
| `testyy/tools/gen_lang_template.sh` | 11 | `tool.literal.double` | -o -name |
| `testyy/tools/gen_lang_template.sh` | 11 | `tool.literal.double` | \) -exec grep -oE |
| `testyy/tools/gen_lang_template.sh` | 15 | `tool.literal.single` | modules.client_locales.installLocale(locale) |
| `testyy/tools/gen_needed_translations.sh` | 2 | `tool.literal.single` | -- generated by ./tools/gen_needed_translations.sh |
| `testyy/tools/gen_needed_translations.sh` | 3 | `tool.literal.single` | neededTranslations = { |
| `testyy/tools/gen_needed_translations.sh` | 4 | `tool.literal.double` | -o -name |
| `testyy/tools/gen_needed_translations.sh` | 4 | `tool.literal.double` | \) -exec grep -oE |
| `testyy/tools/gen_needed_translations.sh` | 5 | `tool.literal.double` | -o -name |
| `testyy/tools/gen_needed_translations.sh` | 5 | `tool.literal.double` | \) -exec grep -oE |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 13 | `tool.literal.single` | You need to select correct output folder. |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 83 | `tool.literal.single` | -antialiased |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 87 | `tool.literal.single` | + fontText + |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 90 | `tool.literal.single` | + fontText + |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 93 | `tool.literal.double` | generate_otc_bitmap_font |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 94 | `tool.literal.double` | Generate OTC font - Eduardo Bart & Qbazzz You can leave input image and drawable empty. |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 95 | `tool.literal.double` | Generate OTC font |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 96 | `tool.literal.double` | Eduardo Bart & Qbazzz |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 97 | `tool.literal.double` | Eduardo Bart & Qbazzz |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 99 | `tool.literal.double` | <Image>/File/Create/_Generate OTC font |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 104 | `tool.literal.double` | Border size |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 104 | `tool.literal.double` | Border_Size |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 106 | `tool.literal.double` | Output directory |
| `testyy/tools/gimp-bitmap-generator/generate_bitmap_font.py` | 106 | `tool.literal.double` | Output_Folder |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 5 | `tool.literal.single` | .. arg[0] .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 19 | `tool.literal.single` | Specify a file. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 64 | `tool.literal.single` | ^%s*(.*%S) |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 75 | `tool.literal.single` | ^const[%s]+ |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 79 | `tool.literal.single` | ^std::string$ |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 80 | `tool.literal.single` | ^OTMLNode$ |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 81 | `tool.literal.single` | ^std::vector<.*>$ |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 82 | `tool.literal.single` | ^std::map<.*>$ |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 83 | `tool.literal.single` | ^[u]?int[0-9_t]*$ |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 99 | `tool.literal.single` | ^(.*[%s]+[&*]?)([%w_]*) |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 119 | `tool.literal.single` | .. luaclass .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 122 | `tool.literal.single` | .. luaclass .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 123 | `tool.literal.double` | ' .. luaclass .. ' |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 123 | `tool.literal.single` | g_lua.registerStaticClass(" |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 134 | `tool.literal.single` | : public |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 136 | `tool.literal.single` | { public: |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 139 | `tool.literal.single` | g_lua.registerClass< |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 140 | `tool.literal.single` | and baseclass and baseclass ~= |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 161 | `tool.literal.single` | .. filterArgs(funcargs) .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 161 | `tool.literal.single` | .. filterReturn(funcret) .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 161 | `tool.literal.single` | .. funcname .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 163 | `tool.literal.double` | ' .. funcname .. ' |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 163 | `tool.literal.double` | ' .. luaclass .. ' |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 163 | `tool.literal.single` | .. cppclass .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 163 | `tool.literal.single` | .. funcname .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 163 | `tool.literal.single` | .. luaclass .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 163 | `tool.literal.single` | g_lua.bindSingletonFunction(" |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 172 | `tool.literal.single` | .. filterArgs(funcargs) .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 172 | `tool.literal.single` | .. filterReturn(funcret) .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 172 | `tool.literal.single` | .. funcname .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 174 | `tool.literal.double` | ' .. funcname .. ' |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 174 | `tool.literal.single` | .. cppclass .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 174 | `tool.literal.single` | .. funcname .. |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 174 | `tool.literal.single` | g_lua.bindClassMemberFunction(" |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 181 | `tool.literal.single` | ^[%s]*class[%s]+([%w_]+) |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 183 | `tool.literal.single` | Invalid directive at |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 196 | `tool.literal.single` | :[%s]+public[%s]+([%w_]+) |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 210 | `tool.literal.single` | Unable to open |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 219 | `tool.literal.single` | ^[%s]*//[%s]*@[%w]+[%s]+(.*)[%s]* |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 222 | `tool.literal.single` | [%s]*//[%s]*@bindsingleton |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 226 | `tool.literal.single` | [%s]*//[%s]*@bindclass |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 234 | `tool.literal.single` | [%s]*//[%s]*@dontbind |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 236 | `tool.literal.single` | [%s]*template |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 238 | `tool.literal.single` | [%s]*public: |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 240 | `tool.literal.single` | [%s]*private: |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 240 | `tool.literal.single` | [%s]*protected: |
| `testyy/tools/lua-binding-generator/generate_lua_bindings.lua` | 246 | `tool.literal.single` | ^[%s]*([%w <>&\*:_]*) ([%w_]+)%(([^%)]*%))[%w ]*[;{=].*$ |
| `testyy/tools/make_snapshot.sh` | 7 | `tool.literal.double` | $HOME/$name-builds |
| `testyy/tools/make_snapshot.sh` | 8 | `tool.literal.double` | i486-mingw32 |
| `testyy/tools/make_snapshot.sh` | 9 | `tool.literal.double` | /usr/$mingwplatform/bin |
| `testyy/tools/make_snapshot.sh` | 23 | `tool.literal.double` | usage: $0 [--replace] [--no-rebuild] |
| `testyy/tools/make_snapshot.sh` | 44 | `tool.literal.double` | set(VERSION |
| `testyy/tools/make_snapshot.sh` | 44 | `tool.literal.single` | s/.*"\([^"]*\)".*/\1/ |
| `testyy/tools/make_snapshot.sh` | 55 | `tool.literal.double` | -Wl,-Bstatic -lgcc -lstdc++ -lpthread -Wl,-Bdynamic |
| `testyy/tools/make_snapshot.sh` | 65 | `tool.literal.double` | $WIN32_EXTRA_LIBS |
| `testyy/tools/make_snapshot.sh` | 79 | `tool.literal.double` | $WIN32_EXTRA_LIBS |
| `testyy/tools/make_snapshot.sh` | 128 | `tool.literal.double` | -march=i686 -m32 |
| `testyy/tools/make_snapshot.sh` | 129 | `tool.literal.double` | -march=i686 -m32 |
| `testyy/tools/make_snapshot.sh` | 130 | `tool.literal.double` | -march=i686 -m32 |
| `testyy/tools/make_snapshot.sh` | 151 | `tool.literal.double` | -linux-$version |
| `testyy/tools/make_snapshot.sh` | 152 | `tool.literal.double` | $name$pkg_suffix |
| `testyy/tools/make_snapshot.sh` | 153 | `tool.literal.double` | $pkgname.tar.gz |
| `testyy/tools/make_snapshot.sh` | 184 | `tool.literal.double` | $pkgname-$i.zip |
| `testyy/tools/make_snapshot.sh` | 193 | `tool.literal.double` | Package generated to $pkgzip |
| `testyy/tools/make_snapshot.sh` | 197 | `tool.literal.double` | -win-$version |
| `testyy/tools/make_snapshot.sh` | 198 | `tool.literal.double` | $name$pkg_suffix |
| `testyy/tools/make_snapshot.sh` | 199 | `tool.literal.double` | $pkgname.zip |
| `testyy/tools/make_snapshot.sh` | 238 | `tool.literal.double` | $pkgname-$i.zip |
| `testyy/tools/make_snapshot.sh` | 247 | `tool.literal.double` | Package generated to $pkgzip |
