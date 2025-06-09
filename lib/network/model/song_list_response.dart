class SongListResponse{
  bool state;
  String message;
  List<SongListResponseData>? data;

  SongListResponse({
    required this.state,
    required this.message,
    this.data
  });

  factory SongListResponse.fromJson(Map<String, dynamic>json){
    return SongListResponse(
      state: json['state'], 
      message: json['message'],
      data: List<SongListResponseData>.from(
        (json['data'] as List).map((x) => SongListResponseData.fromJson(x))
      )
    );
  }
}

class SongListResponseData{
  String name;
  String extention;
  SongListResponseDetail? detail;

  SongListResponseData({
    required this.name,
    required this.extention,
    this.detail
  });

  factory SongListResponseData.fromJson(Map<String, dynamic>json){
    return SongListResponseData(
      name: json['name'],
      extention: json['extention'],
      detail: SongListResponseDetail.fromJson(json['song_detail'])
    );
  }
}

class SongListResponseDetail{
  String songId;
  String song;
  String singSatu;
  String? singDua;
  String? singTiga;
  String? singEmpat;
  String? singLima;

  SongListResponseDetail({
    required this.songId,
    required this.song,
    required this.singSatu,
    this.singDua,
    this.singTiga,
    this.singEmpat,
    this.singLima
  });

  factory SongListResponseDetail.fromJson(Map<String, dynamic>json){
    return SongListResponseDetail(
      songId: json['SongId'], 
      song: json['Song'], 
      singSatu: json['Sing1'],
      singDua: json['Sing2'],
      singTiga: json['Sing3'],
      singEmpat: json['Sing4'],
      singLima: json['Sing5']
    );
  }
}