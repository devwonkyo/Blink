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
        final tree = await repository.getTree(event.userId);

        emit(PointsAndTreeUpdated(
          points: points,
          treeLevel: tree.level,
          water: tree.water,
          userId: event.userId,
        ));
        print("LoadPoints 성공: $points");
      } catch (e) {
        print("LoadPoints 실패: $e");
        emit(PointError("포인트 불러오기 실패!: $e"));
      }
    });

    // WaterTreeEvent 처리
    on<WaterTreeEvent>((event, emit) async {
      emit(PointsLoading());
      try {
        await repository.waterTree(event.userId, event.waterAmount);

        final updatedPoints = await repository.getUserPoints(event.userId);
        final updatedTree = await repository.getTree(event.userId);

        emit(PointsAndTreeUpdated(
          points: updatedPoints,
          treeLevel: updatedTree.level,
          water: updatedTree.water,
          userId: event.userId,
        ));
      } catch (e) {
        emit(PointError("물주기 실패!: ${e.toString()}"));
      }
    });

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
        add(LoadPoints(event.userId));
      } catch (e) {
        emit(PointError("Failed to claim fruit: $e"));
      }
    });
  }
}
