import 'package:flutter_bloc/flutter_bloc.dart';
import '../controller/live_location_cubit.dart';

/// Centralized Bloc management class for the application.
class AppBloc {
  static final liveLocationCubit = LiveLocationCubit();  // Singleton instance of LiveLocationCubit

  static final List<BlocProvider> providers = [
    BlocProvider<LiveLocationCubit>(
      create: (context) => liveLocationCubit,  // Providing the live location cubit
    ),
  ];

  static void dispose() {
    liveLocationCubit.close();  // Dispose of the cubit when done
  }

  /// Singleton factory for the AppBloc
  static final AppBloc _instance = AppBloc._internal();

  factory AppBloc() {
    return _instance;
  }

  AppBloc._internal();  // Private constructor for singleton pattern
}