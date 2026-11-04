import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showError(String message) {
  Get.snackbar(
    'Oops',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
  );
}

void showSuccess(String message) {
  Get.snackbar(
    'Done',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
  );
}