import 'package:lazycook/core/viewmodels/base_model.dart';

class StateShell<T> {
  ViewState state;
  T data;

  StateShell({this.state = ViewState.LOADING, this.data});
}
