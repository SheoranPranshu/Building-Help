### 1. Adapt Device Tree for VoltageOS

This script automates the process of adapting a LineageOS-based device tree for VoltageOS. It patches `BoardConfig` files to use VoltageOS paths for sm8250 devices common tree.

**Where to use:** Use in root of voltage source

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

