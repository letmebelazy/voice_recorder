import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

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

class Recorder extends StatefulWidget {
  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mPlayBackReady = false;
  final String _mPath = 'flutter_sound_example.aac';

  @override
  void initState() {
    _mPlayer!.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _mPlayer!.closeAudioSession();
    _mPlayer = null;

    _mRecorder!.closeAudioSession();
    _mRecorder = null;

    super.dispose();
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

  void record() {
    _mRecorder!
        .startRecorder(toFile: _mPath, codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS)
        .then((value) => setState(() {}));
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        _mPlayBackReady = true;
      });
    });
  }

  void play() {
    assert(_mPlayerIsInited && _mPlayBackReady && _mRecorder!.isStopped && _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(fromURI: _mPath, whenFinished: () => setState(() {}))
        .then((value) => setState(() {}));
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

  getRecorderFunc() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return;
    }
    _mRecorder!.isStopped ? record() : stopRecorder();
  }

  getPlayBackFunc() {
    if (!_mPlayerIsInited || !_mPlayBackReady || !_mRecorder!.isStopped) {
      return;
    }
    _mPlayer!.isStopped ? play() : stopPlayer();
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
                  onPressed: getRecorderFunc,
                  child: Text(_mRecorder!.isRecording ? 'Stop' : 'Record'),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Text(_mRecorder!.isRecording ? 'Recording in progress' : 'Recorder is stopped')
              ],
            ),
          ),
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
                  onPressed: getPlayBackFunc,
                  child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play'),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Text(_mPlayer!.isPlaying ? 'PlayBack is progress' : 'Player is stopped')
              ],
            ),
          )
        ],
      ),
    );
  }
}
