import 'package:InTheatres/blocs/movie_detail_bloc.dart';
import 'package:InTheatres/models/movie_response.dart';
import 'package:InTheatres/networking/api_response.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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

      padding: const EdgeInsets.only(left: 4),
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

        new SingleChildScrollView(
          child:  Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(

        child: Stack(
          children:<Widget>[

            Padding(
              padding: EdgeInsets.only(top: size.height * 0.3),
              child: Card(

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                ),
                elevation: 5,
                child: Row(
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
                                    textBuild(displayMovie.releaseDate.substring(0,4), Color.fromARGB(200, 70, 70, 70), 14),
                                    SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Text("🍿",style: TextStyle(fontSize: 23),),
                                        textBuild(((displayMovie.voteAverage)*10).toString().substring(0,2)+"%", Colors.black, 16),
                                        SizedBox(width: 20,),
                                        Text("🍅",style: TextStyle(fontSize: 23),),
                                        textBuild("", Colors.black, 16)
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        textBuild("Audience", Color.fromARGB(225, 131, 131, 131), 13),
                                        SizedBox(width: 20,),
                                        textBuild("Tomatometer", Color.fromARGB(225, 131, 131, 131), 13)
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
            ),
            Padding(
              padding:  EdgeInsets.only(top: size.height * 0.29),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w342${displayMovie.posterPath}',
                  height: size.height * 0.20,

                ),
              ),
            ),
          ],
        ),
      ),
    ),
        )
      ]),
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
          ),
        ],
      ),
    );
  }
}