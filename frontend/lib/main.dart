import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/room/room_cubit.dart';
import 'package:frontend/bloc/user/user_cubit.dart';
import 'package:frontend/bloc/ws/ws_cubit.dart';
import 'package:frontend/bloc/youtube/video_cubit.dart';
import 'package:frontend/bloc/youtube/youtube_cubit.dart';
import 'package:frontend/repository/search_video.dart';
import 'package:frontend/screen/create_join.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return MultiRepositoryProvider(
        providers: [RepositoryProvider(create: (context) => SearchVideoRepo())],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => WsCubit()),
            BlocProvider(create: (context) => UserCubit()),
            BlocProvider(create: (context) => RoomCubit()),
            BlocProvider(
                create: (context) =>
                    YoutubeCubit(context.read<SearchVideoRepo>())),
            BlocProvider(create: (context) => VideoCubit())
          ],
          child: MaterialApp(
            title: 'ytb_sync',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
              useMaterial3: true,
            ),
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark(),
            home: const CreateOrJoinRoom(),
          ),
        ),
      );
    });
  }
}
