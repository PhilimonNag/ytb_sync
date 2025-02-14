import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WsState extends Equatable {
  final String event;
  final Map<String, dynamic> data;
  final bool isConnected;

  const WsState(
      {required this.event, required this.data, required this.isConnected});
  WsState copyWith(
      {String? event, Map<String, String>? data, bool? isConnected}) {
    return WsState(
      event: event ?? this.event,
      data: data ?? this.data,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [event, data];
}

class WsCubit extends Cubit<WsState> {
  WebSocket? _webSocket;
  StreamSubscription? _messageSubscription;

  WsCubit()
      : super(const WsState(
          event: '',
          data: {},
          isConnected: false,
        ));
  Future<void> connect(String url) async {
    try {
      _webSocket = await WebSocket.connect(url);
      emit(state.copyWith(isConnected: true));

      // Listen for incoming messages
      _messageSubscription = _webSocket!.listen(
        (message) => _onMessageReceived(message),
        onDone: _onConnectionClosed,
        onError: (error) => _onError(error.toString()),
      );
    } catch (error) {
      emit(state.copyWith(isConnected: false));
      print('WebSocket connection error: $error');
    }
  }

  void _onMessageReceived(dynamic message) {
    print(message.runtimeType); // Print the type of the message for debugging

    if (message is String) {
      try {
        // Decode the JSON string into a Map
        final msg = json.decode(message) as Map<String, dynamic>;
        print("Socket received: $msg");
        emit(WsState(
          event: msg['event'],
          data: Map<String, dynamic>.from(msg['data'] ?? {}),
          isConnected: true,
        ));
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    } else {
      print("Unexpected message type: ${message.runtimeType}");
    }
  }

  void _onConnectionClosed() {
    emit(state.copyWith(isConnected: false));
    print('WebSocket connection closed.');
  }

  void _onError(String error) {
    emit(state.copyWith(isConnected: false));
    print('WebSocket error: $error');
  }

  void sendEvent(String event, Map<String, dynamic> data) {
    if (_webSocket != null && state.isConnected) {
      final message = json.encode({"event": event, "payload": data});
      _webSocket!.add(message);
    } else {
      print('WebSocket is not connected.');
    }
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    await _messageSubscription?.cancel();
    await _webSocket?.close();
    emit(state.copyWith(isConnected: false));
  }

  @override
  Future<void> close() {
    disconnect();
    return super.close();
  }
}
