import 'package:flutter/material.dart';
import 'package:frontend/bloc/room/room_cubit.dart';
import 'package:frontend/bloc/user/user_cubit.dart';
import 'package:frontend/bloc/ws/ws_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/screen/room.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final roomIdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "YTB sync",
          style: TextStyle(
              color: Colors.amber, fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: BlocListener<WsCubit, WsState>(
        listener: (context, state) {
          if (state.event == "room_joined") {
            final msg = state.data["msg"];
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
            final roomDetails = state.data["room"];
            print("roomDetails : $roomDetails");
            final room = Room(
                id: roomDetails['id'],
                name: roomDetails['name'],
                hostId: roomDetails['host_id'],
                videoId: roomDetails['video_id'],
                participents: (roomDetails["participants"] as List<dynamic>)
                    .map((e) => e.toString())
                    .toList());
            context.read<RoomCubit>().setRoomState(RoomEvent.join, room);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (ctx) => RoomScreen(
                      videoId: roomDetails['video_id'],
                    )));
          } else if (state.event == "room_not_found") {
            final msg = state.data["msg"];
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: roomIdController,
                decoration: const InputDecoration(hintText: 'Enter Room ID'),
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.amber),
                  onPressed: () {
                    final roomId = roomIdController.text;
                    if (roomId.length == 16) {
                      context.read<WsCubit>().sendEvent("join_room", {
                        "room_id": roomId,
                        "user_id": context.read<UserCubit>().state.user.id
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please Provide Valid RoomId")));
                    }
                  },
                  child: const Text("Join A Room"))
            ],
          ),
        ),
      ),
    );
  }
}
