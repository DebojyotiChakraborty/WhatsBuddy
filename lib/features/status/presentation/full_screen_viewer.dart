import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:heroine/heroine.dart';
import '../../../core/presentation/widgets/action_button.dart';

class FullScreenViewer extends StatefulWidget {
  final String uri;
  final bool isVideo;

  const FullScreenViewer({super.key, required this.uri, required this.isVideo});

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  final _channel = const MethodChannel('com.debojyoti.whatsbuddy/status_files');
  Uint8List? _imageBytes;
  bool _isPlaying = false;
  late AnimationController _buttonAnimationController;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonOpacityAnimation;
  bool _isVideoInitialized = false;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (!widget.isVideo) {
      _loadImage();
    } else {
      _initializeVideoPlayer();
    }
  }

  void _setupAnimations() {
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _buttonOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _buttonAnimationController.forward();
      }
    });
  }

  void _startDismissing() {
    if (!_isDismissing && mounted) {
      setState(() => _isDismissing = true);
      _buttonAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    if (widget.isVideo) {
      _controller?.pause();
      _controller?.dispose();
      _controller = null;
    }
    super.dispose();
  }

  Future<void> _loadImage() async {
    final bytes = await _channel
        .invokeMethod<Uint8List>('getFileBytes', {'uri': widget.uri});
    if (mounted) {
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveToDownloads() async {
    try {
      final fileName = widget.uri.split('/').last;
      final mimeType = widget.isVideo ? 'video/*' : 'image/*';

      final success = await _channel.invokeMethod<bool>('saveFile', {
        'uri': widget.uri,
        'fileName': fileName,
        'mimeType': mimeType,
      });

      if (success == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to Downloads/WhatsBuddy')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
  }

  Future<void> _shareFile() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.uri.split('/').last;
      final tempFile = File('${tempDir.path}/$fileName');

      final bytes = await _channel
          .invokeMethod<Uint8List>('getFileBytes', {'uri': widget.uri});
      await tempFile.writeAsBytes(bytes ?? Uint8List(0));

      await Share.shareXFiles([XFile(tempFile.path)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing file: $e')),
        );
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.uri));
    try {
      await _controller?.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isPlaying = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReactToHeroineDismiss(
      builder: (context, progress, offset, child) {
        final opacity = 1 - progress;
        if (progress > 0.1 && !_isDismissing) {
          _startDismissing();
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: opacity * 20,
                sigmaY: opacity * 20,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5 * opacity),
                child: SafeArea(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.85,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.7,
                            ),
                            child: DragDismissable(
                              child: KeyedSubtree(
                                key: ValueKey(widget.uri),
                                child: Heroine(
                                  tag: widget.uri,
                                  spring: Spring.bouncy,
                                  flightShuttleBuilder:
                                      const FlipShuttleBuilder(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.zero,
                                    child: widget.isVideo
                                        ? _buildVideoPlayer()
                                        : _buildImage(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _buttonAnimationController,
                          builder: (context, child) => FadeTransition(
                            opacity: _buttonOpacityAnimation,
                            child: SlideTransition(
                              position: _buttonSlideAnimation,
                              child: child,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ActionButton(
                                icon: Icons.file_download_outlined,
                                label: 'Save file',
                                onPressed: _saveToDownloads,
                              ),
                              const SizedBox(width: 16),
                              ActionButton(
                                icon: Icons.share_outlined,
                                label: 'Share',
                                onPressed: _shareFile,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_isPlaying) {
            _controller?.pause();
          } else {
            _controller?.play();
          }
          _isPlaying = !_isPlaying;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.transparent,
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
          if (!_isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (_imageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Image.memory(
      _imageBytes!,
      fit: BoxFit.contain,
    );
  }
}
