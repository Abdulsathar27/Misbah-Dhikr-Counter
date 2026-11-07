import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/haptics_service.dart';
import '../data/repositories/shared_preferences_counter_repository.dart';
import '../domain/repositories/counter_repository.dart';
import '../presentation/counter/bloc/counter_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<HapticsService>(() => const DeviceHapticsService())
    ..registerLazySingleton<CounterRepository>(() => SharedPreferencesCounterRepository(sl()))
    ..registerFactory<CounterBloc>(() => CounterBloc(repository: sl(), haptics: sl()));
}
