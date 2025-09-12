import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAudioEnabled = true;
  bool _isVibrationEnabled = true;
  int _malaSize = 108; // New state variable for mala size

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAudioEnabled = prefs.getBool('audio_enabled') ?? true;
      _isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _malaSize = prefs.getInt('mala_size') ?? 108; // Load custom mala size
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_enabled', _isAudioEnabled);
    await prefs.setBool('vibration_enabled', _isVibrationEnabled);
    await prefs.setInt('mala_size', _malaSize); // Save custom mala size
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          _buildTile(
            icon: Icons.volume_up,
            title: 'Enable Audio',
            value: _isAudioEnabled,
            onChanged: (val) {
              setState(() => _isAudioEnabled = val);
              _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          _buildTile(
            icon: Icons.vibration,
            title: 'Enable Vibration',
            value: _isVibrationEnabled,
            onChanged: (val) {
              setState(() => _isVibrationEnabled = val);
              _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          _buildMalaSizeTile(), // New custom mala size tile
          const SizedBox(height: 40),
          Text(
            'About',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.info_outline,
            title: 'App Version',
            value: '1.0.0',
          ),
          _buildInfoTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            value: '',
            onTap: () {
              // Handle privacy tap
            },
          ),
          _buildInfoTile(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            value: '',
            onTap: () {
              // Handle feedback tap
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.tealAccent[400],
        inactiveThumbColor: Colors.grey[500],
        inactiveTrackColor: Colors.grey[700],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildMalaSizeTile() {
    const List<int> malaOptions = [27, 54, 108, 216];
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.countertops, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _malaSize,
              dropdownColor: Colors.grey[850],
              decoration: const InputDecoration(
                labelText: 'Mala Size',
                labelStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
              items: malaOptions
                  .map(
                    (size) => DropdownMenuItem(
                      value: size,
                      child: Text(
                        '$size Beads',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _malaSize = value);
                  _saveSettings();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: value.isNotEmpty
            ? Text(value, style: TextStyle(color: Colors.white70))
            : const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
