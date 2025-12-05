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
import 'pages/notes_list_page.dart' hide NoteAdapter, NoteTypeAdapter;
import 'pages/note_models.dart';
import 'services/washer_service.dart';
import 'providers/chat_provider.dart';
import 'models/chat_data.dart';
import 'providers/checklist_provider.dart';

final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDocumentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDirectory.path);
    }

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

  final washerService = WasherService();
  await washerService.loadInitialWasher();

  washerService.onWasherUpdated = (washer) {
    final context = mainScreenKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            washer != null
                ? '${washer.washerName}이(가) 내 세탁기로 설정되었습니다.'
                : '내 세탁기 정보가 삭제되었습니다.',
          ),
          backgroundColor: washer != null ? Colors.green : Colors.red,
        ),
      );
    }
  };

  final chatProvider = ChatProvider(washerService);
  await chatProvider.loadInitialChat();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: washerService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: chatProvider),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
      ],
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
          supportedLocales: const [Locale('ko'), Locale('en')],
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
            key: mainScreenKey, 
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const FindWasherPage(),
      Consumer<WasherService>(
        builder: (context, washerService, child) {
          return washerService.currentWasher != null
              ? const ChatbotPage()
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      '챗봇을 사용하려면 먼저 제품을 등록해주세요.\n[내 제품] 탭에서 제품을 선택할 수 있습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
        },
      ),
      const NoteListPage(),
      SettingsPage(
        onBackPressed: () => setState(() => _currentIndex = 0),
        onLogout: widget.onLogout,
      ),
    ];
  }

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
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
          BottomNavigationBarItem(icon: Icon(Icons.note), label: '노트'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
