import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'widgets/google_maps_widget.dart';
import 'app_bloc.dart';
import 'src/drawer.dart';
import 'src/menu.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    service.invoke('update', {
      "current_date": DateTime.now().toIso8601String(),
    });

    // Restart your mock location service
    AppBloc.liveLocationCubit.startMockService(
      mockLocation:
          LatLng(GoogleMapsWidgetState.lat, GoogleMapsWidgetState.lng),
    );
  });
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBloc.providers,
      child: MaterialApp(
        title: 'Google Maps Training',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }

  @override
  void dispose() {
    AppBloc.dispose();
    super.dispose();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isPlaying = prefs.getBool('isPlaying') ?? false;
    });
  }

  void _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isPlaying', isPlaying);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App is in the background or not focused
      if (isPlaying) {
        final service = FlutterBackgroundService();
        service.startService();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App is back to foreground
      if (isPlaying) {
        AppBloc.liveLocationCubit.startMockService(
          mockLocation: LatLng(
            GoogleMapsWidgetState.lat,
            GoogleMapsWidgetState.lng,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Changer'),
        actions: const [
          Menu(),
        ],
      ),
      drawer: const MyDrawer(),
      // Pass the state here
      body: const GoogleMapsWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isPlaying) {
            AppBloc.liveLocationCubit.closeMockService();
          } else {
            AppBloc.liveLocationCubit.startMockService(
              mockLocation: LatLng(
                GoogleMapsWidgetState.lat,
                GoogleMapsWidgetState.lng,
              ),
            );
          }

          setState(() {
            isPlaying = !isPlaying;
          });

          _saveState();
        },
        backgroundColor: isPlaying ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
