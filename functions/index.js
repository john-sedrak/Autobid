const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {applicationDefault} = require("firebase-admin/app");

admin.initializeApp({
  credential: applicationDefault(),
  // databaseURL: "https://autobid-64a4c-default-rtdb.firebaseio.com/"
});

exports.messageNotification = functions.firestore
    .document("Chats/{chatID}/Texts/{textID}")
    .onCreate(async (snapshot, context) => {
      const receiverSnapshotPromise = admin.firestore()
          .doc(snapshot.get("receiver")["path"]).get();
      const senderSnapshotPromise = admin.firestore()
          .doc(snapshot.get("sender")["path"]).get();

      const receiverSnapshot = await receiverSnapshotPromise;
      const receiverToken = receiverSnapshot.get("notifToken");

      const senderSnapshot = await senderSnapshotPromise;

      return admin.messaging().sendToDevice(
          receiverToken,
          {
            notification: {
              title: `New message from ${senderSnapshot.get("name")}`,
              body: snapshot.get("content"),
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
            data: {
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              sound: "default",
              status: "done",
              screen: "/messages",
              senderRef: senderSnapshot.ref.path,
            },
          },
      );
    });

exports.outBidNotification = functions.firestore
    .document("Cars/{carID}")
    .onUpdate( async (change, context) =>{
      const bidderID = change.before.get("bidderID");
      const newBidderID = change.after.get("bidderID");

      if (bidderID === newBidderID) {
        return;
      }
      const bidderSnapshot = await admin.firestore().doc("Users/"+bidderID)
          .get();
      const bidderToken = bidderSnapshot.get("notifToken");

      const sellerID = change.after.get("sellerID");
      const sellerSnapshot = await admin.firestore()
          .doc("Users/"+sellerID).get();
      const sellerToken = sellerSnapshot.get("notifToken");

      const newBid = change.after.get("currentBid");

      admin.messaging().sendToDevice(
          bidderToken,
          {
            notification: {
              title: `You lost your bid for the ${change.after.get("brand")} `+
                    `${change.after.get("model")}!`,
              body: `Reclaim this car by bidding higher than ${newBid} EGP.`,
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
            data: {
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              screen: "/bidRoot",
              carId: context.params.carID,
            },
          },
      );

      admin.messaging().sendToDevice(
          sellerToken,
          {
            notification: {
              title: `The bid for your ${change.after.get("brand")} `+
                    `${change.after.get("model")} has increased!`,
              body: `The current bid is ${newBid} EGP.`,
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
            data: {
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              screen: "/bidRoot",
              carId: context.params.carID,
            },
          },
      );
    });
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
