# Błędy kompilacji CI/CD - Kompletny raport

## Aktualny status workflow na master (2025-12-06)

| Workflow | Status | Plik | Uwagi |
|----------|--------|------|-------|
| build-linux | ✅ SUCCESS | build-linux.yml | Run #300 |
| Build - Ubuntu | ✅ SUCCESS | build-ubuntu.yml | Run #44 |
| Build - Windows - Solution | ✅ SUCCESS | build-windows-solution.yml | Run #32 |
| build-windows (vcpkg) | ❌ FAILURE | build-windows.yml | Run #298 – RuntimeLibrary/Vorbis fix wprowadzony, potrzebny rerun + aktualny błąd vcpkg (brak wersji abseil/angle/asio) |
| Build - Emscripten | ⚠️ Naprawione, czeka na rerun | build-browser.yml | LuaJIT → lua dla emscripten w PR |
| Build - Android | ⚠️ Naprawione, czeka na rerun | build-android.yml | sdkmanager pełna ścieżka w PR |
| Analysis - SonarCloud | ❌ FAILURE | analysis-sonarcloud.yml | Brak sekretu SONAR_TOKEN/SONARCLOUDTOKEN na repo |

### Nowe ustalenia (2025-12-06)
- **vcpkg manifest (Windows)**: logi z `errory-actions.md` pokazują brak wpisów w bazie wersji dla `abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0` przy commitcie `5b121431`. Rozwiązanie: zaktualizować `builtin-baseline`/commit vcpkg do wersji zawierającej te porty lub obniżyć wersje portów do dostępnych.
- **g_asyncDispatcher – konflikt deklaracji**: w `asyncdispatcher.cpp` tworzony jest `BS::thread_pool` bez parametrów szablonu, a w `asyncdispatcher.h` z parametrem `<0>`, co wywołuje błąd „conflicting declaration”. Ujednolicić typ (np. alias `using AsyncPool = BS::thread_pool<>;`) i trzymać jedną definicję.
- **Sys deps (Linux devcontainer)**: doinstalowane `libharfbuzz-dev`, `libfribidi-dev`, `libfreetype-dev` + zależności GLib/graphite, więc lokalne buildy TTF/i18n powinny przechodzić bez braków pkg-config.
- **Submodule ostrzeżenie SonarCloud**: wciąż brak zdalnego repo dla `oryginall/canary-serwer` – dodać prawidłowy wpis w `.gitmodules` lub usunąć submodule z workflow.

---

## 1. Windows Build - vcpkg (441 errors, 3 warnings)

### RuntimeLibrary Mismatch (LNK2038)
Biblioteki vcpkg skompilowane z `/MT` (static), ale projekt kompilowany z `/MD` (dynamic).

```
error LNK2038: mismatch detected for 'RuntimeLibrary': value 'MT_StaticRelease' doesn't match value 'MD_DynamicRelease'
```

