
# 🧰 Android Build Helper Scripts

A collection of scripts to fix common issues and simplify tasks when building custom Android ROMs.

### One-Liner Utilities

These scripts are designed to be run with a single command. The command downloads, executes, and then removes the script.

| Script | Purpose | Context & Command |
| :--- | :--- | :--- |
| **`fsgen_hacks.sh`** | Fixes `fsgen` build errors caused by duplicate file entries when creating system images. | > Run this **from the root of your source tree**: <br> ```bash <br> bash -c "$(curl -sL https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/fsgen_hacks.sh)" <br> ``` |
| **`setup_voltage.sh`** | Adapts a LineageOS device tree for VoltageOS by patching configs and renaming files. | > Run this **from the root of your source tree**: <br> ```bash <br> bash -c "$(curl -sL https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/setup_voltage.sh)" <br> ``` |
| **`update_firmware_hash.sh`** | Automatically updates firmware blob SHA1 hashes in your device's `Android.mk`. | > Run this **from your vendor directory** (e.g., `vendor/xiaomi/pipa`): <br> ```bash <br> bash -c "$(curl -sL https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/update_firmware_hash.sh)" <br> ``` |

*Note: I've replaced the `wget && chmod && ./ && rm` chain with a cleaner `bash -c "$(curl ...)"` command which achieves the same result in a more modern way.*

---

### Remote Build Execution (RBE) Setup

This will set up your environment to build with RBE using a service like BuildBuddy.

**1. Download the Configuration & Setup Files**

Run this command to download both the `rbe.conf` and `setup_rbe.sh` files into your current directory.
```bash
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/rbe.conf && \
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/setup_rbe.sh && \
chmod +x setup_rbe.sh
```

**2. Edit Your Configuration**

> **This is the most important step.**
> Open the `rbe.conf` file and fill in your personal `RBE_DIR`, `RBE_SERVICE`, and `RBE_API_KEY`.

**3. Activate the Environment**

Before starting a build, you must `source` the setup script. This loads your configuration and prepares your terminal for a remote build.
```bash
source ./setup_rbe.sh
```

You only need to download the files once, but you must run the `source` command every time you open a new terminal for building.
