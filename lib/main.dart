import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'services/washer_service.dart';
import 'providers/chat_provider.dart';
import 'providers/checklist_provider.dart';

// Navigation state management
class NavigationProvider with ChangeNotifier {
  Widget? _customPage;
  Widget? get customPage => _customPage;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void showCustomPage(Widget page) {
    _customPage = page;
    notifyListeners();
  }

  void hideCustomPage() {
    if (_customPage != null) {
      _customPage = null;
      notifyListeners();
    }
  }

  void changeTab(int index) {
    _currentIndex = index;
    _customPage = null; // Hide custom page when changing tab
    notifyListeners();
  }
}

// Removed the GlobalKey

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

    await Hive.openBox('accounts');
    await Hive.openBox('session');
    await Hive.openBox('chat_logs');
    await Hive.openBox('checklists');
    await Hive.openBox('user_settings');

  } catch (e) {
    print('main.dart에서 Hive 초기화 중 치명적인 오류 발생: $e');
  }

  runApp(const SmartGuideApp());
}

class SmartGuideApp extends StatelessWidget {
  const SmartGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
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
      ),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoggedIn = false;
  final _washerService = WasherService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _washerService.loadInitialWasher();
  }
  
  @override
  void dispose() {
    _washerService.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final sessionBox = Hive.box('session');
    setState(() {
       _isLoggedIn = sessionBox.get('current_user') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => NavigationProvider()),
              ChangeNotifierProvider.value(value: _washerService),
              ChangeNotifierProvider(create: (_) => ChatProvider(_washerService)),
              ChangeNotifierProvider(create: (_) => ChecklistProvider()),
            ],
            child: MainScreen(
              onLogout: () {
                final sessionBox = Hive.box('session');
                sessionBox.delete('current_user');
                setState(() {
                  _isLoggedIn = false;
                });
              },
            ),
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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadInitialChat();
    });
    
    _pages = [
      const HomePage(),
      Consumer<WasherService>(
        builder: (context, washerService, child) {
          return FindWasherPage(currentWasher: washerService.currentWasher);
        },
      ),
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
        onBackPressed: () => Provider.of<NavigationProvider>(context, listen: false).changeTab(0),
        onLogout: widget.onLogout,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: navProvider.customPage ?? IndexedStack(index: navProvider.currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.currentIndex,
        onTap: (index) => Provider.of<NavigationProvider>(context, listen: false).changeTab(index),
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
