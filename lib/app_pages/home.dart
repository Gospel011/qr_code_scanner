import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrious/utils/mixins.dart';
import 'package:qrious/utils/string_extensions.dart';
import 'package:qrious/widgets/my_mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver, UiInfoMixin {
  late final MobileScannerController controller;
  StreamSubscription<Object>? _subscription;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  // ...

  bool loadDataImmediately = true;

  BarcodeType? _barcodeType;

  //? BarCode values
  String? url;
  String? text;
  Uri? email;
  String? emailBody;
  Uri? phone;
  Uri? sms;
  String? get smsBody => sms?.queryParameters['body'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Q R I O U S',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 64,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  leading: const Text(
                    "Load data immediately",
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Switch.adaptive(
                    value: loadDataImmediately,
                    onChanged: (value) {
                      setState(() {
                        loadDataImmediately = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),

              //? Mobile Scanner
              MyMobileScanner(
                  controller: controller,
                  onSwitchCameraPressed: () => controller.switchCamera()),

              //?
              const SizedBox(
                height: 32,
              ),

              //?
              if ((url != null && loadDataImmediately == false) ||
                  [
                    BarcodeType.text,
                    BarcodeType.email,
                    BarcodeType.phone,
                    BarcodeType.sms
                  ].contains(_barcodeType))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: BarcodeDisplayData(
                              text: displayData,
                              maxLines:
                                  _barcodeType == BarcodeType.url ? 1 : null,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: isEmail
                                        ? email!.path
                                        : isPhone
                                            ? phone!.path
                                            : isSms
                                                ? sms!.path
                                                : url!));

                                showSnackMessage(context,
                                    "${_barcodeType!.name.capitalize} copied",
                                    duration:
                                        const Duration(milliseconds: 1500));
                              },
                              icon: const Icon(Icons.copy))
                        ],
                      ),
                    ),
                    if (isUrl)
                      const SizedBox(
                        height: 16,
                      ),
                    if ((isEmail && emailBody != null) ||
                        (isSms && sms != null))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: BarcodeDisplayData(
                            text: isEmail ? emailBody : smsBody),
                      ),
                    if ((isEmail && emailBody != null) ||
                        (isSms && sms != null))
                      SizedBox(
                        height: 16,
                      ),
                    if (isEmail || isSms)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16, bottom: 16),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    Theme.of(context).colorScheme.onTertiary)),
                            onPressed: () {
                              if (emailBody == null) return;
                              Clipboard.setData(ClipboardData(
                                  text: isEmail ? emailBody! : smsBody!));

                              showSnackMessage(context,
                                  "${_barcodeType!.name.capitalize} body copied",
                                  duration: const Duration(milliseconds: 1500));
                            },
                            child: Text(
                              "Copy ${_barcodeType!.name} body",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                            )),
                      ),
                    if (isUrl)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                            onPressed: () {
                              launchUrl(isEmail
                                  ? email!
                                  : isPhone
                                      ? phone!
                                      : Uri.parse(url!));
                            },
                            child: Text(isEmail
                                ? "Open in email app"
                                : isPhone
                                    ? "Open phone app"
                                    : isSms
                                        ? "Open messaging app"
                                        : "Launch Url")),
                      ),
                    SizedBox(
                      height: 32,
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  bool get isEmail => _barcodeType == BarcodeType.email;
  bool get isPhone => _barcodeType == BarcodeType.phone;
  bool get isSms => _barcodeType == BarcodeType.sms;

  bool get isUrl {
    switch (_barcodeType) {
      case BarcodeType.url:
      case BarcodeType.email:
      case BarcodeType.sms:
      case BarcodeType.phone:
        return true;
      default:
        return false;
    }
  }

  String? get displayData {
    switch (_barcodeType) {
      case BarcodeType.url:
        return url;
      case BarcodeType.text:
        return text;
      case BarcodeType.email:
        print("Email display data: ${email?.path}");
        return email?.path;
      case BarcodeType.phone:
        print("Phone display data: ${phone?.path}");
        return phone?.path;

      case BarcodeType.sms:
        print(
            "Sms display data: ${sms?.path}, ${sms?.queryParameters['body']}");
        return sms?.path;
      default:
    }
    return null;
  }

  void _handleBarcode(BarcodeCapture event) {
    // final image = event.
    print("N E W   B A R C O D E   E V E N T");
    _barcodeType = event.barcodes.first.type;
    final Barcode code = event.barcodes.first;
    print(code.type);

    switch (_barcodeType) {
      //* For Http Urls
      case BarcodeType.url:
        url = code.url!.url;
        if (loadDataImmediately) _launchUrl(url!);
        break;

      //* For Text
      case BarcodeType.text:
        loadDataImmediately = false;
        text = code.displayValue;
        break;

      //* For Emails
      case BarcodeType.email:
        loadDataImmediately = false;

        emailBody = code.email?.body;
        email =
            Uri(scheme: 'mailto', path: code.email?.address, queryParameters: {
          "subject": code.email?.subject?.replaceAll('+', ' '),
          "body": code.email?.body?.replaceAll('+', ' ')
        });
        if (loadDataImmediately) _launchUrl(email!);

        break;

      //* For Phones
      case BarcodeType.phone:
        // loadDataImmediately = false;

        phone = Uri(scheme: 'tel', path: code.phone?.number);

        print("Phone: ${phone?.path}");
        if (loadDataImmediately) _launchUrl(phone!);

        break;

      //* For SMS
      case BarcodeType.sms:
        loadDataImmediately = false;

        sms = Uri(
          scheme: 'sms',
          path: code.sms?.phoneNumber,
          queryParameters: {"body": code.sms?.message},
        );

        print("SMS path: ${sms?.path}");
        print("SMS body: ${smsBody}");

        if (loadDataImmediately) _launchUrl(sms!);

        break;
      default:
        showSnackMessage(context,
            "We can't parse ${_barcodeType?.name} qr codes at the momemt");
    }

    setState(() {});
  }

  Future<void> _launchUrl(dynamic uri) async {
    if (!await launchUrl(uri is Uri ? uri : Uri.parse(uri))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Cannot launch url: $uri"),
        duration: const Duration(milliseconds: 1000),
      ));
    }
  }
}

class BarcodeDisplayData extends StatelessWidget {
  const BarcodeDisplayData({
    super.key,
    required this.text,
    this.maxLines,
  });

  final String? text;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8)),
        child: Text(
          text!,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              // fontSize: 16,
              color: Theme.of(context).colorScheme.onTertiary),
        ));
  }
}
