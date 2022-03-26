import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_w_log/flutter_w_log.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'file/file_web_page.dart';
import 'h5/h5_page.dart';
import 'shelf/shelf_web_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: (RouteSettings s) {
        return MaterialPageRoute(
          builder: (BuildContext context) => _createPage(context, s),
          settings: s,
        );
      },
      onUnknownRoute: (RouteSettings s) {
        return MaterialPageRoute(
          builder: (BuildContext context) => Scaffold(
            appBar: AppBar(title: const Text("404")),
            body: const Center(child: Text("404")),
          ),
          settings: s,
        );
      },
      initialRoute: "/",
    );
  }

  Widget _createPage(BuildContext c, RouteSettings s) {
    switch (s.name) {
      case '/':
        return const MyHomePage(title: 'Flutter Demo Home Page');
      case '/h5':
        dynamic args = s.arguments ?? {};
        String url = args["url"] ?? "";
        String title = args["title"] ?? "";
        return H5Page(url: url, title: title);
      case '/file_web':
        dynamic args = s.arguments ?? {};
        String dirPath = args["dirPath"] ?? "";
        return FileWebPage(dirPath: dirPath);
      case '/shelf_web':
        dynamic args = s.arguments ?? {};
        String dirPath = args["dirPath"] ?? "";
        return ShelfWebPage(dirPath: dirPath);
      default:
        return Scaffold(
          appBar: AppBar(title: const Text("404")),
          body: const Center(child: Text("404")),
        );
    }
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    _counter++;
    setState(() {});
  }

  String _appDirPath = "";
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      getExternalStorageDirectory().then((value) {
        _appDirPath = value?.path ?? "/";
        setState(() {});
      });
    } else {
      getApplicationDocumentsDirectory().then((value) {
        _appDirPath = value.path;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              Text('$_counter', style: Theme.of(context).textTheme.headline4),
              ElevatedButton(
                child: const Text("Nav Baidu"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/h5", arguments: {
                    "url": "http:///www.baidu.com",
                    "title": "Baidu",
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(_appDirPath),
              ),
              if (_appDirPath != "")
                ElevatedButton(
                  child: const Text("UnZip Assets"),
                  onPressed: () {
                    _unZipAssets(context);
                  },
                ),
              if (_zipDirPath != "")
                ElevatedButton(
                  child: const Text("Nav FileWebPage"),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/file_web", arguments: {
                      "dirPath": _zipDirPath,
                    });
                  },
                ),
              if (_zipDirPath != "")
                ElevatedButton(
                  child: const Text("Nav ShelfWebPage"),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/shelf_web", arguments: {
                      "dirPath": _zipDirPath,
                    });
                  },
                ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _zipDirPath = "";
  void _unZipAssets(BuildContext context) async {
    ByteData data = await rootBundle.load("assets/vue_demo.zip");
    final b = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    final archive = ZipDecoder().decodeBytes(b);
    _zipDirPath = join(_appDirPath, "vue_demo");
    extractArchiveToDisk(archive, _zipDirPath);

    WLog.d('unZipAssets success: $_zipDirPath');
    setState(() {});
  }
}
