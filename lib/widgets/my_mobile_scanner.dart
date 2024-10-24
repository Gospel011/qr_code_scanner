import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MyMobileScanner extends StatelessWidget {
  const MyMobileScanner(
      {super.key,
      required this.controller,
      required this.onSwitchCameraPressed});

  final MobileScannerController controller;
  final VoidCallback onSwitchCameraPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'QR code scanner',
      child: Stack(
        children: [
          // QR SCANNER
          Container(
            width: MediaQuery.sizeOf(context).width - 64,
            height: MediaQuery.sizeOf(context).width - 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).colorScheme.tertiary,
                    blurRadius: 10)
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: MobileScanner(
                controller: controller,
              ),
            ),
          ),

          // CAMERA FACING TOGGLE BUTTON
          Positioned(
            top: 8,
            right: 8,
            child: Tooltip(
              message: "Switch camera",
              child: IconButton(
                  onPressed: onSwitchCameraPressed,
                  icon: const Icon(
                    Icons.switch_camera_outlined,
                    size: 32,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
