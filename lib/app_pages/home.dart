import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
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
  String? url;

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
              Stack(
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
                            width: 2)),
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
                      child: IconButton(
                          onPressed: () => controller.switchCamera(),
                          icon: const Icon(
                            Icons.switch_camera_outlined,
                            size: 32,
                          )))
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              if (url != null && loadDataImmediately == false)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                url!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      // fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary),
                              )),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: url!));

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: const Text(
                                    "Url copied",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.only(
                                      bottom: 16, left: 16, right: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  duration: const Duration(milliseconds: 1500),
                                ));
                              },
                              icon: const Icon(Icons.copy))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                          onPressed: () {
                            launchUrl(Uri.parse(url!));
                          },
                          child: const Text("Launch Url")),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  void _handleBarcode(BarcodeCapture event) {
    // final image = event.
    print("N E W   B A R C O D E   E V E N T");
    final BarcodeType barcodeType = event.barcodes.first.type;
    print(event.barcodes.first.type);

    switch (barcodeType) {
      case BarcodeType.url:
        setState(() {
          url = event.barcodes.first.url!.url;

          print('Url in set state is $url');

          print(
              "Show hidden column: ${url != null && loadDataImmediately == false}");
        });
        if (loadDataImmediately) _launchUrl(url!);
        break;
      default:
    }

    // url = null;
  }

  Future<void> _launchUrl(String uri) async {
    if (!await launchUrl(Uri.parse(uri))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Cannot launch url: $uri"),
        duration: const Duration(milliseconds: 1000),
      ));
    }
  }
}
