// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:frontend/bloc/room/room_cubit.dart';
// import 'package:frontend/bloc/ws/ws_cubit.dart';
// import 'package:frontend/screen/youtube_search.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class RoomScreen extends StatefulWidget {
//   const RoomScreen({super.key, this.videoId = "Jer0FgPZj6w"});
//   final String? videoId;

//   @override
//   State<RoomScreen> createState() => _RoomScreenState();
// }

// class _RoomScreenState extends State<RoomScreen> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: widget.videoId!,
//       flags: const YoutubePlayerFlags(
//           autoPlay: false,
//           mute: false,
//           disableDragSeek: false,
//           enableCaption: false,
//           controlsVisibleAtStart: true,
//           showLiveFullscreenButton: false),
//     )..addListener(() {
//         final isPlaying = _controller.value.isPlaying;
//         final currentPosition = _controller.value.position;

//         if (currentPosition.inSeconds > 3) {
//           final room = context.read<RoomCubit>().state.room;
//           if (isPlaying != room.isPlaying) {
//             context.read<WsCubit>().sendEvent("video_state", {
//               "room_id": room.id,
//               "video_id": room.videoId!,
//               "is_playing": isPlaying,
//               "seek_time": currentPosition.inSeconds
//             });
//           }
//         }
//         context.read<RoomCubit>().setVideoState(
//             isPlaying: isPlaying, seekTime: currentPosition.inSeconds);
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _openSearchOverlay() async {
//     final selectedVideoId = await showModalBottomSheet<String>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const YoutubeSearchScreen(),
//     );
//     if (selectedVideoId != null && selectedVideoId.isNotEmpty) {
//       _controller.load(selectedVideoId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Room'),
//         actions: [
//           IconButton(
//             onPressed: _openSearchOverlay,
//             icon: const Icon(Icons.search),
//           ),
//           IconButton(
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(
//                     text: context.read<RoomCubit>().state.room.id));
//               },
//               icon: const Icon(Icons.copy))
//         ],
//       ),
//       body: BlocConsumer<WsCubit, WsState>(
//         listener: (context, state) {
//           if (state.event == "video_selected") {
//             _controller.load(state.data["video_id"]);
//           }
//           if (state.event == "video_state") {
//             _controller.load(state.data['video_id']);
//             if (state.data['is_playing'] && !_controller.value.isPlaying) {
//               _controller.play();
//             } else if (!state.data['is_playing'] &&
//                 _controller.value.isPlaying) {
//               _controller.pause();
//             }
//             _controller.seekTo(Duration(seconds: state.data['seek_time']));
//             context.read<RoomCubit>().setVideoState(
//                 videoId: state.data['video_id'],
//                 isPlaying: state.data['is_playing'],
//                 seekTime: state.data['seek_time']);
//           } else if (state.event == "user_joined") {
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(SnackBar(content: Text(state.data["msg"])));
//             final participants = ((state.data["participants"] as List<dynamic>)
//                 .map((e) => e.toString())
//                 .toList());
//             context.read<RoomCubit>().addParticipants(participants);
//           }
//         },
//         builder: (context, state) {
//           return Column(
//             children: [
//               YoutubePlayer(
//                 controller: _controller,
//                 showVideoProgressIndicator: true,
//                 progressIndicatorColor: Colors.red,
//                 onReady: () {
//                   debugPrint('Player is ready');
//                 },
//                 onEnded: (metaData) {
//                   debugPrint('Video ended');
//                 },
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/room/room_cubit.dart';
import 'package:frontend/bloc/ws/ws_cubit.dart';
import 'package:frontend/screen/youtube_search.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, this.videoId = "Jer0FgPZj6w"});
  final String? videoId;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late YoutubePlayerController _controller;

  // Track the last video state to avoid repeated events
  bool? lastIsPlaying;
  int? lastSeekTime;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        enableCaption: false,
        controlsVisibleAtStart: true,
        showLiveFullscreenButton: false,
      ),
    )..addListener(_videoStateListener);
  }

  void _videoStateListener() {
    final isPlaying = _controller.value.isPlaying;
    final currentPosition = _controller.value.position.inSeconds;

    if (currentPosition > 3 &&
        (isPlaying != lastIsPlaying || currentPosition != lastSeekTime)) {
      final room = context.read<RoomCubit>().state.room;

      // Send the video state only if it changes
      context.read<WsCubit>().sendEvent("video_state", {
        "room_id": room.id,
        "video_id": room.videoId!,
        "is_playing": isPlaying,
        "seek_time": currentPosition,
      });

      lastIsPlaying = isPlaying;
      lastSeekTime = currentPosition;
    }

    context.read<RoomCubit>().setVideoState(
          isPlaying: isPlaying,
          seekTime: currentPosition,
        );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoStateListener);
    _controller.dispose();
    super.dispose();
  }

  void _openSearchOverlay() async {
    final selectedVideoId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const YoutubeSearchScreen(),
    );
    if (selectedVideoId != null && selectedVideoId.isNotEmpty) {
      _controller.load(selectedVideoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Room'),
        actions: [
          IconButton(
            onPressed: _openSearchOverlay,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: context.read<RoomCubit>().state.room.id,
              ));
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: BlocConsumer<WsCubit, WsState>(
        listener: (context, state) {
          if (state.event == "video_selected") {
            _controller.load(state.data["video_id"]);
            // _controller.pause();
            context.read<RoomCubit>().setVideoState(
                isPlaying: false, videoId: state.data["video_id"]);
          }

          if (state.event == "video_state") {
            final videoId = state.data['video_id'];
            final isPlaying = state.data['is_playing'];
            final seekTime = state.data['seek_time'];

            // Sync video state only if necessary
            if (_controller.metadata.videoId != videoId) {
              _controller.load(videoId);
            }
            if ((isPlaying && !_controller.value.isPlaying) ||
                (!isPlaying && _controller.value.isPlaying)) {
              if (isPlaying) {
                _controller.seekTo(Duration(seconds: seekTime));
                _controller.play();
              } else {
                _controller.pause();
              }
            } else {
              // _controller.seekTo(Duration(seconds: seekTime));
            }

            context.read<RoomCubit>().setVideoState(
                  videoId: videoId,
                  isPlaying: isPlaying,
                  seekTime: seekTime,
                );
          } else if (state.event == "user_joined") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.data["msg"])),
            );
            final participants = (state.data["participants"] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
            context.read<RoomCubit>().addParticipants(participants);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                onReady: () {
                  debugPrint('Player is ready');
                },
                onEnded: (metaData) {
                  debugPrint('Video ended');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
