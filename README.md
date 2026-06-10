# CRACKSTATION — Hash Cracking Wrapper

**Crack MD5, SHA1, and SHA256 hashes using a wordlist. Auto-detects hash type.**

Part of the **AdhiHub** security toolkit.

---

## What It Does

| Hash Type | Length | Example |
|-----------|--------|---------|
| MD5 | 32 chars | `5d41402abc4b2a76b9719d911017c592` |
| SHA1 | 40 chars | `5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8` |
| SHA256 | 64 chars | `5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8` |

CrackStation will:
1. Auto-detect the hash type by its length
2. Hash each word in your wordlist and compare
3. If **hashcat** is installed — uses that (faster)
4. If **John the Ripper** is installed — uses that
5. Otherwise — uses pure bash

---

## One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/AdhiHub/crackstation/main/install.sh | bash
```

After install:

```bash
crackstation
```

---

## How to Use

### Method 1: Interactive Menu

```bash
crackstation
```

Paste in your hash, choose the type (or auto-detect), enter your wordlist path.

### Method 2: Command Line

```bash
# Auto-detect hash type and crack
crackstation -auto 5d41402abc4b2a76b9719d911017c592 wordlist.txt

# Force MD5
crackstation -md5 5d41402abc4b2a76b9719d911017c592 wordlist.txt

# Force SHA1
crackstation -sha1 5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8 wordlist.txt

# Force SHA256
crackstation -sha256 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8 wordlist.txt

# Help
crackstation -h
```

---

## Example

```
Enter hash: 5d41402abc4b2a76b9719d911017c592
[+] Detected: MD5 (32 chars)
Enter wordlist path: rockyou.txt
[+] Cracking...
[✓] FOUND: hello
```

---

## Requirements

- **Linux** or **Termux** (Android)
- coreutils (md5sum, sha1sum, sha256sum — preinstalled)
- Optional: hashcat, John the Ripper

---

## Run Without Installing

```bash
git clone https://github.com/AdhiHub/crackstation.git
cd crackstation
chmod +x crackstation.sh
./crackstation.sh
```

---

> **⚠️ DISCLAIMER: FOR EDUCATIONAL PURPOSES ONLY**
>
> Use at your own risk. Developer(s) assume NO liability.
> Only crack hashes you own or have permission to test.
