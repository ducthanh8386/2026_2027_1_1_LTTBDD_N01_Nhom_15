import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/routes.dart';
import '../../data/remote/off_api_client.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/nutrition_provider.dart';

class BarcodeScanScreen extends StatefulWidget {
  final String? mealType;

  const BarcodeScanScreen({super.key, this.mealType});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  late final MobileScannerController _controller;
  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String barcode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final provider = context.read<NutritionProvider>();
    final food = await provider.lookupBarcode(barcode);

    if (!mounted) return;

    if (food != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.foodDetail,
        arguments: {
          'food': food,
          'mealType': widget.mealType,
        },
      );
    } else {
      _showErrorSheet(barcode, provider.lookupErrorType, provider.lookupErrorMessage);
    }
  }

  void _showErrorSheet(
    String barcode,
    OffExceptionType? errorType,
    String? rawMessage,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String message;

    switch (errorType) {
      case OffExceptionType.notFound:
        message = l10n.productNotFound;
        break;
      case OffExceptionType.noInternet:
        message = l10n.networkError;
        break;
      case OffExceptionType.timeout:
        message = l10n.timeoutError;
        break;
      default:
        message = rawMessage ?? l10n.networkError;
        break;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              'Mã vạch: $barcode',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _isProcessing = false;
                      });
                    },
                    child: Text(l10n.retry),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.manualFood,
                        arguments: {
                          'barcode': barcode,
                          'mealType': widget.mealType,
                        },
                      );
                    },
                    child: Text(l10n.manualEntry),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.barcodeScanner),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.amber : Colors.white,
            ),
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final b in barcodes) {
                final val = b.rawValue;
                if (val != null && val.trim().isNotEmpty) {
                  _handleBarcode(val.trim());
                  break;
                }
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.no_photography_outlined,
                        size: 64,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.cameraPermissionRequired,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.manualFood,
                            arguments: {
                              'mealType': widget.mealType,
                            },
                          );
                        },
                        icon: const Icon(Icons.edit_note),
                        label: Text(l10n.manualEntry),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scanner viewfinder overlay
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // Instruction and manual entry button
          Positioned(
            top: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.barcodePointCamera,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),

          // Bottom quick action button: Manual Entry
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.manualFood,
                  arguments: {
                    'mealType': widget.mealType,
                  },
                );
              },
              icon: const Icon(Icons.edit_note),
              label: Text(l10n.manualEntry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Loading overlay when fetching from OFF
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          l10n.searchingProduct,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
