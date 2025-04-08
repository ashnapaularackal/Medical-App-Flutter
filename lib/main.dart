import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'screens/welcomescreen.dart';
import 'screens/patient_list_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/critical_patients_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'models/patient.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellCare Hospital Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          elevation: 2,
          backgroundColor: Colors.blue[600],
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[700],
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/home': (context) => MainScreen(),
        '/add_patient': (context) => AddPatientScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/patient_details') {
          final patient = settings.arguments as Patient?;
          return MaterialPageRoute(
            builder: (context) {
              if (patient != null) {
                return PatientDetailScreen(patient: patient);
              } else {
                return Scaffold(
                  appBar: AppBar(title: Text('Invalid Patient')),
                  body: Center(child: Text('Invalid patient data')),
                );
              }
            },
          );
        }
        return null;
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _patientListScreenKey = GlobalKey<PatientListScreenState>();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  late final List<Widget> _pages = [
    PatientListScreen(key: _patientListScreenKey),
    CriticalPatientsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      _navigateToAddPatient();
    } else {
      int actualIndex = index > 1 ? index - 1 : index;
      setState(() {
        _currentIndex = index;
        _pageController.jumpToPage(actualIndex);
      });
    }
  }

  void _navigateToAddPatient() async {
    try {
      final result = await Navigator.pushNamed(context, '/add_patient');
      if (result != null && result == true) {
        setState(() {
          _currentIndex = 0;
          _pageController.jumpToPage(0);
        });
        _patientListScreenKey.currentState?.loadPatients();
      }
    } catch (e) {
      print('Error navigating to AddPatientScreen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to navigate. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index == 0 ? 0 : index + 1;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple[700],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_outlined),
            activeIcon: Icon(Icons.person_add),
            label: 'Add Patient',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_outlined),
            activeIcon: Icon(Icons.warning),
            label: 'Critical',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToAddPatient,
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.purple[700],
              tooltip: 'Add New Patient',
            )
          : null,
    );
  }
}
