import 'package:flutter/material.dart';
import 'package:voice_recorder/file_play_page.dart';

class FileListPage extends StatefulWidget {
  // main.dart파일에서 FileListPage에 이동하며 파일네임리스트를 아규먼트로 보냄
  final List<dynamic> fileNameList;
  FileListPage(this.fileNameList);

  @override
  _FileListPageState createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  // 이전 페이지에서 파일 주소 목록을 전달 받았으므로 바로 파일 주소를 넣고 비동기적으로 파일을 삭제함
  void deleteFile(int index) async {
    final file = widget.fileNameList[index];
    if (await file.exists()) {
      await file.delete();
    } else {
      print('there is no such file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File list'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          // 원래 자동으로 아이콘이 생성되지만 우리는 Navigator를 pop시키며 파일네임리스트를 업데이트하여
          // 이전 페이지로 보내야하므로 따로 leading을 설정해주어 Navigator.pop에 리스트를 전달
          onPressed: () => Navigator.pop(
            context,
            widget.fileNameList,
          ),
        ),
      ),
      body: Container(
        child: ListView.builder(
            itemCount: widget.fileNameList.length,
            itemBuilder: (context, index) {
              return ListTile(
                  // 파일 주소에서 파일 이름만 뽑아내는 코드. 시간에 쫓기며 준비하다보니 다소 지저분함
                  title: Text(widget.fileNameList[index].toString().substring(
                      widget.fileNameList[index].toString().length - 25,
                      widget.fileNameList[index].toString().length - 1)),
                  onTap: () {
                    // 목록에서 파일을 선택하면 그 파일주소만 네비게이터에 넣어 다음 페이지에 전달
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FilePlayPage(widget.fileNameList[index])));
                  },
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text('선택한 파일을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel')),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    // 파일 삭제 후 리스트 아이템도 삭제해주어야 함
                                    deleteFile(index);
                                    widget.fileNameList.removeAt(index);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("삭제되었습니다."),
                                    ));
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text('OK'))
                          ],
                        );
                      }));
            }),
      ),
    );
  }
}
