import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../data/status_repository.dart';
import './full_screen_viewer.dart';
import 'package:flutter/services.dart';
import 'package:heroine/heroine.dart';

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
  late Future<List<String>> _filesFuture;
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
        _filesFuture = _loadFiles();
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
        _filesFuture = _loadFiles();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Saver'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.image), text: 'Images'),
            Tab(icon: Icon(Icons.videocam), text: 'Videos'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_selectedDirectory == null) {
      return Center(
        child: ElevatedButton(
          onPressed: _requestAccess,
          child: const Text('Select Status Folder'),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final statusAsync = ref.watch(statusNotifierProvider);
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(statusNotifierProvider),
          child: statusAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (files) {
              _images = files.where(StatusRepository.isImage).toList();
              _videos = files.where(StatusRepository.isVideo).toList();
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildMediaGrid(_images),
                  _buildMediaGrid(_videos),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMediaGrid(List<String> uris) {
    if (uris.isEmpty) {
      return const Center(child: Text('No statuses found'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: uris.length,
      itemBuilder: (context, index) => KeyedSubtree(
        key: ValueKey(uris[index]),
        child: Heroine(
          tag: uris[index],
          spring: Spring.bouncy,
          flightShuttleBuilder: const FlipShuttleBuilder(),
          child: _MediaThumbnail(uri: uris[index]),
        ),
      ),
    );
  }

  void _requestAccess() async {
    await StatusRepository.requestStatusAccess();
    final uri = await StatusRepository.getStatusFolderUri();
    if (mounted && uri != null) {
      setState(() {
        _selectedDirectory = uri;
        _filesFuture = _loadFiles();
      });
      // Now ref is accessible
      ref.refresh(statusNotifierProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
                  return Container(color: Colors.grey[800]);
                },
              )
            : _VideoPreview(uri: uri),
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenViewer(
          uri: uri,
          isVideo: StatusRepository.isVideo(uri),
        ),
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
