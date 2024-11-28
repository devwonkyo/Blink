import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/video/presentation/blocs/video/video_bloc.dart';
import 'package:blink/features/video/presentation/widgets/video_player_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoBloc()..add(LoadVideos()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '팔로잉',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 20),
              Text(
                '추천',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            if (state is VideoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VideoLoaded) {
              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: state.videos.length,
                onPageChanged: (index) {
                  context.read<VideoBloc>().add(ChangeVideo(index: index));
                },
                itemBuilder: (context, index) {
                  final video = state.videos[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoPlayerWidget(
                        videoUrl: video.videoUrl,
                        isPlaying: index == state.currentIndex,
                      ),
                      Positioned(
                        right: 16,
                        bottom: MediaQuery.of(context).size.height * 0.3,
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Material(
                                color: Colors.transparent,
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.2),
                                child: const Icon(CupertinoIcons.person,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Material(
                                    color: Colors.transparent,
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.2),
                                    child: const Icon(CupertinoIcons.heart,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Material(
                                  color: Colors.transparent,
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                  child: Text(
                                    '${video.likes}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Material(
                                    color: Colors.transparent,
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.2),
                                    child: const Icon(
                                        CupertinoIcons.chat_bubble,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Material(
                                  color: Colors.transparent,
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                  child: Text(
                                    '${video.comments}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: Material(
                                    color: Colors.transparent,
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.2),
                                    child: const Icon(CupertinoIcons.paperplane,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Material(
                                  color: Colors.transparent,
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.2),
                                  child: Text(
                                    '${video.shares}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 100,
                        bottom: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${video.userName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              video.caption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  video.musicName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }

            if (state is VideoError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
