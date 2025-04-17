import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'screens/welcomescreen.dart';
import 'screens/patient_list_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/critical_patients_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'models/patient.dart';

/// The main entry point for the application.
/// Sets up the device orientation and system UI styles before running the app.
void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait orientation only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.light, // Light status bar icons
    ));
  }

  // Launch the application
  runApp(MyApp());
}

/// Root widget of the application.
/// Configures the theme and routing for the entire app.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellCare Hospital Management',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100], // Light gray background
        // Configure app bar appearance
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
        // Configure button appearance
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
      // Define initial route
      initialRoute: '/',
      // Define named routes for navigation
      routes: {
        '/': (context) => WelcomeScreen(),
        '/home': (context) => MainScreen(),
        '/add_patient': (context) => AddPatientScreen(),
      },
      // Dynamic route generation for patient details page
      onGenerateRoute: (settings) {
        if (settings.name == '/patient_details') {
          // Extract Patient object passed as argument
          final patient = settings.arguments as Patient?;
          return MaterialPageRoute(
            builder: (context) {
              if (patient != null) {
                return PatientDetailScreen(patient: patient);
              } else {
                // Fallback for invalid patient data
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

/// Main screen of the application containing the page view and bottom navigation.
/// Manages navigation between patient list and critical patient screens.
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Track the current selected tab
  // Key to access methods in the PatientListScreen
  final _patientListScreenKey = GlobalKey<PatientListScreenState>();
  // Controller for managing page transitions
  final PageController _pageController = PageController();

  @override
  void dispose() {
    // Clean up resources
    _pageController.dispose();
    super.dispose();
  }

  // Define the pages to be displayed in the PageView
  late final List<Widget> _pages = [
    PatientListScreen(key: _patientListScreenKey),
    CriticalPatientsScreen(),
  ];

  /// Handles taps on bottom navigation items
  void _onItemTapped(int index) {
    if (index == 1) {
      // Middle button is for adding a new patient
      _navigateToAddPatient();
    } else {
      // Calculate actual index for PageView (accounting for the "Add Patient" button)
      int actualIndex = index > 1 ? index - 1 : index;
      setState(() {
        _currentIndex = index;
        _pageController.jumpToPage(actualIndex);
      });
    }
  }

  /// Navigate to the add patient screen and refresh patient list if new patient added
  void _navigateToAddPatient() async {
    try {
      // Navigate and wait for result
      final result = await Navigator.pushNamed(context, '/add_patient');
      if (result != null && result == true) {
        // If patient was added, switch to patient list tab and refresh data
        setState(() {
          _currentIndex = 0;
          _pageController.jumpToPage(0);
        });
        // Trigger refresh of patient list
        _patientListScreenKey.currentState?.loadPatients();
      }
    } catch (e) {
      // Handle navigation errors
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
      // PageView to switch between screens
      body: PageView(
        controller: _pageController,
        physics:
            NeverScrollableScrollPhysics(), // Disable swiping between pages
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            // Update bottom nav index when page changes
            _currentIndex = index == 0 ? 0 : index + 1;
          });
        },
      ),
      // Bottom navigation bar with 3 items
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Fixed position items
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple[700],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        elevation: 8,
        items: [
          // All patients tab
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Patients',
          ),
          // Add patient tab
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_outlined),
            activeIcon: Icon(Icons.person_add),
            label: 'Add Patient',
          ),
          // Critical patients tab
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_outlined),
            activeIcon: Icon(Icons.warning),
            label: 'Critical',
          ),
        ],
      ),
      // Show floating action button only on patient list screen
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
