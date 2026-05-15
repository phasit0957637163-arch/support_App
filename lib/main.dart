import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _spreadsheetName = 'Support App Data';
const _driveFolderId = '1Ch-zzljZl8_sZK-4DXtzD86-eqNUAk5X';
const _credentialsAsset = 'assets/credentials.json';
const _manualFilesKey = 'manual_guide_files';

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
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
        ),
      ),
      home: const HomeGallery(),
    );
  }
}

class HomeGallery extends StatelessWidget {
  const HomeGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 24,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00E5FF), Color(0xFF0088FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withAlpha((0.3 * 255).round()),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.computer,
                    size: 34,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ไอทีชัพพอร์ท',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'IT Support Command Center',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                GalleryCard(
                  icon: Icons.note_alt,
                  title: 'CM Work Notes',
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CMWorkNotesScreen(),
                    ),
                  ),
                ),
                GalleryCard(
                  icon: Icons.assignment,
                  title: 'PM Work Notes',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PMWorkNotesScreen(),
                    ),
                  ),
                ),
                GalleryCard(
                  icon: Icons.wifi,
                  title: 'WiFi Password',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WiFiPasswordScreen(),
                    ),
                  ),
                ),
                GalleryCard(
                  icon: Icons.mic,
                  title: 'Microphone Channel',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MicrophoneChannelScreen(),
                    ),
                  ),
                ),
                GalleryCard(
                  icon: Icons.menu_book,
                  title: 'คู่มือ',
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManualGuideScreen(),
                    ),
                  ),
                ),
                GalleryCard(
                  icon: Icons.bar_chart,
                  title: 'สถิติ',
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const GalleryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha((0.7 * 255).round()), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManualGuideFile {
  final String name;
  final String path;
  final int size;

  ManualGuideFile({required this.name, required this.path, required this.size});

  factory ManualGuideFile.fromJson(Map<String, dynamic> json) {
    return ManualGuideFile(
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      size: json['size'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'path': path, 'size': size};
  }
}

class ManualGuideScreen extends StatefulWidget {
  const ManualGuideScreen({super.key});

  @override
  State<ManualGuideScreen> createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  final List<ManualGuideFile> _files = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_manualFilesKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> raw = jsonDecode(jsonString);
      _files
        ..clear()
        ..addAll(
          raw.whereType<Map<String, dynamic>>().map(ManualGuideFile.fromJson),
        );
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _manualFilesKey,
      jsonEncode(_files.map((file) => file.toJson()).toList()),
    );
  }

  Future<void> _addFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) {
      return;
    }

    final picked = result.files.first;
    if (picked.path == null) {
      return;
    }

    setState(() {
      _files.add(
        ManualGuideFile(
          name: picked.name,
          path: picked.path!,
          size: picked.size,
        ),
      );
    });

    await _saveFiles();
  }

  Future<void> _deleteFile(int index) async {
    setState(() {
      _files.removeAt(index);
    });
    await _saveFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คู่มือ'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFile,
            tooltip: 'เพิ่มไฟล์',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _files.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'คู่มือใช้งาน',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ยังไม่มีไฟล์คู่มือ คุณสามารถกดปุ่ม + เพื่อเพิ่มไฟล์ได้ตามต้องการ',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              )
            : ListView.separated(
                itemCount: _files.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final file = _files[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: const Icon(
                        Icons.insert_drive_file,
                        color: Colors.cyanAccent,
                      ),
                      title: Text(
                        file.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        file.path,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteFile(index),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

enum StatsCategory { all, cm, pm }

class _StatsScreenState extends State<StatsScreen> {
  final List<WorkNote> _cmNotes = [];
  final List<WorkNote> _pmNotes = [];
  final List<DateTime> _months = [];
  bool _loading = true;
  DateTime? _selectedMonth;
  StatsCategory _selectedCategory = StatsCategory.all;

  static const List<String> _thaiMonthNames = [
    '',
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
    });

    final cmNotes = await SheetSyncService.instance.fetchWorkNotes('CM');
    final pmNotes = await SheetSyncService.instance.fetchWorkNotes('PM');

    final months = <DateTime>{};
    for (final note in [...cmNotes, ...pmNotes]) {
      months.add(DateTime(note.createdAt.year, note.createdAt.month));
    }

    final sortedMonths = months.toList()..sort((a, b) => b.compareTo(a));
    if (sortedMonths.isEmpty) {
      sortedMonths.add(DateTime(DateTime.now().year, DateTime.now().month));
    }

    setState(() {
      _cmNotes
        ..clear()
        ..addAll(cmNotes);
      _pmNotes
        ..clear()
        ..addAll(pmNotes);
      _months
        ..clear()
        ..addAll(sortedMonths);
      _selectedMonth ??= _months.first;
      _loading = false;
    });
  }

  int _countForMonth(List<WorkNote> notes, DateTime month) {
    return notes
        .where(
          (note) =>
              note.createdAt.year == month.year &&
              note.createdAt.month == month.month,
        )
        .length;
  }

  String _monthLabel(DateTime month) {
    return '${_thaiMonthNames[month.month]} ${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        _selectedMonth ?? DateTime(DateTime.now().year, DateTime.now().month);
    final cmCount = _countForMonth(_cmNotes, selected);
    final pmCount = _countForMonth(_pmNotes, selected);
    final showAll = _selectedCategory == StatsCategory.all;
    final totalCount = showAll ? cmCount + pmCount : (_selectedCategory == StatsCategory.cm ? cmCount : pmCount);
    final selectedLabel = _selectedCategory == StatsCategory.cm
        ? 'CM'
        : _selectedCategory == StatsCategory.pm
            ? 'PM'
            : 'ทั้งหมด';
    final selectedCount = _selectedCategory == StatsCategory.cm
        ? cmCount
        : _selectedCategory == StatsCategory.pm
            ? pmCount
            : totalCount;
    final pieValues = showAll
        ? [cmCount.toDouble(), pmCount.toDouble()]
        : [selectedCount.toDouble()];
    final pieLabels = showAll ? const ['CM', 'PM'] : [selectedLabel];
        title: const Text('สถิติ'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'สถิติงาน CM/PM',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C1928),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<DateTime>(
                              value: selected,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF0C1928),
                              iconEnabledColor: Colors.cyanAccent,
                              items: _months
                                  .map(
                                    (month) => DropdownMenuItem(
                                      value: month,
                                      child: Text(
                                        _monthLabel(month),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedMonth = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CategoryButton(
                        label: 'ทั้งหมด',
                        selected: _selectedCategory == StatsCategory.all,
                        onTap: () {
                          setState(() {
                            _selectedCategory = StatsCategory.all;
                          });
                        },
                      ),
                      _CategoryButton(
                        label: 'งาน CM',
                        selected: _selectedCategory == StatsCategory.cm,
                        onTap: () {
                          setState(() {
                            _selectedCategory = StatsCategory.cm;
                          });
                        },
                      ),
                      _CategoryButton(
                        label: 'งาน PM',
                        selected: _selectedCategory == StatsCategory.pm,
                        onTap: () {
                          setState(() {
                            _selectedCategory = StatsCategory.pm;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (totalCount == 0)
                    Expanded(
                      child: Center(
                        child: Text(
                          'ไม่มีสถิติในเดือน ${_monthLabel(selected)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: PieChart(
                                values: pieValues,
                                colors: showAll
                                    ? const [Colors.blue, Colors.green]
                                    : const [Colors.cyanAccent],
                                labels: pieLabels,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (showAll)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatBadge(
                                  label: 'CM',
                                  count: cmCount,
                                  color: Colors.blue,
                                ),
                                _StatBadge(
                                  label: 'PM',
                                  count: pmCount,
                                  color: Colors.green,
                                ),
                              ],
                            )
                          else
                            _StatBadge(
                              label: selectedLabel,
                              count: selectedCount,
                              color: Colors.cyanAccent,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.cyanAccent : const Color(0xFF0C1928),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.cyanAccent : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1928),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha((0.4 * 255).round())),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PieChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;

  const PieChart({
    super.key,
    required this.values,
    required this.colors,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(260, 260),
      painter: _PieChartPainter(values: values, colors: colors),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: labels.asMap().entries.map((entry) {
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value} ${values[index].toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (sum, value) => sum + value);
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;
    double startAngle = -pi / 2;

    if (total <= 0) {
      paint.color = Colors.grey.shade800;
      canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
      return;
    }

    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SheetSyncService {
  SheetSyncService._();
  static final SheetSyncService instance = SheetSyncService._();

  sheets.SheetsApi? _sheetsApi;
  drive.DriveApi? _driveApi;
  sheets.Spreadsheet? _spreadsheet;
  String? _spreadsheetId;
  final Map<String, int> _sheetIdCache = {};
  bool _useLocalStorage = false;
  static const String _localStoragePrefix = 'sheets_';

  Future<void> _init() async {
    if (_sheetsApi != null || _useLocalStorage) return;
    try {
      final jsonContent = await rootBundle.loadString(_credentialsAsset);
      final accountCredentials = ServiceAccountCredentials.fromJson(
        jsonDecode(jsonContent),
      );
      final client = await clientViaServiceAccount(accountCredentials, [
        sheets.SheetsApi.spreadsheetsScope,
        drive.DriveApi.driveScope,
      ]);
      _sheetsApi = sheets.SheetsApi(client);
      _driveApi = drive.DriveApi(client);
      _spreadsheetId = await _findOrCreateSpreadsheet();
      _spreadsheet = await _sheetsApi!.spreadsheets.get(_spreadsheetId!);
    } catch (e) {
      _useLocalStorage = true;
      debugPrint('Google Sheets unavailable, using local storage fallback: $e');
    }
  }

  Future<String> _findOrCreateSpreadsheet() async {
    final query =
        "mimeType='application/vnd.google-apps.spreadsheet' "
        "and name='$_spreadsheetName' "
        "and '$_driveFolderId' in parents "
        "and trashed=false";
    final listResponse = await _driveApi!.files.list(
      q: query,
      spaces: 'drive',
      includeItemsFromAllDrives: true,
      supportsAllDrives: true,
      $fields: 'files(id,name)',
    );
    final files = listResponse.files;
    if (files != null && files.isNotEmpty && files.first.id != null) {
      return files.first.id!;
    }
    final created = await _driveApi!.files.create(
      drive.File(
        name: _spreadsheetName,
        mimeType: 'application/vnd.google-apps.spreadsheet',
        parents: [_driveFolderId],
      ),
      supportsAllDrives: true,
      $fields: 'id',
    );
    if (created.id == null) {
      throw Exception('Unable to create spreadsheet in Drive folder');
    }
    return created.id!;
  }

  Future<void> _refreshSpreadsheet() async {
    if (_useLocalStorage) return;
    _spreadsheet = await _sheetsApi!.spreadsheets.get(_spreadsheetId!);
    _sheetIdCache.clear();
  }

  Future<List<List<String>>> _loadLocalRows(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_localStoragePrefix$title');
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> raw = jsonDecode(jsonString);
    return raw
        .whereType<List<dynamic>>()
        .map((row) => row.map((cell) => cell?.toString() ?? '').toList())
        .toList();
  }

  Future<void> _saveLocalRows(String title, List<List<String>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_localStoragePrefix$title', jsonEncode(rows));
  }

  Future<List<List<String>>> _readRowsFromLocal(
    String title,
    int columnCount,
  ) async {
    final rows = await _loadLocalRows(title);
    return rows
        .map(
          (row) => row.length >= columnCount
              ? row.sublist(0, columnCount)
              : [...row, ...List.filled(columnCount - row.length, '')],
        )
        .toList();
  }

  Future<List<String>> _sheetTitleCandidates(String title) async {
    switch (title) {
      case 'CM':
        return ['CM', 'CM Work Notes'];
      case 'PM':
        return ['PM', 'PM Work Notes'];
      case 'WiFi':
        return ['WiFi', 'WiFi Password'];
      case 'Mic':
        return ['Mic', 'Microphone Channel'];
      default:
        return [title];
    }
  }

  String _quoteSheetTitle(String title) {
    if (RegExp(r"[^A-Za-z0-9_]").hasMatch(title)) {
      final escaped = title.replaceAll("'", "''");
      return "'$escaped'";
    }
    return title;
  }

  Future<String> _resolveSheetTitle(String title) async {
    await _init();
    final titles =
        _spreadsheet?.sheets
            ?.map((sheet) => sheet.properties?.title)
            .whereType<String>()
            .toList() ??
        [];
    for (final candidate in await _sheetTitleCandidates(title)) {
      if (titles.contains(candidate)) {
        return candidate;
      }
    }
    return title;
  }

  Future<int> _sheetId(String title) async {
    final resolvedTitle = await _resolveSheetTitle(title);
    if (_sheetIdCache.containsKey(resolvedTitle)) {
      return _sheetIdCache[resolvedTitle]!;
    }
    final sheets.Sheet? sheet = _spreadsheet?.sheets?.firstWhere(
      (sheet) => sheet.properties?.title == resolvedTitle,
      orElse: () => sheets.Sheet(),
    );
    final sheetId = sheet?.properties?.sheetId;
    if (sheetId == null) {
      throw Exception('Sheet "$resolvedTitle" not found.');
    }
    _sheetIdCache[resolvedTitle] = sheetId;
    return sheetId;
  }

  Future<void> _ensureSheet(String title, List<String> headers) async {
    await _init();
    if (_useLocalStorage) {
      final rows = await _loadLocalRows(title);
      if (rows.isEmpty) {
        await _saveLocalRows(title, []);
      }
      return;
    }
    final resolvedTitle = await _resolveSheetTitle(title);
    final exists =
        _spreadsheet?.sheets?.any(
          (sheet) => sheet.properties?.title == resolvedTitle,
        ) ??
        false;
    if (!exists) {
      final addSheetRequest = sheets.Request(
        addSheet: sheets.AddSheetRequest(
          properties: sheets.SheetProperties(title: title),
        ),
      );
      await _sheetsApi!.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: [addSheetRequest]),
        _spreadsheetId!,
      );
      await _refreshSpreadsheet();
      final sheetName = await _resolveSheetTitle(title);
      final headerRange =
          '${_quoteSheetTitle(sheetName)}!A1:${String.fromCharCode(64 + headers.length)}1';
      await _sheetsApi!.spreadsheets.values.update(
        sheets.ValueRange(values: [headers]),
        _spreadsheetId!,
        headerRange,
        valueInputOption: 'RAW',
      );
    }
  }

  Future<List<List<String>>> _readRows(String title, int columnCount) async {
    await _ensureSheet(title, _headerForSheet(title));
    if (_useLocalStorage) {
      return await _readRowsFromLocal(title, columnCount);
    }
    final sheetName = await _resolveSheetTitle(title);
    final range =
        '${_quoteSheetTitle(sheetName)}!A2:${String.fromCharCode(64 + columnCount)}';
    final response = await _sheetsApi!.spreadsheets.values.get(
      _spreadsheetId!,
      range,
    );
    final values = response.values ?? [];
    return values
        .map((row) => row.map((cell) => cell?.toString() ?? '').toList())
        .toList();
  }

  List<String> _headerForSheet(String title) {
    switch (title) {
      case 'CM':
      case 'PM':
        return ['Title', 'Description', 'ImagePath', 'CreatedAt'];
      case 'WiFi':
        return ['SSID', 'Password'];
      case 'Mic':
        return ['Name', 'Channel'];
      default:
        return ['Title', 'Description'];
    }
  }

  Future<void> _appendRow(String title, List<Object?> row) async {
    await _ensureSheet(title, _headerForSheet(title));
    if (_useLocalStorage) {
      final rows = await _loadLocalRows(title);
      rows.add(row.map((e) => e?.toString() ?? '').toList());
      await _saveLocalRows(title, rows);
      return;
    }
    final sheetName = await _resolveSheetTitle(title);
    await _sheetsApi!.spreadsheets.values.append(
      sheets.ValueRange(values: [row]),
      _spreadsheetId!,
      '${_quoteSheetTitle(sheetName)}!A:A',
      valueInputOption: 'RAW',
      insertDataOption: 'INSERT_ROWS',
    );
  }

  Future<void> _updateRow(String title, int index, List<Object?> row) async {
    await _ensureSheet(title, _headerForSheet(title));
    if (_useLocalStorage) {
      final rows = await _loadLocalRows(title);
      if (index >= 0 && index < rows.length) {
        rows[index] = row.map((e) => e?.toString() ?? '').toList();
        await _saveLocalRows(title, rows);
      }
      return;
    }
    final sheetName = await _resolveSheetTitle(title);
    final rowNumber = index + 2;
    await _sheetsApi!.spreadsheets.values.update(
      sheets.ValueRange(values: [row]),
      _spreadsheetId!,
      '${_quoteSheetTitle(sheetName)}!A$rowNumber',
      valueInputOption: 'RAW',
    );
  }

  Future<void> _deleteRow(String title, int index) async {
    await _ensureSheet(title, _headerForSheet(title));
    if (_useLocalStorage) {
      final rows = await _loadLocalRows(title);
      if (index >= 0 && index < rows.length) {
        rows.removeAt(index);
        await _saveLocalRows(title, rows);
      }
      return;
    }
    final sheetId = await _sheetId(title);
    final request = sheets.BatchUpdateSpreadsheetRequest(
      requests: [
        sheets.Request(
          deleteDimension: sheets.DeleteDimensionRequest(
            range: sheets.DimensionRange(
              sheetId: sheetId,
              dimension: 'ROWS',
              startIndex: index + 1,
              endIndex: index + 2,
            ),
          ),
        ),
      ],
    );
    await _sheetsApi!.spreadsheets.batchUpdate(request, _spreadsheetId!);
    await _refreshSpreadsheet();
  }

  Future<List<WorkNote>> fetchWorkNotes(String title) async {
    final rows = await _readRows(title, 4);
    return rows.map((row) {
      final createdAtString = row.length > 3 ? row[3] : '';
      final createdAt = createdAtString.isNotEmpty
          ? DateTime.tryParse(createdAtString)
          : null;
      return WorkNote(
        title: row.isNotEmpty ? row[0] : '',
        description: row.length > 1 ? row[1] : '',
        imagePath: row.length > 2 ? row[2] : null,
        createdAt: createdAt ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> addWorkNote(String title, WorkNote note) async {
    await _appendRow(title, [
      note.title,
      note.description,
      note.imagePath ?? '',
      note.createdAt.toIso8601String(),
    ]);
  }

  Future<void> updateWorkNote(String title, int index, WorkNote note) async {
    await _updateRow(title, index, [
      note.title,
      note.description,
      note.imagePath ?? '',
      note.createdAt.toIso8601String(),
    ]);
  }

  Future<void> deleteSheetRow(String title, int index) async {
    await _deleteRow(title, index);
  }

  Future<List<WiFiEntry>> fetchWiFiEntries() async {
    final rows = await _readRows('WiFi', 2);
    return rows
        .map(
          (row) => WiFiEntry(
            ssid: row.isNotEmpty ? row[0] : '',
            password: row.length > 1 ? row[1] : '',
          ),
        )
        .toList();
  }

  Future<void> addWiFiEntry(WiFiEntry entry) async {
    await _appendRow('WiFi', [entry.ssid, entry.password]);
  }

  Future<void> updateWiFiEntry(int index, WiFiEntry entry) async {
    await _updateRow('WiFi', index, [entry.ssid, entry.password]);
  }

  Future<List<MicrophoneEntry>> fetchMicrophoneEntries() async {
    final rows = await _readRows('Mic', 2);
    return rows
        .map(
          (row) => MicrophoneEntry(
            name: row.isNotEmpty ? row[0] : '',
            channel: row.length > 1 ? row[1] : '',
          ),
        )
        .toList();
  }

  Future<void> addMicrophoneEntry(MicrophoneEntry entry) async {
    await _appendRow('Mic', [entry.name, entry.channel]);
  }

  Future<void> updateMicrophoneEntry(int index, MicrophoneEntry entry) async {
    await _updateRow('Mic', index, [entry.name, entry.channel]);
  }
}

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
    await showDialog(
      context: context,
      builder: (context) => AddNoteDialog(
        onAdd: (title, description, imagePath) async {
          await SheetSyncService.instance.addWorkNote(
            'CM',
            WorkNote(
              title: title,
              description: description,
              imagePath: imagePath,
              createdAt: DateTime.now(),
            ),
          );
          await _loadNotes();
        },
      ),
    );
  }

  Future<void> _editNote(int index) async {
    await showDialog(
      context: context,
      builder: (context) => EditNoteDialog(
        note: cmNotes[index],
        onSave: (title, description, imagePath) async {
          await SheetSyncService.instance.updateWorkNote(
            'CM',
            index,
            WorkNote(
              title: title,
              description: description,
              imagePath: imagePath,
              createdAt: cmNotes[index].createdAt,
            ),
          );
          await _loadNotes();
        },
      ),
    );
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
    await showDialog(
      context: context,
      builder: (context) => AddNoteDialog(
        onAdd: (title, description, imagePath) async {
          await SheetSyncService.instance.addWorkNote(
            'PM',
            WorkNote(
              title: title,
              description: description,
              imagePath: imagePath,
              createdAt: DateTime.now(),
            ),
          );
          await _loadNotes();
        },
      ),
    );
  }

  Future<void> _editNote(int index) async {
    await showDialog(
      context: context,
      builder: (context) => EditNoteDialog(
        note: pmNotes[index],
        onSave: (title, description, imagePath) async {
          await SheetSyncService.instance.updateWorkNote(
            'PM',
            index,
            WorkNote(
              title: title,
              description: description,
              imagePath: imagePath,
              createdAt: pmNotes[index].createdAt,
            ),
          );
          await _loadNotes();
        },
      ),
    );
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
                        Icon(
                          Icons.assignment,
                          size: 64,
                          color: Colors.grey[400],
                        ),
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
  final String? imagePath;
  final DateTime createdAt;

  WorkNote({
    required this.title,
    required this.description,
    this.imagePath,
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
  final Function(String title, String description, String? imagePath) onAdd;

  const AddNoteDialog({super.key, required this.onAdd});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imagePath;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_imagePath == null ? 'Add Image' : 'Image Added'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              widget.onAdd(
                _titleController.text,
                _descriptionController.text,
                _imagePath,
              );
              Navigator.pop(context);
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

class EditNoteDialog extends StatefulWidget {
  final WorkNote note;
  final Function(String title, String description, String? imagePath) onSave;

  const EditNoteDialog({super.key, required this.note, required this.onSave});

  @override
  State<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _imagePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descriptionController = TextEditingController(
      text: widget.note.description,
    );
    _imagePath = widget.note.imagePath;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_imagePath == null ? 'Add Image' : 'Change Image'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(
              _titleController.text,
              _descriptionController.text,
              _imagePath,
            );
            Navigator.pop(context);
          },
          child: const Text('Save'),
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

class AddWiFiDialog extends StatefulWidget {
  final Function(String ssid, String password) onAdd;

  const AddWiFiDialog({super.key, required this.onAdd});

  @override
  State<AddWiFiDialog> createState() => _AddWiFiDialogState();
}

class _AddWiFiDialogState extends State<AddWiFiDialog> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add WiFi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ssidController,
            decoration: const InputDecoration(
              hintText: 'WiFi Name (SSID)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(),
            ),
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
          onPressed: () {
            if (_ssidController.text.isNotEmpty &&
                _passwordController.text.isNotEmpty) {
              widget.onAdd(_ssidController.text, _passwordController.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class EditWiFiDialog extends StatefulWidget {
  final WiFiEntry entry;
  final Function(String ssid, String password) onSave;

  const EditWiFiDialog({super.key, required this.entry, required this.onSave});

  @override
  State<EditWiFiDialog> createState() => _EditWiFiDialogState();
}

class _EditWiFiDialogState extends State<EditWiFiDialog> {
  late final TextEditingController _ssidController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _ssidController = TextEditingController(text: widget.entry.ssid);
    _passwordController = TextEditingController(text: widget.entry.password);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit WiFi'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _ssidController,
            decoration: const InputDecoration(
              hintText: 'WiFi Name (SSID)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(),
            ),
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
          onPressed: () {
            widget.onSave(_ssidController.text, _passwordController.text);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class AddMicDialog extends StatefulWidget {
  final Function(String name, String channel) onAdd;

  const AddMicDialog({super.key, required this.onAdd});

  @override
  State<AddMicDialog> createState() => _AddMicDialogState();
}

class _AddMicDialogState extends State<AddMicDialog> {
  final _nameController = TextEditingController();
  final _channelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Microphone'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Microphone Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _channelController,
            decoration: const InputDecoration(
              hintText: 'Channel Number',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _channelController.text.isNotEmpty) {
              widget.onAdd(_nameController.text, _channelController.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _channelController.dispose();
    super.dispose();
  }
}

class EditMicDialog extends StatefulWidget {
  final MicrophoneEntry entry;
  final Function(String name, String channel) onSave;

  const EditMicDialog({super.key, required this.entry, required this.onSave});

  @override
  State<EditMicDialog> createState() => _EditMicDialogState();
}

class _EditMicDialogState extends State<EditMicDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _channelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
    _channelController = TextEditingController(text: widget.entry.channel);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Microphone'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Microphone Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _channelController,
            decoration: const InputDecoration(
              hintText: 'Channel Number',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_nameController.text, _channelController.text);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _channelController.dispose();
    super.dispose();
  }
}

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

  bool get _hasLocalImage =>
      note.imagePath != null && File(note.imagePath!).existsSync();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(note.description),
            if (_hasLocalImage) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(note.imagePath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.ssid,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Password: '),
                Expanded(
                  child: Text(
                    entry.password,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Channel: '),
                Text(
                  entry.channel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