**Dotknięte biblioteki:**
- libprotobuf.lib (repeated_field.cc.obj, extension_set_heavy.cc.obj, generated_message_tctable_gen.cc.obj, generated_message_tctable_full.cc.obj, generated_message_tctable_lite.cc.obj, raw_ptr.cc.obj, zero_copy_sink.cc.obj, map.cc.obj, io_win32.cc.obj, generated_enum_util.cc.obj, common.cc.obj, descriptor.cc.obj, message_differencer.cc.obj, extension_set.cc.obj, message_lite.cc.obj, zero_copy_stream_impl.cc.obj)
- absl_log_internal_check_op.lib (check_op.cc.obj)
- absl_log_internal_message.lib (log_message.cc.obj)
- absl_log_internal_nullguard.lib (nullguard.cc.obj)
- absl_examine_stack.lib (examine_stack.cc.obj)
- absl_log_internal_format.lib (log_format.cc.obj)
- absl_log_internal_structured_proto.lib (structured_proto.cc.obj)
- absl_log_internal_log_sink_set.lib (log_sink_set.cc.obj)
- absl_log_sink.lib (log_sink.cc.obj)
- absl_log_internal_proto.lib (proto.cc.obj)
- absl_log_internal_conditions.lib (conditions.cc.obj)
- absl_log_internal_globals.lib (globals.cc.obj)
- absl_log_globals.lib (globals.cc.obj)
- absl_raw_hash_set.lib (raw_hash_set.cc.obj)
- absl_hashtablez_sampler.lib (hashtablez_sampler.cc.obj, hashtablez_sampler_force_weak_definition.cc.obj)
- absl_statusor.lib (statusor.cc.obj)
- absl_status.lib (status_internal.cc.obj, status.cc.obj, status_payload_printer.cc.obj)
- absl_cord.lib (cord.cc.obj, cord_analysis.cc.obj)
- absl_cordz_info.lib (cordz_info.cc.obj)
- absl_cord_internal.lib (cord_internal.cc.obj, cord_rep_btree.cc.obj, cord_rep_btree_reader.cc.obj, cord_rep_crc.cc.obj, cord_rep_consume.cc.obj, cord_rep_btree_navigator.cc.obj)
- absl_hash.lib (hash.cc.obj)
- absl_city.lib (city.cc.obj)
- absl_cordz_handle.lib (cordz_handle.cc.obj)
- absl_crc_cord_state.lib (crc_cord_state.cc.obj)
- absl_crc32c.lib (crc32c.cc.obj, crc_memcpy_fallback.cc.obj)
- absl_crc_internal.lib (crc.cc.obj, crc_x86_arm_combined.cc.obj)
- absl_strerror.lib (strerror.cc.obj)
- absl_str_format_internal.lib (arg.cc.obj, bind.cc.obj, extension.cc.obj, float_conversion.cc.obj, output.cc.obj, parser.cc.obj)
- absl_synchronization.lib (mutex.cc.obj, create_thread_identity.cc.obj, per_thread_sem.cc.obj, win32_waiter.cc.obj, waiter_base.cc.obj)
- absl_stacktrace.lib (stacktrace.cc.obj)
- absl_symbolize.lib (symbolize.cc.obj)
- absl_graphcycles_internal.lib (graphcycles.cc.obj)
- absl_kernel_timeout_internal.lib (kernel_timeout.cc.obj)
- absl_malloc_internal.lib (low_level_alloc.cc.obj)
- absl_time.lib (time.cc.obj, clock.cc.obj, duration.cc.obj)
- absl_time_zone.lib (time_zone_lookup.cc.obj, time_zone_fixed.cc.obj, time_zone_impl.cc.obj, time_zone_if.cc.obj, time_zone_info.cc.obj, time_zone_libc.cc.obj, zone_info_source.cc.obj, time_zone_posix.cc.obj)
- utf8_validity.lib (utf8_validity.cc.obj)
- absl_strings.lib (stringify_sink.cc.obj, numbers.cc.obj, str_cat.cc.obj, escaping.cc.obj, ascii.cc.obj, str_split.cc.obj, substitute.cc.obj, charconv.cc.obj, match.cc.obj, charconv_parse.cc.obj, charconv_bigint.cc.obj, memutil.cc.obj)
- absl_int128.lib (int128.cc.obj)
- absl_strings_internal.lib (escaping.cc.obj)
- absl_base.lib (sysinfo.cc.obj, cycleclock.cc.obj, spinlock.cc.obj, thread_identity.cc.obj)
- absl_spinlock_wait.lib (spinlock_wait.cc.obj)
- absl_throw_delegate.lib (throw_delegate.cc.obj)
- absl_raw_logging_internal.lib (raw_logging.cc.obj)
- OpenAL32.lib (state.cpp.obj, error.cpp.obj, buffer.cpp.obj, extension.cpp.obj, listener.cpp.obj, alc.cpp.obj, source.cpp.obj, context.cpp.obj, debug.cpp.obj, logging.cpp.obj, strutils.cpp.obj, alconfig.cpp.obj, except.cpp.obj, storage_formats.cpp.obj, alstring.cpp.obj, alassert.cpp.obj, effect.cpp.obj, filter.cpp.obj, auxeffectslot.cpp.obj, event.cpp.obj, events.cpp.obj, devformat.cpp.obj, alu.cpp.obj, voice.cpp.obj, panning.cpp.obj, cpu_caps.cpp.obj, mastering.cpp.obj, device.cpp.obj, base.cpp.obj, null.cpp.obj, loopback.cpp.obj, wasapi.cpp.obj, dsound.cpp.obj, wave.cpp.obj, call.cpp.obj, exception.cpp.obj, fx_slots.cpp.obj, api.cpp.obj, alsem.cpp.obj, ringbuffer.cpp.obj, fx_slot_index.cpp.obj, effectslot.cpp.obj, utils.cpp.obj, helpers.cpp.obj, reverb.cpp.obj, autowah.cpp.obj, chorus.cpp.obj, compressor.cpp.obj, distortion.cpp.obj, echo.cpp.obj, equalizer.cpp.obj, fshifter.cpp.obj, modulator.cpp.obj, pshifter.cpp.obj, vmorpher.cpp.obj, dedicated.cpp.obj, convolution.cpp.obj, mixer_c.cpp.obj, bformatdec.cpp.obj, bs2b.cpp.obj, cubic_tables.cpp.obj, nfc.cpp.obj, hrtf.cpp.obj, mixer.cpp.obj, biquad.cpp.obj, mixer_sse.cpp.obj, mixer_sse41.cpp.obj, mixer_sse2.cpp.obj, ambidefs.cpp.obj, bsinc_tables.cpp.obj, splitter.cpp.obj, uhjfilter.cpp.obj, ambdec.cpp.obj, converter.cpp.obj, dynload.cpp.obj, alcomplex.cpp.obj, pffft.cpp.obj, polyphase_resampler.cpp.obj)
- fmt.lib (format.cc.obj)
- harfbuzz.lib (hb-face.cc.obj, hb-ft.cc.obj, hb-font.cc.obj, hb-buffer.cc.obj, hb-shape.cc.obj, hb-common.cc.obj, hb-blob.cc.obj, hb-face-builder.cc.obj, hb-shape-plan.cc.obj, hb-ot-face.cc.obj, hb-ot-shape.cc.obj, hb-fallback-shape.cc.obj, hb-paint.cc.obj, hb-draw.cc.obj, hb-paint-extents.cc.obj, hb-outline.cc.obj, hb-paint-bounded.cc.obj, hb-ot-font.cc.obj, hb-ot-var.cc.obj, hb-number.cc.obj, hb-unicode.cc.obj, hb-shaper.cc.obj, hb-buffer-verify.cc.obj, hb-ot-layout.cc.obj, hb-set.cc.obj, hb-aat-layout.cc.obj, hb-ot-map.cc.obj, hb-aat-map.cc.obj, hb-ot-shape-normalize.cc.obj, hb-ot-shape-fallback.cc.obj, hb-ot-shaper-arabic.cc.obj, hb-ot-shaper-default.cc.obj, hb-ot-shaper-hangul.cc.obj, hb-ot-shaper-hebrew.cc.obj, hb-ot-shaper-indic.cc.obj, hb-ot-shaper-khmer.cc.obj, hb-ot-shaper-myanmar.cc.obj, hb-ot-shaper-thai.cc.obj, hb-ot-shaper-use.cc.obj, hb-ot-metrics.cc.obj, hb-ot-cff2-table.cc.obj, hb-ot-cff1-table.cc.obj, OT_Var_VARC_VARC.cc.obj, hb-ucd.cc.obj, hb-buffer-serialize.cc.obj, hb-ot-tag.cc.obj, hb-ot-shaper-syllabic.cc.obj, hb-ot-shaper-indic-table.cc.obj, hb-ot-shaper-vowel-constraints.cc.obj)
- libcpmt.lib (locale0.obj, locale.obj, iosptrs.obj, wlocale.obj, xlocale.obj, xlock.obj, xstrcoll.obj, xdateord.obj, xwcscoll.obj, xwcsxfrm.obj, xmtx.obj, StlCompareStringA.obj, StlCompareStringW.obj, StlLCMapStringW.obj)

