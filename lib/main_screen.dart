import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ezcars/services/impl/location_service.dart';  // Import the LocationService
import 'package:ezcars/services/impl/vehicle_service.dart';   // Import the VehicleService

import 'features/search/search_screen.dart';
import 'features/home/home_screen.dart';  // Import updated HomeScreen
import 'features/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng class

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index of the currently selected tab
  int _selectedIndex = 0;
  LatLng? _vehicleLocation;  // Store the vehicle location to pass to SearchScreen
  final GlobalKey<SearchScreenState> _searchScreenKey = GlobalKey<SearchScreenState>(); // Add GlobalKey for SearchScreen

  late List<Widget> _screens;
  late VehicleService vehicleService;
  late LocationService locationService;

  @override
  void initState() {
    super.initState();

    // Initialize services
    vehicleService = VehicleService();  // Initialize VehicleService
    locationService = LocationService(); // Initialize LocationService

    // List of screens corresponding to each tab
    _screens = [
      HomeScreen(
        vehicleService: vehicleService,
        locationService: locationService,
        onVehicleDoubleTap: _navigateToSearchScreen, // Pass the navigation callback
      ),  // Home screen with VehicleService and LocationService dependency
      SearchScreen(
        key: _searchScreenKey, // Assign GlobalKey to SearchScreen
        vehicleLocation: _vehicleLocation, // Pass the vehicle location to SearchScreen
      ),  // Search screen
      const SettingsScreen(),  // Settings screen
      const ProfileScreen(),  // Profile screen
    ];
  }

  /// Method to navigate to the SearchScreen with a vehicle's location
  void _navigateToSearchScreen(LatLng vehicleLocation) {
    setState(() {
      _vehicleLocation = vehicleLocation; // Set the vehicle location for SearchScreen
      _selectedIndex = 1; // Switch to SearchScreen tab
    });
    // Use the GlobalKey to trigger the focus method in SearchScreen
    _searchScreenKey.currentState?.animateOrMoveToVehicleLocation(vehicleLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body contains the screen corresponding to the selected index
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,  // Use IndexedStack to maintain state of all screens
        ),
      ),
      // BottomNavigationBar used to switch between different screens
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Method to handle tab selection in BottomNavigationBar
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;  // Update the selected index
    });
  }

  // Method to build the BottomNavigationBar
  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,  // Set the current active tab
      onTap: _onDestinationSelected,  // Call the method to handle tab switching
      type: BottomNavigationBarType.fixed,  // Ensure the bar items are always visible
      items: [
        _buildBottomNavigationBarItem(
          icon: Icons.home,
          label: AppLocalizations.of(context)?.nav_home ?? 'Home',  // Fallback to 'Home' if localization fails
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.search,
          label: AppLocalizations.of(context)?.nav_search ?? 'Search',  // Fallback to 'Search' if localization fails
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.settings,
          label: AppLocalizations.of(context)?.nav_settings ?? 'Settings',  // Fallback to 'Settings' if localization fails
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.person,
          label: AppLocalizations.of(context)?.nav_profile ?? 'Profile',  // Fallback to 'Profile' if localization fails
        ),
      ],
    );
  }

  // Helper method to build each BottomNavigationBar item
  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required IconData icon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),  // Icon for the tab
      label: label,  // Label for the tab
    );
  }
}
