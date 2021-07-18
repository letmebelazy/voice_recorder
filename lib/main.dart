import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' as io;
import 'package:voice_recorder/file_list_page.dart';

// 플레이어는 다른 페이지로 독립시켰기 때문에 main.dart에 있던 플레이어 관련 기존 코드들은 모두 삭제

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Recorder(),
    );
  }
}

typedef Func = void Function();

class Recorder extends StatefulWidget {
  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  String fileName = '';
  String path = '';
  List<dynamic> fileNameList = [];

  @override
  void initState() {
    openTheRecorder();

    super.initState();
  }

  @override
  void dispose() {
    _mRecorder!.closeAudioSession();
    _mRecorder = null;

    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print('directory.path:::::${directory.path}');
    return directory.path;
  }

  void getFileNameList() async {
    var filePath = await _localPath;
    setState(() {
      fileNameList = io.Directory('$filePath/').listSync();
    });
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openAudioSession();
    _mRecorderIsInited = true;
  }

  void record() async {
    // 현재 시간을 파일명으로 저장
    path = await _localPath;
    fileName = '$path/${DateTime.now().toString().replaceAll(RegExp(r'\D'), '')}.acc';

    _mRecorder!
        .startRecorder(toFile: fileName, codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS)
        .then((value) => setState(() {}));
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {});
    });
  }

  Func? getRecorderFunc() {
    if (!_mRecorderIsInited) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recorder Example')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3.0),
            padding: const EdgeInsets.all(3.0),
            height: 80.0,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.amber, border: Border.all(color: Colors.indigo, width: 3.0)),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: getRecorderFunc(),
                  child: Text(_mRecorder!.isRecording ? 'Stop' : 'Record'),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Text(_mRecorder!.isRecording ? 'Recording in progress' : 'Recorder is stopped')
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                getFileNameList();
              });
              fileNameList = await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => FileListPage(fileNameList)));
            },
            child: Text('File list'),
          ),
        ],
      ),
    );
  }
}
