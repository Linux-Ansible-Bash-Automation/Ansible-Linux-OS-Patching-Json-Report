---

# Patch Linux Servers – JSON Reporting  
### Ansible & Bash Automation

This repository provides a **production-ready Linux OS patching automation framework** using **Ansible** with an **interactive Bash wrapper**, designed to generate a **structured JSON patching report**.

It supports **RHEL and Debian/Ubuntu families**, performs **upgrade previews**, applies **safe OS updates**, handles **conditional reboots**, collects **post-reboot uptime**, and writes a **single consolidated JSON report** on the control node.

---

## ✨ Key Features

- Interactive **Bash-driven execution**
- Multi-OS support:
  - RedHat / RHEL / AlmaLinux / Rocky Linux
  - Ubuntu / Debian
- **Preview mode** (shows packages that would be upgraded)
- Full system upgrade support
- **Change-based reboot logic**
- **Post-reboot uptime collection**
- **Structured JSON reporting**
- Single consolidated report for all hosts
- Report generated **only on the control node**
- Controlled rolling execution using `serial`

---

## 📝 Notes

- If you want to run the playbook with **sudo or dzdo privileges**, uncomment the relevant sections in the Bash script.
- If **package preview/review** is not required, you can safely remove the corresponding preview sections from the Ansible playbook.

---

## 📁 Repository Structure

```

Patch-Linux-Servers/
├── patch_linux_servers_json.sh     # Interactive Bash wrapper
├── patch_linux_servers_Json.yml    # Ansible playbook (JSON report)
├── hosts                           # Ansible inventory
├── patch_report.json               # Json report file
└── README.md

````

---

## ⚙️ Prerequisites

### Control Node Requirements
- Ansible 2.12 or later
- Python 3.x
- SSH access to all target hosts
- `sudo` or `dzdo` available (based on environment)

### Managed Node Requirements
- Python installed
- Supported package managers:
  - `dnf` / `yum` (RHEL family)
  - `apt` (Ubuntu / Debian)

---

## 🧾 Inventory Configuration

Edit the `hosts` file to define target systems:

```ini
[linux]
server1.example.com
server2.example.com
````

---

## 🚀 Execution Guide

### Step 1: Make the Script Executable

```bash
chmod +x patch_linux_servers_json.sh
```

### Step 2: Run the Script

```bash
./patch_linux_servers_json.sh
```

---

## 🧑‍💻 Interactive User Prompts

During execution, the Bash wrapper will prompt for:

1. **Remote Ansible User**

   * Predefined users (`aduser01`–`aduser05`, `sandeep`, `ansible`)
   * Or a custom username

2. **Remote Become Method**

   * `sudo` or `dzdo`

3. **Consolidated JSON Report Path**

   * Example: `/tmp/patch_report.json` or current directory

---

## 🔧 Playbook Workflow

### 🔍 Initialization

* Creates a per-host JSON structure containing:

  * Host metadata
  * Upgrade status
  * Reboot status
  * Uptime details

---

### 🔍 Pre-Patching Phase

* Detects OS family
* Collects package facts
* Displays upgrade previews:

  * `dnf / yum` preview (RHEL)
  * `apt list --upgradable` (Ubuntu/Debian)

---

### ⬆️ Patching Phase

* Updates package cache
* Upgrades all packages to latest versions
* Tracks whether upgrades resulted in changes

---

### 🔁 Reboot Logic (Change-Based)

A reboot is performed **only if package upgrades caused changes**.

```yaml
- name: Reboot servers if required
  ansible.builtin.reboot:
    reboot_timeout: 1200
  when: upgrade_report_json.reboot.required
```

* No package changes → **No reboot**
* Package changes → **Reboot triggered**

Reboot status is recorded in the JSON report.

---

### ⏱ Post-Reboot Validation

* Waits for host availability
* Collects:

  * System boot time
  * Human-readable uptime
* Stores uptime data in JSON

---

## 📊 Consolidated JSON Report

A **single JSON file** is generated on the **control node** after all hosts are processed.

### JSON Report Structure

```json
{
  "generated_at": "2025-12-21T17:18:14Z",
  "hosts": [
    {
      "host": "server1.example.com",
      "os_family": "RedHat",
      "distribution": "AlmaLinux",
      "upgrade": {
        "changed": true,
        "packages": []
      },
      "reboot": {
        "required": true,
        "performed": true
      },
      "uptime": {
        "boot_time": "2025-12-21 22:33:38",
        "uptime_pretty": "up 17 minutes"
      }
    }
  ]
}
```

---

## 🔐 Security Best Practices

* Prefer **SSH key-based authentication**
* Use `--ask-pass` only when required
* Validate reboot impact in production environments
* Test thoroughly in **non-production systems**

---

## 🛠 Customization & Extensions

This framework can be extended to:

* Patch **specific packages only**
* Export reports to **CSV or HTML**
* Add **snapshot logic** (vCenter, etc.)
* Integrate **maintenance window enforcement**
* Add **email or Slack notifications**
* Push JSON reports to logging or SIEM systems or to remote server with sftp configuration

---

## ⚠️ Known Limitations

* Requires reboot privileges on managed nodes
* Performs full system upgrade (`*`)
* Snapshot handling is not included by design

---

## 👤 Author

* **Sandeep Reddy Bandela**
* **Linux | Ansible | Automation**




