import 'package:InTheatres/blocs/movie_detail_bloc.dart';
import 'package:InTheatres/models/movie_response.dart';
import 'package:InTheatres/networking/api_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';
class MovieDetail extends StatefulWidget {
  final int selectedMovie;
  const MovieDetail(this.selectedMovie);

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  MovieDetailBloc _movieDetailBloc;

  @override
  void initState() {
    super.initState();
    _movieDetailBloc = MovieDetailBloc(widget.selectedMovie);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

//      backgroundColor: Color(0xFF333333),
      body: RefreshIndicator(
        onRefresh: () =>
            _movieDetailBloc.fetchMovieDetail(widget.selectedMovie),
        child: StreamBuilder<ApiResponse<Movie>>(
          stream: _movieDetailBloc.movieDetailStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return ShowMovieDetail(displayMovie: snapshot.data.data);
                  break;
                case Status.ERROR:
                  return Error(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () =>
                        _movieDetailBloc.fetchMovieDetail(widget.selectedMovie),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _movieDetailBloc.dispose();
    super.dispose();
  }
}

class ShowMovieDetail extends StatelessWidget {
  final Movie displayMovie;

  ShowMovieDetail({Key key, this.displayMovie}) : super(key: key);
  Container textBuild(String text,Color colour, double size ) {


    return Container(

      padding: const EdgeInsets.only(left: 25),
      child: Text(
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
  Container textBuild_new(String text,Color colour, double size ) {


    return Container(

      padding: const EdgeInsets.only(left: 5),
      child: Text(
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
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return new Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Image.network("https://image.tmdb.org/t/p/w342${displayMovie.posterPath}", fit: BoxFit.cover,),
        ClipRRect( // Clip it cleanly.
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: new SingleChildScrollView(
          child:  Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(

        child: Stack(
          children:<Widget>[



            Padding(
              padding: EdgeInsets.only(top: size.height * 0.2),
              child: Container(
                /* decoration: new BoxDecoration(
                 boxShadow: [
                    new BoxShadow(
                      color: Color.fromRGBO(89, 202, 109, 0.7),
                      offset: Offset(5, 2),
                      blurRadius: 15.0,
                    ),
                  ],
                ),*/

                height: size.height * 0.3,
                child: Card(

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  ),
                  elevation: 25,
                  child: Column(

                    children:<Widget>[
                      Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[

                        Column(
                          children: <Widget>[
                            Stack(
                              children: [
                                if(displayMovie.voteAverage > 6)
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
                                        textBuild(displayMovie.title, Color.fromARGB(200, 41, 41, 41), 15),
                                        SizedBox(height: 5,),
                                        textBuild(displayMovie.releaseDate.substring(0,4), Color.fromARGB(200, 70, 70, 70), 13),
                                        SizedBox(height: 20,),
                                        Row(
                                          children: [

                                            textBuild("🍿", Colors.black, 23),
                                            textBuild_new(((displayMovie.voteAverage)*10).toString().substring(0,2)+"%", Colors.black, 16),
                                            SizedBox(width: 20,),
                                            Text("⭐",style: TextStyle(fontSize: 22),),
                                            FutureBuilder<Tomato>(
                                              future: fetchTomato(displayMovie.title),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return textBuild_new(snapshot.data.rating, Colors.black, 16);
                                                }

                                                // By default, show a loading spinner.
                                                else{
                                                  return textBuild_new("--", Colors.black, 16);
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
                                              future: fetchTomato(displayMovie.title),
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
                      SizedBox(height: 25,),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                          child: Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("ADD YOUR RATING", style: TextStyle(fontFamily: "Roboto-Regular",
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3.5,),),
                            ),
                          width: double.infinity,

                          height: size.height * 0.1,
                          color: Color.fromRGBO(89, 202, 109, 1),),
                        )
                      ),
                  ]
                  ),
                ),
              ),
            ),

            Padding(
              padding:  EdgeInsets.only(top: size.height * 0.16,left: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w342${displayMovie.posterPath}',
                  height: size.height * 0.24,

                ),
              ),
            ),
            
          ],
        ),
      ),
    ),
        ),
          ),
        ),
       Expanded(

           child: Padding(
             padding: EdgeInsets.only(top: size.height * 0.55,),
             child: DefaultTabController(
               length: 5,
               child: Scaffold(

                   body: TabBar(
                     indicatorColor: Colors.redAccent,
                     labelColor: Colors.black,
                     unselectedLabelColor: Colors.grey,
                     tabs: [
                       Tab(text: 'Info'),
                       Tab(text: "Cast",),
                       Tab(text:"News",),
                       Tab(text: "Critics",),
                       Tab(text: "Media",),

                     ],
                   ),



               ),
             ),
           ),
       ),
        
      ]),
    );
  }
}

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

class Error extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.redAccent,
            child: Text(
              'Retry',
              style: TextStyle(
//                color: Colors.white,
              ),
            ),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({Key key, this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
//              color: Colors.lightGreen,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
          ),
        ],
      ),
    );
  }
}