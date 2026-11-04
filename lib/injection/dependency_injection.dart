import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/haptics_service.dart';
import '../data/datasources/counter_local_datasource.dart';
import '../data/repositories/counter_repository_impl.dart';
import '../domain/repositories/counter_repository.dart';
import '../presentation/counter/bloc/counter_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<HapticsService>(() => const PlatformHapticsService())
    ..registerLazySingleton<CounterLocalDataSource>(() => SharedPreferencesCounterDataSource(sl()))
    ..registerLazySingleton<CounterRepository>(() => CounterRepositoryImpl(sl()))
    ..registerFactory<CounterBloc>(() => CounterBloc(repository: sl(), haptics: sl()));
}
