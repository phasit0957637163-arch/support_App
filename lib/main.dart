import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:printing/printing.dart';

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
                      'icon': Icons.folder,
                      'label': 'Manual Files',
                      'builder': () => const ManualFilesScreen(),
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
                                  backgroundColor: Colors.cyanAccent.withAlpha(
                                    32,
                                  ),
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
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedType = 'All';
  DateTime? _month;

  void _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select month for statistics',
    );
    if (picked != null) {
      setState(() => _month = DateTime(picked.year, picked.month));
    }
  }

  int _countNotes(String type) {
    final notes = type == 'PM'
        ? SheetSyncService.instance.pmNotes
        : SheetSyncService.instance.cmNotes;
    if (_month == null) return notes.length;
    return notes
        .where(
          (note) =>
              note.scheduledAt.year == _month!.year &&
              note.scheduledAt.month == _month!.month,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final pmCount = _countNotes('PM');
    final cmCount = _countNotes('CM');
    final total = pmCount + cmCount;
    final selectedCount = _selectedType == 'PM'
        ? pmCount
        : _selectedType == 'CM'
        ? cmCount
        : total;
    final monthLabel = _month == null
        ? 'All months'
        : '${_month!.year}-${_month!.month.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedType == 'All',
                  onSelected: (_) => setState(() => _selectedType = 'All'),
                ),
                ChoiceChip(
                  label: const Text('PM'),
                  selected: _selectedType == 'PM',
                  onSelected: (_) => setState(() => _selectedType = 'PM'),
                ),
                ChoiceChip(
                  label: const Text('CM'),
                  selected: _selectedType == 'CM',
                  onSelected: (_) => setState(() => _selectedType = 'CM'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickMonth,
              child: Text('Month: $monthLabel'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(label: 'PM', value: pmCount),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(label: 'CM', value: cmCount),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(label: 'Total', value: total),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: _StatPieChart(pmCount: pmCount, cmCount: cmCount),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Showing ${_selectedType == 'All' ? 'all' : _selectedType} records for $monthLabel: $selectedCount total.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPieChart extends StatelessWidget {
  final int pmCount;
  final int cmCount;

  const _StatPieChart({required this.pmCount, required this.cmCount});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _PiePainter(pmCount: pmCount, cmCount: cmCount),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('PM / CM', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${pmCount + cmCount} total',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final int pmCount;
  final int cmCount;

  _PiePainter({required this.pmCount, required this.cmCount});

  @override
  void paint(Canvas canvas, Size size) {
    final total = pmCount + cmCount;
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;

    if (total == 0) {
      paint.color = Colors.grey.shade800;
      canvas.drawArc(rect, 0, 2 * pi, true, paint);
      return;
    }

    final startAngle = -pi / 2;
    final pmSweep = 2 * pi * (pmCount / total);
    paint.color = Colors.cyanAccent;
    canvas.drawArc(rect, startAngle, pmSweep, true, paint);
    paint.color = Colors.orangeAccent;
    canvas.drawArc(rect, startAngle + pmSweep, 2 * pi - pmSweep, true, paint);
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.pmCount != pmCount || oldDelegate.cmCount != cmCount;
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
      builder: (context) => WorkNoteDialog(
        workType: 'CM',
        onSave: (note) async {
          await SheetSyncService.instance.addWorkNote('CM', note);
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
      builder: (context) => WorkNoteDialog(
        workType: 'CM',
        initialNote: cmNotes[index],
        onSave: (note) async {
          await SheetSyncService.instance.updateWorkNote('CM', index, note);
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
      builder: (context) => WorkNoteDialog(
        workType: 'PM',
        onSave: (note) async {
          await SheetSyncService.instance.addWorkNote('PM', note);
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
      builder: (context) => WorkNoteDialog(
        workType: 'PM',
        initialNote: pmNotes[index],
        onSave: (note) async {
          await SheetSyncService.instance.updateWorkNote('PM', index, note);
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
      await SheetSyncService.instance.deleteWiFiEntry(index);
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
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => MicrophoneDialog(
        onSave: (entry) async {
          await SheetSyncService.instance.addMicrophoneEntry(entry);
          await _loadEntries();
        },
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Microphone entry saved')));
    }
  }

  Future<void> _editMic(int index) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => MicrophoneDialog(
        initialEntry: micEntries[index],
        onSave: (entry) async {
          await SheetSyncService.instance.updateMicrophoneEntry(index, entry);
          await _loadEntries();
        },
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Microphone entry updated')));
    }
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
      await SheetSyncService.instance.deleteMicrophoneEntry(index);
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
  final String documentNumber;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final String location;
  final String beforeNote;
  final String afterNote;
  final List<String> beforeImages;
  final List<String> afterImages;
  final List<String> requesters;
  final List<String> assistants;
  final String issueCategory;
  final String problemReceived;
  final String problemOccurred;
  final String noteType;
  final DateTime createdAt;

  WorkNote({
    required this.documentNumber,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.location,
    this.beforeNote = '',
    this.afterNote = '',
    this.beforeImages = const [],
    this.afterImages = const [],
    this.requesters = const [],
    this.assistants = const [],
    this.issueCategory = '',
    this.problemReceived = '',
    this.problemOccurred = '',
    required this.noteType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'documentNumber': documentNumber,
    'title': title,
    'description': description,
    'scheduledAt': scheduledAt.toIso8601String(),
    'location': location,
    'beforeNote': beforeNote,
    'afterNote': afterNote,
    'beforeImages': beforeImages,
    'afterImages': afterImages,
    'requesters': requesters,
    'assistants': assistants,
    'issueCategory': issueCategory,
    'problemReceived': problemReceived,
    'problemOccurred': problemOccurred,
    'noteType': noteType,
    'createdAt': createdAt.toIso8601String(),
  };

  static WorkNote fromJson(Map<String, dynamic> json) {
    List<String> parseNames(dynamic raw) {
      if (raw is String) {
        return raw.isNotEmpty ? [raw] : [];
      }
      if (raw is Iterable) {
        return raw.cast<String>().where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    return WorkNote(
      documentNumber: json['documentNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      scheduledAt:
          DateTime.tryParse(json['scheduledAt'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      beforeNote: json['beforeNote'] ?? '',
      afterNote: json['afterNote'] ?? '',
      beforeImages: List<String>.from(json['beforeImages'] ?? []),
      afterImages: List<String>.from(json['afterImages'] ?? []),
      requesters: parseNames(json['requesters'] ?? json['requester'] ?? []),
      assistants: parseNames(json['assistants'] ?? json['assistant'] ?? []),
      issueCategory: json['issueCategory'] ?? '',
      problemReceived: json['problemReceived'] ?? '',
      problemOccurred: json['problemOccurred'] ?? '',
      noteType: json['noteType'] ?? 'PM',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class WiFiEntry {
  final String ssid;
  final String password;

  WiFiEntry({required this.ssid, required this.password});

  Map<String, dynamic> toJson() => {'ssid': ssid, 'password': password};

  static WiFiEntry fromJson(Map<String, dynamic> json) =>
      WiFiEntry(ssid: json['ssid'] ?? '', password: json['password'] ?? '');
}

class MicrophoneEntry {
  final String roomName;
  final List<String> channels;
  final List<String> frequencies;

  MicrophoneEntry({
    required this.roomName,
    required this.channels,
    required this.frequencies,
  });

  Map<String, dynamic> toJson() => {
    'roomName': roomName,
    'channels': channels,
    'frequencies': frequencies,
  };

  static MicrophoneEntry fromJson(Map<String, dynamic> json) => MicrophoneEntry(
    roomName: json['roomName'] ?? '',
    channels: List<String>.from(json['channels'] ?? []),
    frequencies: List<String>.from(json['frequencies'] ?? []),
  );
}

class ManualFileEntry {
  final String title;
  final String path;
  final DateTime addedAt;

  ManualFileEntry({
    required this.title,
    required this.path,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'path': path,
    'addedAt': addedAt.toIso8601String(),
  };

  static ManualFileEntry fromJson(Map<String, dynamic> json) => ManualFileEntry(
    title: json['title'] ?? '',
    path: json['path'] ?? '',
    addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
  );
}

class WorkNoteDialog extends StatefulWidget {
  final String workType;
  final WorkNote? initialNote;
  final Future<void> Function(WorkNote note) onSave;

  const WorkNoteDialog({
    super.key,
    required this.workType,
    this.initialNote,
    required this.onSave,
  });

  @override
  State<WorkNoteDialog> createState() => _WorkNoteDialogState();
}

class _WorkNoteDialogState extends State<WorkNoteDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _beforeNoteController;
  late final TextEditingController _afterNoteController;
  late final TextEditingController _locationController;
  late final TextEditingController _problemReceivedController;
  late final TextEditingController _problemOccurredController;
  late final TextEditingController _issueCategoryController;
  late DateTime _scheduledAt;
  late String _documentNumber;
  List<String> _beforeImages = [];
  List<String> _afterImages = [];
  late List<String> _selectedRequesters;
  late List<String> _selectedAssistants;

  final _locations = ['Office', 'Warehouse', 'Server Room', 'Field Site'];
  final _requesterOptions = ['เตย', 'พัท', 'ซาวด์'];
  final _assistantOptions = ['เตย', 'พัท', 'ซาวด์'];
  final _cmLocations = [
    'NC Sky9 R1',
    'NC Sky9 R2',
    'NC Sky9 R3',
    'NC Sky9 R4',
    'NC Sky9 R5',
    'NC Sky9 R6',
    'NC Sky9 R7',
    'NC Sky9 R8',
    'NC Sky9 R9',
    'NC Sky9 R10',
    'NC Sky9 R11',
    'NC Sky9 R12',
    'NC Sky9 HR&CAMERA',
    'NC Sky9 ROOMBOSS',
    'NC Sky9 ห้องแต่งตัว',
    'NC Sky9 ห้องการเงิน',
    'NC Sky9 ห้องซ้อมเต้น',
    'NC NewBuilding R1',
    'NC NewBuilding R3',
    'NC NewBuilding R4',
    'NC NewBuilding R5',
    'NC NewBuilding R6',
    'NC NewBuilding R7',
    'NC NewBuilding R8',
    'NC NewBuilding HR&CAMERA&Interior',
    'NC NewBuilding ห้องการเงินชั้น 2',
    'NC NewBuilding Assistant ชั้น 2',
    'NC NewBuilding ROOMBOSS ชั้น 2',
    'NC NewBuilding ห้องแต่งตัว ชั้นลอย',
    'NC NewBuilding ห้องซ้อมเต้น ชั้น 2(1)',
    'NC NewBuilding ห้องซ้อมเต้น ชั้น 2(2)',
  ];
  final _issueCategories = [
    'Wi-Fi',
    'Router',
    'LAN',
    'Internet',
    'PC',
    'Windows',
    'Notebook',
    'Microphone',
    'Display',
    'LED',
    'Sound',
    'Camera',
    'Capture Card',
    'Program',
    'TV',
    'Electric',
  ];

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _beforeNoteController = TextEditingController(text: note?.beforeNote ?? '');
    _afterNoteController = TextEditingController(text: note?.afterNote ?? '');
    _locationController = TextEditingController(
      text: note?.location ?? _locations.first,
    );
    _problemReceivedController = TextEditingController(
      text: note?.problemReceived ?? '',
    );
    _problemOccurredController = TextEditingController(
      text: note?.problemOccurred ?? '',
    );
    _issueCategoryController = TextEditingController(
      text: note?.issueCategory ?? _issueCategories.first,
    );
    _selectedRequesters = List<String>.from(note?.requesters ?? []);
    _selectedAssistants = List<String>.from(note?.assistants ?? []);
    _scheduledAt = note?.scheduledAt ?? DateTime.now();
    _beforeImages = List<String>.from(note?.beforeImages ?? []);
    _afterImages = List<String>.from(note?.afterImages ?? []);
    _documentNumber =
        note?.documentNumber ??
        SheetSyncService.instance.generateDocumentNumber(widget.workType);
  }

  Future<void> _pickImages(bool before) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      if (!mounted) return;
      setState(() {
        final selected = result.paths.whereType<String>().toList();
        if (before) {
          _beforeImages = selected;
        } else {
          _afterImages = selected;
        }
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (!mounted || time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCM = widget.workType == 'CM';
    return AlertDialog(
      title: Text(
        widget.initialNote == null
            ? 'Add ${widget.workType} Work Note'
            : 'Edit ${widget.workType} Work Note',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Document #: $_documentNumber'),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            if (isCM) ...[
              const Text('Requester'),
              ..._requesterOptions.map((name) {
                return CheckboxListTile(
                  title: Text(name),
                  value: _selectedRequesters.contains(name),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    if (checked == null) return;
                    setState(() {
                      if (checked) {
                        _selectedRequesters.add(name);
                      } else {
                        _selectedRequesters.remove(name);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 12),
              const Text('Assistant'),
              ..._assistantOptions.map((name) {
                return CheckboxListTile(
                  title: Text(name),
                  value: _selectedAssistants.contains(name),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    if (checked == null) return;
                    setState(() {
                      if (checked) {
                        _selectedAssistants.add(name);
                      } else {
                        _selectedAssistants.remove(name);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _cmLocations.contains(_locationController.text)
                    ? _locationController.text
                    : _cmLocations.first,
                decoration: const InputDecoration(labelText: 'Location'),
                items: _cmLocations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _locationController.text = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _problemReceivedController,
                decoration: const InputDecoration(labelText: 'ปัญหาที่ได้รับ'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _problemOccurredController,
                decoration: const InputDecoration(
                  labelText: 'ปัญหาที่เกิดขึ้น',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _issueCategoryController.text,
                decoration: const InputDecoration(labelText: 'เกี่ยวกับ'),
                items: _issueCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _issueCategoryController.text = value);
                  }
                },
              ),
            ] else ...[
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'ห้อง/สถานที่'),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(
                'Date / Time: ${_scheduledAt.toString().split('.').first}',
              ),
            ),
            const SizedBox(height: 16),
            const Text('ก่อนทำ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _pickImages(true),
              icon: const Icon(Icons.photo_library),
              label: Text(
                _beforeImages.isEmpty
                    ? 'Add Before Images'
                    : '${_beforeImages.length} Before Images',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _beforeNoteController,
              decoration: const InputDecoration(labelText: 'หมายเหตุก่อนทำ'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            const Text('หลังทำ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _pickImages(false),
              icon: const Icon(Icons.photo_library),
              label: Text(
                _afterImages.isEmpty
                    ? 'Add After Images'
                    : '${_afterImages.length} After Images',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _afterNoteController,
              decoration: const InputDecoration(labelText: 'หมายเหตุหลังทำ'),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final note = WorkNote(
              documentNumber: _documentNumber,
              title: _titleController.text.trim(),
              description: '',
              scheduledAt: _scheduledAt,
              location: _locationController.text,
              beforeNote: _beforeNoteController.text.trim(),
              afterNote: _afterNoteController.text.trim(),
              beforeImages: _beforeImages,
              afterImages: _afterImages,
              requesters: _selectedRequesters,
              assistants: _selectedAssistants,
              issueCategory: _issueCategoryController.text.trim(),
              problemReceived: _problemReceivedController.text.trim(),
              problemOccurred: _problemOccurredController.text.trim(),
              noteType: widget.workType,
              createdAt: widget.initialNote?.createdAt ?? DateTime.now(),
            );
            widget.onSave(note);
            Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _beforeNoteController.dispose();
    _afterNoteController.dispose();
    _locationController.dispose();
    _problemReceivedController.dispose();
    _problemOccurredController.dispose();
    _issueCategoryController.dispose();
    super.dispose();
  }
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
                if (edit != null && index != null) {
                  _entries[index] = entry;
                } else {
                  _entries.add(entry);
                }
              });
              final navigator = Navigator.of(context);
              await _saveEntries();
              if (!mounted) return;
              navigator.pop();
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
                separatorBuilder: (context, _) => const Divider(),
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text(
                      'Username: ${e.username}\nPassword: ${e.password}\nCategory: ${e.category}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'copy') {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(
                            ClipboardData(text: e.password),
                          );
                          if (!mounted) return;
                          messenger.showSnackBar(
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
            ...notes.asMap().entries.expand<pw.Widget>((entry) {
              final note = entry.value;
              return [
                pw.Divider(),
                pw.Text(
                  'Document: ${note.documentNumber}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Title: ${note.title}'),
                pw.Text('Type: ${note.noteType}'),
                pw.Text(
                  'Scheduled: ${note.scheduledAt.toIso8601String().replaceFirst('T', ' ')}',
                ),
                pw.Text('Location: ${note.location}'),
                if (note.requesters.isNotEmpty)
                  pw.Text('Requester(s): ${note.requesters.join(', ')}'),
                if (note.assistants.isNotEmpty)
                  pw.Text('Assistant(s): ${note.assistants.join(', ')}'),
                if (note.issueCategory.isNotEmpty)
                  pw.Text('Issue Category: ${note.issueCategory}'),
                if (note.problemReceived.isNotEmpty)
                  pw.Text('Problem Received: ${note.problemReceived}'),
                if (note.problemOccurred.isNotEmpty)
                  pw.Text('Problem Occurred: ${note.problemOccurred}'),
                if (note.beforeNote.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('Before Note:'),
                  pw.Text(note.beforeNote),
                ],
                if (note.afterNote.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('After Note:'),
                  pw.Text(note.afterNote),
                ],
                if (note.description.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('Notes:'),
                  pw.Text(note.description),
                ],
                if (note.beforeImages.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text('Before Images (${note.beforeImages.length})'),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: note.beforeImages.map((path) {
                      try {
                        final bytes = File(path).readAsBytesSync();
                        return pw.Container(
                          width: 120,
                          height: 120,
                          child: pw.Image(
                            pw.MemoryImage(bytes),
                            fit: pw.BoxFit.cover,
                          ),
                        );
                      } catch (_) {
                        return pw.Container();
                      }
                    }).toList(),
                  ),
                ],
                if (note.afterImages.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text('After Images (${note.afterImages.length})'),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: note.afterImages.map((path) {
                      try {
                        final bytes = File(path).readAsBytesSync();
                        return pw.Container(
                          width: 120,
                          height: 120,
                          child: pw.Image(
                            pw.MemoryImage(bytes),
                            fit: pw.BoxFit.cover,
                          ),
                        );
                      } catch (_) {
                        return pw.Container();
                      }
                    }).toList(),
                  ),
                ],
                pw.SizedBox(height: 12),
              ];
            }),
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
        if (_from != null && n.scheduledAt.isBefore(_from!)) return false;
        if (_to != null && n.scheduledAt.isAfter(_to!)) return false;
        return true;
      }).toList();
      final pdfData = await _buildPdf(filtered);
      await Printing.sharePdf(
        bytes: pdfData,
        filename:
            'report_${_type}_${DateTime.now().toIso8601String().split('T').first}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
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

class ManualFilesScreen extends StatefulWidget {
  const ManualFilesScreen({super.key});

  @override
  State<ManualFilesScreen> createState() => _ManualFilesScreenState();
}

class _ManualFilesScreenState extends State<ManualFilesScreen> {
  final List<ManualFileEntry> entries = [];
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
      entries.clear();
      entries.addAll(await SheetSyncService.instance.fetchManualFiles());
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _addFile() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ManualFileDialog(
        onSave: (entry) async {
          await SheetSyncService.instance.addManualFile(entry);
          await _loadEntries();
        },
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Manual file saved')));
    }
  }

  Future<void> _editFile(int index) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ManualFileDialog(
        initialEntry: entries[index],
        onSave: (entry) async {
          await SheetSyncService.instance.updateManualFile(index, entry);
          await _loadEntries();
        },
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Manual file updated')));
    }
  }

  Future<void> _deleteFile(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete file'),
        content: const Text(
          'Are you sure you want to remove this manual file?',
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
    if (confirmed == true) {
      await SheetSyncService.instance.deleteManualFile(index);
      await _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Files'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addFile)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : entries.isEmpty
          ? const Center(child: Text('No manual files added yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: entries.length,
              separatorBuilder: (context, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    title: Text(entry.title),
                    subtitle: Text(entry.path),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editFile(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteFile(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ManualFileDialog extends StatefulWidget {
  final ManualFileEntry? initialEntry;
  final Future<void> Function(ManualFileEntry entry) onSave;

  const ManualFileDialog({super.key, this.initialEntry, required this.onSave});

  @override
  State<ManualFileDialog> createState() => _ManualFileDialogState();
}

class _ManualFileDialogState extends State<ManualFileDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialEntry?.title ?? '',
    );
    _pathController = TextEditingController(
      text: widget.initialEntry?.path ?? '',
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _pathController.text = result.files.first.path ?? '';
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = result.files.first.name;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialEntry == null ? 'Add Manual File' : 'Edit Manual File',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pathController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'File path'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Select File'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty ||
                _pathController.text.trim().isEmpty) {
              return;
            }
            widget.onSave(
              ManualFileEntry(
                title: _titleController.text.trim(),
                path: _pathController.text.trim(),
                addedAt: widget.initialEntry?.addedAt ?? DateTime.now(),
              ),
            );
            Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

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
        title: Text('${note.documentNumber} - ${note.title}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${note.location}'),
            if (note.requesters.isNotEmpty || note.assistants.isNotEmpty)
              Text(
                'Requester: ${note.requesters.join(', ')}  •  Assistant: ${note.assistants.join(', ')}',
              ),
            if (note.problemReceived.isNotEmpty)
              Text('Problem received: ${note.problemReceived}'),
            if (note.problemOccurred.isNotEmpty)
              Text('Problem occurred: ${note.problemOccurred}'),
            if (note.beforeNote.isNotEmpty)
              Text(
                'Before note: ${note.beforeNote}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (note.afterNote.isNotEmpty)
              Text(
                'After note: ${note.afterNote}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (note.description.isNotEmpty) Text(note.description),
            if (note.beforeImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Before images: ${note.beforeImages.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
            if (note.afterImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'After images: ${note.afterImages.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ),
          ],
        ),
        isThreeLine: true,
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
      title: Text(entry.roomName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Channels: ${entry.channels.join(', ')}'),
          Text('Frequencies: ${entry.frequencies.join(', ')}'),
        ],
      ),
      isThreeLine: true,
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
        TextField(
          controller: _s,
          decoration: const InputDecoration(labelText: 'SSID'),
        ),
        TextField(
          controller: _p,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
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
        TextField(
          controller: _s,
          decoration: const InputDecoration(labelText: 'SSID'),
        ),
        TextField(
          controller: _p,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
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

class MicrophoneDialog extends StatefulWidget {
  final MicrophoneEntry? initialEntry;
  final Future<void> Function(MicrophoneEntry entry) onSave;

  const MicrophoneDialog({super.key, this.initialEntry, required this.onSave});

  @override
  State<MicrophoneDialog> createState() => _MicrophoneDialogState();
}

class _MicrophoneDialogState extends State<MicrophoneDialog> {
  late final TextEditingController _roomController;
  late final List<TextEditingController> _channelControllers;
  late final List<TextEditingController> _frequencyControllers;

  @override
  void initState() {
    super.initState();
    _roomController = TextEditingController(
      text: widget.initialEntry?.roomName ?? '',
    );
    _channelControllers = List.generate(
      4,
      (index) => TextEditingController(
        text:
            widget.initialEntry != null &&
                widget.initialEntry!.channels.length > index
            ? widget.initialEntry!.channels[index]
            : '',
      ),
    );
    _frequencyControllers = List.generate(
      4,
      (index) => TextEditingController(
        text:
            widget.initialEntry != null &&
                widget.initialEntry!.frequencies.length > index
            ? widget.initialEntry!.frequencies[index]
            : '',
      ),
    );
  }

  @override
  void dispose() {
    _roomController.dispose();
    for (final controller in _channelControllers) {
      controller.dispose();
    }
    for (final controller in _frequencyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialEntry == null ? 'Add Microphone' : 'Edit Microphone',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Room Name'),
            ),
            const SizedBox(height: 12),
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _channelControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Channel ${index + 1}',
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _frequencyControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Frequency ${index + 1}',
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final entry = MicrophoneEntry(
              roomName: _roomController.text.trim(),
              channels: _channelControllers
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
              frequencies: _frequencyControllers
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            );
            widget.onSave(entry);
            Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class SheetSyncService {
  static const _pmNotesKey = 'work_notes_pm_v1';
  static const _cmNotesKey = 'work_notes_cm_v1';
  static const _wifiEntriesKey = 'wifi_entries_v1';
  static const _micEntriesKey = 'mic_entries_v1';
  static const _manualFilesKey = 'manual_guide_files';

  final List<WorkNote> pmNotes = [];
  final List<WorkNote> cmNotes = [];
  final List<WiFiEntry> wifiEntries = [];
  final List<MicrophoneEntry> microphoneEntries = [];
  final List<ManualFileEntry> manualFiles = [];

  bool _notesLoaded = false;
  bool _wifiLoaded = false;
  bool _micLoaded = false;
  bool _manualFilesLoaded = false;

  SheetSyncService._private();
  static final instance = SheetSyncService._private();

  Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  Future<void> _loadNotes() async {
    if (_notesLoaded) return;
    final prefs = await _prefs();
    pmNotes.clear();
    cmNotes.clear();
    final pmJson = prefs.getString(_pmNotesKey);
    final cmJson = prefs.getString(_cmNotesKey);
    if (pmJson != null && pmJson.isNotEmpty) {
      try {
        final raw = jsonDecode(pmJson) as List<dynamic>;
        pmNotes.addAll(
          raw.whereType<Map<String, dynamic>>().map(WorkNote.fromJson),
        );
      } catch (_) {}
    }
    if (cmJson != null && cmJson.isNotEmpty) {
      try {
        final raw = jsonDecode(cmJson) as List<dynamic>;
        cmNotes.addAll(
          raw.whereType<Map<String, dynamic>>().map(WorkNote.fromJson),
        );
      } catch (_) {}
    }
    _notesLoaded = true;
  }

  Future<void> _saveNotes() async {
    final prefs = await _prefs();
    await prefs.setString(
      _pmNotesKey,
      jsonEncode(pmNotes.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _cmNotesKey,
      jsonEncode(cmNotes.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<WorkNote>> fetchWorkNotes(String title) async {
    await _loadNotes();
    if (title == 'PM') return List<WorkNote>.from(pmNotes);
    if (title == 'CM') return List<WorkNote>.from(cmNotes);
    return [];
  }

  Future<void> addWorkNote(String title, WorkNote note) async {
    await _loadNotes();
    if (title == 'PM') {
      pmNotes.add(note);
    } else if (title == 'CM') {
      cmNotes.add(note);
    }
    await _saveNotes();
  }

  Future<void> updateWorkNote(String title, int index, WorkNote note) async {
    await _loadNotes();
    if (title == 'PM' && index >= 0 && index < pmNotes.length) {
      pmNotes[index] = note;
    }
    if (title == 'CM' && index >= 0 && index < cmNotes.length) {
      cmNotes[index] = note;
    }
    await _saveNotes();
  }

  Future<void> deleteSheetRow(String title, int index) async {
    await _loadNotes();
    if (title == 'PM' && index >= 0 && index < pmNotes.length) {
      pmNotes.removeAt(index);
    }
    if (title == 'CM' && index >= 0 && index < cmNotes.length) {
      cmNotes.removeAt(index);
    }
    await _saveNotes();
  }

  String generateDocumentNumber(String type) {
    final count = type == 'PM' ? pmNotes.length : cmNotes.length;
    final now = DateTime.now();
    return '$type-${now.year}${now.month.toString().padLeft(2, '0')}-${(count + 1).toString().padLeft(3, '0')}';
  }

  Future<void> _loadWiFi() async {
    if (_wifiLoaded) return;
    final prefs = await _prefs();
    wifiEntries.clear();
    final jsonString = prefs.getString(_wifiEntriesKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final raw = jsonDecode(jsonString) as List<dynamic>;
        wifiEntries.addAll(
          raw.whereType<Map<String, dynamic>>().map(WiFiEntry.fromJson),
        );
      } catch (_) {}
    }
    _wifiLoaded = true;
  }

  Future<void> _saveWiFi() async {
    final prefs = await _prefs();
    await prefs.setString(
      _wifiEntriesKey,
      jsonEncode(wifiEntries.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<WiFiEntry>> fetchWiFiEntries() async {
    await _loadWiFi();
    return List<WiFiEntry>.from(wifiEntries);
  }

  Future<void> addWiFiEntry(WiFiEntry entry) async {
    await _loadWiFi();
    wifiEntries.add(entry);
    await _saveWiFi();
  }

  Future<void> updateWiFiEntry(int index, WiFiEntry entry) async {
    await _loadWiFi();
    if (index >= 0 && index < wifiEntries.length) {
      wifiEntries[index] = entry;
      await _saveWiFi();
    }
  }

  Future<void> deleteWiFiEntry(int index) async {
    await _loadWiFi();
    if (index >= 0 && index < wifiEntries.length) {
      wifiEntries.removeAt(index);
      await _saveWiFi();
    }
  }

  Future<void> _loadMic() async {
    if (_micLoaded) return;
    final prefs = await _prefs();
    microphoneEntries.clear();
    final jsonString = prefs.getString(_micEntriesKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final raw = jsonDecode(jsonString) as List<dynamic>;
        microphoneEntries.addAll(
          raw.whereType<Map<String, dynamic>>().map(MicrophoneEntry.fromJson),
        );
      } catch (_) {}
    }
    _micLoaded = true;
  }

  Future<void> _saveMic() async {
    final prefs = await _prefs();
    await prefs.setString(
      _micEntriesKey,
      jsonEncode(microphoneEntries.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<MicrophoneEntry>> fetchMicrophoneEntries() async {
    await _loadMic();
    return List<MicrophoneEntry>.from(microphoneEntries);
  }

  Future<void> addMicrophoneEntry(MicrophoneEntry entry) async {
    await _loadMic();
    microphoneEntries.add(entry);
    await _saveMic();
  }

  Future<void> updateMicrophoneEntry(int index, MicrophoneEntry entry) async {
    await _loadMic();
    if (index >= 0 && index < microphoneEntries.length) {
      microphoneEntries[index] = entry;
      await _saveMic();
    }
  }

  Future<void> deleteMicrophoneEntry(int index) async {
    await _loadMic();
    if (index >= 0 && index < microphoneEntries.length) {
      microphoneEntries.removeAt(index);
      await _saveMic();
    }
  }

  Future<void> _loadManualFiles() async {
    if (_manualFilesLoaded) return;
    final prefs = await _prefs();
    manualFiles.clear();
    final jsonString = prefs.getString(_manualFilesKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final raw = jsonDecode(jsonString) as List<dynamic>;
        manualFiles.addAll(
          raw.whereType<Map<String, dynamic>>().map(ManualFileEntry.fromJson),
        );
      } catch (_) {}
    }
    _manualFilesLoaded = true;
  }

  Future<void> _saveManualFiles() async {
    final prefs = await _prefs();
    await prefs.setString(
      _manualFilesKey,
      jsonEncode(manualFiles.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<ManualFileEntry>> fetchManualFiles() async {
    await _loadManualFiles();
    return List<ManualFileEntry>.from(manualFiles);
  }

  Future<void> addManualFile(ManualFileEntry entry) async {
    await _loadManualFiles();
    manualFiles.add(entry);
    await _saveManualFiles();
  }

  Future<void> updateManualFile(int index, ManualFileEntry entry) async {
    await _loadManualFiles();
    if (index >= 0 && index < manualFiles.length) {
      manualFiles[index] = entry;
      await _saveManualFiles();
    }
  }

  Future<void> deleteManualFile(int index) async {
    await _loadManualFiles();
    if (index >= 0 && index < manualFiles.length) {
      manualFiles.removeAt(index);
      await _saveManualFiles();
    }
  }
}
