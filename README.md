# CrackStation v1.0

Multi-algorithm hash cracking wrapper supporting MD5, SHA1, and SHA256 with auto-detection and fallback modes.

## One-Line Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AdhiHub/crackstation/main/install.sh)
```

## Features

| Feature          | Description                                    |
|------------------|------------------------------------------------|
| MD5 Cracking     | Hash line-by-line against wordlist             |
| SHA1 Cracking    | Hash line-by-line against wordlist             |
| SHA256 Cracking  | Hash line-by-line against wordlist             |
| Auto-Detect      | Detects hash type by length (32/40/64)         |
| hashcat Support  | Auto-uses hashcat if available                 |
| John Support     | Auto-uses John the Ripper if available         |
| Bash Fallback    | Pure bash implementation when no tools found   |
| Save Results     | Writes cracked passwords to file               |

## Usage

```bash
# Interactive mode
./crackstation.sh

# Crack MD5 hash
./crackstation.sh -md5 5d41402abc4b2a76b9719d911017c592 wordlist.txt

# Crack SHA1 hash
./crackstation.sh -sha1 5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8 wordlist.txt

# Crack SHA256 hash
./crackstation.sh -sha256 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8 wordlist.txt

# Auto-detect hash type and crack
./crackstation.sh -auto 5d41402abc4b2a76b9719d911017c592 wordlist.txt

# Show help
./crackstation.sh -h
```

## Requirements

- curl (for install)
- md5sum, sha1sum, sha256sum (coreutils, preinstalled on Linux/Termux)
- hashcat (optional, for faster cracking)
- John the Ripper (optional, for alternative cracking)
- Linux or Termux (Android)

## Disclaimer

> Use at your own risk. Developer(s) assume NO liability. For authorized security testing ONLY.
