import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:InTheatres/models_provider/models_provider.dart';
import 'package:provider/provider.dart';
import 'package:InTheatres/components/animator.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
final Shader linearGradient = LinearGradient(
  colors: <Color>[Color.fromARGB(100, 13, 216,60), Color.fromARGB(100, 13, 209, 180), Color.fromARGB(100, 0, 212, 255)],
).createShader(Rect.fromLTWH(75.0, 50.0, 200.0, 70.0));

class _HomeScreenState extends State<HomeScreen>

    with SingleTickerProviderStateMixin {

  AnimationController _animationController;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var subscription;
  var connectionStatus;

  @override
  void initState() {

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    super.initState();

  }


  // function to toggle circle animation
  changeThemeMode(bool theme) {
    if (!theme) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reverse(from: 1.0);
    }
  }
  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // to get size
    var size = MediaQuery.of(context).size;

    // style
    var cardTextStyle = TextStyle(
        fontFamily: "Montserrat Regular",
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: themeProvider.themeMode().textColor);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
          children: <Widget>[
            Container(

              width: size.width,
              height: size.height * .3,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    alignment: Alignment.topCenter,
                    image: AssetImage('assets/images/top_header.png')),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: size.height * .015,right: size.height * .015, bottom: size.height * .005),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: size.height * 0.10,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.bars,color: Colors.white,size: 20),



                          AutoSizeText(
                            'IN THEATERS',
                            style: TextStyle(
                                fontFamily: "Railway",
                                color: Colors.white,
                                fontSize: 17,
                            ),
                          ),
                          Icon(FontAwesomeIcons.slidersH,color: Colors.white,size: 20,),
                        ],
                      ),
                    ),

                    //add listview here


                  ],
                ),
              ),
            ),

            Container(

              child: Padding(
                padding:  EdgeInsets.only(bottom: size.height * 0.045),
                child: Align(
                  alignment: FractionalOffset.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: (){_launchURL();},
                        child: Text("© Developed by icodex",
                          style: new TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient),
                        ),),

                      ZAnimatedToggle(
                        values: ['☀', '🌙'],
                        onToggleCallback: (v) async {
                          await themeProvider.toggleThemeData();
                          setState(() {});
                          changeThemeMode(themeProvider.isLightTheme);
                        },
                      ),],),
                ),
              ),
            ),

          ],
        ),


    );
  }
  //external links to form, developer contact etc.
  _launchURL() async {
    const url = 'https://www.instagram.com/_icodex_/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}


