import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import '../../domain/repositories/share_repository.dart';

class ShareRepositoryImpl implements ShareRepository {
  final FirebaseDynamicLinks _dynamicLinks;

  ShareRepositoryImpl({FirebaseDynamicLinks? dynamicLinks})
      : _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  @override
  Future<String?> createDynamicLink(String videoId) async {
    try {
      final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse('https://blinkanacana.com/video?id=$videoId'),
        uriPrefix: 'https://blinkanacana.page.link',
        androidParameters: const AndroidParameters(
          packageName: 'com.blink.blink',
          minimumVersion: 1,
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.blink.blink',
          minimumVersion: '1.0.0',
        ),
        socialMetaTagParameters: const SocialMetaTagParameters(
          title: 'videoLink',
          description: '동영상 공유 링크입니다.',
        ),
      );

      final dynamicLink = await _dynamicLinks.buildShortLink(
        dynamicLinkParams,
        shortLinkType: ShortDynamicLinkType.short,
      );

      return dynamicLink.shortUrl.toString();
    } catch (e) {
      print('Error creating dynamic link: $e');
      return null;
    }
  }

  @override
  Future<String?> handleInitialDynamicLink() async {
    try {
      final data = await _dynamicLinks.getInitialLink();
      print('Initial Dynamic Link Data: ${data?.link}');
      final videoId = _extractVideoId(data?.link);
      print('Extracted Video ID from Initial Link: $videoId');
      return videoId;
    } catch (e) {
      print('Error handling initial dynamic link: $e');
      return null;
    }
  }

  @override
  Stream<String?> handleDynamicLinkStream() {
    return _dynamicLinks.onLink.map((dynamicLinkData) {
      print('Received Dynamic Link: ${dynamicLinkData.link}');
      final videoId = _extractVideoId(dynamicLinkData.link);
      print('Extracted Video ID from Stream: $videoId');
      return videoId;
    });
  }

  String? _extractVideoId(Uri? uri) {
    print('Extracting Video ID from URI: $uri');
    if (uri?.queryParameters.containsKey('id') ?? false) {
      final videoId = uri!.queryParameters['id'];
      print('Successfully extracted Video ID: $videoId');
      return videoId;
    }
    print('No Video ID found in URI');
    return null;
  }
}
