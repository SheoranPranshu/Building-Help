
### 1. Adapt Device Tree for VoltageOS

This script automates the process of adapting a LineageOS-based device tree for VoltageOS. It patches `BoardConfig` files to use VoltageOS paths for the sm8250 devices common tree.

**Where to use:** Use in the root of your VoltageOS source directory.

**Command:**
```bash
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/setup_voltage.sh && chmod +x setup_voltage.sh && ./setup_voltage.sh && rm setup_voltage.sh
```

---

### 2. Update Firmware Hashes

When you update the proprietary firmware blobs for your device, their SHA1 hashes need to be updated in the makefiles. This script automates that process by recalculating the hashes and updating the `Android.mk` file.

**When to use:** Navigate to your device's vendor directory (e.g., `vendor/xiaomi/pipa`) and run the command from there.

**Command:**
```bash
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/update_firmware_hash.sh && chmod +x update_firmware_hash.sh && ./update_firmware_hash.sh && rm update_firmware_hash.sh
```

---

### 3. Configure Remote Build Execution (RBE)

This setup dramatically accelerates build times by offloading compilation tasks to a remote server like BuildBuddy. It uses a script (`setup_rbe.sh`) and a separate configuration file (`rbe.conf`) to keep your private API keys and settings secure and easy to manage.

**When to use:** Place the two files in the root of your ROM source directory. You must first edit `rbe.conf` with your details. Then, before every build, you **source** the script in your terminal to activate the RBE environment.

**Commands:**

**A) First-Time Setup:**
Download the script and the configuration file template.
```bash
# Download the script and its config file
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/setup_rbe.sh
wget https://github.com/glitch-wraith/Building-Help/raw/refs/heads/main/rbe.conf
chmod +x setup_rbe.sh
```
Edit rbe.conf
```
nano rbe.conf
```
**Usage**
Use this command befor mka
```
source ./setup_rbe.sh
```
