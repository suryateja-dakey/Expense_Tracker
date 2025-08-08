import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  var isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
   Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
  final hasInternet = results.any((r) => r != ConnectivityResult.none);
  isConnected.value = hasInternet;

  if (!hasInternet) {
    _showNoInternetDialog();
  } else {
    if (Get.isDialogOpen ?? false) Get.back();
  }
});

    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    var result = await Connectivity().checkConnectivity();
    isConnected.value = result != ConnectivityResult.none;

    if (!isConnected.value) _showNoInternetDialog();
  }

  void _showNoInternetDialog() {
    if (Get.isDialogOpen ?? false) return; // prevent multiple dialogs

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Disable back button
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'No Internet Connection',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Please check your connection and try again.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                var result = await Connectivity().checkConnectivity();
                if (result != ConnectivityResult.none) {
                  isConnected.value = true;
                  if (Get.isDialogOpen ?? false) Get.back();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
