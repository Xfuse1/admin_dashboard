/**
 * One-time script to set Custom Claims for existing admins/superAdmins.
 * Run: node scripts/bootstrap_claims.js
 */
const admin = require("../functions/node_modules/firebase-admin");
const path = require("path");
const serviceAccountPath = "d:\\deliverzler\\studio-2837415731-5df0e-firebase-adminsdk-fbsvc-1b54822015.json";
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function bootstrap() {
  console.log("Starting Custom Claims bootstrap...\n");

  // Set claims for superAdmins
  const superAdminsSnap = await db
    .collection("users")
    .where("role", "==", "superAdmin")
    .get();

  for (const doc of superAdminsSnap.docs) {
    const uid = doc.id;
    const data = doc.data();
    console.log(`Setting superAdmin claims for: ${data.email} (${uid})`);
    await admin.auth().setCustomUserClaims(uid, {
      role: "superAdmin",
      admin: true,
    });
    console.log(`  Done!`);
  }

  // Set claims for admins
  const adminsSnap = await db
    .collection("users")
    .where("role", "==", "admin")
    .get();

  for (const doc of adminsSnap.docs) {
    const uid = doc.id;
    const data = doc.data();
    console.log(`Setting admin claims for: ${data.email} (${uid})`);
    await admin.auth().setCustomUserClaims(uid, {
      role: "admin",
      admin: true,
    });
    console.log(`  Done!`);
  }

  console.log(
    `\nAll done! ${superAdminsSnap.size} superAdmins + ${adminsSnap.size} admins updated.`
  );
  console.log(
    "IMPORTANT: All users must sign out and sign back in for claims to take effect."
  );
}

bootstrap()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error("Error:", e);
    process.exit(1);
  });
