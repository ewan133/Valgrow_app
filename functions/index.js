const { onCall } = require("firebase-functions/v2/https");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createUserAsAdmin = onCall(async (req, context) => {
  const { email, password, role } = req.data;

  if (!email || !password) {
    console.log('❌ Missing email or password', { email, password });
    throw new functions.https.HttpsError('invalid-argument', 'Email and password are required.');
  }

  try {
    const userRecord = await admin.auth().createUser({
      email,
      password,
      emailVerified: true,
      disabled: false,
    });

    await admin.auth().setCustomUserClaims(userRecord.uid, { role });

    return {
      uid: userRecord.uid,
      email: userRecord.email,
      role,
      message: "✅ User created successfully",
    };
  } catch (error) {
    console.error("❌ Error creating user:", error);
    throw new functions.https.HttpsError("internal", error.message, error);
  }
});

// ✅ NEW: Delete user
exports.deleteUserAsAdmin = onCall(async (req, context) => {
  const { uid } = req.data;

  if (!uid) {
    throw new functions.https.HttpsError('invalid-argument', 'UID is required.');
  }

  try {
    await admin.auth().deleteUser(uid);
    return { message: `✅ User with UID ${uid} deleted successfully.` };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// ✅ NEW: Disable or enable user
exports.toggleUserDisabledStatus = onCall(async (req, context) => {
  const { uid, disable } = req.data;

  if (!uid || typeof disable !== "boolean") {
    throw new functions.https.HttpsError('invalid-argument', 'UID and disable (true/false) are required.');
  }

  try {
    await admin.auth().updateUser(uid, { disabled: disable });
    return {
      message: `✅ User with UID ${uid} has been ${disable ? 'disabled' : 'enabled'}.`,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
