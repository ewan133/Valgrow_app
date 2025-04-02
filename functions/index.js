const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createUserAsAdmin = functions.https.onCall(async (data, context) => {
  const {email, password} = data;

  try {
    const userRecord = await admin.auth().createUser({
      email,
      password,
      emailVerified: true, // Optional: immediately verify if needed
    });

    // ✅ Use toJSON() to safely access full properties
    const user = userRecord.toJSON();

    return {
      uid: user.uid,
      email: user.email,
      message: "User created successfully",
    };
  } catch (error) {
    console.error("Error creating user:", error);
    throw new functions.https.HttpsError("unknown", error.message, error);
  }
});
