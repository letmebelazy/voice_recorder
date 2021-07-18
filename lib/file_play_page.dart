import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

// 녹음 파일 리스트 클릭 시 이동되는 플레이어 페이지
class FilePlayPage extends StatefulWidget {
  // FileListPage에서 건네받는 파일주소
  final file;
  FilePlayPage(this.file);

  @override
  _FilePlayPageState createState() => _FilePlayPageState();
}

class _FilePlayPageState extends State<FilePlayPage> {
  // 트랙은 initState에서 초기화할 것이므로 late 키워드 사용
  late Track track;

  @override
  void initState() {
    super.initState();
    // 받아온 파일주소가 파일주소가 아니라 파일이었으므로 이것을 주소처럼 변경해주기 위해 대충 바꿔놓음
    print(
        'track path is ${widget.file.toString().substring(7, widget.file.toString().length - 1)}');
    track =
        Track(trackPath: widget.file.toString().substring(7, widget.file.toString().length - 1));
  }

  @override
  Widget build(BuildContext context) {
    //사운드플레이어 위젯UI를 선언. 아까 선언한 트랙을 넣어줌으로서 파일 접근 가능
    // 위젯에 트랙만 넣어주면 play stop pause와 같은 기본 기능은 물론 버튼 슬라이더로 재생 위치를 이동 가능
    var player = SoundPlayerUI.fromTrack(
      track,
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.file
              .toString()
              .substring(widget.file.toString().length - 25, widget.file.toString().length - 1)),
        ),
        body: Column(
          children: [player],
        ));
  }
}
