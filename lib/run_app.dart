import 'package:bloc_test/bloc/authentication/authentication_bloc.dart';
import 'package:bloc_test/bloc/chat/chat_bloc.dart';
import 'package:bloc_test/bloc/conversation/conversation_bloc.dart';
import 'package:bloc_test/bloc/users/users_bloc.dart';
import 'package:bloc_test/ui/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc(),
        ),
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
        BlocProvider<ConversationBloc>(
          create: (context) => ConversationBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Official Chat App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
