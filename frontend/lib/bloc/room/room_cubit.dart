import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/room.dart';

enum RoomEvent {
  initial,
  create,
  join,
  leave,
}

class RoomState extends Equatable {
  final RoomEvent roomEvent;
  final Room room;

  const RoomState({required this.roomEvent, required this.room});

  RoomState copyWith({
    RoomEvent? roomEvent,
    Room? room,
  }) {
    return RoomState(
      roomEvent: roomEvent ?? this.roomEvent,
      room: room ?? this.room,
    );
  }

  @override
  List<Object?> get props => [roomEvent, room];
}

class RoomCubit extends Cubit<RoomState> {
  RoomCubit()
      : super(RoomState(
            roomEvent: RoomEvent.initial,
            room: Room(id: "", name: "", hostId: "")));
  void setRoomState(RoomEvent roomEvent, Room room) {
    emit(state.copyWith(room: room, roomEvent: roomEvent));
  }

  void setVideoState({String? videoId, int? seekTime, bool? isPlaying}) {
    emit(state.copyWith(
        room: state.room.copyWith(
            videoId: videoId, isPlaying: isPlaying, seekTime: seekTime)));
  }

  void addParticipants(List<String> participants) {
    emit(state.copyWith(room: state.room.copyWith(participents: participants)));
  }
}
