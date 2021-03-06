import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:lazycook/utils/string_utils.dart';

class LdcImage extends StatelessWidget {
  final String img;
  final num width;
  final num height;

  const LdcImage({Key key, this.img, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Logger("LdcImage").log("img = $img");
    if (StringUtils.isEmpty(img))
      return Image.asset("assets/images/icon-default.png",
          width: width, height: height);
    var scheme = Uri.parse(img).scheme;
    Logger("LdcImage").log("scheme = $scheme");
    return scheme == "http" || scheme == "https"
        ? CachedNetworkImage(
            placeholder: (context, url) => SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(),
            ),
            imageUrl: img,
            width: width,
            height: height,
            fit: BoxFit.contain,
          )
        : Image.file(File(img), width: width, height: height);
  }
}
