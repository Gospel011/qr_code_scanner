import 'dart:async';
import 'dart:io';

import 'package:cross_file/src/types/interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrious/app_pages/create_qr_code_page.dart';
import 'package:qrious/utils/logger.dart';
import 'package:qrious/utils/mixins.dart';
import 'package:qrious/utils/string_extensions.dart';
import 'package:qrious/utils/widget_extensions.dart';
import 'package:qrious/widgets/barcode_display_data.dart';
import 'package:qrious/widgets/my_mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with WidgetsBindingObserver, UiInfoMixin, ImageMixin, AppBarMixin {
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
    // startController();
    startController();
  }

  void startController() {
    controller.start(
        cameraDirection: Platform.isIOS ? CameraFacing.front : null);
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

        startController();
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
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          tooltip: "Create QR code",
          onPressed: () {
            log.i("Implement creating qr codes");

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateQrCodePage(),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
      appBar: buildAppBar(context, appBarTitle: 'Q R I O U S'),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 64.h,
              ),
              ListTile(
                leading: Text(
                  "Load data immediately",
                  style: TextStyle(fontSize: 16.sp),
                ),
                trailing: Switch.adaptive(
                  value: loadDataImmediately,
                  onChanged: (value) {
                    setState(() {
                      loadDataImmediately = value;
                    });
                  },
                ),
              ).pSymmetric(),

              SizedBox(
                height: 16.sp,
              ),

              //? Mobile Scanner
              MyMobileScanner(
                  controller: controller,
                  onSwitchCameraPressed: () => controller.switchCamera()),

              //?
               SizedBox(
                height: 32.h,
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
                    //? Main Data
                    Row(
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
                          width: 10.w,
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
                    ).pSymmetric(),
                    if (isUrl)
                       SizedBox(
                        height: 16.h,
                      ),

                    //? Email Or SMS body
                    if ((isEmail && emailBody != null) ||
                        (isSms && sms != null))
                      BarcodeDisplayData(
                          text: isEmail ? emailBody : smsBody).pSymmetric(),
                    if ((isEmail && emailBody != null) ||
                        (isSms && sms != null))
                      SizedBox(
                        height: 16.h,
                      ),

                    //? Copy body
                    if (isEmail || isSms)
                      Padding(
                        padding:  EdgeInsets.only(
                            left: 16.0.w, right: 16.w, bottom: 16.h),
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

                    //? Launch Url button
                    if (isUrl)
                      ElevatedButton(
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
                                      : "Launch Url")).pSymmetric(),
                  ],
                ),

              SizedBox(
                height: 16.h,
              ),

              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  onPressed: analyzeQRCodeFromImageFile,
                  child: Text(
                    "Scan from gallery",
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500),
                  )).pSymmetric(),
              SizedBox(
                height: 64.h,
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
        log.i("Email display data: ${email?.path}");
        return email?.path;
      case BarcodeType.phone:
        log.i("Phone display data: ${phone?.path}");
        return phone?.path;

      case BarcodeType.sms:
        log.i(
            "Sms display data: ${sms?.path}, ${sms?.queryParameters['body']}");
        return sms?.path;
      default:
    }
    return null;
  }

  void _handleBarcode(BarcodeCapture event) {
    // final image = event.
    log.i("N E W   B A R C O D E   E V E N T");
    _barcodeType = event.barcodes.first.type;
    final Barcode code = event.barcodes.first;
    log.i(code.type);

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

        log.i("Phone: ${phone?.path}");
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

        log.i("SMS path: ${sms?.path}");
        log.i("SMS body: ${smsBody}");

        if (loadDataImmediately) _launchUrl(sms!);

        break;
      default:
        showSnackMessage(context,
            "We don't support ${_barcodeType?.name} qr codes at the momemt");
    }

    setState(() {});
  }

  Future<void> _launchUrl(dynamic uri) async {
    if (uri is! String && uri is! Uri) return;
    if (!await launchUrl(uri is Uri ? uri : Uri.parse(uri))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Cannot launch url: $uri"),
        duration: const Duration(milliseconds: 1000),
      ));
    }
  }

  void analyzeQRCodeFromImageFile() async {
    log.i("pick single image");

    final imageFile = await getSingleImageFromSource();

    if (imageFile == null) return;

    CroppedFile? croppedFile = await cropImage(context, imageFile);

    if (croppedFile == null) return;

    log.d("Image File, Cropped File: ${imageFile.path}, ${croppedFile.path}");

    final BarcodeCapture? event =
        await controller.analyzeImage(croppedFile.path);

    if (event == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleBarcode(event);
    });
  }
}
