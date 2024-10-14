import 'features/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import 'features/home/home_screen.dart';
import 'features/home/services/impl/animal_service.dart';
import 'features/profile_screen.dart';
import 'features/settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index of the currently selected tab
  int _selectedIndex = 0;

  // List of screens corresponding to each tab
  final List<Widget> _screens = [
    HomeScreen(animalService: AnimalService()), // Home screen with AnimalService dependency
    const SearchScreen(), // Search screen
    const SettingsScreen(), // Settings screen
    const ProfileScreen(), // Profile screen
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // The body contains the screen corresponding to the selected index
      body: SafeArea(
        child: _screens[_selectedIndex], // Display the current screen
      ),
      // BottomNavigationBar used to switch between different screens
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Method to handle tab selection in BottomNavigationBar
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  // Method to build the BottomNavigationBar
  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex, // Set the current active tab
      onTap: _onDestinationSelected, // Call the method to handle tab switching
      type: BottomNavigationBarType.fixed, // Ensure the bar items are always visible
      items: [
        _buildBottomNavigationBarItem(
          icon: Icons.home,
          label: AppLocalizations.of(context)?.nav_home ?? 'Home', // Fallback to 'Home' if localization fails
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.search,
          label: AppLocalizations.of(context)?.nav_search ?? 'Search', // Fallback to 'Search' if localization fails
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.settings,
          label: AppLocalizations.of(context)?.nav_settings ?? 'Settings', // Fallback to 'Settings' if localization fails
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.person,
          label: AppLocalizations.of(context)?.nav_profile ?? 'Profile', // Fallback to 'Profile' if localization fails
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
      icon: Icon(icon), // Icon for the tab
      label: label, // Label for the tab
    );
  }
}
