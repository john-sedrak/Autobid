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
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
