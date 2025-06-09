import 'package:master_song/network/model/song_list_response.dart';
import 'dart:convert';
import 'package:http/http.dart';

class NetworkRequest{
  static Future<SongListResponse> getSong(int page)async{
    try{
      final url = Uri.parse('http://192.168.1.189:3333/song/$page');
      final apiResponse = await get(url);
      final convertedResult = json.decode(apiResponse.body);
      return SongListResponse.fromJson(convertedResult);
    }catch(e){
     return (SongListResponse(state: false, message: e.toString()));
    }
  }

  static Future<SongListResponse> searchSong(String search) async {
    try {
      final url = Uri.parse('http://192.168.1.189:3333/song/search?search=$search');
      final apiResponse = await get(url);
      final convertedResult = json.decode(apiResponse.body);
      return SongListResponse.fromJson(convertedResult);
    } catch (e) {
     return (SongListResponse(state: false, message: e.toString()));
    }
  }
}