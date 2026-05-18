import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:printing/printing.dart';

const _spreadsheetName = 'Support App Data';
const _driveFolderId = '1Ch-zzljZl8_sZK-4DXtzD86-eqNUAk5X';
const _credentialsAsset = 'assets/credentials.json';
const _manualFilesKey = 'manual_guide_files';
const _imagePickerKey = 'image_picker';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Support App',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF07101B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF081827),
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.cyanAccent,
            letterSpacing: 0.8,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF0C1928),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF122136),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support App')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxis = constraints.maxWidth > 900
                      ? 4
                      : (constraints.maxWidth > 600 ? 3 : 2);

                  final items = <Map<String, Object>>[
                    {
                      'icon': Icons.work_outline,
                      'label': 'PM Work Notes',
                      'builder': () => const PMWorkNotesScreen(),
                    },
                    {
                      'icon': Icons.build_outlined,
                      'label': 'CM Work Notes',
                      'builder': () => const CMWorkNotesScreen(),
                    },
                    {
                      'icon': Icons.bar_chart,
                      'label': 'Statistics',
                      'builder': () => const StatisticsScreen(),
                    },
                    {
                      'icon': Icons.vpn_key,
                      'label': 'ID / Password',
                      'builder': () => const IdPasswordScreen(),
                    },
                    {
                      'icon': Icons.picture_as_pdf,
                      'label': 'Reports',
                      'builder': () => const ReportsScreen(),
                    },
                    {
                      'icon': Icons.wifi,
                      'label': 'WiFi',
                      'builder': () => const WiFiPasswordScreen(),
                    },
                    {
                      'icon': Icons.mic,
                      'label': 'Microphone',
                      'builder': () => const MicrophoneChannelScreen(),
                    },
                  ];

                  return GridView.count(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: items.map((it) {
                      final icon = it['icon'] as IconData;
                      final label = it['label'] as String;
                      final builder = it['builder'] as Widget Function();
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => builder()),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.cyanAccent
                                      .withOpacity(0.12),
                                  child: Icon(
                                    icon,
                                    size: 28,
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Ready',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- Statistics Screen -------------------------
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PM Notes: ${SheetSyncService.instance.pmNotes.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'CM Notes: ${SheetSyncService.instance.cmNotes.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'เพิ่มงาน PM/CM แล้วจะเห็นจำนวนอัปเดตที่นี่ทันที',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------- Remaining screens and helpers -------------------------

class CMWorkNotesScreen extends StatefulWidget {
  const CMWorkNotesScreen({super.key});

  @override
  State<CMWorkNotesScreen> createState() => _CMWorkNotesScreenState();
}

class _CMWorkNotesScreenState extends State<CMWorkNotesScreen> {
  final List<WorkNote> cmNotes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      cmNotes.clear();
      cmNotes.addAll(await SheetSyncService.instance.fetchWorkNotes('CM'));
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _addNote() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AddNoteDialog(
        onAdd: (title, description, imagePaths) async {
          await SheetSyncService.instance.addWorkNote(
            'CM',
            WorkNote(
              title: title,
              description: description,
              imagePaths: imagePaths,
              createdAt: DateTime.now(),
            ),
          );
          await _loadNotes();
        },
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกงานเรียบร้อยแล้ว')));
    }
  }

  Future<void> _editNote(int index) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => EditNoteDialog(
        note: cmNotes[index],
        onSave: (title, description, imagePaths) async {
          await SheetSyncService.instance.updateWorkNote(
            'CM',
            index,
            WorkNote(
              title: title,
              description: description,
              imagePaths: imagePaths,
              createdAt: cmNotes[index].createdAt,
            ),
          );
          await _loadNotes();
        },
      ),
    );
    if (updated == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกงานเรียบร้อยแล้ว')));
    }
  }

  Future<void> _deleteNote(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true) {
      await SheetSyncService.instance.deleteSheetRow('CM', index);
      await _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CM Work Notes'), elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotes,
              child: _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading data: $_error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  : cmNotes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.note_alt, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No CM notes yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: cmNotes.length,
                      itemBuilder: (context, index) {
                        final note = cmNotes[index];
                        return NoteCard(
                          note: note,
                          onEdit: () => _editNote(index),
                          onDelete: () => _deleteNote(index),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PMWorkNotesScreen extends StatefulWidget {
  const PMWorkNotesScreen({super.key});

  @override
  State<PMWorkNotesScreen> createState() => _PMWorkNotesScreenState();
}

class _PMWorkNotesScreenState extends State<PMWorkNotesScreen> {
  final List<WorkNote> pmNotes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      pmNotes.clear();
      pmNotes.addAll(await SheetSyncService.instance.fetchWorkNotes('PM'));
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _addNote() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AddNoteDialog(
        onAdd: (title, description, imagePaths) async {
          await SheetSyncService.instance.addWorkNote(
            'PM',
            WorkNote(
              title: title,
              description: description,
              imagePaths: imagePaths,
              createdAt: DateTime.now(),
            ),
          );
          await _loadNotes();
        },
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกงานเรียบร้อยแล้ว')));
    }
  }

  Future<void> _editNote(int index) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => EditNoteDialog(
        note: pmNotes[index],
        onSave: (title, description, imagePaths) async {
          await SheetSyncService.instance.updateWorkNote(
            'PM',
            index,
            WorkNote(
              title: title,
              description: description,
              imagePaths: imagePaths,
              createdAt: pmNotes[index].createdAt,
            ),
          );
          await _loadNotes();
        },
      ),
    );
    if (updated == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกงานเรียบร้อยแล้ว')));
    }
  }

  Future<void> _deleteNote(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true) {
      await SheetSyncService.instance.deleteSheetRow('PM', index);
      await _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PM Work Notes'), elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotes,
              child: _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading data: $_error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  : pmNotes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.note_alt, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No PM notes yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: pmNotes.length,
                      itemBuilder: (context, index) {
                        final note = pmNotes[index];
                        return NoteCard(
                          note: note,
                          onEdit: () => _editNote(index),
                          onDelete: () => _deleteNote(index),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WiFiPasswordScreen extends StatefulWidget {
  const WiFiPasswordScreen({super.key});

  @override
  State<WiFiPasswordScreen> createState() => _WiFiPasswordScreenState();
}

class _WiFiPasswordScreenState extends State<WiFiPasswordScreen> {
  final List<WiFiEntry> wifiEntries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      wifiEntries.clear();
      wifiEntries.addAll(await SheetSyncService.instance.fetchWiFiEntries());
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _addWiFi() async {
    await showDialog(
      context: context,
      builder: (context) => AddWiFiDialog(
        onAdd: (ssid, password) async {
          await SheetSyncService.instance.addWiFiEntry(
            WiFiEntry(ssid: ssid, password: password),
          );
          await _loadEntries();
        },
      ),
    );
  }

  Future<void> _editWiFi(int index) async {
    await showDialog(
      context: context,
      builder: (context) => EditWiFiDialog(
        entry: wifiEntries[index],
        onSave: (ssid, password) async {
          await SheetSyncService.instance.updateWiFiEntry(
            index,
            WiFiEntry(ssid: ssid, password: password),
          );
          await _loadEntries();
        },
      ),
    );
  }

  Future<void> _deleteWiFi(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete WiFi'),
        content: const Text('Are you sure you want to delete this WiFi entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true) {
      await SheetSyncService.instance.deleteSheetRow('WiFi', index);
      await _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WiFi Password'), elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading data: $_error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  : wifiEntries.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.wifi, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No WiFi entries yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: wifiEntries.length,
                      itemBuilder: (context, index) {
                        final entry = wifiEntries[index];
                        return WiFiCard(
                          entry: entry,
                          onEdit: () => _editWiFi(index),
                          onDelete: () => _deleteWiFi(index),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWiFi,
        tooltip: 'Add WiFi',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MicrophoneChannelScreen extends StatefulWidget {
  const MicrophoneChannelScreen({super.key});

  @override
  State<MicrophoneChannelScreen> createState() =>
      _MicrophoneChannelScreenState();
}

class _MicrophoneChannelScreenState extends State<MicrophoneChannelScreen> {
  final List<MicrophoneEntry> micEntries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      micEntries.clear();
      micEntries.addAll(
        await SheetSyncService.instance.fetchMicrophoneEntries(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _addMic() async {
    await showDialog(
      context: context,
      builder: (context) => AddMicDialog(
        onAdd: (name, channel) async {
          await SheetSyncService.instance.addMicrophoneEntry(
            MicrophoneEntry(name: name, channel: channel),
          );
          await _loadEntries();
        },
      ),
    );
  }

  Future<void> _editMic(int index) async {
    await showDialog(
      context: context,
      builder: (context) => EditMicDialog(
        entry: micEntries[index],
        onSave: (name, channel) async {
          await SheetSyncService.instance.updateMicrophoneEntry(
            index,
            MicrophoneEntry(name: name, channel: channel),
          );
          await _loadEntries();
        },
      ),
    );
  }

  Future<void> _deleteMic(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Microphone'),
        content: const Text(
          'Are you sure you want to delete this microphone entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true) {
      await SheetSyncService.instance.deleteSheetRow('Mic', index);
      await _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Microphone Channel'), elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading data: $_error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  : micEntries.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.mic, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No microphone entries yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: micEntries.length,
                      itemBuilder: (context, index) {
                        final entry = micEntries[index];
                        return MicrophoneCard(
                          entry: entry,
                          onEdit: () => _editMic(index),
                          onDelete: () => _deleteMic(index),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMic,
        tooltip: 'Add Microphone',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WorkNote {
  final String title;
  final String description;
  final List<String> imagePaths;
  final DateTime createdAt;

  WorkNote({
    required this.title,
    required this.description,
    this.imagePaths = const [],
    required this.createdAt,
  });
}

class WiFiEntry {
  final String ssid;
  final String password;

  WiFiEntry({required this.ssid, required this.password});
}

class MicrophoneEntry {
  final String name;
  final String channel;

  MicrophoneEntry({required this.name, required this.channel});
}

class AddNoteDialog extends StatefulWidget {
  final Function(String title, String description, List<String> imagePaths)
  onAdd;

  const AddNoteDialog({super.key, required this.onAdd});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

// ------------------------- ID / Password Screen -------------------------

class IdPasswordEntry {
  final String title;
  final String username;
  final String password;
  final String category;
  final DateTime createdAt;

  IdPasswordEntry({
    required this.title,
    required this.username,
    required this.password,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'username': username,
    'password': password,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  static IdPasswordEntry fromJson(Map<String, dynamic> j) => IdPasswordEntry(
    title: j['title'] ?? '',
    username: j['username'] ?? '',
    password: j['password'] ?? '',
    category: j['category'] ?? '',
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class IdPasswordScreen extends StatefulWidget {
  const IdPasswordScreen({super.key});

  @override
  State<IdPasswordScreen> createState() => _IdPasswordScreenState();
}

class _IdPasswordScreenState extends State<IdPasswordScreen> {
  final _storage = const FlutterSecureStorage();
  final List<IdPasswordEntry> _entries = [];
  bool _loading = true;

  static const _storageKey = 'credentials_json_v1';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final jsonString = await _storage.read(key: _storageKey);
    _entries.clear();
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> raw = jsonDecode(jsonString);
        _entries.addAll(
          raw.whereType<Map<String, dynamic>>().map(IdPasswordEntry.fromJson),
        );
      } catch (e) {
        debugPrint('Invalid credentials JSON: $e');
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveEntries() async {
    final jsonString = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await _storage.write(key: _storageKey, value: jsonString);
  }

  Future<void> _showAddDialog([IdPasswordEntry? edit, int? index]) async {
    final titleCtl = TextEditingController(text: edit?.title ?? '');
    final userCtl = TextEditingController(text: edit?.username ?? '');
    final passCtl = TextEditingController(text: edit?.password ?? '');
    final catCtl = TextEditingController(text: edit?.category ?? 'Other');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(edit == null ? 'Add Credential' : 'Edit Credential'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: userCtl,
                decoration: const InputDecoration(
                  labelText: 'Username / Email',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passCtl,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: catCtl,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final entry = IdPasswordEntry(
                title: titleCtl.text.trim(),
                username: userCtl.text.trim(),
                password: passCtl.text,
                category: catCtl.text.trim(),
                createdAt: DateTime.now(),
              );
              setState(() {
                if (edit != null && index != null)
                  _entries[index] = entry;
                else
                  _entries.add(entry);
              });
              await _saveEntries();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry(int index) async {
    setState(() => _entries.removeAt(index));
    await _saveEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID / Password'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
            ? const Center(child: Text('ยังไม่มีรายการ'))
            : ListView.separated(
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text(e.username),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'copy') {
                          await Clipboard.setData(
                            ClipboardData(text: e.password),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password copied')),
                          );
                        } else if (v == 'edit') {
                          await _showAddDialog(e, i);
                        } else if (v == 'delete') {
                          await _deleteEntry(i);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'copy',
                          child: Text('Copy Password'),
                        ),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ------------------------- Reports Screen -------------------------

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _type = 'PM';
  DateTime? _from;
  DateTime? _to;
  bool _loading = false;

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _from = d);
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _to = d);
  }

  Future<Uint8List> _buildPdf(List<WorkNote> notes) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
        build: (ctx) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Report - $_type',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Date: ${DateTime.now().toIso8601String().split('T').first}',
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Filter: from ${_from?.toIso8601String().split('T').first ?? '-'} to ${_to?.toIso8601String().split('T').first ?? '-'}',
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: ['No', 'Date', 'Title', 'Description'],
              data: notes.asMap().entries.map((e) {
                final n = e.value;
                return [
                  (e.key + 1).toString(),
                  n.createdAt.toIso8601String().split('T').first,
                  n.title,
                  n.description.length > 80
                      ? '${n.description.substring(0, 80)}...'
                      : n.description,
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );
    return doc.save();
  }

  Future<void> _generateReport() async {
    setState(() => _loading = true);
    try {
      final notes = await SheetSyncService.instance.fetchWorkNotes(_type);
      final filtered = notes.where((n) {
        if (_from != null && n.createdAt.isBefore(_from!)) return false;
        if (_to != null && n.createdAt.isAfter(_to!)) return false;
        return true;
      }).toList();
      final pdfData = await _buildPdf(filtered);
      await Printing.sharePdf(
        bytes: pdfData,
        filename:
            'report_${_type}_${DateTime.now().toIso8601String().split('T').first}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Type'),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('PM'),
                  selected: _type == 'PM',
                  onSelected: (v) => setState(() => _type = 'PM'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('CM'),
                  selected: _type == 'CM',
                  onSelected: (v) => setState(() => _type = 'CM'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickFrom,
                    child: Text(
                      _from == null
                          ? 'From'
                          : _from!.toIso8601String().split('T').first,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickTo,
                    child: Text(
                      _to == null
                          ? 'To'
                          : _to!.toIso8601String().split('T').first,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loading ? null : _generateReport,
              icon: const Icon(Icons.picture_as_pdf),
              label: _loading
                  ? const Text('Generating...')
                  : const Text('Export PDF (A4)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<String> _imagePaths = [];

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _imagePaths = result.paths.whereType<String>().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image),
              label: Text(
                _imagePaths.isEmpty
                    ? 'Add Images'
                    : '${_imagePaths.length} images selected',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              widget.onAdd(
                _titleController.text.trim(),
                _descriptionController.text.trim(),
                _imagePaths,
              );
              Navigator.pop(context, true);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// The rest of dialogs and helper classes (EditNoteDialog, AddWiFiDialog, EditWiFiDialog,
// AddMicDialog, EditMicDialog, NoteCard, WiFiCard, MicrophoneCard, SheetSyncService, etc.)
// remain in other files or can be refactored out into separate files for clarity.

// ------------------------- Minimal stubs to satisfy analyzer -------------------------

class NoteCard extends StatelessWidget {
  final WorkNote note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(note.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.description),
            if (note.imagePaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${note.imagePaths.length} รูปภาพ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class WiFiCard extends StatelessWidget {
  final WiFiEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WiFiCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(entry.ssid),
      subtitle: Text(entry.password),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
    ),
  );
}

class MicrophoneCard extends StatelessWidget {
  final MicrophoneEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MicrophoneCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(entry.name),
      subtitle: Text(entry.channel),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
    ),
  );
}

class EditNoteDialog extends StatefulWidget {
  final WorkNote note;
  final Function(String, String, List<String> imagePaths) onSave;

  const EditNoteDialog({super.key, required this.note, required this.onSave});

  @override
  State<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  late final TextEditingController _titleCtl;
  late final TextEditingController _descCtl;
  late List<String> _imagePaths;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.note.title);
    _descCtl = TextEditingController(text: widget.note.description);
    _imagePaths = List<String>.from(widget.note.imagePaths);
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _imagePaths = result.paths.whereType<String>().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit Note'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: _titleCtl),
          const SizedBox(height: 12),
          TextField(controller: _descCtl, maxLines: 4),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.image),
            label: Text(
              _imagePaths.isEmpty
                  ? 'Add Images'
                  : '${_imagePaths.length} images selected',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          widget.onSave(
            _titleCtl.text.trim(),
            _descCtl.text.trim(),
            _imagePaths,
          );
          Navigator.pop(context, true);
        },
        child: const Text('Save'),
      ),
    ],
  );
}

class AddWiFiDialog extends StatefulWidget {
  final Function(String, String) onAdd;

  const AddWiFiDialog({super.key, required this.onAdd});

  @override
  State<AddWiFiDialog> createState() => _AddWiFiDialogState();
}

class _AddWiFiDialogState extends State<AddWiFiDialog> {
  final _s = TextEditingController();
  final _p = TextEditingController();
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add WiFi'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: _s),
        TextField(controller: _p),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => widget.onAdd(_s.text, _p.text),
        child: const Text('Add'),
      ),
    ],
  );
}

class EditWiFiDialog extends StatefulWidget {
  final WiFiEntry entry;
  final Function(String, String) onSave;

  const EditWiFiDialog({super.key, required this.entry, required this.onSave});

  @override
  State<EditWiFiDialog> createState() => _EditWiFiDialogState();
}

class _EditWiFiDialogState extends State<EditWiFiDialog> {
  late final TextEditingController _s;
  late final TextEditingController _p;
  @override
  void initState() {
    super.initState();
    _s = TextEditingController(text: widget.entry.ssid);
    _p = TextEditingController(text: widget.entry.password);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit WiFi'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: _s),
        TextField(controller: _p),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => widget.onSave(_s.text, _p.text),
        child: const Text('Save'),
      ),
    ],
  );
}

class AddMicDialog extends StatefulWidget {
  final Function(String, String) onAdd;

  const AddMicDialog({super.key, required this.onAdd});

  @override
  State<AddMicDialog> createState() => _AddMicDialogState();
}

class _AddMicDialogState extends State<AddMicDialog> {
  final _n = TextEditingController();
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add Mic'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: _n),
        TextField(controller: _c),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => widget.onAdd(_n.text, _c.text),
        child: const Text('Add'),
      ),
    ],
  );
}

class EditMicDialog extends StatefulWidget {
  final MicrophoneEntry entry;
  final Function(String, String) onSave;

  const EditMicDialog({super.key, required this.entry, required this.onSave});

  @override
  State<EditMicDialog> createState() => _EditMicDialogState();
}

class _EditMicDialogState extends State<EditMicDialog> {
  late final TextEditingController _n;
  late final TextEditingController _c;
  @override
  void initState() {
    super.initState();
    _n = TextEditingController(text: widget.entry.name);
    _c = TextEditingController(text: widget.entry.channel);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit Mic'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: _n),
        TextField(controller: _c),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => widget.onSave(_n.text, _c.text),
        child: const Text('Save'),
      ),
    ],
  );
}

class SheetSyncService {
  // In-memory storage for PM/CM notes
  final List<WorkNote> pmNotes = [];
  final List<WorkNote> cmNotes = [];

  Future<List<WorkNote>> fetchWorkNotes(String title) async {
    if (title == 'PM') return List<WorkNote>.from(pmNotes);
    if (title == 'CM') return List<WorkNote>.from(cmNotes);
    return [];
  }

  Future<void> addWorkNote(String title, WorkNote note) async {
    if (title == 'PM') pmNotes.add(note);
    if (title == 'CM') cmNotes.add(note);
  }

  Future<void> updateWorkNote(String title, int index, WorkNote note) async {
    if (title == 'PM' && index >= 0 && index < pmNotes.length)
      pmNotes[index] = note;
    if (title == 'CM' && index >= 0 && index < cmNotes.length)
      cmNotes[index] = note;
  }

  Future<void> deleteSheetRow(String title, int index) async {
    if (title == 'PM' && index >= 0 && index < pmNotes.length)
      pmNotes.removeAt(index);
    if (title == 'CM' && index >= 0 && index < cmNotes.length)
      cmNotes.removeAt(index);
  }

  SheetSyncService._private();
  static final instance = SheetSyncService._private();

  Future<List<WiFiEntry>> fetchWiFiEntries() async => [];
  Future<void> addWiFiEntry(WiFiEntry entry) async {}
  Future<void> updateWiFiEntry(int index, WiFiEntry entry) async {}

  Future<List<MicrophoneEntry>> fetchMicrophoneEntries() async => [];
  Future<void> addMicrophoneEntry(MicrophoneEntry entry) async {}
  Future<void> updateMicrophoneEntry(int index, MicrophoneEntry entry) async {}
}
