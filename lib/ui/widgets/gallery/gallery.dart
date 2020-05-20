import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:lazycook/config/config.dart';
import 'package:lazycook/ui/route/nav.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';

class GalleryData {
  String description;
  String url;

  GalleryData({this.description, this.url});

  factory GalleryData.fromJson(Map<String, dynamic> json) {
    return GalleryData(
      description: json['description'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['url'] = this.url;
    return data;
  }
}

class Gallery extends StatefulWidget {
  final List<GalleryData> list;
  final int initialIndex;

  const Gallery({Key key, this.list, this.initialIndex = 0}) : super(key: key);

  @override
  GalleryState createState() => new GalleryState();
}

class GalleryState extends CustomState<Gallery> {
  SwiperController _swiperController;

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: new AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        title: new Text(
          '',
        ),
      ),
      body: GestureDetector(
        onVerticalDragStart: (details) {},
        onVerticalDragUpdate: (details) {},
        onVerticalDragEnd: (details) {
          var velocity = details.velocity.pixelsPerSecond.dy;
          if (velocity > 300) {
            Nav.back();
          }
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Swiper(
            index: widget.initialIndex,
            controller: _swiperController,
            layout: SwiperLayout.DEFAULT,
            autoplay: false,
            loop: false,
            autoplayDisableOnInteraction: false,
//                  index: _currentIndex,
            scrollDirection: Axis.horizontal,
            itemCount: widget.list.length,
//            pagination: SwiperPagination(
//                alignment: Alignment.bottomCenter,
//                builder: DotSwiperPaginationBuilder(
//                  color: Colors.white,
//                  activeColor: Theme.of(context).accentColor,
//                  size: width(6),
//                  activeSize: width(6),
//                )),
            itemBuilder: (context, index) => Container(
              padding: EdgeInsets.symmetric(horizontal: width(8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    constraints:
                        BoxConstraints(maxHeight: ScreenUtil.screenWidthDp*.7),
                    margin: EdgeInsets.only(top: height(48)),
                    width: double.infinity,
                    child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                              color: skeletonGray,
                              width: double.infinity,
                              alignment: Alignment.center,
//                                child: SizedBox(
//                                  width: width(36),
//                                  height: width(36),
//                                  child: CircularProgressIndicator(),
//                                ),
                            ),
                        imageUrl: widget.list != null && widget.list.isNotEmpty
                            ? Config.envConfig().imgBasicUrl() +
                                widget.list[index].url
                            : "",
                        fit: BoxFit.fitWidth),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: height(30)),
                    child: Text(
                      widget.list[index].description,
                      style: textStyle(
                          color: white.withOpacity(.8),
                          fontSize: sp(14),
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ),
            onTap: (index) {},
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
  }

  @override
  void dispose() {
    super.dispose();
    _swiperController.dispose();
  }
}
