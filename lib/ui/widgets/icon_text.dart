import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconText extends StatelessWidget {
  double iconWidth = ScreenUtil.getInstance().setWidth(12);
  double iconHeight = ScreenUtil.getInstance().setWidth(12);
  TextStyle textStyle = TextStyle(
      color: Colors.black, fontSize: ScreenUtil.getInstance().setSp(12));
  String text;
  double space = 0.0;
  String assetImagePath = 'assets/images/icon-uncollected.png';

  IconText({
    this.iconWidth,
    this.iconHeight,
    this.text = '',
    this.textStyle,
    this.assetImagePath,
    this.space,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image(
          alignment: Alignment.center,
          width: iconWidth,
          height: iconHeight,
          image: AssetImage(assetImagePath),
        ),
        SizedBox(
          width: space,
        ),
        Flexible(
            child: Text(
          text,
          maxLines: 1,
          style: textStyle,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        )),
      ],
    );
  }
}
