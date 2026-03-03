# Polityka podpisywania artefaktów

**ID:** LR-046  
**Status:** zamrozony  
**Data:** 2026-03-03

## Cel

Zapewnienie, ze pobrane artefakty (instalatory, paczki update, binarka launchera)
sa autentyczne i nie zostaly zmodyfikowane po stronie CDN/hostingu.

## Model wielopoziomowy

### Poziom 1 — SHA-256 (aktywny od Etapu 3)

- Kazdy artefakt w `installer-catalog.php` ma pole `sha256` (hex, 64 znaki).
- Launcher weryfikuje hash PO pobraniu, PRZED instalacja/uruchomieniem.
- Hash mismatch → blokada operacji + kod bledu `LCH_HASH_MISMATCH`.

### Poziom 2 — Podpisy `.sig` (Etap 5: Hardening)

- Kazdy artefakt ma odpowiadajacy plik `.sig` (podpis).
- Podpis generowany kluczem prywatnym Ed25519 (offline, nie w CI).
- Launcher weryfikuje podpis kluczem publicznym wbudowanym w binarkę.

### Poziom 3 — Authenticode / GPG (opcjonalny, OS-level)

- Windows: Authenticode code signing (cert EV/OV).
- Linux: GPG detached signature.
- OS sam ostrzega uzytkownika jesli binarny nie jest podpisany.

## Schemat podpisywania (Poziom 2)

```
1. Build: GHA produkuje binarkę launcher-tauri
2. Checksums: GHA generuje checksums.txt (SHA-256)
3. Podpis: Maintainer offline podpisuje checksums.txt kluczem Ed25519
4. Release: checksums.txt + checksums.txt.sig publikowane w GitHub Release
5. installer-catalog.json zawiera sha256 + opcjonalnie signature URL
6. Launcher: pobiera artefakt → weryfikuje SHA-256 → weryfikuje .sig
```

## Klucz publiczny

```
Format: Ed25519 (32 bajty, base64)
Lokalizacja w launcherze: wbudowany jako const w kodzie Rust
Rotacja: nowy klucz = nowa wersja launchera (self-update z nowym kluczem)
```

### Przykladowy schemat:

```rust
// Wbudowany klucz publiczny do weryfikacji podpisów
const SIGNING_PUBLIC_KEY: &[u8; 32] = include_bytes!("../keys/signing_pub.key");
```

## Schemat weryfikacji w launcherze

```rust
// Pseudokod
fn verify_artifact_signature(data: &[u8], signature: &[u8]) -> bool {
    let public_key = ed25519_dalek::VerifyingKey::from_bytes(SIGNING_PUBLIC_KEY);
    let sig = ed25519_dalek::Signature::from_bytes(signature);
    public_key.verify(data, &sig).is_ok()
}
```

## Pola w API

### installer-catalog.php

```json
{
  "artifacts": [
    {
      "filename": "Launcher-Setup-0.2.0.exe",
      "sha256": "abc123...",
      "signature": "https://cdn.example.com/releases/Launcher-Setup-0.2.0.exe.sig"
    }
  ]
}
```

### launcher-version.php

```json
{
  "version": "0.2.0",
  "sha256": "abc123...",
  "url": "https://cdn.example.com/releases/launcher-0.2.0.tar.gz"
}
```

## Procedura rotacji klucza

1. Wygenerowac nowy keypair Ed25519 offline.
2. Wbudowac nowy klucz publiczny w nowa wersje launchera.
3. Opublikowac self-update z nowym kluczem.
4. Grace period: akceptowac podpisy obydwoma kluczami przez 30 dni.
5. Wycofac stary klucz.

## Przechowywanie klucza prywatnego

- **NIGDY** w repozytorium.
- **NIGDY** w CI/CD secrets (chyba ze wymuszone).
- Najlepiej: offline (USB), podpisywanie recznym procesem.
- Ewentualnie: GitHub Actions secrets z restricted environment + approval gate.

## Harmonogram wdrozenia

| Pozziom | Kiedy | Blokuje release? |
|---------|-------|-------------------|
| SHA-256 | Etap 3 (teraz) | TAK — brak sha256 = brak pobierania |
| .sig Ed25519 | Etap 5 (Hardening) | NIE na starcie; docelowo: tak |
| Authenticode/GPG | Etap 5+ (opcjonalnie) | NIE |

## Uwagi

- Na starcie (MVP) wystarczy SHA-256.
- Podpisy `.sig` sa defense-in-depth — nie zastepuja ticket-gate.
- Podpis manifestu (HMAC lub Ed25519) to osobne zadanie (LR-053).
