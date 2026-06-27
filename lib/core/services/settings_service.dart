import 'dart:async';

/// Represents user app settings.
class AppSettings {
  final String theme;
  final String language;
  final String audioQuality;
  final bool autoplay;
  final bool explicitContent;

  const AppSettings({
    this.theme = 'system',
    this.language = 'en',
    this.audioQuality = 'high',
    this.autoplay = true,
    this.explicitContent = false,
  });

  AppSettings copyWith({
    String? theme,
    String? language,
    String? audioQuality,
    bool? autoplay,
    bool? explicitContent,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      audioQuality: audioQuality ?? this.audioQuality,
      autoplay: autoplay ?? this.autoplay,
      explicitContent: explicitContent ?? this.explicitContent,
    );
  }
}

/// Service for managing user app settings.
abstract class SettingsService {
  /// Saves the app settings.
  Future<void> saveSettings(AppSettings settings);

  /// Loads the app settings.
  Future<AppSettings> loadSettings();

  /// Stream of settings changes.
  Stream<AppSettings> get settingsStream;

  /// Updates a specific setting.
  Future<void> updateSetting(String key, dynamic value);
}

/// Mock implementation of SettingsService for development and testing.
///
/// Later this will use SharedPreferences or similar.
class MockSettingsService implements SettingsService {
  AppSettings _settings = const AppSettings();
  final _controller = StreamController<AppSettings>.broadcast();

  @override
  Stream<AppSettings> get settingsStream => _controller.stream;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    // Mock: save settings
    _settings = settings;
    _controller.add(_settings);
  }

  @override
  Future<AppSettings> loadSettings() async {
    // Mock: load settings
    return _settings;
  }

  @override
  Future<void> updateSetting(String key, dynamic value) async {
    // Mock: update single setting
    switch (key) {
      case 'theme':
        _settings = _settings.copyWith(theme: value as String);
        break;
      case 'language':
        _settings = _settings.copyWith(language: value as String);
        break;
      case 'audioQuality':
        _settings = _settings.copyWith(audioQuality: value as String);
        break;
      case 'autoplay':
        _settings = _settings.copyWith(autoplay: value as bool);
        break;
      case 'explicitContent':
        _settings = _settings.copyWith(explicitContent: value as bool);
        break;
    }
    _controller.add(_settings);
  }
}