import 'package:best_flutter_ui_templates/fitness_app/models/tabIcon_data.dart';
// import 'package:best_flutter_ui_templates/fitness_app/training/training_screen.dart';
import 'package:best_flutter_ui_templates/views/camera_stream_view.dart';
import 'package:best_flutter_ui_templates/views/historial_view.dart';
import 'package:best_flutter_ui_templates/views/humidity_view.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'fitness_app_theme.dart';
// import 'my_diary/my_diary_screen.dart';

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<Widget> tabViews = [];
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  Widget tabBody = Container(
    color: FitnessAppTheme.background,
  );

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = RegistroRiegoView(animationController: animationController);
    tabViews = [
      RegistroRiegoView(animationController: animationController), // index 0
      CameraStreamView(animationController: animationController), // index 1
      HumidityView(animationController: animationController), // index 2
      Container(
        // ejemplo para el tab 4
        alignment: Alignment.center,
        child: const Text("Configuración", style: TextStyle(fontSize: 22)),
      ),
    ];

    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {},
          changeIndex: (int index) {
            animationController?.reverse().then<dynamic>((data) {
              if (!mounted) return;
              setState(() {
                tabIconsList.forEach((tab) => tab.isSelected = false);
                tabIconsList[index].isSelected = true;
                tabBody = tabViews[index];
              });
              animationController?.forward();
            });
          },
        ),
      ],
    );
  }
}
