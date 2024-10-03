import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerDialog extends StatefulWidget {
  final String videoPath;

  VideoPlayerDialog({required this.videoPath});

  @override
  _VideoPlayerDialogState createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    // Add listener to detect when video finishes
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        // Delay for 2 seconds before closing the dialog
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop(); // Close the dialog after 2 seconds
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: ClipRRect(
      borderRadius:
          BorderRadius.circular(20), // Apply the same rounded corners here
      child: SizedBox(
        width: 700, // Set the desired width
        height: 200, // Set the desired height
        child: Container(
          color: Colors.white.withOpacity(1),
          child: Center(
            child: _controller.value.isInitialized
                ? SizedBox(
                    width: 500, // Set desired width
                    height: 700, // Set desired height
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : CircularProgressIndicator(),
          ),
        ),
      ),
    ));
  }
}

// To show the dialog
void showVideoPlayerDialog(BuildContext context, String videoPath) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside the dialog
    builder: (BuildContext context) {
      return VideoPlayerDialog(videoPath: videoPath);
    },
  );
}
