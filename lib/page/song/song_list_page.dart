import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:master_song/network/model/song_list_response.dart';
import 'package:master_song/network/network_request.dart';
import 'package:master_song/provider/video_player_provider.dart';
import 'package:provider/provider.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key});
  static const routeName = 'song-list';

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {

  final PagingController<int, SongListResponseData> _pagingController = PagingController(
    getNextPageKey: (state) => (state.keys?.last??0)+1,
    fetchPage: (pageKey) => NetworkRequest.getSong(pageKey),
  );

  VlcPlayerController? _videoPlayerController;

  @override
  void dispose() {
    if(_videoPlayerController != null){
      _videoPlayerController!.dispose();
    }
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: PagingListener(
              controller: _pagingController, 
              builder: (context, state, fetchNextPage)=>PagedListView<int, SongListResponseData>(
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, item, index) {
                    return InkWell(
                      onTap: ()async{
                        final url = 'http://192.168.1.189:3333/song/stream?name=${item.name}&ext=${item.extention}';
                          // Dispose controller lama dengan aman
                            if (_videoPlayerController != null) {
                              print('DEBUGGING START STOP AND DISPOSE');
                              try {
                                if (_videoPlayerController!.value.isInitialized) {
                                  print('DEBUGGING START STOP');
                                  await _videoPlayerController!.stop();
                                  print('DEBUGGING STOPPED');
                                }
                              } catch (e) {
                                print('DEBUGGING ERROR  STOPPED $e');
                              }
                                  print('DEBUGGING START DISPOSE');
                                  print('DEBUGGING DISPOSED');
                              await _videoPlayerController!.dispose();
                              setState(() {
                                _videoPlayerController=null;
                              });
                            }

                            VlcPlayerController newController = VlcPlayerController.network(
                              url,
                              autoPlay: true,
                              allowBackgroundPlayback: false,
                              hwAcc: HwAcc.full,
                            );

                            try {
                              print('DEBUGGING START INITIALIZE');

                              await newController.initialize();
                              print('DEBUGGING INITIALIZED');
                            } catch (e) {
                              print('DEBUGGING ERROR INITIALIZE $e');
                            }

                            print('DEBUGGING UPDATE CONTROLLER');
                            setState(() {
                              _videoPlayerController = newController;
                            });
                            print('DEBUGGING DONE');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        color: Colors.lightBlue.shade50,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(item.detail?.song??'', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                Text(' - ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                Text(item.detail?.singSatu??'', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(item.name),
                                Text('.'),
                                Text(item.extention)
                              ],
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
              )
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                  if (_videoPlayerController != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: VlcPlayer(
                        controller: _videoPlayerController!,
                        aspectRatio: 16 / 9,
                        placeholder: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else
                    const Center(child: Text("Pilih lagu untuk memutar"))
              ],
            )
          )
        ],
      ),
    );
  }
}