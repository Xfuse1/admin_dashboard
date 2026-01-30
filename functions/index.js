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