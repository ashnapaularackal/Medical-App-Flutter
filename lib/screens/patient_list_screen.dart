import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import '../services/api_service.dart';
import 'patient_detail_screen.dart';
import '../utils/dialog_utils.dart';
import 'dart:math' as math;

/// PatientListScreen displays a list of patients with pull-to-refresh functionality,
/// swipe-to-delete, and navigation to patient details.
///
/// Features:
/// - Material Design 3 inspired UI with dynamic theming
/// - Animated transitions and loading states
/// - Pull-to-refresh for updated patient data
/// - Swipe-to-delete with confirmation
/// - Search functionality for filtering patients
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  PatientListScreenState createState() => PatientListScreenState();
}

class PatientListScreenState extends State<PatientListScreen>
    with AutomaticKeepAliveClientMixin, RouteAware, TickerProviderStateMixin {
  // Data state
  List<Patient> patients = [];
  List<Patient> filteredPatients = [];
  bool _loading = true;
  String _searchQuery = '';
  bool _isSearching = false;

  // Animation controllers
  late AnimationController _refreshIconController;
  late AnimationController _loadingController;

  // Route observer for navigation events
  late RouteObserver<PageRoute> _routeObserver;

  // Scroll controller for list behaviors
  final ScrollController _scrollController = ScrollController();

  // Key for forcing rebuild of the ListView
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _refreshIconController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Setup route observer
    _routeObserver = RouteObserver<PageRoute>();

    // Initial data load
    loadPatients();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to refresh data when returning to this screen
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null && modalRoute is PageRoute) {
      _routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _refreshIconController.dispose();
    _loadingController.dispose();
    _scrollController.dispose();
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Called when returning to this screen from another route
  @override
  void didPopNext() {
    // Always reload data when returning to this screen for freshness
    loadPatients();
  }

  /// Loads all patients from the API with error handling
  Future<void> loadPatients() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      // Start refresh animation
      _refreshIconController.forward(from: 0.0);

      // Load patient data from API
      final loadedPatients = await ApiService.getAllPatients();

      if (!mounted) return;

      setState(() {
        patients = loadedPatients;
        // Also update filtered list based on any active search
        _filterPatients();
        _loading = false;
      });
    } catch (e) {
      print('Error loading patients: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
      _showErrorSnackBar('Failed to load patients. Please try again.');
    }
  }

  /// Filters patients based on search query
  void _filterPatients() {
    if (_searchQuery.isEmpty) {
      filteredPatients = List.from(patients);
    } else {
      filteredPatients = patients.where((patient) {
        final name = patient.name?.toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  /// Shows error messages to the user with improved styling
  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: loadPatients,
        ),
      ),
    );
  }

  /// Handles patient deletion with confirmation dialog
  Future<void> _deletePatient(String patientId) async {
    final confirm = await showDeleteConfirmationDialog(context);
    if (!confirm) return;

    try {
      // Show loading indicator during deletion
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Deleting patient...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );

      // Call API to delete patient
      await ApiService.deletePatient(patientId);
      await loadPatients(); // Reload the entire list after deletion

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Patient deleted successfully'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete patient: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Toggle search bar visibility
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _filterPatients();
      }
    });
  }

  /// Update search query and filter results
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _filterPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Extract theme colors for consistent styling
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search patients...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _updateSearchQuery,
              )
            : const Text('Patient Directory',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          // Search button
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Cancel Search' : 'Search Patients',
          ),
          // Refresh button with rotation animation
          AnimatedBuilder(
            animation: _refreshIconController,
            builder: (_, child) {
              return Transform.rotate(
                angle: _refreshIconController.value * 2.0 * math.pi,
                child: child,
              );
            },
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                // Manually trigger the refresh indicator
                _refreshIndicatorKey.currentState?.show();
              },
              tooltip: 'Refresh',
            ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.8),
              secondaryColor.withOpacity(0.5),
            ],
            stops: const [0.2, 0.9],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: loadPatients,
            color: primaryColor,
            backgroundColor: Colors.white,
            displacement: 40,
            strokeWidth: 3,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  /// Builds the main content based on loading state and data availability
  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom loading animation
            AnimatedBuilder(
              animation: _loadingController,
              builder: (_, __) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Loading patients...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.person_off,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No patients match "$_searchQuery"'
                  : 'No patients found in the database',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_searchQuery.isNotEmpty) {
                  setState(() {
                    _searchQuery = '';
                    _filterPatients();
                  });
                } else {
                  loadPatients();
                }
              },
              icon: Icon(
                _searchQuery.isNotEmpty ? Icons.clear : Icons.refresh,
              ),
              label: Text(
                _searchQuery.isNotEmpty ? 'Clear Search' : 'Refresh',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      // Load new data when user scrolls to top and releases
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == 0 &&
            scrollInfo is ScrollEndNotification) {
          loadPatients();
        }
        return false;
      },
      child: Scrollbar(
        controller: _scrollController,
        thickness: 6,
        radius: const Radius.circular(8),
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              16, 8, 16, 80), // Bottom padding for FAB
          itemCount: filteredPatients.length,
          itemBuilder: (context, index) {
            final patient = filteredPatients[index];

            // Add staggered animation for items
            return AnimatedOpacity(
              duration: Duration(milliseconds: 300 + (index * 50)),
              opacity: 1.0,
              curve: Curves.easeInOut,
              child: AnimatedPadding(
                duration: Duration(milliseconds: 300 + (index * 50)),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Dismissible(
                  key: Key(
                      '${patient.id}-${DateTime.now().millisecondsSinceEpoch}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_forever,
                            color: Colors.white, size: 32),
                        const SizedBox(height: 4),
                        const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) {
                    if (patient.id != null) {
                      _deletePatient(patient.id!);
                    }
                  },
                  confirmDismiss: (direction) async {
                    return showDeleteConfirmationDialog(context);
                  },
                  child: Hero(
                    tag: 'patient-${patient.id}',
                    child: PatientCard(
                      patient: patient,
                      onTap: () async {
                        // Navigate to detail screen
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PatientDetailScreen(patient: patient),
                          ),
                        );

                        // Always refresh after returning from detail screen
                        loadPatients();
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