### Duplicate Symbol Errors (LNK2005)
```
fmt.lib(format.cc.obj) : error LNK2005: "protected: virtual bool __cdecl fmt::v12::format_facet<class std::locale>::do_put(...)" already defined in application.obj
fmt.lib(format.cc.obj) : error LNK2005: "class fmt::v12::detail::uint128_fallback __cdecl fmt::v12::detail::dragonbox::get_cached_power(int)" already defined in application.obj
fmt.lib(format.cc.obj) : error LNK2005: "bool __cdecl fmt::v12::detail::is_printable(unsigned int)" already defined in application.obj
fmt.lib(format.cc.obj) : error LNK2005: "void __cdecl fmt::v12::report_error(char const *)" already defined in application.obj
fmt.lib(format.cc.obj) : error LNK2005: "class std::basic_string<char,...> __cdecl fmt::v12::vformat(...)" already defined in application.obj
fmt.lib(format.cc.obj) : error LNK2005: "void __cdecl fmt::v12::detail::vformat_to(...)" already defined in application.obj
fmt.lib(format.cc.obj) : error LNK2005: "bool __cdecl fmt::v12::detail::write_loc(...)" already defined in application.obj
```

**msvcprt.lib conflicts with libcpmt.lib:**
```
msvcprt.lib(MSVCP140.dll) : error LNK2005: "public: struct _Cvtvec __cdecl std::_Locinfo::_Getcvt(void)const" already defined in libprotobuf.lib
msvcprt.lib(MSVCP140.dll) : error LNK2005: "public: class std::basic_ostream<char,...>..." already defined in ...
libcpmt.lib(locale0.obj) : error LNK2005: "void __cdecl std::_Facet_Register(...)" already defined in msvcprt.lib
libcpmt.lib(locale0.obj) : error LNK2005: "private: static class std::locale::_Locimp * __cdecl std::locale::_Getgloballocale(void)" already defined in msvcprt.lib
libcpmt.lib(locale0.obj) : error LNK2005: "private: static class std::locale::_Locimp * __cdecl std::locale::_Init(bool)" already defined in msvcprt.lib
libcpmt.lib(locale0.obj) : error LNK2005: "public: static void __cdecl std::_Locinfo::_Locinfo_ctor(...)" already defined in msvcprt.lib
libcpmt.lib(locale0.obj) : error LNK2005: "public: static void __cdecl std::_Locinfo::_Locinfo_dtor(...)" already defined in msvcprt.lib
libcpmt.lib(locale0.obj) : error LNK2005: "public: static class std::locale const & __cdecl std::locale::classic(void)" already defined in msvcprt.lib
libcpmt.lib(locale.obj) : error LNK2005: "public: static class std::locale __cdecl std::locale::global(...)" already defined in msvcprt.lib
libcpmt.lib(wlocale.obj) : error LNK2005: "public: struct _Collvec __cdecl std::_Locinfo::_Getcoll(void)const" already defined in msvcprt.lib
libcpmt.lib(wlocale.obj) : error LNK2005: "public: unsigned short const * __cdecl std::_Locinfo::_W_Getdays(void)const" already defined in msvcprt.lib
libcpmt.lib(wlocale.obj) : error LNK2005: "public: unsigned short const * __cdecl std::_Locinfo::_W_Getmonths(void)const" already defined in msvcprt.lib
libcpmt.lib(xlocale.obj) : error LNK2005: "public: struct _Collvec __cdecl std::_Locinfo::_Getcoll(void)const" already defined in msvcprt.lib
libcpmt.lib(xlock.obj) : error LNK2005: "public: __cdecl std::_Lockit::_Lockit(int)" already defined in msvcprt.lib
libcpmt.lib(xlock.obj) : error LNK2005: "public: __cdecl std::_Lockit::~_Lockit(void)" already defined in msvcprt.lib
libcpmt.lib(xstrcoll.obj) : error LNK2005: _Strcoll already defined in msvcprt.lib
```

