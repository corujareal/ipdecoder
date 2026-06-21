# IP Decoder

A modular Bash script that bundles several network and system utilities into a single, colorful terminal menu. It is not just about IP addresses – it helps you:

- View system information (uptime, current directory, user).
- Restart services and inspect running processes/open ports.
- Discover live hosts on a local network (ICMP sweep).
- Scan a specific port across a subnet.
- Extract domain names from a web page and resolve their IP addresses.

All of this with a styled banner and straightforward prompts. **Every pause is now a “Press Enter to continue” – you control the pace.**

## Prerequisites

The script **can automatically install** the required tools on many Linux distributions (see below). If you prefer to install them manually, here is what it needs:

| Tool   | Why it is used                      |
|--------|-------------------------------------|
| bash   | Script interpreter                  |
| figlet | Stylized banners                    |
| ping   | Host discovery (ICMP)               |
| hping3 | Port scanning                       |
| ss     | Listing open ports                  |
| wget   | Downloading HTML for parsing        |
| host   | Resolving domains to IP             |
| grep, awk, cut, ps, rm | Text processing and system commands |

Manual install examples (if you skip auto‑install):

```bash
# Debian/Ubuntu
sudo apt update && sudo apt install figlet hping3 wget dnsutils iproute2 procps grep iputils-ping gawk coreutils

# Fedora
sudo dnf install figlet hping3 wget bind-utils iproute initscripts procps-ng grep iputils gawk coreutils

# Arch
sudo pacman -S figlet hping3 wget bind-tools iproute2 systemd-sysvcompat procps-ng grep iputils gawk coreutils
```

## Installation and usage

```bash
git clone https://github.com/corujareal/ipdecoder
cd ipdecoder
chmod +x ipdecoder.sh
./ipdecoder.sh
```

When you run it for the first time, the script checks for missing dependencies and offers to install everything with a single confirmation – no need to leave the script.

Navigate the menu by typing a number (1‑5, or 0 to exit). After each operation, press **Enter** to return to the menu.

## Notes

- **Root privileges:** The script will ask for `sudo` only when a command actually needs it (e.g., port scanning, listing process names on ports, or installing packages). You can also run the whole script as root if you prefer.
- **Compatibility:** Tested on Debian, Ubuntu, Fedora, CentOS, Arch, openSUSE, and Alpine. If your distribution is not detected, you can still install the required tools manually.
- **Security:** All user inputs are validated. The script never passes raw input to dangerous commands without sanitisation.
- **File handling:** Temporary files are created in `/tmp` securely and are removed automatically, even if you press Ctrl+C.

Feel free to open an issue or pull request if you find a bug or want to suggest an improvement.
