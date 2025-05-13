
# DixitGuard 🔐

**DixitGuard** is a Linux-based security monitoring script that:
- Monitors Firebase in real-time
- Sends login alerts via Telegram
- Optionally takes and sends screenshots to Telegram
- Logs system details to Firebase

---

## 📦 Features

- ⏱ Real-time Firebase listener
- 🔔 Login alerts to Telegram
- 🖥 Screenshot capture and upload
- ☁️ Firebase JSON logging
- 🛠 Easy to configure and run

---

## ⚙️ Setup Instructions

### 1. 🔐 Create Telegram Bot
1. Open Telegram
2. Search `@BotFather`
3. Run `/newbot`
4. Save the **Bot Token** and your **Chat ID**

### 2. 🔥 Setup Firebase Realtime Database
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project → Realtime Database
3. Click on `Rules` and make sure you set:
```
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

> ⚠️ **Warning:** Public rules are for testing only. Use secure rules in production.

### 3. 🖥 Install Dependencies
```bash
sudo apt update
sudo apt install curl imagemagick
```

### 4. ✏️ Edit `login-alert.sh`
Set your credentials in the config section:

```bash
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
DB_URL="YOUR_FIREBASE_DATABASE_URL"
```

### 5. ✅ Run Script
```bash
chmod +x login-alert.sh
./login-alert.sh
```

---

## 🧪 Test Realtime Control
In your Firebase database:
- Set `dixitcoder` to `true` to trigger login alert
- Set `loginscreen` to `true` to take and send a screenshot

---

## 📂 Files

| File            | Description                                |
|-----------------|--------------------------------------------|
| `login-alert.sh`| Main script to monitor and act             |
| `HackComputer.sh`| Optional setup or configuration helper    |
| `README.md`     | This file                                   |

---

## 📄 License

MIT License

---

## 👤 Author

**Dixitcoder**  
[GitHub](https://github.com/dixitcoder) | [Website](https://dixitcoder-tools-ai.web.app)