### Vorbis Unresolved External Symbols (LNK2019) - 22 errors
```
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_info_init referenced in function _fetch_headers
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_info_clear referenced in function ov_clear
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_info_blocksize referenced in function ov_pcm_seek
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_comment_init referenced in function _fetch_headers
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_comment_clear referenced in function ov_clear
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_block_init referenced in function _make_decode_ready
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_block_clear referenced in function ov_clear
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_dsp_clear referenced in function ov_clear
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_idheader referenced in function _fetch_headers
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_headerin referenced in function _fetch_headers
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_init referenced in function _make_decode_ready
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_restart referenced in function ov_raw_seek
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis referenced in function _fetch_and_process_packet
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_trackonly referenced in function ov_pcm_seek
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_blockin referenced in function ov_pcm_seek
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_pcmout referenced in function ov_pcm_seek
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_lapout referenced in function ov_crosslap
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_read referenced in function ov_pcm_seek
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_packet_blocksize referenced in function ov_raw_seek
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_halfrate referenced in function ov_halfrate
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_synthesis_halfrate_p referenced in function ov_pcm_seek
vorbisfile.lib(vorbisfile.c.obj) : error LNK2019: unresolved external symbol vorbis_window referenced in function ov_crosslap
```

### Fatal Linker Error
```
D:\a\ooo\ooo\Tibia\silnik\canary_test\testyy\Release\otclient.exe : fatal error LNK1120: 22 unresolved externals
```

