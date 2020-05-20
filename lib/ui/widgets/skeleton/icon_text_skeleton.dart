import 'package:flutter/material.dart';
import 'package:lazycook/ui/shared/colors.dart';

enum IconDirection { LEFT, RIGHT, TOP, BOTTOM }

///文字骨架
class TextSkeleton extends StatelessWidget {
  final bool withIcon;
  final ImageProvider image;
  final double iconWidth;
  final double iconHeight;
  final double textWidth;
  final double textHeight;
  final IconDirection iconDirection;

  const TextSkeleton(
      {this.withIcon = false,
      this.image,
      this.iconWidth = 12.0,
      this.iconHeight = 12.0,
      this.textWidth = 26.0,
      this.textHeight = 12.0,
      this.iconDirection = IconDirection.LEFT});

  @override
  Widget build(BuildContext context) {
    var icon = Image(image: image, width: iconWidth, height: iconHeight);
    var text = Container(
        margin: EdgeInsets.only(left: 2.0),
        width: textWidth,
        height: textHeight,
        color: skeletonGray);
    var children = <Widget>[];
    if (iconDirection == IconDirection.LEFT) {
      if (withIcon) {
        children.add(icon);
      }
      children.add(text);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    } else if (iconDirection == IconDirection.RIGHT) {
      children.add(text);
      if (withIcon) {
        children.add(icon);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    } else if (iconDirection == IconDirection.TOP) {
      if (withIcon) {
        children.add(icon);
      }
      children.add(text);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    } else if (iconDirection == IconDirection.BOTTOM) {
      children.add(text);
      if (withIcon) {
        children.add(icon);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    } else {
      return text;
    }
  }
}
