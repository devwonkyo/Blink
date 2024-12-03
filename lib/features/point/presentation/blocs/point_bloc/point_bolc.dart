import 'package:blink/features/point/domain/repositories/point_repository.dart';
import 'package:blink/features/point/presentation/blocs/point_bloc/point_event.dart';
import 'package:blink/features/point/presentation/blocs/point_bloc/point_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PointBloc extends Bloc<PointEvent, PointState> {
  final PointRepository repository;

  PointBloc(this.repository) : super(PointsLoading()) {
    // LoadPoints 이벤트 처리
    on<LoadPoints>((event, emit) async {
      emit(PointsLoading());
      try {
        final points = await repository.getUserPoints(event.userId);
        emit(PointsLoaded(points));
      } catch (e) {
        emit(PointError("Failed to load points: $e"));
      }
    });

    Future<void> _onWaterTree(WaterTreeEvent event, Emitter<PointState> emit) async {
      emit(PointsLoading());
      try {
        await repository.waterTree(event.userId, event.waterAmount);

        final updatedPoints = await repository.getUserPoints(event.userId);
        final updatedTree = await repository.getTree(event.userId);

        emit(PointsAndTreeUpdated(
          points: updatedPoints,
          treeLevel: updatedTree.level,
          water: updatedTree.water,
        ));
      } catch (e) {
        emit(PointError("Failed to water tree: ${e.toString()}"));
      }
    }

    // ClaimFruit 이벤트 처리
    on<ClaimFruit>((event, emit) async {
      emit(PointsLoading());
      try {
        await repository.claimFruitReward(
          event.userId,
          event.fruitId,
          event.giftUrl,
        );
        emit(FruitClaimed());
        add(LoadPoints(event.userId)); // 포인트 로드 재요청
      } catch (e) {
        emit(PointError("Failed to claim fruit: $e"));
      }
    });
  }
}
