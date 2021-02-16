import 'package:InTheatres/networking/api_base_helper.dart';
import 'package:InTheatres/models/movie_response.dart';
import 'package:InTheatres/apiKey.dart';

class MovieRepository {
  final String _apiKey = apiKey;

  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Movie>> fetchMovieList() async {
    final response = await _helper.get("movie/now_playing?api_key=$_apiKey");
    return MovieResponse.fromJson(response).results;
  }
}
