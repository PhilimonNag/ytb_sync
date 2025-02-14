import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/error_response.dart';
import '../models/video_details.dart';

const String baseUrl = "http://127.0.0.1:8000/";

class SearchVideoRepo {
  final client = http.Client();

  Future<Either<ErrorResponse, List<VideoDetails>>> searchVideo(String query,
      {int maxResults = 10}) async {
    try {
      final Uri url =
          Uri.parse("${baseUrl}search-videos").replace(queryParameters: {
        "query": Uri.encodeQueryComponent(query),
        "max_results": maxResults.toString(),
      });
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<VideoDetails> videos =
            data.map((json) => VideoDetails.fromJson(json)).toList();
        print(videos);
        return Right(videos);
      } else {
        return Left(ErrorResponse(
            "Error: ${response.statusCode} - ${response.reasonPhrase}"));
      }
    } catch (e) {
      return Left(ErrorResponse(e.toString()));
    }
  }
}
