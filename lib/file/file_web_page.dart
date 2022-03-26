/*
 * @FilePath     : /lib/file/file_web_page.dart
 * @Date         : 2022-03-24 15:17:29
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : 文件模式网页
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_w_log/flutter_w_log.dart';
import 'package:path/path.dart';

class FileWebPage extends StatefulWidget {
  final String dirPath;
  const FileWebPage({Key? key, required this.dirPath}) : super(key: key);

  @override
  State<FileWebPage> createState() => _FileWebPageState();
}

class _FileWebPageState extends State<FileWebPage> {
  late Directory _locDir;
  final List<FileSystemEntity> _files = [];
  final ScrollController _ctrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WLog.d(widget.dirPath);
    getCurrentPathFiles(widget.dirPath);
  }

  void getCurrentPathFiles(String path) {
    _locDir = Directory(path);
    _files.clear();
    _files.addAll(_locDir.listSync());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("file_web_page")),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        controller: _ctrl,
        itemCount: _files.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return ListTile(
              leading: const Icon(Icons.arrow_back_ios_new),
              title: const Text(".."),
              onTap: () {
                if (_locDir.path == widget.dirPath) return;
                getCurrentPathFiles(_locDir.parent.path);
              },
            );
          } else if (FileSystemEntity.isDirectorySync(_files[index - 1].path)) {
            return _buildDirectoryItem(context, _files[index - 1]);
          } else {
            return _buildFileItem(context, _files[index - 1]);
          }
        },
      ),
    );
  }

  Widget _buildDirectoryItem(BuildContext context, FileSystemEntity file) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(file.path.substring(file.parent.path.length + 1)),
      subtitle: const Text("文件夹", style: TextStyle(fontSize: 12.0)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        getCurrentPathFiles(file.path);
      },
    );
  }

  Widget _buildFileItem(BuildContext context, FileSystemEntity file) {
    bool isIndexHtml = basename(file.path) == "index.html";
    return ListTile(
      leading: const Icon(Icons.description),
      title: Text(file.path.substring(file.parent.path.length + 1)),
      subtitle: const Text("文件", style: TextStyle(fontSize: 12.0)),
      trailing: isIndexHtml ? const Icon(Icons.language) : null,
      onTap: () {
        if (basename(file.path) == "index.html") {
          Navigator.of(context).pushNamed("/h5", arguments: {
            "url": "file:///${file.path}",
            "title": basename(file.parent.path),
          });
        }
      },
    );
  }
}
