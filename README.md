# Android ROM Building Helper Scripts

This repository contains a collection of utility scripts designed to simplify common tasks and fix frequent issues encountered while building custom Android ROMs.

## Usage

Most scripts are designed to be downloaded and run with a single command. The general pattern is:

```bash
wget [URL_TO_SCRIPT] && chmod +x [SCRIPT_NAME] && ./[SCRIPT_NAME] && rm [SCRIPT_NAME]
```

This downloads the script, makes it executable, runs it, and then cleans up the script file.

---

### 1. Fix `fsgen` Duplicate File Errors

This script patches the `fsgen` tool to prevent build failures caused by duplicate file entries when generating system images. This is a common issue when porting devices.

**When to use:** Run this once at the beginning of your build setup if you encounter `fsgen` errors related to duplicate files.

**Command:**
```bash
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/fsgen_hacks.sh && chmod +x fsgen_hacks.sh && ./fsgen_hacks.sh && rm fsgen_hacks.sh
```

---

### 2. Adapt Device Tree for VoltageOS

This script automates the process of adapting a LineageOS-based device tree for VoltageOS. It renames dependency files and patches `BoardConfig` files to use VoltageOS paths.

**When to use:** Run this script from the root of your source tree after cloning a new device tree you intend to use with VoltageOS.

**Command:**
```bash
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/setup_voltage.sh && chmod +x setup_voltage.sh && ./setup_voltage.sh && rm setup_voltage.sh
```

---

### 3. Update Firmware Hashes

When you update the proprietary firmware blobs for your device, their SHA1 hashes need to be updated in the makefiles. This script automates that process by recalculating the hashes and updating the `Android.mk` file.

**When to use:** Navigate to your device's vendor directory (e.g., `vendor/xiaomi/pipa`) and run the command from there.

**Command:**
```bash
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/update_firmware_hash.sh && chmod +x update_firmware_hash.sh && ./update_firmware_hash.sh && rm update_firmware_hash.sh
```

---

### 4. Setup Remote Build Execution (RBE)

These files help you configure your environment for building with Google's Remote Build Execution, using a service like BuildBuddy. This setup uses two files: a configuration file for your keys and a script to set up the environment.

**Instructions:**

1.  **Download the configuration file (`rbe.conf`).**
    ```bash
    wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/rbe.conf
    ```

2.  **IMPORTANT: Edit the configuration file.** Open `rbe.conf` in a text editor and fill in your personal `RBE_DIR`, `RBE_SERVICE`, and `RBE_API_KEY`.

3.  **Download the setup script (`setup_rbe.sh`).**
    ```bash
    wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/setup_rbe.sh && chmod +x setup_rbe.sh
    ```

4.  **Activate the RBE environment.** Each time you start a new terminal session for building, you must `source` the setup script. This will load the configuration and export the necessary variables for your build.
    ```bash
    # From the root of your Android source
    source /path/to/your/scripts/setup_rbe.sh
    ```
