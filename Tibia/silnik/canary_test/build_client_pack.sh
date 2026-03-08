#!/bin/bash
# build_client_pack.sh — tworzy czystą paczkę klienta OTClient dla graczy
# Użycie: ./build_client_pack.sh [wersja]
# Wynik: /home/ptaku/serweryt/Tibia/silnik/client_pack/<wersja>/

set -euo pipefail

VERSION="${1:-1.1.0}"
SRC="/home/ptaku/serweryt/Tibia/silnik/canary_test/testyy"
DEST="/home/ptaku/serweryt/Tibia/silnik/client_pack/${VERSION}"

if [[ -d "$DEST" ]]; then
    echo "BŁĄD: Katalog ${DEST} już istnieje. Usuń go lub podaj inną wersję."
    exit 1
fi

echo "=== Budowanie paczki klienta v${VERSION} ==="
echo "Źródło: ${SRC}"
echo "Cel:    ${DEST}"

mkdir -p "$DEST"

# --- Pliki binarne (Windows) ---
echo "[1/6] Kopiowanie binariów Windows..."
for f in otclient.exe \
         brotlicommon.dll brotlidec.dll bz2.dll \
         fmt.dll freetype.dll fribidi-0.dll glew32.dll harfbuzz.dll \
         libcrypto-3-x64.dll liblzma.dll libpng16.dll libprotobuf.dll libssl-3-x64.dll \
         lua51.dll ogg.dll OpenAL32.dll physfs.dll vorbis.dll vorbisfile.dll zlib1.dll \
         cacert.pem; do
    if [[ -f "${SRC}/${f}" ]]; then
        cp "${SRC}/${f}" "${DEST}/"
    else
        echo "  UWAGA: brak ${f} — pomijam"
    fi
done

# --- Binary Linux ---
echo "[2/6] Kopiowanie binary Linux..."
if [[ -f "${SRC}/otclient" ]]; then
    cp "${SRC}/otclient" "${DEST}/"
    chmod +x "${DEST}/otclient"
fi

# --- Pliki konfiguracyjne ---
echo "[3/6] Kopiowanie plików konfiguracyjnych..."
cp "${SRC}/init.lua" "${DEST}/"
cp "${SRC}/otclientrc.lua" "${DEST}/"
[[ -f "${SRC}/meta.lua" ]] && cp "${SRC}/meta.lua" "${DEST}/"

# --- Katalogi danych ---
echo "[4/6] Kopiowanie data/..."
cp -r "${SRC}/data" "${DEST}/data"

echo "[5/6] Kopiowanie modules/..."
cp -r "${SRC}/modules" "${DEST}/modules"

echo "[6/6] Kopiowanie mods/..."
if [[ -d "${SRC}/mods" ]]; then
    cp -r "${SRC}/mods" "${DEST}/mods"
fi

# --- Usuwanie zbędnych plików z skopiowanych katalogów ---
echo "Czyszczenie zbędnych plików..."
find "$DEST" -name "*.git*" -exec rm -rf {} + 2>/dev/null || true
find "$DEST" -name ".ai_cache" -exec rm -rf {} + 2>/dev/null || true
find "$DEST" -name "*.md" -not -name "LICENSE*" -exec rm -f {} + 2>/dev/null || true
find "$DEST" -name "*.patch" -exec rm -f {} + 2>/dev/null || true

# --- Podsumowanie ---
FILE_COUNT=$(find "$DEST" -type f | wc -l)
TOTAL_SIZE=$(du -sh "$DEST" | cut -f1)
echo ""
echo "=== Paczka gotowa ==="
echo "Wersja:    ${VERSION}"
echo "Plików:    ${FILE_COUNT}"
echo "Rozmiar:   ${TOTAL_SIZE}"
echo "Katalog:   ${DEST}"
echo ""
echo "Następny krok: wygeneruj manifest poleceniem:"
echo "  curl -sk -X POST https://tibia.reddaxe.pl/apik/v1/generate_manifest.php \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"version\":\"${VERSION}\",\"channel\":\"stable\"}'"
