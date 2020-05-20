import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lazycook/ui/widgets/slidemenu/slide_menu.dart';

typedef Widget ViewCreateFunc(BuildContext context);

typedef Widget WidgetCreator(int index);
typedef List<SlideMenu> WidgetsCreator(int index);
typedef void OnItemTap(int index);

typedef void OnImageSourceSelect(ImageSource source);

typedef ValueCallback<T> = Function(T value);
