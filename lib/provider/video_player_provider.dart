import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoPlayerProvider with ChangeNotifier {
  VlcPlayerController? _controller;
  bool _isVisible = false;
  String? _currentUrl;

  VlcPlayerController? get controller => _controller;
  bool get isVisible => _isVisible;

  void showPlayer(String url) {
    if (_currentUrl != url) {
      _controller?.dispose(); // dispose if new video
      _controller = VlcPlayerController.network(
        url,
        autoPlay: true,
        hwAcc: HwAcc.full,
        options: VlcPlayerOptions(),
      );
      _currentUrl = url;
    }

    _isVisible = true;
    notifyListeners();
  }

  void hidePlayer() {
    _controller?.pause();
    _isVisible = false;
    notifyListeners();
  }

  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void disposeController() {
    _controller?.dispose();
    _controller = null;
    _currentUrl = null;
    notifyListeners();
  }
}
