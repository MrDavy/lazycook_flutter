import 'package:flutter/material.dart';
import 'package:lazycook/ui/shared/styles.dart';

class Detail extends StatelessWidget {
  final int did;

  Detail(this.did);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              '注册',
              style: textStyle(color: Colors.black, fontSize: 17.0),
            ),
          ),
          preferredSize: Size.fromHeight(48.0)),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName(""));
          },
          child: Text("详情页点我"),
        ),
      ),
    );
  }
}
