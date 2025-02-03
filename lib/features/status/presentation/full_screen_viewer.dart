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
  bool _isVideoInitialized = false;
  bool _isDismissing = false;
  final _spring = Spring.bouncy;
  bool _canDismiss = false;

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
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 100),
    );

    if (!widget.isVideo) {
      _buttonAnimationController.forward().then((_) {
        if (mounted) setState(() => _canDismiss = true);
      });
    }
  }

  void _startDismissing() async {
    if (!_isDismissing && mounted) {
      setState(() => _isDismissing = true);
      await _buttonAnimationController.reverse();
      if (mounted) {
        setState(() => _canDismiss = true);
      }
    }
  }

  Future<bool> _onWillPop() async {
    _startDismissing();
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
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
    try {
      final bytes = await _channel
          .invokeMethod<Uint8List>('getFileBytes', {'uri': widget.uri});
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
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
        await _buttonAnimationController.forward();
        if (mounted) setState(() => _canDismiss = true);
      }
    } catch (error) {
      debugPrint('Error initializing video: $error');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _canDismiss = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ReactToHeroineDismiss(
        builder: (context, progress, offset, child) {
          final actualProgress = _canDismiss ? progress : 0.0;
          final opacity = (1 - actualProgress).clamp(0.0, 1.0);
          final blurSigma = (1 - actualProgress) * 20.0;

          if (actualProgress > 0.1 && !_isDismissing) {
            _startDismissing();
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: blurSigma * value,
                        sigmaY: blurSigma * value,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.6 * opacity * value),
                      ),
                    );
                  },
                ),
                SafeArea(
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
                                  spring: _spring,
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
                      AnimatedBuilder(
                        animation: _buttonAnimationController,
                        builder: (context, child) {
                          final value = _buttonAnimationController.value;
                          final yOffset = (1 - value) * 120;
                          final scale = 0.8 + (value * 0.2);
                          final buttonOpacity = value.clamp(0.0, 1.0);

                          return Positioned(
                            bottom: 40,
                            left: 0,
                            right: 0,
                            child: Transform.translate(
                              offset: Offset(0, yOffset),
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: buttonOpacity,
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
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
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
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          if (!_isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (_imageBytes == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }
    return Image.memory(
      _imageBytes!,
      fit: BoxFit.contain,
    );
  }
}
