import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import '../data/status_repository.dart';
import './full_screen_viewer.dart';
import 'package:flutter/services.dart';
import 'package:heroine/heroine.dart';
import 'package:shimmer/shimmer.dart';

// Create a state notifier to handle the status files
class StatusNotifier extends StateNotifier<AsyncValue<List<String>>> {
  StatusNotifier() : super(const AsyncValue.loading()) {
    loadStatuses();
  }

  Future<void> loadStatuses() async {
    try {
      state = const AsyncValue.loading();
      final files = await StatusRepository.getStatusFiles();
      if (!mounted) return;
      state = AsyncValue.data(files);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }
}

// Create a provider for the status notifier
final statusNotifierProvider =
    StateNotifierProvider.autoDispose<StatusNotifier, AsyncValue<List<String>>>(
        (ref) {
  return StatusNotifier()..loadStatuses();
});

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<String> _images = [];
  List<String> _videos = [];
  String? _selectedDirectory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    StatusRepository.setupDirectoryListener();
    _checkExistingAccess();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _loadFiles();
      });
    }
  }

  void _checkExistingAccess() async {
    final uri = await StatusRepository.getStatusFolderUri();
    if (mounted) {
      setState(() {
        _selectedDirectory = uri;
        if (uri != null) {
          // Now ref is accessible
          ref.refresh(statusNotifierProvider);
        }
        _loadFiles();
      });
    }
  }

  Future<List<String>> _loadFiles() async {
    if (_selectedDirectory == null) return [];
    final files = await StatusRepository.getStatusFiles();
    _images = files.where(StatusRepository.isImage).toList();
    _videos = files.where(StatusRepository.isVideo).toList();
    return files;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Column(
                  children: [
                    Text(
                      'Status Saver',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                        fontFamily: 'Geist',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Easily save any WhatsApp\nStatus to your local storage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        height: 1.4,
                        fontFamily: 'Geist',
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
          body: _selectedDirectory == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Storage access is required for Status files',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _requestAccess,
                        child: const Text('Select Status Folder'),
                      ),
                    ],
                  ),
                )
              : Consumer(
                  builder: (context, ref, _) {
                    final statusAsync = ref.watch(statusNotifierProvider);
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.refresh(statusNotifierProvider),
                      child: statusAsync.when(
                        loading: () => _buildShimmerLoading(isDark),
                        error: (error, stack) =>
                            Center(child: Text('Error: $error')),
                        data: (files) {
                          _images =
                              files.where(StatusRepository.isImage).toList();
                          _videos =
                              files.where(StatusRepository.isVideo).toList();
                          return Column(
                            children: [
                              Container(
                                height: 40,
                                padding: const EdgeInsets.all(4),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 48),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[900]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  dividerColor: Colors.transparent,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelColor:
                                      isDark ? Colors.white : Colors.black,
                                  unselectedLabelColor: isDark
                                      ? Colors.white38
                                      : Colors.grey[400],
                                  labelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Geist',
                                  ),
                                  unselectedLabelStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Geist',
                                  ),
                                  padding: EdgeInsets.zero,
                                  labelPadding: EdgeInsets.zero,
                                  tabs: const [
                                    Tab(text: 'Images'),
                                    Tab(text: 'Videos'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildMediaGrid(_images),
                                    _buildMediaGrid(_videos),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid(List<String> uris) {
    if (uris.isEmpty) {
      return const Center(child: Text('No statuses found'));
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => KeyedSubtree(
                key: ValueKey(uris[index]),
                child: _MediaThumbnail(uri: uris[index]),
              ),
              childCount: uris.length,
            ),
          ),
        ),
      ],
    );
  }

  void _requestAccess() async {
    await StatusRepository.requestStatusAccess();
    await Future.delayed(const Duration(milliseconds: 500));
    final uri = await StatusRepository.getStatusFolderUri();
    if (mounted && uri != null) {
      setState(() => _selectedDirectory = uri);
      ref.read(statusNotifierProvider.notifier).loadStatuses();
      _loadFiles();
    } else if (mounted) {
      _checkExistingAccess();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: [
          // Tab Bar Skeleton
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          // Grid Skeleton
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      childCount: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final String uri;
  final _channel = const MethodChannel('com.debojyoti.whatsbuddy/status_files');

  const _MediaThumbnail({required this.uri});

  Future<Uint8List> _loadImageBytes() async {
    try {
      final bytes =
          await _channel.invokeMethod<Uint8List>('getFileBytes', {'uri': uri});
      return bytes ?? Uint8List(0);
    } catch (e) {
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: Container(
        decoration: ShapeDecoration(
          shape: SquircleBorder(radius: BorderRadius.circular(32)),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Heroine(
          tag: uri,
          spring: Spring.bouncy,
          flightShuttleBuilder: const FlipShuttleBuilder(),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: SquircleBorder(radius: BorderRadius.circular(32)),
            ),
            child: StatusRepository.isImage(uri)
                ? FutureBuilder<Uint8List>(
                    future: _loadImageBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        );
                      }
                      return Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            size: 32,
                          ),
                        ),
                      );
                    },
                  )
                : _VideoPreview(uri: uri),
          ),
        ),
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenViewer(
          uri: uri,
          isVideo: StatusRepository.isVideo(uri),
        ),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final String uri;

  const _VideoPreview({required this.uri});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.uri));
    try {
      await _controller?.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isInitialized && _controller != null)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
        else
          Container(color: Colors.grey[800]),
        const Center(
          child: Icon(Icons.play_circle_filled, size: 50, color: Colors.white),
        ),
      ],
    );
  }
}
