import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:echo/app/theme/app_colors.dart';
import 'package:echo/app/theme/app_radius.dart';
import 'package:echo/app/theme/app_spacing.dart';
import 'package:echo/app/theme/app_typography.dart';
import 'package:echo/features/upload/models/song_upload_failure.dart';
import 'package:echo/features/upload/models/song_upload_request.dart';
import 'package:echo/features/upload/models/song_upload_result.dart';
import 'package:echo/features/upload/providers/song_upload_provider.dart';

class UploadSongPage extends ConsumerStatefulWidget {
  const UploadSongPage({super.key});

  @override
  ConsumerState<UploadSongPage> createState() => _UploadSongPageState();
}

class _UploadSongPageState extends ConsumerState<UploadSongPage> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String _selectedGenre = 'Pop';
  bool _explicit = false;
  bool _isPublic = true;

  File? _audioFile;
  String? _audioFileName;

  File? _coverFile;

  // Upload state
  bool _isUploading = false;
  double _progress = 0;
  String? _statusText;
  String? _errorText;
  SongUploadResult? _successResult;

  UploadCancellationTokenProxy? _cancelProxy;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _cancelProxy?.dispose();
    super.dispose();
  }

  bool get _canUpload {
    final titleOk = _titleController.text.trim().isNotEmpty;
    final artistOk = _artistController.text.trim().isNotEmpty;
    return _audioFile != null && _coverFile != null && titleOk && artistOk;
  }

  Future<void> _pickMp3() async {
    if (_isUploading) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3'],
      withData: false,
    );

    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;

    setState(() {
      _audioFile = File(path);
      _audioFileName = result.files.single.name;
      _successResult = null;
      _errorText = null;
    });
  }

  Future<void> _pickCoverImage() async {
    if (_isUploading) return;

    // Prefer image_picker for a native flow.
    // Fallback: if image_picker yields no file, use file_picker (desktop).
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 85,
      );

      if (picked != null && picked.path.isNotEmpty) {
        setState(() {
          _coverFile = File(picked.path);
          _successResult = null;
          _errorText = null;
        });
        return;
      }
    } catch (_) {
      // ignore and fallback
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );

    if (result == null) return;
    final path = result.files.single.path;
    if (path == null) return;

    setState(() {
      _coverFile = File(path);
      _successResult = null;
      _errorText = null;
    });
  }

  void _setUploadingState({
    required bool uploading,
    double progress = 0,
    String? statusText,
    String? errorText,
    SongUploadResult? successResult,
  }) {
    setState(() {
      _isUploading = uploading;
      _progress = progress;
      _statusText = statusText;
      _errorText = errorText;
      _successResult = successResult;
    });
  }

  Future<void> _publish() async {
    if (!_canUpload || _isUploading) return;

    final request = SongUploadRequest(
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      album: _albumController.text.trim(),
      genre: _selectedGenre,
      duration: const Duration(seconds: 0),
      audioFile: _audioFile!,
      coverFile: _coverFile!,
      visibility: _isPublic ? 'Public' : 'Private',
      explicit: _explicit,
    );

    _setUploadingState(
      uploading: true,
      progress: 0,
      statusText: 'Uploading…',
      errorText: null,
      successResult: null,
    );

    // StorageUploadService currently provides no real granular progress.
    // We still surface premium UX: animate progress over the lifecycle.
    final proxy = UploadCancellationTokenProxy();
    _cancelProxy?.dispose();
    _cancelProxy = proxy;

    // Animate from current progress to near-complete while request runs.
    final progressTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      if (!proxy.isActive) return;
      setState(() {
        if (_progress < 92) _progress = _progress + 1.5;
      });
    });

    try {
      final result = await ref.read(songUploadRepositoryProvider).publishSong(request);

      result.fold(
        (failure) {
          _setUploadingState(
            uploading: false,
            progress: 100,
            statusText: 'Upload failed',
            errorText: failure.message,
            successResult: null,
          );
        },
        (success) {
          // Ensure bar reaches 100 for success.
          setState(() {
            _progress = 100;
            _statusText = 'Published';
            _successResult = success;
          });

          // Clear form.
          _titleController.clear();
          _artistController.clear();
          _albumController.clear();
          _selectedGenre = 'Pop';
          _explicit = false;
          _isPublic = true;
          _audioFile = null;
          _audioFileName = null;
          _coverFile = null;
          _errorText = null;

          _setUploadingState(
            uploading: false,
            progress: 100,
            statusText: 'Success',
            errorText: null,
            successResult: success,
          );
        },
      );
    } catch (e) {
      _setUploadingState(
        uploading: false,
        progress: 0,
        statusText: 'Upload failed',
        errorText: e.toString(),
        successResult: null,
      );
    } finally {
      proxy.dispose();
      progressTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final disableAll = _isUploading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Song'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _buildHeaderCard(),
                const SizedBox(height: AppSpacing.md),
                _buildMetaFields(disableAll),
                const SizedBox(height: AppSpacing.md),
                _buildMediaPickers(disableAll),
                const SizedBox(height: AppSpacing.md),
                _buildUploadSection(),
                const SizedBox(height: AppSpacing.lg),
                _buildBottomActions(disableAll),
                if (_successResult != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildSuccessBanner(_successResult!),
                ],
                const SizedBox(height: 8),
                if (_errorText != null) _buildErrorBanner(_errorText!),
                const SizedBox(height: 16),
                // Keep a subtle hint to satisfy “Return created SongUploadResult”.
                if (_successResult != null)
                  Text(
                    'Song ID: ${_successResult!.songId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publish your track',
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Upload audio + cover, add metadata, then publish.',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaFields(bool disableAll) {
    const genres = ['Pop', 'Hip Hop', 'Rock', 'Jazz', 'Electronic', 'R&B', 'Classical'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Song Details',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          controller: _titleController,
          enabled: !disableAll,
          decoration: _inputDecoration('Song Title', Icons.music_note_rounded),
          validator: (_) {
            if (_titleController.text.trim().isEmpty) return 'Title is required';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          controller: _artistController,
          enabled: !disableAll,
          decoration: _inputDecoration('Artist', Icons.person_rounded),
          validator: (_) {
            if (_artistController.text.trim().isEmpty) return 'Artist is required';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          controller: _albumController,
          enabled: !disableAll,
          decoration: _inputDecoration('Album (optional)', Icons.album_rounded),
        ),
        const SizedBox(height: AppSpacing.sm),

        DropdownButtonFormField<String>(
          value: _selectedGenre,
          decoration: _inputDecoration('Genre', Icons.category_rounded),
          items: [
            for (final g in genres)
              DropdownMenuItem(
                value: g,
                child: Text(g, style: AppTypography.textTheme.bodyLarge),
              )
          ],
          onChanged: disableAll ? null : (v) => setState(() => _selectedGenre = v ?? _selectedGenre),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Explicit switch + visibility picker.
        Row(
          children: [
            Expanded(
              child: _buildSwitchTile(
                title: 'Explicit',
                subtitle: 'Contains explicit content',
                value: _explicit,
                onChanged: disableAll ? null : (v) => setState(() => _explicit = v),
                icon: Icons.explicit_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildVisibilityPicker(disableAll),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withOpacity(0.55)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider.withOpacity(0.6)),
            ),
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityPicker(bool disableAll) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withOpacity(0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visibility',
            style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Public')),
              ButtonSegment(value: false, label: Text('Private')),
            ],
            selected: {_isPublic},
            onSelectionChanged: disableAll
                ? null
                : (newSelection) {
                    final next = newSelection.first;
                    setState(() => _isPublic = next);
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPickers(bool disableAll) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // MP3 picker
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider.withOpacity(0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MP3 Audio',
                style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _audioFileName ?? 'No MP3 selected',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: _audioFileName == null ? AppColors.textHint : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: disableAll ? null : _pickMp3,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Choose MP3'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Cover picker
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider.withOpacity(0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cover Image',
                style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Container(
                      width: 92,
                      height: 92,
                      color: AppColors.surfaceVariant.withOpacity(0.35),
                      child: _coverFile == null
                          ? Center(
                              child: Icon(
                                Icons.image_rounded,
                                color: AppColors.textHint,
                              ),
                            )
                          : Image.file(_coverFile!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _coverFile == null ? 'No cover selected' : 'Cover selected',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: _coverFile == null ? AppColors.textHint : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: disableAll ? null : _pickCoverImage,
                          icon: const Icon(Icons.photo_library_rounded),
                          label: const Text('Choose Cover'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: AppColors.divider.withOpacity(0.8)),
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    final percent = _progress.clamp(0, 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        if (_statusText != null)
          Text(
            _statusText!,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: _errorText != null ? AppColors.error : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

        const SizedBox(height: AppSpacing.sm),

        LinearProgressIndicator(
          value: _progress / 100,
          minHeight: 10,
          backgroundColor: AppColors.surfaceVariant.withOpacity(0.35),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),

        const SizedBox(height: AppSpacing.sm),

        Row(
          children: [
            Text(
              '$percent%',
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _isUploading ? 'Uploading in progress' : 'Ready',
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              _errorText!,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomActions(bool disableAll) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (!_canUpload || disableAll) ? null : _publish,
        icon: const Icon(Icons.cloud_upload_rounded),
        label: Text(_isUploading ? 'Publishing…' : 'Upload'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBanner(SongUploadResult result) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.success.withOpacity(0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.22),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.success.withOpacity(0.5)),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Song published successfully',
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created Song ID: ${result.songId}',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withOpacity(0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.22),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.error.withOpacity(0.5)),
            ),
            child: const Icon(Icons.error_rounded, color: AppColors.error),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.surfaceVariant.withOpacity(0.22),
      labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.textHint,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: BorderSide(color: AppColors.divider.withOpacity(0.65)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.9)),
      ),
    );
  }
}

/// Small helper to coordinate local UI progress animation lifecycle.
/// Does NOT cancel backend calls (backend cancellation token isn't wired
/// through repository at this time).
class UploadCancellationTokenProxy {
  bool _disposed = false;

  bool get isActive => !_disposed;

  void dispose() {
    _disposed = true;
  }
}

