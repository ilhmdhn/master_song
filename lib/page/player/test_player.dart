import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class MediaPlayer extends StatefulWidget {
  const MediaPlayer({super.key});
  static const routeName = '/player';

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  late VlcPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VlcPlayerController.network(
      'http://192.168.1.189:3333/song/stream?name=1103845&ext=DAT',
      hwAcc: HwAcc.full,
      autoPlay: false,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.stopRendererScanning();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final isPlaying = await _videoPlayerController.isPlaying();
                  if (isPlaying??false) {
                    _videoPlayerController.pause();
                  } else {
                    _videoPlayerController.play();
                  }
                },
                child: Text('Play / Pause'),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: VlcPlayer(
                controller: _videoPlayerController,
                aspectRatio: 16 / 9,
                virtualDisplay: true,
                placeholder: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
