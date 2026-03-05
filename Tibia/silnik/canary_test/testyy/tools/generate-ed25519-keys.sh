#!/usr/bin/env bash
# ============================================================
# generate-ed25519-keys.sh — generacja pary kluczy Ed25519
# ============================================================
# Użycie:
#   ./generate-ed25519-keys.sh [output_dir]
#
# Output:
#   <output_dir>/manifest-signing.key     — klucz prywatny (TAJNY!)
#   <output_dir>/manifest-signing.pub     — klucz publiczny (hex, 64 znaki)
#   <output_dir>/manifest-signing.pub.pem — klucz publiczny (PEM)
#
# WAŻNE:
#   - Klucz prywatny NIGDY nie trafia do repo!
#   - Dodaj do GHA Secrets jako: MANIFEST_SIGNING_KEY (base64 encoded)
#   - Klucz publiczny embed w launcherze lub launcher_config.json
# ============================================================

set -euo pipefail

OUTPUT_DIR="${1:-.}"
mkdir -p "$OUTPUT_DIR"

PRIV_KEY="$OUTPUT_DIR/manifest-signing.key"
PUB_KEY_PEM="$OUTPUT_DIR/manifest-signing.pub.pem"
PUB_KEY_HEX="$OUTPUT_DIR/manifest-signing.pub"

# ─── Sprawdź czy openssl obsługuje Ed25519 ───
if ! openssl genpkey -algorithm Ed25519 -help &>/dev/null; then
  echo "ERROR: OpenSSL nie obsługuje Ed25519 (wymaga >= 1.1.1)"
  echo "Wersja: $(openssl version)"
  exit 1
fi

# ─── Sprawdź czy klucz już istnieje ───
if [ -f "$PRIV_KEY" ]; then
  echo "WARN: Klucz prywatny już istnieje: $PRIV_KEY"
  echo "      Nadpisać? (y/N)"
  read -r answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
    echo "Przerwano."
    exit 0
  fi
fi

# ─── Generuj klucz prywatny Ed25519 ───
echo "Generuję klucz prywatny Ed25519..."
openssl genpkey -algorithm Ed25519 -out "$PRIV_KEY"
chmod 600 "$PRIV_KEY"

# ─── Wyeksportuj klucz publiczny (PEM) ───
openssl pkey -in "$PRIV_KEY" -pubout -out "$PUB_KEY_PEM"

# ─── Wyeksportuj klucz publiczny jako hex (32 bajty = 64 hex znaków) ───
# Ed25519 public key raw = ostatnie 32 bajty z DER
openssl pkey -in "$PRIV_KEY" -pubout -outform DER 2>/dev/null \
  | tail -c 32 \
  | xxd -p -c 64 \
  > "$PUB_KEY_HEX"

echo ""
echo "═══════════════════════════════════════"
echo "Klucze Ed25519 wygenerowane!"
echo ""
echo "  Prywatny: $PRIV_KEY (TAJNY — nie commituj!)"
echo "  Publiczny (PEM): $PUB_KEY_PEM"
echo "  Publiczny (hex): $PUB_KEY_HEX"
echo ""
echo "Hex klucza publicznego (do wklejenia w config):"
echo "  $(cat "$PUB_KEY_HEX")"
echo ""
echo "Aby dodać do GHA Secrets:"
echo "  base64 < $PRIV_KEY | pbcopy  # macOS"
echo "  base64 < $PRIV_KEY | xclip   # Linux"
echo "  Wklej jako: MANIFEST_SIGNING_KEY"
echo "═══════════════════════════════════════"
