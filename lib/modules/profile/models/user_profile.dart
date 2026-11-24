import 'package:get/get.dart';
import 'package:hatbodol/core/services/profile_session.dart';

class UserProfile {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final String photo;
  final String area;
  final double? latitude;
  final double? longitude;
  final String phone;
  final bool isPhoneVerified;

  const UserProfile({
    this.id = 0,
    this.email = '',
    this.username = '',
    this.fullName = '',
    this.photo = '',
    this.area = '',
    this.latitude,
    this.longitude,
    this.phone = '',
    this.isPhoneVerified = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: (j['id'] as num?)?.toInt() ?? 0,
    email: (j['email'] ?? '').toString(),
    username: (j['username'] ?? '').toString(),
    fullName: (j['full_name'] ?? '').toString(),
    photo: (j['photo'] ?? '').toString(),
    area: (j['area'] ?? '').toString(),
    latitude: double.tryParse('${j['latitude']}'),
    longitude: double.tryParse('${j['longitude']}'),
    phone: (j['phone'] ?? '').toString(),
    isPhoneVerified: j['is_phone_verified'] == true,
  );

  /// নাম না থাকলে username
  String get displayName => fullName.isNotEmpty ? fullName : username;
}

/// সার্ভার থেকে পাওয়া প্রোফাইল ProfileSession এ বসায়,
/// যাতে ProfileGuard আবার "প্রোফাইল তৈরি করুন" পেজে না পাঠায়
void syncProfileSession(UserProfile p) {
  Get.find<ProfileSession>()
    ..setDraft(name: p.displayName, area: p.area, phone: p.phone, photo: null)
    ..complete();
}

/// ProfileSession নতুন করে বানায় (সাইন-আউট বা অ্যাকাউন্ট মোছার পর পুরনো ডেটা সরাতে)
void resetProfileSession() {
  Get.delete<ProfileSession>(force: true);
  Get.put(ProfileSession(), permanent: true);
}

/// error থেকে HTTP status code বের করে (না থাকলে null)
int? httpStatusOf(Object e) {
  try {
    return (e as dynamic).statusCode as int?;
  } catch (_) {
    return null;
  }
}