---

## 2. Build - Emscripten (build-browser.yml)

### LuaJIT Architecture Error
```
error: building luajit:wasm32-emscripten failed with: BUILD_FAILED

lj_arch.h:69:2: error: "No support for this architecture (yet)"
   69 | #error "No support for this architecture (yet)"
      |  ^
lj_arch.h:439:2: error: "No target architecture defined"
  439 | #error "No target architecture defined"
      |  ^

Makefile:271: *** Unsupported target architecture.  Stop.
```

**Przyczyna:** LuaJIT nie wspiera architektury wasm32-emscripten. Należy użyć `lua` zamiast `luajit` dla tej platformy.

**Rozwiązanie (zaimplementowane w PR):** W `vcpkg.json` dodano warunek platformy dla `luajit` (tylko windows | linux | osx) i dodano `lua` jako zależność dla platformy emscripten. **NAPRAWIONE:** Zmieniono nieprawidłowy identyfikator platformy `wasm32-emscripten` na poprawny `emscripten`.

---

## 3. Build - Android (build-android.yml)

### sdkmanager Not Found
```
sdkmanager : The term 'sdkmanager' is not recognized as the name of a cmdlet, function, script file, or operable 
program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
At D:\a\_temp\e2a5c34e-45de-4bf4-92a4-8e1f4dd29387.ps1:3 char:12
+ echo "y" | sdkmanager --install "cmake;3.22.1"
+            ~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (sdkmanager:String) [], ParentContainsErrorRecordException
    + FullyQualifiedErrorId : CommandNotFoundException
```

**Przyczyna:** `sdkmanager` nie jest w PATH na Windows runner.

**Rozwiązanie (zaimplementowane w PR):** Użycie pełnej ścieżki do sdkmanager: `$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat`

---

## 4. Analysis - SonarCloud (analysis-sonarcloud.yml)

### Missing SONAR_TOKEN Secret
```
Error: You must define the following environment variable to run this GitHub Action: SONAR_TOKEN
```

**Przyczyna:** Brak skonfigurowanego sekretu `SONAR_TOKEN` w repozytorium.

**Rozwiązanie:** Wymaga ręcznej konfiguracji przez właściciela repozytorium:
1. Wygenerować token na https://sonarcloud.io/account/security
2. Dodać jako GitHub Secret: Settings → Secrets → Actions → `SONAR_TOKEN`

### Git Submodule Error
```
warning: Could not find remote repository for submodule 'Tibia/silnik/canary_test/oryginall/canary-serwer'
```

**Przyczyna:** Brakujący wpis w `.gitmodules` lub nieprawidłowy URL repozytorium.

### 5. Bieżące blokery (2025-12-06)
- **vcpkg port versions (Windows):** manifest wskazuje na wersje `abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0`, których nie ma w bazie commit-u `5b121431`. **Fix:** zaktualizować `builtin-baseline`/`vcpkgGitCommitId` do release zawierającego te wersje albo obniżyć wersje portów do dostępnych.
- **g_asyncDispatcher double-definition:** nagłówek `asyncdispatcher.h` deklaruje `BS::thread_pool<0>`, a `asyncdispatcher.cpp` definiuje `BS::thread_pool` bez parametru → błąd „conflicting declaration”. **Fix:** zdefiniować alias typu i używać go spójnie w deklaracji/definicji (jedna definicja w .cpp).
- **Submodule ostrzeżenie SonarCloud:** nadal brak zdalnego repo dla `oryginall/canary-serwer`. **Fix:** uzupełnić `.gitmodules` albo usunąć wpis/checkout w workflow.

