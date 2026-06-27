import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_download_service.dart';
import 'service.dart';

/// Riverpod provider for [DownloadService].
///
/// This layer uses mock implementations only for Sprint 11.
final downloadServiceProvider =
    Provider<DownloadService>((ref) => MockDownloadService());

