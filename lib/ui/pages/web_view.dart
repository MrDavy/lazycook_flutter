import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Browser extends StatefulWidget {
  final String url;
  final String title;

  Browser({Key key, @required this.url, this.title}) : super(key: key);

  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends CustomState<Browser> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: white),
        brightness: Brightness.dark,
        title: new Text(
          widget.title,
          style: textStyle(color: white),
        ),
        actions: <Widget>[
          FutureBuilder<WebViewController>(
            builder: (BuildContext context,
                AsyncSnapshot<WebViewController> snapshot) {
              final webViewReady =
                  snapshot.connectionState == ConnectionState.done;
              return IconButton(
                icon: Icon(Icons.refresh),
                onPressed: webViewReady
                    ? () {
                        snapshot.data.reload();
                      }
                    : null,
              );
            },
            future: _controller.future,
          )
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onPageStarted: (String url) {
            dLog('Page started loading: $url');
            showLoading("加载中...");
          },
          onPageFinished: (String url) {
            dLog('Page finished loading: $url');
            hideLoading();
          },
          gestureNavigationEnabled: true,
        );
      }),
    );
  }
}
