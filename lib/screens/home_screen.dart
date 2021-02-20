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
import 'package:InTheatres/models/movie_response.dart';
import 'package:InTheatres/blocs/movie_bloc.dart';
import 'package:InTheatres/networking/api_response.dart';
import 'movie_details.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;



class HomeScreen extends StatefulWidget {

  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
final Shader linearGradient = LinearGradient(
  colors: <Color>[Color.fromARGB(100, 13, 216,60), Color.fromARGB(100, 13, 209, 180), Color.fromARGB(100, 0, 212, 255)],
).createShader(Rect.fromLTWH(75.0, 50.0, 200.0, 70.0));

Future<Tomato> fetchTomato(String movie) async {
  final response =
  await http.get('http://www.omdbapi.com/?t=$movie&apikey=82107fde');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Tomato.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print('Failed to load Tomato');
  }
}

class Tomato {

  final String rating;
  final String source;

  Tomato({this.rating, this.source});

  factory Tomato.fromJson(Map<String, dynamic> json) {

    return Tomato(

     rating: json['Ratings'][1]['Value'],
      source: json['Ratings'][1]['Source'],
    );
  }
}
class _HomeScreenState extends State<HomeScreen>

    with SingleTickerProviderStateMixin {
  MovieBloc _bloc;

  AnimationController _animationController;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var subscription;
  var connectionStatus;
  Future<Tomato> futureTomato;

  @override
  void initState() {

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    super.initState();
    _bloc = MovieBloc();
    futureTomato = fetchTomato('');

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
    _bloc.dispose();
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
                        GestureDetector(

                          child: SvgPicture.asset(
                          "assets/images/bar.svg",
                            height: 30,
                      ),
                        ),

                          AutoSizeText(
                            'IN THEATERS',
                            style: TextStyle(
                                fontFamily: "Railway",
                                color: Colors.white,
                                fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3
                            ),
                          ),
                          GestureDetector(
                            child: SvgPicture.asset(
                              "assets/images/filter_search.svg",
                              height: 35,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //add listview here


                  ],
                ),
              ),
            ),





            RefreshIndicator(
              onRefresh: () => _bloc.fetchMovieList(),
              child: StreamBuilder<ApiResponse<List<Movie>>>(
                stream: _bloc.movieListStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return Center(
                          child: CircularProgressIndicator()
                        );
                        break;
                      case Status.COMPLETED:
                        return MovieList(movieList: snapshot.data.data);
                        break;
                      case Status.ERROR:
                        return Text("bruh crashed");

                        break;
                    }
                  }
                  return Container();
                },
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

class MovieList extends StatelessWidget {
  final List<Movie> movieList;


  const MovieList({Key key, this.movieList}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    
    Container textBuild(String text,Color colour, double size ) {


      return Container(

        padding: const EdgeInsets.only(left: 4),
        child: AutoSizeText(
          text,
          style: TextStyle(fontSize: size, color: colour ,
            fontFamily: "Roboto-Regular",
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            
            ),
          softWrap: true,
        ),
      );
    }

    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 0.55;
    return Container(
      padding: EdgeInsets.only(top: size.height * 0.105),
      child: GridView.builder(
        itemCount: movieList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: (itemWidth / itemHeight),

        ),
        itemBuilder: (context, index) {

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MovieDetail(movieList[index].id)));
              },
              child: Stack(
                children:<Widget>[
                  Card(

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)
                  ),
                  elevation: 5,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(7.5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w342${movieList[index].posterPath}',
                            height: size.height * 0.20,

                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Stack(
                            children: [
                              if(movieList[index].voteAverage > 6)
                            (
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Image.asset("assets/images/fresh.png", height: size.height * 0.085,fit: BoxFit.fill,),
                                ))
                              else(
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Image.asset("assets/images/rotten.png", height: size.height * 0.085,fit: BoxFit.fill,),
                                )),
                              Padding(padding: const EdgeInsets.only(top: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textBuild(movieList[index].title, Color.fromARGB(200, 41, 41, 41), 15),
                              SizedBox(height: 5,),
                                  textBuild(movieList[index].releaseDate.substring(0,4), Color.fromARGB(200, 70, 70, 70), 14),
                                  SizedBox(height: 20,),
                              Row(
                              children: [
                                Text("🍿",style: TextStyle(fontSize: 23),),
                                textBuild(((movieList[index].voteAverage)*10).toString().substring(0,2)+"%", Colors.black, 16),
                                SizedBox(width: 20,),
                                Text("⭐",style: TextStyle(fontSize: 22),),
                                FutureBuilder<Tomato>(
                                future: fetchTomato(movieList[index].title),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return textBuild(snapshot.data.rating, Colors.black, 16);
                                    } 

                                    // By default, show a loading spinner.
                                    else{
                                      return textBuild("--", Colors.black, 16);
                                    }
                                  },
                                ),

                              ],
                              ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      textBuild("Audience", Color.fromARGB(225, 131, 131, 131), 13),
                                      SizedBox(width: 20,),
                                      FutureBuilder<Tomato>(
                                        future: fetchTomato(movieList[index].title),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return textBuild(snapshot.data.source, Color.fromARGB(225, 131, 131, 131), 13);
                                          }

                                          // By default, show a loading spinner.
                                          else{
                                            return textBuild("No rating available",Color.fromARGB(225, 131, 131, 131), 13);
                                          }
                                        },
                                      ),
                               
                                    ],

                                  )
                              
                                ],
                              )
          ),
                            ],
                          ),
                       
                        ],
                      ),
                      
                    ],
                  ),
                ),
          ],
              ),
            ),
          );
        },
      ),
    );
  }
}




