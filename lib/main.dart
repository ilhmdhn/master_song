import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:master_song/page/player/test_player.dart';
import 'package:master_song/page/song/song_list_page.dart';
import 'package:master_song/provider/song_list_provider.dart';
import 'package:master_song/provider/video_player_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoPlayerProvider()),
        ChangeNotifierProvider(create: (_) => SongListProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: SongListPage.routeName,
        routes: {
          MediaPlayer.routeName: (context) => const MediaPlayer(),
          SongListPage.routeName: (context) => const SongListPage()
        },
      ),
    );
  }
}
