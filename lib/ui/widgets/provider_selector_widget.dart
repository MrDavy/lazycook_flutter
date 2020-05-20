import 'package:flutter/material.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:provider/provider.dart';

class ProviderSelectorWidget<A extends SampleModel, S> extends StatefulWidget {
  final Widget Function(BuildContext context, S value, Widget child) builder;
  final A model;
  final S Function(BuildContext, A) selector;
  final Widget child;
  final Function(A) onModelReady;

  ProviderSelectorWidget({
    Key key,
    this.selector,
    this.builder,
    this.model,
    this.child,
    this.onModelReady,
  }) : super(key: key);

  _ProviderSelectorWidgetState<A, S> createState() =>
      _ProviderSelectorWidgetState<A, S>();
}

class _ProviderSelectorWidgetState<A extends SampleModel, S>
    extends State<ProviderSelectorWidget<A, S>> {
  A model;

  @override
  void initState() {
    model = widget.model;

    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }

    super.initState();
  }

  @override
  void dispose() {
    widget.model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<A>(
      create: (context) => model,
      child: Selector<A, S>(
        selector: widget.selector,
        builder: widget.builder,
        child: widget.child,
      ),
    );
  }
}
