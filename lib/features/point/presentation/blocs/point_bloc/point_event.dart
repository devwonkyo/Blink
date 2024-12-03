abstract class PointEvent {}

class LoadPoints extends PointEvent {
  final String userId;

  LoadPoints(this.userId);
}

class WaterTreeEvent extends PointEvent {
  final String userId;
  final int waterAmount;

  WaterTreeEvent(this.userId, this.waterAmount);
}

class ClaimFruit extends PointEvent {
  final String userId;
  final String fruitId;
  final String giftUrl;

  ClaimFruit(this.userId, this.fruitId, this.giftUrl);
}
