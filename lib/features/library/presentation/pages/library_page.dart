import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/features/library/domain/entities/favorite_song.dart';
import 'package:echo/features/library/domain/entities/favorite_album.dart';
import 'package:echo/features/library/domain/entities/favorite_artist.dart';
import 'package:echo/features/library/domain/entities/downloaded_song.dart';
import 'package:echo/features/library/domain/entities/recently_played.dart';
import 'package:echo/features/library/domain/entities/collection.dart';
import 'package:echo/features/library/domain/entities/user_library.dart';
import 'package:echo/features/library/presentation/providers/library_providers.dart';
import 'package:echo/features/library/presentation/widgets/library_section.dart';
import 'package:echo/features/library/presentation/widgets/context_menu.dart';
import 'package:echo/features/library/presentation/widgets/library_empty_state.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  ViewMode _viewMode = ViewMode.list;
  SortOption _sortOption = SortOption.recent;
  final Set<String> _activeFilters = {};

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryRepositoryProvider);

    final favoriteSongs = libraryState.getFavoriteSongs();
    final favoriteAlbums = libraryState.getFavoriteAlbums();
    final favoriteArtists = libraryState.getFavoriteArtists();
    final downloadedSongs = libraryState.getDownloadedSongs();
    final recentlyPlayed = libraryState.getRecentlyPlayed();
    final collections = libraryState.getCollections();
    final userPlaylists = libraryState.getUserPlaylists();

    final library = UserLibrary(
      favoriteSongs: favoriteSongs,
      favoriteAlbums: favoriteAlbums,
      favoriteArtists: favoriteArtists,
      downloadedSongs: downloadedSongs,
      recentlyPlayed: recentlyPlayed,
      collections: collections,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: Icon(_viewMode == ViewMode.list ? Icons.grid_view : Icons.list),
            onPressed: () {
              setState(() {
                _viewMode =
                    _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
              });
            },
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortOption.recent,
                child: Text('Recently Added'),
              ),
              PopupMenuItem(
                value: SortOption.name,
                child: Text('Name'),
              ),
              PopupMenuItem(
                value: SortOption.artist,
                child: Text('Artist'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_activeFilters.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ..._activeFilters.map((filter) => Chip(
                        label: Text(filter),
                        onDeleted: () {
                          setState(() {
                            _activeFilters.remove(filter);
                          });
                        },
                      )),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _activeFilters.clear();
                      });
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _buildLibraryContent(library, userPlaylists),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCollectionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Collection'),
      ),
    );
  }

  Widget _buildLibraryContent(UserLibrary library, List<Playlist> playlists) {
    final hasContent = library.recentlyPlayed.isNotEmpty ||
        library.favoriteSongs.isNotEmpty ||
        library.favoriteAlbums.isNotEmpty ||
        library.favoriteArtists.isNotEmpty ||
        library.downloadedSongs.isNotEmpty ||
        playlists.isNotEmpty ||
        library.collections.isNotEmpty;

    if (!hasContent) {
      return const LibraryEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (library.recentlyPlayed.isNotEmpty)
          LibrarySection<RecentlyPlayed>(
            title: 'Recently Played',
            items: _sortedItems(library.recentlyPlayed),
            viewMode: _viewMode,
            itemBuilder: (item) => RecentPlayedTile(item: item),
            emptyMessage: 'No recently played songs',
          ),
        const SizedBox(height: 24),
        if (library.favoriteSongs.isNotEmpty ||
            library.favoriteAlbums.isNotEmpty ||
            library.favoriteArtists.isNotEmpty)
          LibrarySection<dynamic>(
            title: 'Favorites',
            items: _buildFavorites(library),
            viewMode: _viewMode,
            itemBuilder: (item) {
              if (item is FavoriteSong) {
                return FavoriteSongTile(item: item);
              } else if (item is FavoriteAlbum) {
                return FavoriteAlbumTile(item: item);
              } else if (item is FavoriteArtist) {
                return FavoriteArtistTile(item: item);
              }
              return const SizedBox.shrink();
            },
            emptyMessage: 'No favorites yet',
          ),
        const SizedBox(height: 24),
        if (library.downloadedSongs.isNotEmpty)
          LibrarySection<DownloadedSong>(
            title: 'Downloaded Music',
            items: _sortedDownloads(library.downloadedSongs),
            viewMode: _viewMode,
            itemBuilder: (item) => DownloadedSongTile(item: item),
            emptyMessage: 'No downloaded songs',
          ),
        const SizedBox(height: 24),
        if (playlists.isNotEmpty)
          LibrarySection<Playlist>(
            title: 'Playlists',
            items: playlists,
            viewMode: _viewMode,
            itemBuilder: (item) => PlaylistTile(playlist: item),
            emptyMessage: 'No playlists',
          ),
        const SizedBox(height: 24),
        if (library.collections.isNotEmpty)
          LibrarySection<Collection>(
            title: 'Collections',
            items: library.collections,
            viewMode: _viewMode,
            itemBuilder: (item) => CollectionTile(collection: item),
            emptyMessage: 'No collections',
          ),
      ],
    );
  }

  List<dynamic> _buildFavorites(UserLibrary library) {
    final items = <dynamic>[];
    items.addAll(library.favoriteSongs);
    items.addAll(library.favoriteAlbums);
    items.addAll(library.favoriteArtists);
    return items;
  }

  List<RecentlyPlayed> _sortedItems(List<RecentlyPlayed> items) {
    final sorted = List<RecentlyPlayed>.from(items);
    switch (_sortOption) {
      case SortOption.recent:
        sorted.sort((a, b) => b.playedAt.compareTo(a.playedAt));
        break;
      case SortOption.name:
        sorted.sort((a, b) => a.songId.compareTo(b.songId));
        break;
      case SortOption.artist:
        sorted.sort((a, b) => a.songId.compareTo(b.songId));
        break;
    }
    return sorted;
  }

  List<DownloadedSong> _sortedDownloads(List<DownloadedSong> items) {
    final sorted = List<DownloadedSong>.from(items);
    sorted.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return sorted;
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Collection name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(collectionsProvider.notifier).createCollection(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class RecentPlayedTile extends StatelessWidget {
  final RecentlyPlayed item;

  const RecentPlayedTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
      title: Text('Song ${item.songId}'),
      subtitle: Text(
        'Played ${_timeAgo(item.playedAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        // Handle tap
      },
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SongContextMenu(),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class FavoriteSongTile extends StatelessWidget {
  final FavoriteSong item;

  const FavoriteSongTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.favorite, color: Colors.red),
      title: Text('Song ${item.songId}'),
      subtitle: Text('Added ${_timeAgo(item.addedAt)}'),
      onTap: () {},
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SongContextMenu(),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class FavoriteAlbumTile extends StatelessWidget {
  final FavoriteAlbum item;

  const FavoriteAlbumTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.album, color: Colors.blue),
      title: Text('Album ${item.albumId}'),
      subtitle: Text('Added ${_timeAgo(item.addedAt)}'),
      onTap: () {},
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SongContextMenu(),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class FavoriteArtistTile extends StatelessWidget {
  final FavoriteArtist item;

  const FavoriteArtistTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person, color: Colors.purple),
      title: Text('Artist ${item.artistId}'),
      subtitle: Text('Added ${_timeAgo(item.addedAt)}'),
      onTap: () {},
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SongContextMenu(),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class DownloadedSongTile extends StatelessWidget {
  final DownloadedSong item;

  const DownloadedSongTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.download, color: Colors.green),
      title: Text('Song ${item.songId}'),
      subtitle: Text('Downloaded ${_timeAgo(item.downloadedAt)}'),
      onTap: () {},
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SongContextMenu(),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;

  const PlaylistTile({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.playlist_play, color: Colors.orange),
      title: Text(playlist.name),
      subtitle: Text(playlist.ownerName),
      onTap: () {},
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SongContextMenu(),
    );
  }
}

class CollectionTile extends StatelessWidget {
  final Collection collection;

  const CollectionTile({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder, color: Colors.amber),
      title: Text(collection.name),
      subtitle: Text('${collection.songIds.length} songs'),
      onTap: () {},
      onLongPress: () => _showContextMenu(context),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SongContextMenu(),
    );
  }
}