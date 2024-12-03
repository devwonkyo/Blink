abstract class PointState {}

class PointsLoading extends PointState {}

class PointsLoaded extends PointState {
  final int points;

  PointsLoaded(this.points);
}

class TreeWatered extends PointState {}

class FruitClaimed extends PointState {}

class PointError extends PointState {
  final String message;

  PointError(this.message);
}

class PointsAndTreeUpdated extends PointState {
  final int points;
  final int treeLevel;
  final int water;

  PointsAndTreeUpdated({
    required this.points,
    required this.treeLevel,
    required this.water,
  });
}