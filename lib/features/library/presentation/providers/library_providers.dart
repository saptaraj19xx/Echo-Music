import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/shared/core/ui_state.dart';
import 'package:echo/features/library/domain/repositories/library_repository.dart';
import 'package:echo/core/firebase/providers/auth_adapter_provider.dart';
import 'package:echo/core/firebase/providers/firestore_adapter_provider.dart';
import 'package:echo/features/library/data/repositories/firestore_library_repository_impl.dart';



// ---------------------------------------------------------------------------
// Library repository provider
// ---------------------------------------------------------------------------
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final auth = ref.watch(authAdapterProvider);
  final firestore = ref.watch(firestoreAdapterProvider);

  return FirestoreLibraryRepositoryImpl(
    auth: auth,
    firestore: firestore,
  );
});


// ---------------------------------------------------------------------------
// Favorites provider
// ---------------------------------------------------------------------------
class FavoritesNotifier extends StateNotifier<UiState<void>> {
  final LibraryRepository _repository;

  FavoritesNotifier(this._repository) : super(const Success(null));

  Future<void> toggleFavoriteSong(String songId) async {
    final current = _repository.getFavoriteSongs();
    final isFavorite = current.any((s) => s.songId == songId);
    if (isFavorite) {
      _repository.removeFavoriteSong(songId);
    } else {
      _repository.addFavoriteSong(songId);
    }
    state = const Success(null);
  }

  Future<void> toggleFavoriteAlbum(String albumId) async {
    final current = _repository.getFavoriteAlbums();
    final isFavorite = current.any((a) => a.albumId == albumId);
    if (isFavorite) {
      _repository.removeFavoriteAlbum(albumId);
    } else {
      _repository.addFavoriteAlbum(albumId);
    }
    state = const Success(null);
  }

  Future<void> toggleFavoriteArtist(String artistId) async {
    final current = _repository.getFavoriteArtists();
    final isFavorite = current.any((a) => a.artistId == artistId);
    if (isFavorite) {
      _repository.removeFavoriteArtist(artistId);
    } else {
      _repository.addFavoriteArtist(artistId);
    }
    state = const Success(null);
  }

  bool isFavoriteSong(String songId) {
    return _repository.getFavoriteSongs().any((s) => s.songId == songId);
  }

  bool isFavoriteAlbum(String albumId) {
    return _repository.getFavoriteAlbums().any((a) => a.albumId == albumId);
  }

  bool isFavoriteArtist(String artistId) {
    return _repository.getFavoriteArtists()
        .any((a) => a.artistId == artistId);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, UiState<void>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return FavoritesNotifier(repository);
});

// ---------------------------------------------------------------------------
// Downloads provider
// ---------------------------------------------------------------------------
class DownloadsNotifier extends StateNotifier<UiState<void>> {
  final LibraryRepository _repository;

  DownloadsNotifier(this._repository) : super(const Success(null));

  Future<void> toggleDownload(String songId) async {
    final current = _repository.getDownloadedSongs();
    final isDownloaded = current.any((d) => d.songId == songId);
    if (isDownloaded) {
      _repository.removeDownload(songId);
    } else {
      _repository.addDownload(songId);
    }
    state = const Success(null);
  }

  bool isDownloaded(String songId) {
    return _repository.getDownloadedSongs().any((d) => d.songId == songId);
  }
}

final downloadsProvider =
    StateNotifierProvider<DownloadsNotifier, UiState<void>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return DownloadsNotifier(repository);
});

// ---------------------------------------------------------------------------
// Recent provider
// ---------------------------------------------------------------------------
class RecentNotifier extends StateNotifier<UiState<void>> {
  final LibraryRepository _repository;

  RecentNotifier(this._repository) : super(const Success(null));

  Future<void> addToRecent(String songId) async {
    _repository.addRecentlyPlayed(songId);
    state = const Success(null);
  }
}

final recentProvider = StateNotifierProvider<RecentNotifier, UiState<void>>(
  (ref) {
    final repository = ref.watch(libraryRepositoryProvider);
    return RecentNotifier(repository);
  },
);

// ---------------------------------------------------------------------------
// Collections provider
// ---------------------------------------------------------------------------
class CollectionsNotifier extends StateNotifier<UiState<void>> {
  CollectionsNotifier() : super(const Success(null));

  Future<void> createCollection(String name) async {
    // Mock: collection creation
    state = const Success(null);
  }
}

final collectionsProvider =
    StateNotifierProvider<CollectionsNotifier, UiState<void>>((ref) {
  return CollectionsNotifier();
});

