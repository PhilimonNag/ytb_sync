import 'package:flutter/material.dart';
import 'package:frontend/bloc/user/user_cubit.dart';
import 'package:frontend/bloc/ws/ws_cubit.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/screen/create_room.dart';
import 'package:frontend/screen/join_room.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateOrJoinRoom extends StatefulWidget {
  const CreateOrJoinRoom({super.key});

  @override
  State<CreateOrJoinRoom> createState() => _CreateOrJoinRoomState();
}

class _CreateOrJoinRoomState extends State<CreateOrJoinRoom> {
  @override
  void initState() {
    context.read<WsCubit>().connect("ws://localhost:8000/ws");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<WsCubit, WsState>(builder: (context, state) {
                if (state.event == "connection") {
                  context.read<UserCubit>().setUser(User(
                        id: state.data["user_id"]!,
                      ));
                  return Text(
                    state.data["user_id"]!,
                    style: const TextStyle(color: Colors.white),
                  );
                }
                return const SizedBox();
              }),
              const Text(
                "YTB sync",
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 46,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey),
                  onPressed: () {
                    if (context.read<UserCubit>().state.active) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (ctx) => const CreateRoomScreen()));
                    }
                  },
                  child: const Text("Create A Room")),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.amber),
                  onPressed: () {
                    if (context.read<UserCubit>().state.active) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (ctx) => const JoinRoomScreen()));
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
