import 'package:flutter/material.dart';
import 'package:master_song/network/model/song_list_response.dart';
import 'package:master_song/network/network_request.dart';
import 'package:master_song/util/checks.dart';

class SongListProvider with ChangeNotifier{
  bool _isLoading = true;
  List<SongListResponseData> _data = [];
  List<SongListResponseData> _searchData = [];

  List<SongListResponseData>? get listSong => _data;
  bool? get isLoading => _isLoading;

  void getSong(int page)async{
    _isLoading = true;
    notifyListeners();
    final networkResponse = await NetworkRequest.getSong(page);
    _isLoading = false;
    if(networkResponse.state && isNotNullOrEmptyList(networkResponse.data)){
      _data = networkResponse.data!;
      notifyListeners();
    }else if(!networkResponse.state){

    }else{
      _data = [];
    }
  }

  void getSearchSong(String search)async{
    final networkResponse = await NetworkRequest.searchSong(search);
    // if(networkResponse.state || isNotNull){

    // }
  }
}