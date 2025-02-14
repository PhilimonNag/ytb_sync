import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/youtube/youtube_state.dart';
import 'package:frontend/repository/search_video.dart';

class YoutubeCubit extends Cubit<YoutubeState> {
  final SearchVideoRepo searchVideoRepo;
  YoutubeCubit(
    this.searchVideoRepo,
  ) : super(YoutubeInitialState());

  Future<void> searchVideo(String query, {int maxResult = 5}) async {
    final result = await searchVideoRepo.searchVideo(query);
    result.fold((l) {
      emit(YoutubeFailureState(error: l.message));
    }, (r) {
      emit(YoutubeLoadedState(videos: r));
    });
  }
}
