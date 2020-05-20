import 'package:lazycook/core/services/api.dart';
import 'package:lazycook/core/viewmodels/base_model.dart';
import 'package:lazycook/utils/string_utils.dart';
import '../../../config/lazy_uri.dart';
class ConsumerService extends BaseModel {
  ConsumerService(API api) : super(api);

  String _title;

  String _content;

  bool _canBeSubmit = false;

  bool get canBeSubmit => _canBeSubmit;

  updateTitle(title) {
    _title = title;
    _update();
  }

  updateContent(content) {
    _content = content;
    _update();
  }

  _update() {
    _canBeSubmit =
        StringUtils.isNotEmpty(_content) && StringUtils.isNotEmpty(_title);
    notifyListeners();
  }

  Future submit() async {
    return api.feedback({"title": _title, "content": _content});
  }

  @override
  List<String> requests() {
    return [LazyUri.FEEDBACK];
  }
}
