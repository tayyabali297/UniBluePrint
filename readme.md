## github clone 

Here is your polished, ready‑to‑paste **README.md** section:

---

# 📘 UniBluePrint — Team Git Workflow Guide

This guide explains how **any team member** can clone the UniBluePrint repository, work on it locally in VS Code, and push their updates back to GitHub.

Follow these steps exactly to stay in sync with the team.

---

## 🚀 1. Clone the Repository (First‑Time Setup)

1. Open **GitHub** and copy the repository URL:  
   ```
   https://github.com/tayyabali297/UniBluePrint.git
   ```

2. Open **VS Code**.

3. Press **Ctrl + Shift + P** → type **Git: Clone** → press Enter.

4. Paste the repo URL and choose a folder on your computer.

5. VS Code will ask:  
   **“Open the cloned repository?”**  
   → Click **Open**.

---

## 📂 2. Open the Project Terminal

Inside VS Code:

- Go to **Terminal → New Terminal**  
- Make sure the terminal path ends with the project folder, e.g.:

```
C:\Users\YourName\Downloads\UniBluePrint>
```

---

## 🔄 3. Pull the Latest Changes (Always Do This First)

Before doing any work:

```
git pull
```

This ensures your local copy matches the team’s latest version.

---

## ✏️ 4. Make Your Changes

Edit files, add new features, fix bugs — whatever your task is.

---

## 📌 5. Stage Your Changes

Check what changed:

```
git status
```

Add all updated files:

```
git add .
```

---

## 📝 6. Commit Your Work

Write a clear commit message:

```
git commit -m "Describe what you changed here"
```

Examples:
- `"Added login page UI"`
- `"Fixed navbar responsiveness"`
- `"Updated README instructions"`

---

## ⬆️ 7. Push Your Changes to GitHub

Send your work to the shared repo:

```
git push
```

If this is your first push, GitHub may ask you to log in or use a Personal Access Token.

---

## 🔁 8. Repeat This Workflow Every Time

Before starting new work:
```
git pull
```

After finishing your work:
```
git add .
git commit -m "message"
git push
```

---

## ⚠️ Common Issues

### **403 Permission Denied**
You are logged in as the wrong GitHub user.  
Ask the repo owner to add you as a collaborator and clear old credentials in Windows Credential Manager.

## testing ignore 
ssh key valid  

---
