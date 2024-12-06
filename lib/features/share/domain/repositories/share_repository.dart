abstract class ShareRepository {
  Future<String?> createDynamicLink(String videoId);
  Future<String?> handleInitialDynamicLink();
  Stream<String?> handleDynamicLinkStream();
}
