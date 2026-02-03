/**
 * Import function triggers from their respective submodules
 * and initialize the admin SDK.
 */
const {onDocumentWritten} = require("firebase-functions/v2/firestore");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const fcm = admin.messaging();
const db = admin.firestore();

/**
 * Send notification when an order status changes.
 */
exports.senddevices = functions.firestore
  .document("orders/{id}")
  .onUpdate((change, context) => {
    const data = change.after.data();
    const previousData = change.before.data();

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
exports.onDriverRequestCreated = functions.firestore
  .document("driver_requests/{driverId}")
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      const driverId = context.params.driverId;
      
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
exports.onDriverRequestStatusUpdated = functions.firestore
  .document("driver_requests/{driverId}")
  .onUpdate(async (change, context) => {
    try {
      const newData = change.after.data();
      const previousData = change.before.data();
      const driverId = context.params.driverId;
      
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
 * Update store rating when a review is created.
 */
exports.onReviewCreated = onDocumentWritten("store_reviews/{reviewId}",
  async (event) => {
    const data = event.data.after.data();
    const storeId = data ? data.storeId : null;
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