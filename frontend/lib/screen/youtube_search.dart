import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/room/room_cubit.dart';
import 'package:frontend/bloc/ws/ws_cubit.dart';
import 'package:frontend/bloc/youtube/youtube_cubit.dart';
import 'package:frontend/bloc/youtube/youtube_state.dart';

class YoutubeSearchScreen extends StatefulWidget {
  const YoutubeSearchScreen({super.key});

  @override
  State<YoutubeSearchScreen> createState() => _YoutubeSearchScreenState();
}

class _YoutubeSearchScreenState extends State<YoutubeSearchScreen> {
  final queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        title: const Text(
          "Search Videos",
          style: TextStyle(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: queryController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    final qText = queryController.text.trim();
                    if (qText.length > 2) {
                      context.read<YoutubeCubit>().searchVideo(qText);
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
                hintText: "Search Video",
              ),
            ),
            Expanded(
              child: BlocBuilder<YoutubeCubit, YoutubeState>(
                builder: (ctx, state) {
                  if (state is YoutubeLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is YoutubeLoadedState) {
                    return ListView.builder(
                      itemCount: state.videos.length,
                      itemBuilder: (ctx, index) {
                        final video = state.videos[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                onTap: () {
                                  context.read<WsCubit>().sendEvent(
                                      "video_selected", {
                                    "room_id":
                                        context.read<RoomCubit>().state.room.id,
                                    "video_id": video.id
                                  });
                                  context
                                      .read<RoomCubit>()
                                      .setVideoState(videoId: video.id);
                                  Navigator.pop(context, video.id);
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 70,
                                    height: 50,
                                    child: Image.network(
                                      video.thumbnail,
                                      width: 70,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.broken_image,
                                        size: 76,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  video.text,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is YoutubeFailureState) {
                    return Center(
                      child: Text(state.error),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
