import 'package:flutter/material.dart';

/// Loading overlay utility matching Java's ProgressDialog pattern
/// Shows a modal loading indicator with message
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// Show loading overlay
  /// Matches Java's showProgress("Loading...") method
  static void show(BuildContext context, {String message = 'Loading...'}) {
    if (_isShowing) return;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;
  }
  
  /// Hide loading overlay
  /// Matches Java's dismissProgress() method
  static void hide() {
    if (!_isShowing) return;
    
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
  
  /// Check if overlay is currently showing
  static bool get isShowing => _isShowing;
}
