import 'login.dart';
import 'profile.dart';
import 'register.dart';
import 'dashboard.dart';
import 'uploadpdf.dart';
import 'tambahsurat.dart';
import 'lampiransurat.dart';
import 'suratmasuklist.dart';
import 'detail_suratmasuk.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Function to check if the token is stored
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _isLoading = false;
    });
    print(_token);
  }

  // Function for logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      _token = null;
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Magang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Splash screen while checking token
      home: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _token != null
              ? DashboardPage(onLogout: _logout)
              : LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/profile': (context) => ProfilePage(),
        '/dashboard': (context) => DashboardPage(onLogout: _logout),
        '/suratmasuk': (context) => SuratMasukList(),
        '/tambahsurat': (context) => TambahSuratPage(onDataAdded: () {
              Navigator.of(context).pop(); // Go back to the previous page
              Navigator.of(context)
                  .pushReplacementNamed('/dashboard'); // Back to dashboard
            }),
        '/lampiransurat': (context) =>
            LampiranSuratPage(nomorSurat: ''), // Route for LampiranSuratPage
        '/uploadpdf': (context) => UploadPdfPage(), // Route for UploadPdfPage
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail_suratmasuk') {
          final args = settings.arguments
              as Map<String, dynamic>?; // Ensure args are available
          if (args != null) {
            return MaterialPageRoute(
              builder: (context) {
                return DetailSuratMasukPage(
                  nomorSurat: args['nomorSurat'],
                  pengirim: args['pengirim'],
                  tujuan: args['tujuan'],
                  perihal: args['perihal'],
                  tanggalSurat: args['tanggalSurat'],
                  tanggalTerima: args['tanggalTerima'],
                  filePath: args['filePath'],
                );
              },
            );
          }
          return _errorRoute(); // Navigate to error route if args are null
        }
        return null; // If route is not generated, return null
      },
    );
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text('Error')),
          body: Center(
            child: Text('Page not found'),
          ),
        );
      },
    );
  }
}
