/**
 * Import function triggers from their respective submodules
 * and initialize the admin SDK.
 */
const {
  onDocumentUpdated,
  onDocumentCreated,
  onDocumentDeleted,
  onDocumentWritten,
} = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

const fcm = admin.messaging();
const db = admin.firestore();

/**
 * Send notification when an order status changes.
 */
exports.senddevices = onDocumentUpdated("orders/{id}", (event) => {
  const data = event.data.after.data();
  const previousData = event.data.before.data();

  const topic = "general";
  const pickupOption = data.pickupOption;
  const deliveryStatus = data.deliveryStatus;
  const previousDeliveryStatus = previousData.deliveryStatus;

  if (pickupOption === "delivery" &&
      deliveryStatus === "upcoming" &&
      previousDeliveryStatus === "pending") {
    const userName = data.userName;
    const message = {
      notification: {
        title: "New Order!",
        body: `New Delivery Order from "${userName}" has been added.`,
      },
      data: {"routeLocation": "/home"},
    };

    return fcm.sendToTopic(topic, message);
  }
  return null;
});

/**
 * Create admin notification when a new driver request is submitted.
 */
exports.onDriverRequestCreated = onDocumentCreated(
  "driver_requests/{driverId}",
  async (event) => {
    try {
      const data = event.data.data();
      const driverId = event.params.driverId;

      // Get all admin users to notify them
      const adminsSnapshot = await db.collection("users")
        .where("role", "==", "admin")
        .get();

      const driverName = data.firstName && data.lastName
        ? `${data.firstName} ${data.lastName}`
        : data.email || "سائق جديد";

      const promises = [];
      adminsSnapshot.docs.forEach((adminDoc) => {
        const adminId = adminDoc.id;

        promises.push(
          db.collection("admin_notifications")
            .doc(adminId)
            .collection("notifications")
            .add({
              type: "driver",
              title: "سائق جديد",
              message: `السائق ${driverName} قدم طلب تسجيل جديد`,
              actionUrl: "/drivers",
              data: {
                driverId: driverId,
                driverName: driverName,
                email: data.email,
              },
              priority: "high",
              isRead: false,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              relatedId: driverId,
            })
        );
      });

      await Promise.all(promises);
      console.log(`Created driver registration notification for driver: ${driverId}`);
      return null;
    } catch (error) {
      console.error("Error creating driver notification:", error);
      return null;
    }
  });

/**
 * Create admin notification when a driver request status is updated.
 */
exports.onDriverRequestStatusUpdated = onDocumentUpdated(
  "driver_requests/{driverId}",
  async (event) => {
    try {
      const newData = event.data.after.data();
      const previousData = event.data.before.data();
      const driverId = event.params.driverId;

      // Only notify if status changed
      if (newData.status === previousData.status) {
        return null;
      }

      // Get all admin users to notify them
      const adminsSnapshot = await db.collection("users")
        .where("role", "==", "admin")
        .get();

      const driverName = newData.firstName && newData.lastName
        ? `${newData.firstName} ${newData.lastName}`
        : newData.email || "سائق";

      const statusMessages = {
        "approved": `تم الموافقة على السائق ${driverName}`,
        "rejected": `تم رفض طلب السائق ${driverName}`,
        "pending": `طلب السائق ${driverName} قيد المراجعة`,
        "suspended": `تم إيقاف السائق ${driverName}`,
      };

      const message = statusMessages[newData.status] ||
        `تحديث حالة السائق ${driverName}: ${newData.status}`;

      const promises = [];
      adminsSnapshot.docs.forEach((adminDoc) => {
        const adminId = adminDoc.id;

        promises.push(
          db.collection("admin_notifications")
            .doc(adminId)
            .collection("notifications")
            .add({
              type: "driver",
              title: "تحديث حالة سائق",
              message: message,
              actionUrl: "/drivers",
              data: {
                driverId: driverId,
                driverName: driverName,
                status: newData.status,
                email: newData.email,
              },
              priority: newData.status === "rejected" ? "high" : "medium",
              isRead: false,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              relatedId: driverId,
            })
        );
      });

      await Promise.all(promises);
      console.log(`Updated driver status notification for driver: ${driverId}`);
      return null;
    } catch (error) {
      console.error("Error updating driver notification:", error);
      return null;
    }
  });