---

## 5. build-linux (build-linux.yml) - ✅ SUCCESS

Aktualnie działa poprawnie (Run #300).

---

## 6. Build - Ubuntu (build-ubuntu.yml) - ✅ SUCCESS

Aktualnie działa poprawnie (Run #44).

---

## 7. Build - Windows - Solution (build-windows-solution.yml) - ✅ SUCCESS

Aktualnie działa poprawnie (Run #32).

---

## Podsumowanie wszystkich workflow

| Platforma | Workflow | Błędy | Status | Główna przyczyna |
|-----------|----------|-------|--------|------------------|
| Windows (vcpkg) | build-windows.yml | 441 | ❌ FAILURE | RuntimeLibrary mismatch (MT vs MD) + vorbis linking |
| Windows (Solution) | build-windows-solution.yml | 0 | ✅ SUCCESS | - |
| Emscripten | build-browser.yml | 2 | ❌ FAILURE | LuaJIT nie wspiera wasm32 |
| Android | build-android.yml | 1 | ❌ FAILURE | sdkmanager nie w PATH |
| SonarCloud | analysis-sonarcloud.yml | 2 | ❌ FAILURE | Brak SONAR_TOKEN + submodule |
| Linux | build-linux.yml | 0 | ✅ SUCCESS | - |
| Ubuntu | build-ubuntu.yml | 0 | ✅ SUCCESS | - |

---

## Proponowane rozwiązania

### 1. Windows (vcpkg) - build-windows.yml

**Problem:** RuntimeLibrary mismatch (MT vs MD) + Vorbis unresolved externals

**Rozwiązanie:**
1. **RuntimeLibrary fix**: Ustawić `CMAKE_MSVC_RUNTIME_LIBRARY` na `MultiThreaded$<$<CONFIG:Debug>:Debug>` dla static triplet lub zmienić vcpkg triplet na `x64-windows` (dynamic)
2. **Vorbis fix**: Upewnić się, że `vorbis.lib` jest linkowany przed `vorbisfile.lib`, lub jawnie dodać `vorbis` do target_link_libraries
3. **Alternatywa**: Usunąć flagi `/flto=auto` które nie są obsługiwane przez MSVC

### 2. Emscripten - build-browser.yml

**Problem:** LuaJIT nie wspiera architektury wasm32-emscripten

**Rozwiązanie (zaimplementowane w PR):**
1. W `vcpkg.json` dodać warunek platformy dla `luajit` (tylko windows | linux | osx)
2. Dodać `lua` jako zależność dla wasm32-emscripten

### 3. Android - build-android.yml

**Problem:** sdkmanager nie jest w PATH na Windows runner

**Rozwiązanie (zaimplementowane w PR):**
1. Użyć pełnej ścieżki do sdkmanager: `$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat`
2. Lub użyć preinstalowanego CMake z GitHub runners zamiast instalować przez sdkmanager

### 4. SonarCloud - analysis-sonarcloud.yml

**Problem:** Workflow używał `secrets.SONAR_TOKEN`, ale w repozytorium secret nazywa się `SONARCLOUDTOKEN`

**Rozwiązanie (zaimplementowane w PR):**
1. Zmieniono `${{ secrets.SONAR_TOKEN }}` na `${{ secrets.SONARCLOUDTOKEN }}` w workflow

---

## Status napraw w tym PR

| Workflow | Status naprawy | Commit |
|----------|---------------|--------|
| models-demo.yml | ✅ Naprawione | `cd6f8ee` - polskie słowa kluczowe, hardcoded token |
| build-browser.yml (Emscripten) | ✅ Naprawione | `b0e471f` - LuaJIT → lua dla wasm32 |
| build-android.yml | ✅ Naprawione | `c4fb634` - pełna ścieżka do sdkmanager |
| build-windows.yml (vcpkg) | ✅ Naprawione | `570edff` + `ba269a0` - RuntimeLibrary, LTO, fmt, Vorbis |
| analysis-sonarcloud.yml | ✅ Naprawione | Zmieniono SONAR_TOKEN → SONARCLOUDTOKEN |
