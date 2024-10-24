import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrious/utils/enums.dart';
import 'package:qrious/utils/logger.dart';
import 'package:qrious/utils/map_extensions.dart';
import 'package:qrious/utils/mixins.dart';
import 'package:qrious/utils/string_extensions.dart';
import 'package:qrious/utils/widget_extensions.dart';
import 'package:qrious/widgets/barcode_display_data.dart';
import 'package:qrious/widgets/my_textformfield.dart';
import 'package:share_plus/share_plus.dart';

class CreateQrCodePage extends StatefulWidget {
  const CreateQrCodePage({super.key});

  @override
  State<CreateQrCodePage> createState() => _CreateQrCodePageState();
}

class _CreateQrCodePageState extends State<CreateQrCodePage>
    with AppBarMixin, UiInfoMixin {
  AvailableBarcodeTypes selectedQrCodeType = AvailableBarcodeTypes.url;
  final TextEditingController _data = TextEditingController();
  final TextEditingController _url = TextEditingController();
  final TextEditingController _text = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  //* Email
  final TextEditingController _emailAddress = TextEditingController();
  final TextEditingController _emailSubject = TextEditingController();
  final TextEditingController _emailBody = TextEditingController();

  //* SMS
  final TextEditingController _sms = TextEditingController();
  final TextEditingController _smsBody = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool get isUrl => selectedQrCodeType == AvailableBarcodeTypes.url;
  bool get isText => selectedQrCodeType == AvailableBarcodeTypes.text;
  bool get isPhone => selectedQrCodeType == AvailableBarcodeTypes.phone;
  bool get isEmail => selectedQrCodeType == AvailableBarcodeTypes.email;
  bool get isSms => selectedQrCodeType == AvailableBarcodeTypes.sms;

  final GlobalKey globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context,
          appBarTitle: "Create QR Code",
          centerTitle: false,
          actions: [
            TextButton(
                style: ButtonStyle(
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(
                        fontSize: 16.sp,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
                onPressed: () async {
                  if (_data.text.isEmpty) {
                    showSnackMessage(context, "No QR code generated yet");
                    return;
                  }
                  try {
                    // Capture the widget as an image
                    RenderRepaintBoundary boundary = globalKey.currentContext!
                        .findRenderObject() as RenderRepaintBoundary;
                    ui.Image image = await boundary.toImage();
                    ByteData? byteData =
                        await image.toByteData(format: ui.ImageByteFormat.png);
                    final pngBytes = byteData!.buffer.asUint8List();

                    // Get the document directory for saving the file
                    final directory = await getApplicationDocumentsDirectory();
                    final filePath = '${directory.path}/qr_code.png';
                    final file = File(filePath);

                    // Write the PNG bytes to a file
                    await file.writeAsBytes(pngBytes);

                    showSnackMessage(context, "Saved!");

                    Share.shareXFiles([XFile(file.path)]);

                    print('QR code saved as PNG: $filePath');
                  } catch (e) {
                    print('Error saving QR code: $e');
                  }
                },
                child: Text("Save")),
            SizedBox(
              width: 16.w,
            )
          ]),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              //? top spacing
              SizedBox(
                height: 32.h,
              ),

              InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (context) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              ...List<Widget>.generate(
                                  AvailableBarcodeTypes.values.length, (index) {
                                final type = AvailableBarcodeTypes.values
                                    .elementAt(index);
                                return ListTile(
                                  leading: Icon(type.icon),
                                  title: Text(
                                    type.name.capitalize,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      selectedQrCodeType = type;
                                    });

                                    log.i("Selected QR code type is: $type");
                                  },
                                );
                              }),
                              SizedBox(
                                height: 16.h,
                              ),
                            ],
                          ),
                        );
                      });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select QR code Type",
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selectedQrCodeType.icon,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),

                          // spacing

                          SizedBox(
                            width: 10.w,
                          ),

                          //? text
                          Text(
                            selectedQrCodeType.name.capitalize,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    // fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ).pSymmetric(),

              SizedBox(
                height: 24.h,
              ),

              // QrView
              RepaintBoundary(
                key: globalKey,
                child: Container(
                  color: Colors.white,
                  child: QrImageView(
                      data: _data.text,
                      version: QrVersions.auto,
                      // backgroundColor: Colors.white,
                      // size: 3200.r,
                      gapless: false,
                  
                      // embeddedImage: AssetImage('assets/app_icon/app_icon.png'),
                      // embeddedImageStyle: QrEmbeddedImageStyle(
                      //   size: Size(40, 40),
                      // ),
                      errorStateBuilder: (cxt, err) {
                        return Container(
                          padding: EdgeInsets.all(8.r),
                          child: Center(
                            child: Text(
                              err.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                ),
              ).pSymmetric(),

              SizedBox(
                height: 32.h,
              ),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    //? QR CODE FORM
                    if (isUrl || isText || isPhone || isEmail || isSms)
                      MyTextFormField(
                        controller: isUrl
                            ? _url
                            : isText
                                ? _text
                                : isEmail
                                    ? _emailAddress
                                    : isPhone
                                        ? _phone
                                        : _sms,
                        hintText: isUrl
                            ? "https://"
                            : isText
                                ? "Write something here..."
                                : isEmail
                                    ? "Recepient email"
                                    : "+234-123-456-7890",
                        minLines: isText ? 1 : null,
                        maxLines: isText ? 8 : null,
                        validator: isUrl
                            ? urlValidator
                            : isText || isPhone || isSms
                                ? nonNullValidator
                                : (value) {
                                    if (value == null ||
                                        !EmailValidator.validate(value))
                                      return 'Invalid email address';
                                    return null;
                                  },
                      ),

                    if (isEmail)
                      SizedBox(
                        height: 16.h,
                      ),

                    if (isEmail)
                      MyTextFormField(
                        controller: _emailSubject,
                        validator: (_) => null,
                        hintText: "Subject",
                      ),

                    if (isEmail || isSms)
                      SizedBox(
                        height: 16.h,
                      ),

                    if (isEmail || isSms)
                      MyTextFormField(
                        controller: isEmail ? _emailBody : _smsBody,
                        validator: (_) => null,
                        hintText: isEmail
                            ? "Compose email here (optional)"
                            : "Compose message here (optional)",
                        maxLines: 8,
                      )
                  ],
                ).pSymmetric(),
              ),

              SizedBox(
                height: 32.h,
              ),

              //? GENERATE QR CODE BUTTON
              ElevatedButton(
                onPressed: () {
                  final bool? isValid = formKey.currentState?.validate();

                  log.i("Is Valid: $isValid");
                  if (isValid != true) {
                    return;
                  }
                  switch (selectedQrCodeType) {
                    case AvailableBarcodeTypes.url:
                      _data.text = _url.text;
                      break;
                    case AvailableBarcodeTypes.text:
                      _data.text = _text.text;
                      break;
                    case AvailableBarcodeTypes.phone:
                      _data.text = "tel:${_phone.text}";
                      break;
                    case AvailableBarcodeTypes.email:
                      final data = {
                        "subject": _emailSubject.text,
                        "body": _emailBody.text
                      };

                      _data.text =
                          "mailto:${_emailAddress.text}?${data.toQueryString()}";

                      break;
                    case AvailableBarcodeTypes.sms:
                      _data.text =
                          "smsto:${_sms.text}${_smsBody.text.isNotEmpty ? ":${_smsBody.text}" : ""}";

                      break;
                    default:
                  }

                  /**
                   * 
                   */

                  setState(() {});
                },
                child: Text("Generate"),
              ),

              SizedBox(
                height: 64.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? nonNullValidator(value) {
    if (value?.isEmpty == true) return 'required';
    return null;
  }

  String? urlValidator(value) {
    log.i("VALIDATOR RUNNING WITH VALUE: $value");
    if (value?.startsWith('https://') != true) return "Invalid url";

    return null;
  }
}
