import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // ✅ Initialize Firebase Remote Config
  static Future<void> initRemoteConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero, // ✅ Force fetch new config on every app launch
    ));

    bool updated = await _remoteConfig.fetchAndActivate(); // ✅ Always fetch latest values

    print("🔄 Remote Config Updated: $updated");
  }

  // ✅ Get API Key
  static String getApiKey() {
    return _remoteConfig.getString('PHILSMS_API_KEY');
  }

  // ✅ Get Sender ID
  static String getSenderId() {
    return _remoteConfig.getString('SENDER_ID'); // Ensure this matches your Firebase key
  }
}
