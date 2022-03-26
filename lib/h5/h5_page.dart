/*
 * @FilePath     : /lib/h5/h5_page.dart
 * @Date         : 2022-03-26 19:03:45
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : H5Page
 */

import 'package:flutter/material.dart';
import 'package:flutter_w_log/flutter_w_log.dart';
import 'package:webview_flutter/webview_flutter.dart';

class H5Page extends StatefulWidget {
  final String url;
  final String title;
  const H5Page({Key? key, required this.url, this.title = "H5Page"})
      : super(key: key);

  @override
  State<H5Page> createState() => _H5PageState();
}

class _H5PageState extends State<H5Page> {
  String? _myUserAgent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebView(
        key: widget.key,
        onWebViewCreated: (WebViewController controller) {
          WLog.d('---------------onWebViewCreated');
          controller.runJavascriptReturningResult('navigator.userAgent').then(
            (userAgent) {
              final temp = userAgent.split("");
              temp.removeAt(0);
              temp.removeLast();
              String ua = temp.join();
              String erudaDebugUA = 'erudaDebug';
              _myUserAgent = "$ua $erudaDebugUA";
              WLog.d(_myUserAgent!);
              setState(() {});
            },
          );
        },
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (NavigationRequest request) {
          WLog.d('---------------navigationDelegate: $request');
          return NavigationDecision.navigate;
        },
        onPageStarted: (String url) {
          WLog.d('---------------onPageStarted: $url');
        },
        onPageFinished: (String url) {
          WLog.d('---------------onPageFinished: $url');
        },
        onProgress: (int progress) {
          WLog.d('---------------onProgress: $progress');
        },
        onWebResourceError: (WebResourceError error) {
          WLog.d('---------------onWebResourceError: ${error.description}');
        },
        userAgent: _myUserAgent,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        allowsInlineMediaPlayback: true,
      ),
    );
  }
}
