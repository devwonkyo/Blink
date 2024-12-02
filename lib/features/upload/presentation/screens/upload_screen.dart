import 'package:blink/core/routes/app_router.dart';
import 'package:blink/features/upload/presentation/blocs/camera/camera_bloc.dart';
import 'package:blink/features/upload/presentation/blocs/camera/camera_event.dart';
import 'package:blink/features/upload/presentation/blocs/camera/camera_state.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      CameraBloc()
        ..add(InitializeCamera()),
      child: BlocListener<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is VideoSelected) {
            context.push("/upload_preview", extra: state.video.path);
          }

          if (state is CameraError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("에러...")),
            );
          }
        },
        child: BlocBuilder<CameraBloc, CameraState>(
          builder: (context, state) {
            return Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    if (state is CameraInitialized || state is CameraRecording)
                      CameraPreview((state as dynamic).controller),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildRecordButton(context, state),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FloatingActionButton(
                            onPressed: () {
                              context.read<CameraBloc>().add(
                                  PickVideoFromGallery());
                            },
                            child: const Icon(Icons.photo)),
                      ),
                    ),
                    if (state is CameraError)
                      Center(
                        child: Text(state.message),
                      ),
                    Positioned(
                      left: 16,
                      top: 16,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecordButton(BuildContext context, CameraState state) {
    if (state is CameraInitialized || state is CameraRecording) {
      return FloatingActionButton(
        onPressed: () {
          if (state is CameraInitialized) {
            context.read<CameraBloc>().add(StartRecording());
          } else if (state is CameraRecording) {
            context.read<CameraBloc>().add(StopRecording());
          }
        },
        child: Icon(
          state is CameraRecording
              ? Icons.stop
              : Icons.fiber_manual_record,
        ),
      );
    }
    return Container();
  }
}
