# MTProxy Installer
# Debian 12

> ⚠️ DISCLAIMER
> This repository and scripts are provided strictly for **educational, research, and system administration purposes only**.
> The author does **not promote, encourage, or support bypassing restrictions, censorship, or violating applicable laws** in any jurisdiction.
> Users are solely responsible for how they use this software and must ensure full compliance with their local laws and regulations.
> The author assumes **no liability** for any misuse, damages, or legal consequences arising from the use of this code.

---

### The script builds MTProxy in Docker from source  
https://github.com/TelegramMessenger/MTProxy

---

### Full example

`bash <(wget -qO- https://raw.githubusercontent.com/prjctz/installer1/refs/heads/main/install.sh) --port=443 --ip=203.0.113.10 --domain=google.com --workers=1`

### Basic usage

`bash <(wget -qO- https://raw.githubusercontent.com/prjctz/installer1/refs/heads/main/install.sh) --port=443`

### Manual

`bash <(wget -qO- https://raw.githubusercontent.com/prjctz/installer1/refs/heads/main/install.sh) --help`

---

Tested: works correctly, deploys successfully, restarts automatically after reboot.

Provides 3 proxy modes:
1. standard
2. secure
3. fake TLS — currently not working on Android, code appears correct, investigating

---

### Note
Fake TLS format is not functional — no implementation exists in official Telegram sources.

---

### Automatic installer:
https://github.com/prjctz/tapok/

---

### Other options:
- https://github.com/prjctz/installer2/
- https://github.com/prjctz/installer3/
- https://github.com/prjctz/installer4/
