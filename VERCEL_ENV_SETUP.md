# 🔐 Vercel Environment Variables Configuration

## Required Environment Variables for Admin Dashboard

Copy these variables to your Vercel project settings under:
**Project Settings → Environment Variables**

---

## 🔥 Firebase Configuration (Web Platform)

### Required for Firebase Services
```bash
# Firebase Web API Key
FIREBASE_API_KEY=AIzaSyBJl538WLhVGpdSbi5XcPIpdjRWX5N1SrM

# Firebase App ID
FIREBASE_APP_ID=1:896018485696:web:1b1a6225df119d2a087825

# Firebase Messaging Sender ID
FIREBASE_MESSAGING_SENDER_ID=896018485696

# Firebase Project ID
FIREBASE_PROJECT_ID=studio-2837415731-5df0e

# Firebase Auth Domain
FIREBASE_AUTH_DOMAIN=studio-2837415731-5df0e.firebaseapp.com

# Firebase Storage Bucket
FIREBASE_STORAGE_BUCKET=studio-2837415731-5df0e.firebasestorage.app
```

---

## 📋 How to Add These in Vercel

### Method 1: Via Vercel Dashboard (Recommended)
1. Go to your project on https://vercel.com
2. Click on **Settings** → **Environment Variables**
3. Add each variable one by one:
   - **Key**: Variable name (e.g., `FIREBASE_API_KEY`)
   - **Value**: The actual value from above
   - **Environment**: Select `Production`, `Preview`, and `Development`
4. Click **Save**

### Method 2: Via Vercel CLI
```bash
# Install Vercel CLI if not installed
npm i -g vercel

# Add environment variables
vercel env add FIREBASE_API_KEY
vercel env add FIREBASE_APP_ID
vercel env add FIREBASE_MESSAGING_SENDER_ID
vercel env add FIREBASE_PROJECT_ID
vercel env add FIREBASE_AUTH_DOMAIN
vercel env add FIREBASE_STORAGE_BUCKET
```

### Method 3: Using .env file (for testing locally)
Create a `.env.local` file in your project root:
```bash
FIREBASE_API_KEY=AIzaSyBJl538WLhVGpdSbi5XcPIpdjRWX5N1SrM
FIREBASE_APP_ID=1:896018485696:web:1b1a6225df119d2a087825
FIREBASE_MESSAGING_SENDER_ID=896018485696
FIREBASE_PROJECT_ID=studio-2837415731-5df0e
FIREBASE_AUTH_DOMAIN=studio-2837415731-5df0e.firebaseapp.com
FIREBASE_STORAGE_BUCKET=studio-2837415731-5df0e.firebasestorage.app
```
**⚠️ Important**: Add `.env.local` to `.gitignore` to prevent committing secrets!

---

## 🔒 Security Notes

1. **These are CLIENT-SIDE keys** - They will be visible in your web bundle
2. **Firebase Security Rules** protect your data, not the API keys
3. **Always configure Firestore Security Rules** properly:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null; // Require authentication
       }
     }
   }
   ```
4. **Enable App Check** in Firebase Console for additional security
5. **Restrict API Key** in Google Cloud Console to specific domains

---

## 🔄 After Adding Variables

1. **Redeploy your app**:
   ```bash
   vercel --prod
   ```
2. Or trigger a new deployment from Vercel dashboard
3. Environment variables are applied only on **new deployments**

---

## ✅ Verification

After deployment, check browser console:
- Firebase should initialize successfully
- No "Firebase: No Firebase App" errors
- Authentication and Firestore should work

---

## 📝 Additional Optional Variables

If you add more services later, you might need:

```bash
# Firebase Analytics (Optional)
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# Custom Domain (Optional)
PUBLIC_URL=https://yourdomain.com

# API Endpoints (Optional)
API_BASE_URL=https://api.yourdomain.com
```

---

## 🆘 Troubleshooting

### Error: "Firebase: No Firebase App '[DEFAULT]'"
- Make sure all variables are added correctly
- Redeploy after adding variables

### Error: "Firebase: API key not valid"
- Double-check the API key value
- Ensure no extra spaces in the value

### Error: "Firebase Auth Domain mismatch"
- Add your Vercel domain to Firebase Console:
  **Firebase Console → Authentication → Settings → Authorized domains**

---

## 📞 Support

For Firebase setup issues:
- Firebase Console: https://console.firebase.google.com/
- Vercel Documentation: https://vercel.com/docs/environment-variables
