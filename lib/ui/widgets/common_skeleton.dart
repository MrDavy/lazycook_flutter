import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazycook/ui/shared/colors.dart';

num height(h) {
  return ScreenUtil.getInstance().setHeight(h);
}

num width(w) {
  return ScreenUtil.getInstance().setWidth(w);
}

Widget buildListSkeleton() {
  return ListView.builder(
      padding: EdgeInsets.all(0.0),
      itemCount: 10,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          child: _buildListSkeletonItem(),
        );
      });
}

Widget _buildListSkeletonItem() {
  return Container(
    height: height(90),
    color: white,
    margin: EdgeInsets.only(left: width(12), top: height(12), right: width(12)),
    child: Row(
      children: <Widget>[
        Container(
          height: double.infinity,
          width: height(120),
          decoration: BoxDecoration(
              color: skeletonGray,
              borderRadius: BorderRadius.all(Radius.circular(width(6)))),
        ),
        Flexible(
            child: Container(
          margin: EdgeInsets.only(
              left: width(10), bottom: height(10), top: height(10)),
          height: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Column(
                  ///标题、配料
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                        child: Container(
                      color: skeletonGray,
                      height: height(10),
                      width: width(50),
                    )),
                    SizedBox(
                      height: height(4),
                    ),
                    Flexible(
                        child: Container(
                      color: skeletonGray,
                      height: height(12),
                      width: double.infinity,
                    )),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: width(100),
                      height: height(12),
                      color: skeletonGray,
                    )
                  ],
                ),
              )
            ],
          ),
        ))
      ],
    ),
  );
}
