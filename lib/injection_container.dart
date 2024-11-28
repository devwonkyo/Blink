import 'package:get_it/get_it.dart';
import 'features/video/presentation/blocs/video/video_bloc.dart';
import 'features/navigation/presentation/bloc/navigation_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => VideoBloc());
  sl.registerFactory(() => NavigationBloc());
}
