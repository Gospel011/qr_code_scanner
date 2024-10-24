import 'package:flutter/material.dart';


class CreateQrCodePage extends StatefulWidget {
  const CreateQrCodePage({super.key});

  @override
  State<CreateQrCodePage> createState() => _CreateQrCodePageState();
}

class _CreateQrCodePageState extends State<CreateQrCodePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Create QR code page.'),
      ),
    );
  }
}