import 'package:echo/shared/music/domain/album.dart';
import 'package:echo/shared/music/domain/artist.dart';
import 'package:echo/shared/music/domain/genre.dart';
import 'package:echo/shared/music/domain/playlist.dart';
import 'package:echo/shared/music/domain/song.dart';

/// Simple seed models used to generate deterministic data.
///
/// These are intentionally plain (no Firestore access) so the seeder remains
/// reusable and testable.
class MusicSeedModels {
  const MusicSeedModels();

  Genre genre({
    required String id,
    required String name,
    required int colorValue,
    String? imageUrl,
  }) {
    return Genre(
      id: id,
      name: name,
      colorValue: colorValue,
      imageUrl: imageUrl,
    );
  }

  Artist artist({
    required String id,
    required String name,
    String? imageUrl,
    int monthlyListeners = 0,
    bool isVerified = false,
    String? bio,
  }) {
    return Artist(
      id: id,
      name: name,
      imageUrl: imageUrl,
      monthlyListeners: monthlyListeners,
      isVerified: isVerified,
      bio: bio,
    );
  }

  Album album({
    required String id,
    required String title,
    required String artistId,
    required String artistName,
    String? coverUrl,
    required int releaseYear,
    required int songCount,
    String? label,
  }) {
    return Album(
      id: id,
      title: title,
      artistId: artistId,
      artistName: artistName,
      coverUrl: coverUrl,
      releaseYear: releaseYear,
      songCount: songCount,
      label: label,
    );
  }

  Song song({
    required String id,
    required String title,
    required String artistId,
    required String artistName,
    String? albumId,
    String? albumTitle,
    String? albumArtUrl,
    required Duration duration,
    String? audioUrl,
    bool isExplicit = false,
    int trackNumber = 1,
  }) {
    return Song(
      id: id,
      title: title,
      artistId: artistId,
      artistName: artistName,
      albumId: albumId,
      albumTitle: albumTitle,
      albumArtUrl: albumArtUrl,
      duration: duration,
      audioUrl: audioUrl,
      isExplicit: isExplicit,
      trackNumber: trackNumber,
    );
  }

  /// Playlist in the domain does not model songIds.
  ///
  /// Seeder will write:
  /// - playlists/{id} using PlaylistMapper
  /// - playlists/{id}/songs subcollection (only songIds)
  ///   matching the app's expected structure.
  Playlist playlist({
    required String id,
    required String name,
    String? description,
    String? coverUrl,
    required String ownerName,
    int songCount = 0,
    Duration totalDuration = Duration.zero,
    bool isCollaborative = false,
  }) {
    return Playlist(
      id: id,
      name: name,
      description: description,
      coverUrl: coverUrl,
      ownerName: ownerName,
      songCount: songCount,
      totalDuration: totalDuration,
      isCollaborative: isCollaborative,
    );
  }
}

