import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class FloatingVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FloatingVideoPlayer({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  State<FloatingVideoPlayer> createState() => _FloatingVideoPlayerState();
}

class _FloatingVideoPlayerState extends State<FloatingVideoPlayer> {
  late VlcPlayerController _controller;
  Offset position = const Offset(50, 100);
  double scale = 1.0;
  bool isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _controller = VlcPlayerController.network(
      widget.videoUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
      scale = isFullscreen ? 3.0 : 1.0;
      position = isFullscreen ? const Offset(0, 0) : const Offset(50, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              if (!isFullscreen) {
                setState(() {
                  position += details.delta;
                });
              }
            },
            onDoubleTap: toggleFullscreen,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: Container(
                width: 300,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: VlcPlayer(
                        controller: _controller,
                        aspectRatio: 16 / 9,
                        placeholder:
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    _buildControls()
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

Widget _buildControls() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              setState(() {});
            },
          ),
          Expanded(
            child: ValueListenableBuilder<VlcPlayerValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                final duration = value.duration.inSeconds.toDouble();
                final position = value.position.inSeconds.toDouble();

                return Slider(
                  min: 0,
                  max: duration > 0 ? duration : 1,
                  value: position.clamp(0, duration),
                  onChanged: (v) {
                    _controller.setTime((v * 1000).toInt());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}
