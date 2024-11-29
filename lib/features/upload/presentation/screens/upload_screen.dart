import 'package:blink/features/upload/presentation/blocs/camera_bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraBloc()..add(InitializeCamera()),
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
                          onPressed:(){

                          },
                          child: Icon(Icons.photo_album)),
                    ),
                  ),
                  if (state is CameraError)
                    Center(
                      child: Text(state.message),
                    ),
                ],
              ),
            ),
          );
        },
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
