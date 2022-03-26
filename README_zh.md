# offline_web_demo

使用 Dart 的 [`shelf`](https://pub.flutter-io.cn/packages/shelf) 包在移动设备上运行本地服务，实现手机端部署本地 web 网页

## 前言

出于人力的考虑，一些公司选用 Flutter 作为移动端 App 的开发技术。打通 Android 和 IOS 双端，一套代码打包两端。

旧迭代的原因，某些项目是由 h5（Vue） 写的业务模块。于是就产生了一个复杂的 Flutter 项目。

即由基础模块（登录/扫码/等基础模块）和 [webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter) 核心模块组成的，通过 JavascriptChannel 调用 Flutter `原生`功能的复杂混合应用。

> 没想到有一天 Flutter 也被称为原生。

> 话说有 web 人力的公司为什么不直接用 RN 呢。

此时出现了一个新需求，需要业务网页离线访问。这个在原生端十分常见，纯正的 Flutter 也能很好的实现。那么出现了一个问题，混合开发的话就麻烦了，业务 H5 怎么实现实现离线打开呢。

## 移动 Web 离线

网上的资料有很多，相关的技术也有很多,主要有两种 `PWA` / `file协议打开`

### PWA

首先想到的是 `PWA`(Progressive Web App)。web 的问题你自己解决。不管我 Flutter 的事情。但 PWA 限制过多，国内也没有太多运用，也没有太多实践例子。暂时先 pass 了。

### file 协议

使用`file:///$_distPath/index.html`的方式打开网页，这种方式也较为普遍，

```dart
WebView(
    key: widget.key,
    /// ###
    initialUrl: "file:///storage/emulated/0/Android/data/com.x.y/files/distOffline/index.html",
    /// ###
)
```

有两个问题

1. CORS 问题，在 Chromium 在某个版本增加了本地文件的请求也需要验证同源策略

   ```log
   Access to script at 'file:///F:/xxProjects/offline_web_demo/vue_demo/distOffline/js/chunk-vendors.js' from origin 'null' has been blocked by CORS policy: Cross origin requests are only supported for protocol schemes: http, data, chrome, chrome-extension, chrome-untrusted, https.
   ```

   手机端和电脑端表现一致，可能在老旧版本中有效

2. file 协议打开的文件固定地址，无法定位到路由

   无法打开如`http:///localhost:8089/#/about`

### shelf 本地服务

在网上搜索资料时，一个包进入了我的视野 [shelf](https://pub.flutter-io.cn/packages/shelf)

Dart 语言也是可以用于后端开发， [shelf](https://pub.flutter-io.cn/packages/shelf) 系列的包用与构建 web 服务

```dart
String _serverUrl = "";
HttpServer? server;
Future<String> _serveDist(BuildContext context, FileSystemEntity file) async {
  server?.close(force: true);
  await Future.delayed(const Duration(milliseconds: 200));
  Pipeline pipeline = const Pipeline();

  // add log
  pipeline = pipeline.addMiddleware(logRequests());

  // add static
  final staticHandler = createStaticHandler(
    file.parent.path,
    defaultDocument: basename(file.path),
    listDirectories: true,
  );
  final handler = pipeline.addHandler(staticHandler);

  // server
  server = await serve(handler, 'localhost', 8089);
  _serverUrl = "http://${server?.address.host}:${server?.port}";
  setState(() {});
  WLog.d('Serving at $_serverUrl');
  await Future.delayed(const Duration(milliseconds: 200));
  return _serverUrl;
}
```

```dart
WebView(
    key: widget.key,
    /// ### other args
    initialUrl: "http:///localhost:8089/",
    /// ###
)
```

```dart
WebView(
    key: widget.key,
    /// ### other args
    initialUrl: "http:///localhost:8089/#/about",
    /// ###
)
```

## 最后

本次例子使用的类似于 NodeJS 的 `express`的静态文件

```js
app.use(express.static(path.join(__dirname, "dist")));
```
