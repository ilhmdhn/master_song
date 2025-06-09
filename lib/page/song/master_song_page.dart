import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:master_song/network/model/choosed_song.dart';
import 'package:master_song/network/model/song_list_response.dart';
import 'package:master_song/network/network_request.dart';
import 'package:master_song/util/checks.dart';

class MasterSongPage extends StatefulWidget {
  const MasterSongPage({super.key});
  static const routeName = 'song-list';

  @override
  State<MasterSongPage> createState() => _MasterSongPageState();
}

class _MasterSongPageState extends State<MasterSongPage> {
  final PagingController<int, SongListResponseData> _pagingController =
      PagingController(
    getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
    fetchPage: (pageKey) => NetworkRequest.getSong(pageKey),
  );

  VlcPlayerController? _videoPlayerController;
  String? _currentVideoUrl;
  ChoosedSong? choosedSong;

  @override
  void dispose() {
    _pagingController.dispose();
    _videoPlayerController?.dispose();
    _positionTimer?.cancel();
    super.dispose();
  }

  Future<void> _playVideo(SongListResponseData item) async {
    String singer = item.detail?.singSatu??'UNKNOWN';
    
    if(isNotNullOrEmpty(item.detail?.singDua)){
      singer = '$singer, ${item.detail?.singDua}';
    }

    if (isNotNullOrEmpty(item.detail?.singTiga)) {
      singer = '$singer, ${item.detail?.singTiga}';
    }

    if (isNotNullOrEmpty(item.detail?.singEmpat)) {
      singer = '$singer, ${item.detail?.singEmpat}';
    }

    if (isNotNullOrEmpty(item.detail?.singLima)) {
      singer = '$singer, ${item.detail?.singLima}';
    }

    choosedSong = ChoosedSong(
      song: item.detail?.song??'UNKNOWN', 
      singer: singer,
      id: item.detail?.songId??'UNKNOWN',
      fileName: item.name, 
      fileExt: item.extention
    );
    final url = 'http://192.168.1.189:3333/song/stream?name=${item.name}&ext=${item.extention}';

    if (_currentVideoUrl == url) return;

    try {
      final oldController = _videoPlayerController;
      _videoPlayerController = null;
      setState(() {});

      await oldController?.stop();
      await oldController?.dispose();
    } catch (e) {
      print('DEBUG: error stopping previous controller: $e');
    }

    final newController = VlcPlayerController.network(
      url,
      hwAcc: HwAcc.auto,
      autoPlay: true,
      allowBackgroundPlayback: false,
    );

    setState(() {
      _videoPlayerController = newController;
      _currentVideoUrl = url;
    });
    _startPositionTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: PagingListener(
              controller: _pagingController,
              builder: (context, state, fetchNextPage){
                return PagedListView<int, SongListResponseData>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index){ 
                      String singer = item.detail?.singSatu ?? 'UNKNOWN';
                      if (isNotNullOrEmpty(item.detail?.singDua)) {
                        singer = '$singer, ${item.detail?.singDua}';
                      }

                      if (isNotNullOrEmpty(item.detail?.singTiga)) {
                        singer = '$singer, ${item.detail?.singTiga}';
                      }

                      if (isNotNullOrEmpty(item.detail?.singEmpat)) {
                        singer = '$singer, ${item.detail?.singEmpat}';
                      }

                      if (isNotNullOrEmpty(item.detail?.singLima)) {
                        singer = '$singer, ${item.detail?.singLima}';
                      }

                      return InkWell(
                        onTap: () => _playVideo(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          color: choosedSong?.fileName == item.name && choosedSong?.fileExt == item.extention? Colors.amber :Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.detail?.song ?? '',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                maxLines: 2,
                              ),
                              Text(
                                singer,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                              ),
                              Text(
                                '${item.name}.${item.extention}',
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                              ),
                              Container(
                                width: double.infinity,
                                height: 0.3,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                );
              }
            ),
          ),
          Expanded(
            flex: 3,
            child: _videoPlayerController != null && choosedSong != null?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VlcPlayer(
                    controller: _videoPlayerController!,
                    aspectRatio: 16 / 9,
                    placeholder: const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(formatDuration(_currentPosition)),
                                SliderTheme(
                                  data: SliderThemeData(overlayShape:SliderComponentShape.noOverlay),
                                  child: Slider(                                  
                                    activeColor: Colors.blue,
                                    value: _currentPosition.inMilliseconds.toDouble(),
                                    max: _totalDuration.inMilliseconds.toDouble().clamp(0, double.infinity),
                                    onChanged: (value) {
                                      _videoPlayerController?.setTime(value.toInt());
                                    },
                                  ),
                                ),
                              Text(formatDuration(_totalDuration)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: () async {
                                  final newPosition = _currentPosition - const Duration(seconds: 10);
                                  await _videoPlayerController?.setTime(newPosition.inMilliseconds);
                                },
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;
                                  final isPlaying = await _videoPlayerController!.isPlaying();
                                  if (isPlaying??false) {
                                    await _videoPlayerController!.pause();
                                  } else {
                                    await _videoPlayerController!.play();
                                  }

                                  setState(() {});
                                },
                                icon: FutureBuilder<bool?>(
                                  future: _videoPlayerController != null && _videoPlayerController!.value.isInitialized? _videoPlayerController!.isPlaying(): Future.value(false),
                                  builder: (context, snapshot) {
                                    final isPlaying = snapshot.data ?? false;
                                    return Icon(isPlaying ? Icons.pause : Icons.play_arrow);
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                onPressed: () async {
                                  final newPosition = _currentPosition + const Duration(seconds: 10);
                                  await _videoPlayerController?.setTime(newPosition.inMilliseconds);
                                },
                              ),
                             (_videoPlayerController != null &&
                                          _videoPlayerController!
                                              .value.isInitialized)
                                      ? FutureBuilder<Map<int, String>>(
                                          future: _videoPlayerController!.getAudioTracks(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return const SizedBox();
                                            }

                                            final tracks = snapshot.data!;
                                            int? selectedTrack;

                                            return Column(
                                              children: [
                                                DropdownButton<int>(
                                                  hint: Text('Audio track'),
                                                  value: selectedTrack,
                                                  items:
                                                      tracks.entries.map((entry) {
                                                    return DropdownMenuItem<int>(
                                                      value: entry.key,
                                                      child: Text(entry.value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (int? value) {
                                                    if (value != null) {
                                                      _videoPlayerController
                                                          ?.setAudioTrack(value);
                                                      setState(() {
                                                        selectedTrack = value;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                      : const SizedBox(),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  choosedSong!.song,
                                  style: const TextStyle( fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  choosedSong!.singer,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '${choosedSong!.fileName}.${choosedSong!.fileExt}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            :
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Pilih lagu untuk diputar"),
              ),
          )
        ],
      ),
    );
  }

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  Timer? _positionTimer;

  void _startPositionTracking() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_videoPlayerController != null) {
        final position = await _videoPlayerController!.getPosition();
        final duration = await _videoPlayerController!.getDuration();
        setState(() {
          _currentPosition = position;
          _totalDuration = duration;
        });
      }
    });
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

}