import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/bn_number.dart';

class ChatMessage {
  final String text;
  final bool isMine;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isMine,
    required this.time,
  });
}

class ChatController extends GetxController {
  final inputCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  final quickReplies = const ['এখনো আছে?', 'দাম কমবে?', 'কোথায় পাবো?'];

  // ডামি মেসেজ, পরে এখানে API/সকেটের ডেটা বসবে
  final messages = <ChatMessage>[
    const ChatMessage(
      text: 'টেবিলটা কি এখনো আছে?',
      isMine: true,
      time: '৫:১৫',
    ),
    const ChatMessage(
      text: 'জি, আছে। আপনি দেখতে চান?',
      isMine: false,
      time: '৫:১৬',
    ),
    const ChatMessage(
      text: 'আজ বিকেলে কোথায় দেখতে পারব?',
      isMine: true,
      time: '৫:১৮',
    ),
    const ChatMessage(
      text: 'ধানমন্ডি ৫ নম্বরে। বিকেল ৫টার পর আসতে পারেন।',
      isMine: false,
      time: '৫:২০',
    ),
    const ChatMessage(
      text: 'ঠিক আছে, আমি আপনাকে জানাব।',
      isMine: true,
      time: '৫:২১',
    ),
  ].obs;

  @override
  void onReady() {
    super.onReady();
    _scrollToEnd();
  }

  /// preset দিলে সেটাই পাঠায় (কুইক রিপ্লাই), না দিলে ইনপুট বক্সের লেখা
  void send([String? preset]) {
    final text = (preset ?? inputCtrl.text).trim();
    if (text.isEmpty) return;

    messages.add(ChatMessage(text: text, isMine: true, time: _now()));
    if (preset == null) inputCtrl.clear();
    _scrollToEnd();
    // TODO: এখানে মেসেজ সার্ভারে পাঠাবে
  }

  void onMenu(String value) {
    if (value == 'report') {
      Get.snackbar('রিপোর্ট', 'রিপোর্ট পাঠানো হয়েছে');
    } else if (value == 'block') {
      Get.snackbar('ব্লক', 'ব্যবহারকারীকে ব্লক করা হয়েছে');
    }
  }

  String _now() {
    final n = DateTime.now();
    final h = n.hour % 12 == 0 ? 12 : n.hour % 12;
    final m = n.minute.toString().padLeft(2, '0');
    return toBn('$h:$m');
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }
}