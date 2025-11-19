import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/home_page.dart';
import 'pages/find_washer.dart';
import 'pages/chatbot_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'providers/theme_provider.dart';
import 'pages/notes_list_page.dart';
import 'pages/note_models.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {

      await Hive.initFlutter();
    } else {

      final appDocumentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDirectory.path);
    }

    // 어댑터 등록 (한 번만 실행되도록 확인)
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(NoteTypeAdapter().typeId)) {
      Hive.registerAdapter(NoteTypeAdapter());
    }

    await Hive.openBox<Note>('notesBox_v3');

  } catch (e) {
    print('main.dart에서 Hive 초기화 중 치명적인 오류 발생: $e');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const SmartGuideApp(),
    ),
  );
}

class SmartGuideApp extends StatelessWidget {
  const SmartGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueAccent,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko'),
            Locale('en'),
          ],
          home: const AuthChecker(),
        );
      },
    );
  }
}


class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    setState(() {
      _isLoggedIn = email != null && email.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isLoggedIn
        ? MainScreen(
      onLogout: () {
        setState(() {
          _isLoggedIn = false;
        });
      },
    )
        : LoginPage(
      onLoginSuccess: () {
        setState(() {
          _isLoggedIn = true;
        });
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const MainScreen({super.key, this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const HomePage(),
    const FindWasherPage(),
    const ChatbotPage(),
    SettingsPage(
      onBackPressed: () => setState(() => _currentIndex = 0),
      onLogout: widget.onLogout,
    ),
    const NoteListPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_other),
            label: '내 제품',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '챗봇'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: '노트'),
        ],
      ),
    );
  }
}
