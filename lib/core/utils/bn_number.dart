/// ইংরেজি সংখ্যাকে বাংলা সংখ্যায় বদলায়: 12 -> ১২
String toBn(Object value) {
  const en = '0123456789';
  const bn = '০১২৩৪৫৬৭৮৯';
  var s = value.toString();
  for (var i = 0; i < en.length; i++) {
    s = s.replaceAll(en[i], bn[i]);
  }
  return s;
}

/// দামে কমা বসিয়ে বাংলা সংখ্যায় দেয়: 65000 -> ৬৫,০০০
String bnPrice(num value) {
  final s = value.toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      );
  return toBn(s);
}

/// বাংলা সংখ্যাকে ইংরেজি সংখ্যায় বদলায়: ০১৭ -> 017
String toEn(String value) {
  const en = '0123456789';
  const bn = '০১২৩৪৫৬৭৮৯';
  var s = value;
  for (var i = 0; i < bn.length; i++) {
    s = s.replaceAll(bn[i], en[i]);
  }
  return s;
}