import 'package:flutter/material.dart';
import 'package:lazycook/ui/widgets/base_state.dart';
import 'package:lazycook/ui/widgets/provider_widget.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_menu.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_model.dart';
import 'package:lazycook/utils/logger.dart';

class SlideItem extends StatefulWidget {
  final List<SlideMenu> menus;
  final double height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final VoidCallback onTap;
  final SlideController controller;

  const SlideItem(
      {Key key,
      this.menus,
      this.height,
      this.margin,
      this.padding,
      this.child,
      this.onTap,
      this.controller})
      : super(key: key);

  @override
  _SlideItemState createState() => _SlideItemState();
}

class _SlideItemState extends BaseState<SlideItem>
    with SingleTickerProviderStateMixin {
//最小有效移动距离
  static const double MIN_MOVE_DISTANCE = 30;

  //最小有效移动速度
  static const double MIN_MOVE_SPEED = 200;

  //向左滑动的最大距离
  double maxDistance = 0;

  //向右滑动的最大距离
  double minDistance = 0;

  AnimationController _animationController;

  SlideNotifier _slideNotifier;

  @override
  void initState() {
    logger = Logger("${runtimeType.toString()}");
    maxDistance = 0;
    widget?.menus?.forEach((menu) {
      maxDistance += menu.width;
    });
    maxDistance *= -1;
    maxDistance += SlideMenu.SPACE;

    _slideNotifier = SlideNotifier();
    _animationController = AnimationController(
        vsync: this,
        lowerBound: maxDistance,
        upperBound: minDistance,
        duration: Duration(milliseconds: 200))
      ..addListener(() {
//        logger.log(
//            "动画：value = ${_animationController
//                .value}，_openState = ${_slideNotifier.state}");

        _slideNotifier
            ?.updateOffset(_animationController.value - _slideNotifier.offset);
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller?._bindState(this);
    return ProviderWidget<SlideNotifier>(
      model: _slideNotifier,
      onModelReady: (model) {
        model.maxDistance = maxDistance;
      },
      builder: (context, model, child) {
        //logger.log("state = ${model.state}");
        widget.controller.onStateChanged(model.state);
        return Container(
          child: (widget?.menus == null || widget?.menus?.isEmpty == true)
              ? widget.child
              : GestureDetector(
                  onHorizontalDragStart: (DragStartDetails details) {
                    _slideNotifier?.onDragStart(details.localPosition.dx);
                    widget.controller.onStateChanged(OpenState.START);
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    _slideNotifier?.onDragUpdate(details.localPosition.dx);
                    _slideNotifier?.updateOffset(details.delta.dx);
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    widget.controller.onStateChanged(OpenState.END);
                    var velocity = details.velocity.pixelsPerSecond.dx;
                    var direction = model.direction;
                    if (velocity < -MIN_MOVE_SPEED) {
                      //offset -> maxDistance，要走的距离为maxDistance-offset
                      _swipeToOpen(model.maxDistance);
                    } else if (velocity > MIN_MOVE_SPEED) {
                      //offset -> minDistance，要走的距离为offset
                      _swipeToClose();
                    } else {
//                      logger.log("自动完成 state = ${model.state}");
                      if (direction == 1) {
                        ///向左
                        if (model.getMoveDx() > MIN_MOVE_DISTANCE ||
                            model.lastState == OpenState.OPEN) {
                          _swipeToOpen(model.maxDistance);
                        } else if (model.lastState == OpenState.CLOSE) {
                          _swipeToClose();
                        }
                      } else {
                        ///向右
                        if (model.getMoveDx() > MIN_MOVE_DISTANCE ||
                            model.lastState == OpenState.CLOSE) {
                          _swipeToClose();
                        } else if (model.lastState == OpenState.OPEN) {
                          _swipeToOpen(model.maxDistance);
                        }
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    //logger.log("onTap");
                    if (model.state == OpenState.CLOSE) {
                      widget.onTap();
                    } else if (model.state == OpenState.OPEN) {
                      _animationController?.value = _slideNotifier.offset;
                      _swipeToClose();
                    }
                  },
                  child: Container(
                    height: widget.height,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ...widget.menus,
                            SizedBox(
                              width: width(SlideMenu.SPACE),
                            )
                          ],
                        )),
                        Transform.translate(
                          offset: Offset((model?.offset ?? 0), 0),
                          child: Container(
                            child: widget.child,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  _swipeToOpen(maxDistance) {
    if (_slideNotifier.offset != maxDistance) {
//      logger.log("_swipeToOpen");
      _animationController?.value = _slideNotifier.offset;
      _animationController?.animateTo(maxDistance);
    }
  }

  _swipeToClose() {
    if (_slideNotifier.offset != 0) {
//      logger.log("_swipeToClose");
      _animationController?.value = _slideNotifier.offset;
      _animationController?.animateTo(0);
    }
  }

  close() {
//    logger.log("close");
    _swipeToClose();
  }

  closeImmediately() {
    _slideNotifier?.updateOffset(-maxDistance);
  }
}

class SlideController {
  Logger _logger;

  int index;

  _SlideItemState _state;

  StateCallback _callback;

  SlideController() {
    _logger = Logger("SlideController");
  }

  addListener(StateCallback listener) {
    this._callback = listener;
  }

  closeImmediately() {
    _state?.closeImmediately();
  }

  close() {
//    _logger.log(
//        "关闭 _state = ${_state}，model = ${_state
//            ?._slideNotifier}， lastState = ${getLastState()}");
    if (getLastState() == OpenState.OPEN) {
      _state?._swipeToClose();
    }
  }

  OpenState getLastState() {
    return _state?._slideNotifier?.lastState;
  }

  OpenState getOpenState() {
    return _state?._slideNotifier?.state;
  }

  _bindState(_SlideItemState state) {
    this._state = state;
  }

  void onStateChanged(OpenState state) {
//    _logger.log("onStateChanged state = $state");
    if (_callback != null) {
      _callback(state);
    }
  }
}

typedef StateCallback = dynamic Function(OpenState);
