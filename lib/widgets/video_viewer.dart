import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoViewer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoViewer({
    Key? key,
    required this.videoUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    String? videoId = _extractVideoId(widget.videoUrl);
    
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        strictRelatedVideos: false
      ),
    );

    if (videoId != null) {
      _controller.loadVideoById(videoId: videoId);
    }
  }

  String? _extractVideoId(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      final uri = Uri.parse(url);
      if (url.contains('youtube.com')) {
        return uri.queryParameters['v'];
      } else {
        return uri.pathSegments.last;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

