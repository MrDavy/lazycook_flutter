import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:lazycook/utils/string_utils.dart';

///
/// 头像
///
class Avatar extends StatelessWidget {
  final double width;
  final double height;
  final double bgWidth;
  final double bgHeight;
  final Color bgColor;
  final ImageProvider image;
  final bool showShadow;
  final Widget hover;
  final Widget child;

  const Avatar(
      {Key key,
      this.image,
      this.child,
      @required this.width,
      @required this.height,
      @required this.bgWidth,
      @required this.bgHeight,
      this.bgColor,
      this.showShadow = false,
      this.hover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      ClipOval(
        child: Container(
          width: bgWidth,
          height: bgHeight,
          color: bgColor,
        ),
      ),
      ClipOval(
        child: image == null
            ? this.child
            : Image(
                image: image,
                width: width,
                height: width,
                fit: BoxFit.cover,
              ),
      )
    ];
    if (hover != null) {
      widgets.add(hover);
    }
    var child = Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[...widgets],
    );

    if (!showShadow) {
      return ClipOval(
        child: child,
      );
    } else {
      return Container(
        width: bgWidth,
        height: bgHeight,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[300], offset: Offset(1, 1), blurRadius: 2),
            BoxShadow(
                color: Colors.grey[300], offset: Offset(-1, -1), blurRadius: 2),
            BoxShadow(
                color: Colors.grey[300], offset: Offset(1, -1), blurRadius: 2),
            BoxShadow(
                color: Colors.grey[300], offset: Offset(-1, 1), blurRadius: 2),
          ],
        ),
        child: ClipOval(
          child: child,
        ),
      );
    }
  }
}
