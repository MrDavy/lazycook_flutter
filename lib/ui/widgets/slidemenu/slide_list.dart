import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:lazycook/ui/widgets/base_state.dart';
import 'package:lazycook/ui/widgets/easy_refresh_header.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_item.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_list_model.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_menu.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_model.dart';
import 'package:lazycook/ui/widgets/typedef.dart';
import 'package:provider/provider.dart';

class SlideListView<T> extends StatefulWidget {
  final IndexedWidgetBuilder separatorBuilder;
  final EdgeInsetsGeometry padding;
  final SlideListModel<T> model;
  final WidgetsCreator menus;
  final WidgetCreator child;
  final OnItemTap onTap;
  final EasyRefreshController controller;
  final Function onLoad;
  final Function onRefresh;
  final ViewCreateFunc emptyView;
  final ViewCreateFunc refreshHeader;
  final ViewCreateFunc refreshFooter;

  const SlideListView(
      {Key key,
      @required this.separatorBuilder,
      this.padding,
      @required this.model,
      this.menus,
      this.child,
      this.onTap,
      this.controller,
      this.onLoad,
      this.onRefresh,
      this.emptyView,
      this.refreshHeader,
      this.refreshFooter})
      : super(key: key);

  @override
  SlideListViewState<T> createState() => new SlideListViewState<T>();
}

class SlideListViewState<T> extends BaseState<SlideListView> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        widget?.model?.closeLast();
      });
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      enableControlFinishRefresh: true,
      enableControlFinishLoad: true,
      emptyWidget: widget.emptyView(context),
      header: widget.refreshHeader ?? easyHeader(),
      footer: widget.refreshFooter ?? easyFooter(),
      controller: widget.controller,
      topBouncing: true,
      bottomBouncing: true,
      scrollController: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: ListView.separated(
            shrinkWrap: true,
            padding: widget.padding ??
                EdgeInsets.symmetric(
                    horizontal: width(12), vertical: height(12)),
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: widget.separatorBuilder ??
                (context, index) => Container(
                      color: Colors.black,
                    ),
            itemCount: widget.model.list.length,
            itemBuilder: (context, index) {
              return Container(
                child: ChangeNotifierProvider<ListItem<T>>.value(
                  value: widget.model.list[index],
                  child: Consumer<ListItem<T>>(
                    builder: (context, model, _) {
                      ///注意：当列表带分页的时候，每次notifyListeners()的时候，
                      ///已经加载的item是会重复利用的，因此这里不能给已经加载的item配置新的controller
                      ///如果删除了或增加了item项，需要重新配置controller
                      if (model.controller == null ||
                          (widget.model.onDataSetChanged ?? false)) {
                        var controller = SlideController()
                          ..addListener((state) {
                            if (state == OpenState.OPEN) {
                              widget.model?.open(index);
//                                  logger.log("打开了 $index");
                            } else if (state == OpenState.START) {
//                                  logger.log("开始了 $index");
                              if (widget.model?.openedPos != index) {
                                widget.model?.closeLast();
                              }
                            } else if (state == OpenState.CLOSE) {
                              //logger.log("关闭了 $index");
                              widget.model?.close(index);
                            }
                          });
                        model.controller = controller;
                      }
                      return SlideItem(
                        controller: model.controller,
                        onTap: () {
                          if (widget.model?.openedPos != -1) {
                            widget.model?.closeLast();
                          } else {
                            widget.onTap(index);
                          }
                        },
                        height: height(90),
                        menus: widget.menus(index),
                        child: widget.child(index),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        )
      ],
      onRefresh: widget.onRefresh,
      onLoad: widget.onLoad,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(SlideListView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}
