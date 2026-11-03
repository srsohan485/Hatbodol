import 'package:get/get.dart';

class ChatPreview {
  final String name;
  final String initial; // ছবি না থাকলে বৃত্তে এই অক্ষর দেখাবে
  final String? avatar;
  final String time;
  final String productTitle;
  final String productImage;
  final String lastMessage;
  final int unread;
  final bool isBuying; // true = আমি কিনছি, false = আমি বিক্রি করছি

  const ChatPreview({
    required this.name,
    required this.initial,
    this.avatar,
    required this.time,
    required this.productTitle,
    required this.productImage,
    required this.lastMessage,
    this.unread = 0,
    required this.isBuying,
  });
}

class ChatListController extends GetxController {
  final tabs = const ['সব', 'কেনা', 'বেচা'];
  final tabIndex = 0.obs;

  // ডামি ডেটা, পরে এখানে API-র ডেটা বসবে
  final chats = <ChatPreview>[
    const ChatPreview(
      name: 'রাফসান আহমেদ',
      initial: 'রা',
      avatar: 'assets/images/avatar.jpg',
      time: '৬:০৪',
      productTitle: 'কাঠের পড়ার টেবিল',
      productImage: 'assets/images/table.jpg',
      lastMessage: 'আপনি: ঠিক আছে, আমি আগে জানাব।',
      unread: 1,
      isBuying: true,
    ),
    const ChatPreview(
      name: 'সাদিয়া রহমান',
      initial: 'সা',
      time: '৯:০৫',
      productTitle: 'স্যামসাং গ্যালাক্সি এ৫২',
      productImage: 'assets/images/phone.jpg',
      lastMessage: 'বক্স আর চার্জার দুটোই আছে।',
      unread: 2,
      isBuying: true,
    ),
    const ChatPreview(
      name: 'তানভীর হাসান',
      initial: 'তা',
      time: 'গতকাল',
      productTitle: 'গল্পের বইয়ের সংগ্রহ',
      productImage: 'assets/images/books.jpg',
      lastMessage: 'সবগুলো বই একসাথে নিতে পারবেন।',
      unread: 1,
      isBuying: false,
    ),
    const ChatPreview(
      name: 'মেহেদী ইসলাম',
      initial: 'মে',
      time: 'সোমবার',
      productTitle: 'আরামদায়ক অফিস চেয়ার',
      productImage: 'assets/images/chair.jpg',
      lastMessage: 'আপনি: ধন্যবাদ, কাল জানাচ্ছি।',
      isBuying: false,
    ),
  ].obs;

  void changeTab(int i) => tabIndex.value = i;

  /// 0 = সব, 1 = কেনা, 2 = বেচা
  List<ChatPreview> filter(List<ChatPreview> all, int tab) {
    if (tab == 1) return all.where((c) => c.isBuying).toList();
    if (tab == 2) return all.where((c) => !c.isBuying).toList();
    return all;
  }
}