import 'package:flutter/material.dart';
import 'package:frontend/bloc/room/room_cubit.dart';
import 'package:frontend/bloc/user/user_cubit.dart';
import 'package:frontend/bloc/ws/ws_cubit.dart';
import 'package:frontend/models/room.dart';
import 'package:frontend/screen/room.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final roomNameController = TextEditingController();
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
        listener: (BuildContext context, WsState state) {
          print(state);
          if (state.event == "create_room") {
            final room = state.data["room"];
            context.read<RoomCubit>().setRoomState(
                RoomEvent.create,
                Room(
                    id: room["id"],
                    name: room["name"],
                    videoId: room["video_id"],
                    hostId: room["host_id"],
                    participents: (room["participants"] as List<dynamic>)
                        .map((e) => e.toString())
                        .toList()));
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.data["msg"]!)));
          }
        },
        child: BlocListener<RoomCubit, RoomState>(
          listener: (context, state) {
            if (state.roomEvent == RoomEvent.create) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => const RoomScreen()));
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: roomNameController,
                  decoration:
                      const InputDecoration(hintText: 'Enter Room Name'),
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.grey),
                    onPressed: () {
                      final roomName = roomNameController.text.trim();
                      if (roomName.length < 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Room name is required")));
                      } else {
                        context.read<WsCubit>().sendEvent("create_room", {
                          "video_id": "Jer0FgPZj6w",
                          "room_name": roomNameController.text,
                          "user_id": context.read<UserCubit>().state.user.id
                        });
                      }
                    },
                    child: const Text("Create A Room")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
