const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationToRole = functions.https.onCall(async (data, context) => {

  const role = data.role;
  const title = data.title;
  const body = data.body;

  let collectionName = role === "providers" ? "Provider_details" : "users";

  const snapshot = await admin.firestore().collection(collectionName).get();

  const tokens = [];

  snapshot.forEach(doc => {
    const token = doc.data().fcmToken;
    if (token) {
      tokens.push(token);
    }
  });

  const payload = {
    notification: {
      title: title,
      body: body
    }
  };

  if(tokens.length > 0){
    await admin.messaging().sendEachForMulticast({
      tokens: tokens,
      notification: payload.notification
    });
  }

  return { success: true };
});