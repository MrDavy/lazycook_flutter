import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazycook/application.dart';
import 'package:lazycook/config/providers_setup.dart';
import 'package:lazycook/core/viewmodels/config/local.dart';
import 'package:lazycook/core/viewmodels/person/about.dart';
import 'package:lazycook/core/viewmodels/person/login/user_model.dart';
import 'package:lazycook/ui/pages/home.dart';
import 'package:lazycook/ui/pages/person.dart';
import 'package:lazycook/ui/route/routers.dart';
import 'package:lazycook/ui/shared/colors.dart';
import 'package:lazycook/ui/shared/styles.dart';
import 'package:lazycook/ui/widgets/custom_state.dart';
import 'package:lazycook/ui/widgets/no_splash_factory.dart';
import 'package:lazycook/utils/logger.dart';
import 'package:provider/provider.dart';

class LazyCookApp extends StatelessWidget {
  final logger = Logger("LazyCookApp");

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: _build(context),
    );
  }

  Widget _build(context) {
    return Consumer<LocalModel>(
      builder: (context, localModel, _) {
        return MaterialApp(
          title: '懒大厨',
//          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            splashFactory: NoSplashFactory(),
//              splashColor: accentColor,
            primaryColor: primaryColor,
            primaryColorDark: primaryColorDark,
            platform: TargetPlatform.iOS,
            errorColor: warnColor,
            accentColor: accentColor,
            textTheme: Theme.of(context).textTheme,
          ),
          home: MyHomePage(),
//          initialRoute: Routers.root,
          onGenerateRoute: Application.router.generator,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends CustomState<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(),
//    Circle(),
//    Basket(),
    PersonPage(),
  ];

  @override
  Widget buildWidget(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 375, height: 667, allowFontScaling: false)
          ..init(context);
    Application.context = context;

    ///注册路由拦截器
    Application.router.interceptor =
        () => Provider.of<UserModel>(context, listen: false).hasUser;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: generateItems(),
        currentIndex: _currentIndex,
        selectedFontSize: sp(10),
        unselectedFontSize: sp(10),
        unselectedItemColor: Color(0xff656565),
        selectedItemColor: Color(0xffff9900),
        selectedLabelStyle: textStyle(fontSize: sp(10)),
        unselectedLabelStyle: textStyle(fontSize: sp(10)),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
    );
  }

  generateItems() {
    final List<BottomNavigationBarItem> _list = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('assets/images/nav-home-off.png'),
            width: width(28),
            height: width(28),
            fit: BoxFit.fitWidth,
          ),
          activeIcon: Image(
            image: AssetImage('assets/images/nav-home-on.png'),
            width: width(28),
            height: width(28),
            fit: BoxFit.fitWidth,
          ),
          title: Text('首页')),
//      BottomNavigationBarItem(
//          icon: Image(
//            image: AssetImage('assets/images/nav-circle-off.png'),
//            width: 24,
//            height: 24,
//            fit: BoxFit.cover,
//          ),
//          activeIcon: Image(
//            image: AssetImage('assets/images/nav-circle-on.png'),
//            width: 24,
//            height: 24,
//            fit: BoxFit.cover,
//          ),
//          title: Text('厨圈')),
//      BottomNavigationBarItem(
//          icon: Image(
//            image: AssetImage('assets/images/nav-basket-off.png'),
//            width: 24,
//            height: 24,
//            fit: BoxFit.cover,
//          ),
//          activeIcon: Image(
//            image: AssetImage('assets/images/nav-basket-on.png'),
//            width: 24,
//            height: 24,
//            fit: BoxFit.cover,
//          ),
//          title: Text('菜篮子')),
      BottomNavigationBarItem(
          icon: Image(
            image: AssetImage('assets/images/nav-mine-off.png'),
            width: width(28),
            height: width(28),
            fit: BoxFit.fitWidth,
          ),
          activeIcon: Image(
            image: AssetImage('assets/images/nav-mine-on.png'),
            width: width(28),
            height: width(28),
            fit: BoxFit.fitWidth,
          ),
          title: Text('我的')),
    ];
    return _list;
  }
}
