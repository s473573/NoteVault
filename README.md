# NoteVault
[![CI](https://github.com/s473573/NoteVault/actions/workflows/ci.yml/badge.svg)](https://github.com/s473573/NoteVault/actions/workflows/ci.yml)

privacy-first, Cupertino-native encrypted notes for iOS

> **Status:** research project / portfolio piece. iOS-first UX with Flutter’s Cupertino widgets. Local-only storage. Cryptography is implemented (PBKDF2-HMAC-SHA256 with per-vault salt) and wiring for encrypted storage is underway. Not for production use.

## What is NoteVault?

NoteVault stores text notes inside **vaults** (categories).  
Each vault is unlocked with its own passphrase; only that vault’s notes become readable while others stay opaque. The project explores:

- **Freedom through privacy** — keep your thoughts local and encrypted.  
- **iOS first** — embrace Apple’s UI patterns via Flutter’s Cupertino widgets.  
- **Security by default** — per-vault key derivation; salts and hashes kept in the OS Keychain.

## Core features

- **Face ID unlock (iOS)** — system biometric prompt to (re)unlock a vault; graceful fallback to passphrase.  
- **Per-vault key derivation** — each vault derives a 256-bit key from its passphrase using PBKDF2-HMAC-SHA256 (10k iters, 16-byte salt).  
- **Secure key material handling** — salts and the **hash of the derived key** are stored in iOS **Keychain** via `flutter_secure_storage`; no plaintext keys are persisted.  
- **Cupertino-native UX** — navigation, dialogs, and controls use Flutter’s Cupertino components.  
- **Offline by design** — no servers, no telemetry, no sync.  
- **GetX state management** — reactive UI (`Obx`) and simple navigation (`Get.toNamed`, `Get.offNamed`).

## Security design (short)

- **KDF:** PBKDF2-HMAC-SHA256, **iterations = 10,000**, **output = 32 bytes (256-bit)**.  
- **Salt:** 16 bytes, unique **per vault**.  
- **At-rest metadata:**  
  - `salt(vaultId)` → base64 salt in Keychain  
  - `hash(vaultId)` → base64 **SHA-256** of the *derived* key (used to validate passphrases without storing the key)  
- **Unlock flow:** derive key → hash → compare to stored hash → (on match) use the in-memory key to open the vault’s storage.  
- **WIP:** wiring this key to the vault’s encrypted storage (Hive encrypted box per vault).

## Input validation

- **Vault name:** `^[a-zA-Z0-9]{2,15}$` (alphanumeric only, 2–15 chars).  
- **Password:** minimum length **4** (room to tighten later).

## How it basically works

1) **Create vault** → generate and store a per-vault **salt** in Keychain → derive a key from the passphrase → compute and store **hash(derivedKey)** in Keychain.  
2) **Unlock vault** → derive key again → hash and compare with stored hash → on success, open the vault’s storage using the in-memory key.  
3) **Delete vault** → UI uses a swipe-to-delete pattern with confirmation; controller handles secure deletion and state updates.

## Build & run (iOS-first)

```bash
# prerequisites: Flutter (stable), Xcode, iOS Simulator or device

flutter pub get
flutter run -d iOS

# Optional: compile check without signing (you may still need to select a Team in Xcode)
flutter build ios --no-codesign

## Tech & dependencies

- **Flutter** (Dart SDK constraint: `>=2.19.4 <3.0.0`)  
- **UI:** `cupertino_icons`  
- **State:** `get`  
- **Storage:** `hive` (git: isar/hive, main) + `path_provider` *(encrypted-box wiring in progress)*  
- **Crypto:** `cryptography` (PBKDF2, SHA-256)  
- **OS keystore:** `flutter_secure_storage` (iOS Keychain)

Dev:
- `flutter_test`, `flutter_lints`


