import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrious/utils/mixins.dart';

class CreateQrCodePage extends StatefulWidget {
  const CreateQrCodePage({super.key});

  @override
  State<CreateQrCodePage> createState() => _CreateQrCodePageState();
}

class _CreateQrCodePageState extends State<CreateQrCodePage> with AppBarMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, appBarTitle: "Create QR Code"),
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: QrImageView(
            data: 'This QR code has an embedded image as well',
            version: QrVersions.auto,
            size: 320,
            gapless: false,
            // embeddedImage: AssetImage('assets/app_icon/app_icon.png'),
            // embeddedImageStyle: QrEmbeddedImageStyle(
            //   size: Size(40, 40),
            // ),
          ),
        ),
      ),
    );
  }
}
