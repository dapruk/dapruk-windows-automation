# 🧠 PowerShell Scheduler & File Sorter

Automate your file organization and maintenance tasks on Windows using PowerShell — no extra software needed!

This system includes:
- 🔃 A **task scheduler** that runs specific scripts on a daily or weekly basis.
- 📂 A **download sorter** that organizes your Downloads folder by file type.
- 🧹 **Task Logging**: All script output is saved to log files automatically.

---

## ⚙️ Features

### ✅ Download Sorter
- Automatically organizes your `Downloads` folder using a configurable `rules.json`.
- Supports a wide variety of file extensions.
- Logs moved files and newly created folders.

### ⏱️ Task Scheduler
- Runs selected scripts based on a `"daily"` or `"weekly"` schedule.
- Logs output to a specified file.
- JSON-driven config (`tasks.json`) makes it easy to manage.

---

---

## 🚀 Setup

### 1. Clone or Copy Scripts

Place all files under `C:\Scripts\` or any folder of your choice.

---

### 2. Add to PowerShell Profile (Optional)

Enable the sorter to be callable like a CLI command:

```powershell

function sort-downloads {
  & "C:\Scripts\sort_downloads\sort-downloads.ps1"
}

```
After that, you can run it from any PowerShell terminal with:
```
sort-downloads
```

3. Define Rules

Edit rules.json inside sort_downloads\:
```
{
  "Documents": ["*.pdf", "*.docx", "*.txt", "*.pbix"],
  "Images": ["*.jpg", "*.png"],
  "Misc": ["*.url", "*.bak"]
}
```
You can expand this list based on your file types.


4. Configure Scheduled Tasks

Edit tasks.json:
```
[
  {
    "name": "Sort Downloads",
    "script": "C:\\Scripts\\sort_downloads\\sort-downloads.ps1",
    "schedule": "daily",
    "active": true,
    "log": "C:\\Scripts\\Logs\\sort.log"
  },
  {
    "name": "Clean Old Files",
    "script": "C:\\Scripts\\file_maintenance\\cleanup-old.ps1",
    "schedule": "weekly",
    "active": true,
    "log": "C:\\Scripts\\Logs\\cleanup.log"
  }
]
```
5. Run the Scheduler

Use this to manually trigger all scheduled tasks:
```
.\scheduler.ps1
```
You can also add it to Windows Task Scheduler for daily/weekly automation.
  
