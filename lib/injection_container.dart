import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:blink/features/user/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:blink/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:blink/features/video/data/repositories/video_repository_impl.dart';
import 'package:blink/features/video/domain/repositories/video_repository.dart';
import 'package:blink/features/video/presentation/blocs/video/video_bloc.dart';
import 'package:blink/features/search/data/datasources/remote/search_remote_datasource.dart';
import 'package:blink/features/search/data/repositories/search_repository_impl.dart';
import 'package:blink/features/search/domain/repositories/search_repository.dart';
import 'package:blink/features/search/domain/usecases/delete_search_query.dart';
import 'package:blink/features/search/domain/usecases/save_search_query.dart';
import 'package:blink/features/search/domain/usecases/search_query.dart';
import 'package:blink/features/search/presentation/blocs/search/search_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Data Sources
  sl.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSource(firestore: sl()));

  // Repository
  sl.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<VideoRepository>(() => VideoRepositoryImpl());

  // Use Cases
  sl.registerLazySingleton(() => SearchQuery(sl()));
  sl.registerLazySingleton(() => SaveSearchQuery(sl()));
  sl.registerLazySingleton(() => DeleteSearchQuery(sl()));

  // Blocs
  sl.registerFactory(() => VideoBloc(videoRepository: sl()));
  sl.registerFactory(() => NavigationBloc());
  sl.registerFactory(() => AuthBloc(authRepository: AuthRepository()));
  sl.registerFactory(() => SearchBloc(
        searchQuery: sl<SearchQuery>(),
        saveSearchQuery: sl<SaveSearchQuery>(),
        deleteSearchQuery: sl<DeleteSearchQuery>(),
      ));
}