/**
 * Update store rating when a review is created, updated, or deleted.
 */
exports.onReviewWritten = onDocumentWritten(
  "store_reviews/{reviewId}",
  async (event) => {
    // On delete, event.data.after.data() is undefined
    const afterData = event.data.after ? event.data.after.data() : null;
    const beforeData = event.data.before ? event.data.before.data() : null;
    const storeId = (afterData && afterData.storeId) ||
                    (beforeData && beforeData.storeId);
    if (!storeId) return null;
    return updateStoreRating(storeId);
  });

/**
 * Helper function to recalculate and update store rating.
 * @param {string} storeId - The ID of the store to update.
 */
async function updateStoreRating(storeId) {
  try {
    const reviewsSnapshot = await db
      .collection("store_reviews")
      .where("storeId", "==", storeId)
      .get();

    let totalRatings = 0;
    let ratingSum = 0;

    reviewsSnapshot.docs.forEach((doc) => {
      const rating = doc.data().rating;
      if (typeof rating === "number") {
        ratingSum += rating;
        totalRatings++;
      }
    });

    const averageRating = totalRatings > 0 ? ratingSum / totalRatings : 0;

    await db.collection("stores").doc(storeId).update({
      rating: parseFloat(averageRating.toFixed(1)),
      totalRatings: totalRatings,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Updated store ${storeId}: ${averageRating}`);
    return null;
  } catch (error) {
    console.error(`Error updating store ${storeId}:`, error);
    return null;
  }
}

/**
 * Create a new admin user (callable by superAdmin only).
 * 
 * SECURITY: Uses Custom Claims (NOT Firestore document) to verify superAdmin.
 * Custom Claims are set server-side only and cannot be tampered with by clients.
 */
exports.createAdmin = onCall(async (request) => {
  // 1. Must be authenticated
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولاً");
  }

  // 2. Verify caller is superAdmin via Custom Claims (tamper-proof)
  const callerClaims = request.auth.token;
  if (callerClaims.role !== "superAdmin") {
    throw new HttpsError(
      "permission-denied",
      "فقط Super Admin يمكنه إضافة مسؤولين"
    );
  }

  const callerUid = request.auth.uid;
  const { name, email, password } = request.data;

  // 3. Input validation
  if (!name || typeof name !== "string" || name.trim().length === 0) {
    throw new HttpsError("invalid-argument", "الاسم مطلوب");
  }
  if (!email || typeof email !== "string") {
    throw new HttpsError("invalid-argument", "البريد الإلكتروني مطلوب");
  }
  if (!password || typeof password !== "string" || password.length < 6) {
    throw new HttpsError(
      "invalid-argument",
      "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
    );
  }

  // 4. Validate email format server-side
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new HttpsError("invalid-argument", "البريد الإلكتروني غير صالح");
  }

  try {
    // 5. Create user in Firebase Auth using Admin SDK
    const userRecord = await admin.auth().createUser({
      email: email.trim().toLowerCase(),
      password: password,
      displayName: name.trim(),
    });

    // 6. Set Custom Claims for the new admin (tamper-proof role)
    await admin.auth().setCustomUserClaims(userRecord.uid, {
      role: "admin",
      admin: true,
    });

    // 7. Save admin data in Firestore (for display/query purposes only)
    const adminData = {
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: "admin",
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: callerUid,
    };

    await db.collection("users").doc(userRecord.uid).set(adminData);

    return {
      success: true,
      admin: {
        id: userRecord.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: "admin",
        isActive: true,
        createdBy: callerUid,
      },
    };
  } catch (error) {
    if (error.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "البريد الإلكتروني مستخدم بالفعل"
      );
    }
    if (error.code === "auth/invalid-email") {
      throw new HttpsError("invalid-argument", "البريد الإلكتروني غير صالح");
    }
    if (error.code === "auth/weak-password") {
      throw new HttpsError("invalid-argument", "كلمة المرور ضعيفة جداً");
    }
    console.error("Error creating admin:", error);
    throw new HttpsError("internal", `فشل إضافة المسؤول: ${error.message}`);
  }
});

/**
 * Delete an admin user (callable by superAdmin only).
 * 
 * SECURITY: Uses Custom Claims to verify superAdmin.
 * Deletes Firebase Auth account + Firestore document + clears claims.
 */
exports.deleteAdmin = onCall(async (request) => {
  // 1. Must be authenticated
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولاً");
  }

  // 2. Verify caller is superAdmin via Custom Claims (tamper-proof)
  const callerClaims = request.auth.token;
  if (callerClaims.role !== "superAdmin") {
    throw new HttpsError(
      "permission-denied",
      "فقط Super Admin يمكنه حذف مسؤولين"
    );
  }

  const callerUid = request.auth.uid;
  const { adminId } = request.data;

  if (!adminId || typeof adminId !== "string") {
    throw new HttpsError("invalid-argument", "معرف المسؤول مطلوب");
  }

  // 3. Prevent deleting yourself
  if (adminId === callerUid) {
    throw new HttpsError(
      "failed-precondition",
      "لا يمكنك حذف حسابك الخاص"
    );
  }

  try {
    // 4. Verify target is NOT a superAdmin (via Custom Claims, not Firestore)
    try {
      const targetUser = await admin.auth().getUser(adminId);
      const targetClaims = targetUser.customClaims || {};
      if (targetClaims.role === "superAdmin") {
        throw new HttpsError(
          "failed-precondition",
          "لا يمكن حذف Super Admin"
        );
      }
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      // User might not exist in Auth, continue to clean up Firestore
      console.warn(`Auth user ${adminId} not found in Auth`);
    }

    // 5. Delete from Firebase Auth
    try {
      await admin.auth().deleteUser(adminId);
    } catch (authError) {
      console.warn(`Could not delete Auth user ${adminId}: ${authError.message}`);
    }

    // 6. Delete from Firestore
    await db.collection("users").doc(adminId).delete();

    return { success: true };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    console.error("Error deleting admin:", error);
    throw new HttpsError("internal", `فشل حذف المسؤول: ${error.message}`);
  }
});

/**
 * Bootstrap: Set Custom Claims for an existing superAdmin.
 * 
 * Call this ONCE from Firebase console or a secure script to set the
 * initial superAdmin claims. After that, this function is no longer needed.
 * 
 * SECURITY: Only works if the caller's Firestore doc has role "superAdmin"
 * AND there are no other users with superAdmin custom claims yet.
 * This prevents abuse after initial setup.
 */
exports.bootstrapSuperAdmin = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول أولاً");
  }

  const callerUid = request.auth.uid;

  // Check if caller already has superAdmin claims (already bootstrapped)
  const callerClaims = request.auth.token;
  if (callerClaims.role === "superAdmin") {
    return { success: true, message: "أنت بالفعل Super Admin" };
  }

  // Verify in Firestore that this user is supposed to be superAdmin
  const callerDoc = await db.collection("users").doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.data().role !== "superAdmin") {
    throw new HttpsError(
      "permission-denied",
      "ليس لديك صلاحية"
    );
  }

  // Safety: Check no one else has superAdmin claims already
  // (list all users and check - limited to 1000 users max)
  const listResult = await admin.auth().listUsers(1000);
  const existingSuperAdmins = listResult.users.filter(
    (u) => u.customClaims && u.customClaims.role === "superAdmin"
  );

  if (existingSuperAdmins.length > 0) {
    throw new HttpsError(
      "failed-precondition",
      "يوجد Super Admin بالفعل. لا يمكن استخدام Bootstrap مرة أخرى."
    );
  }

  // Set claims
  await admin.auth().setCustomUserClaims(callerUid, {
    role: "superAdmin",
    admin: true,
  });

  return {
    success: true,
    message: "تم تعيينك كـ Super Admin. أعد تسجيل الدخول لتفعيل الصلاحيات.",
  };
});