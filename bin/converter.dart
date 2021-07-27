import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

import 'movie.dart';

class CSVConverter {
  final csvConveter = CsvToListConverter();
  late List<Movie> movies;
  Stream<List<dynamic>> get netflixRows => readFromCSV();

  CSVConverter.Init() {
    movies = [];
    netflixRows.forEach((element) {
      var title = element[0];
      var genre = element[1];
      var premiere = element[2];
      var IMDBScore = int.parse(element[3]);
      var language = element[4];
      var movie = Movie(title, genre, premiere, IMDBScore, language);
      movies.add(movie);
    });

    print(movies);
  }

  Stream<List> readFromCSV() {
    var file = File('NetflixOriginals.csv').openRead();
    return file
        .transform(utf8.decoder)
        .transform(CsvToListConverter(eol: '\n', fieldDelimiter: ','));
  }
}
