import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';
import 'features/home/services/impl/animal_service.dart';
import 'features/profile_screen.dart';
import 'features/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // A list of keys for managing each Navigator independently
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine if the screen is wide enough to use NavigationRail
    bool useNavigationRail = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Row(
        children: [
          if (useNavigationRail)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
          // SafeArea to prevent overlapping with system UI
          Expanded(
            child: SafeArea(
              child: Navigator(
                key: _navigatorKeys[_selectedIndex],
                onGenerateRoute: (RouteSettings settings) {
                  WidgetBuilder builder;
                  switch (_selectedIndex) {
                    case 0:
                    // Instantiate AnimalService here
                      final animalService = AnimalService();
                      builder = (BuildContext _) => HomeScreen(animalService: animalService); {}
                      break;
                    case 1:
                      builder = (BuildContext _) => const SettingsScreen();
                      break;
                    case 2:
                      builder = (BuildContext _) => const ProfileScreen();
                      break;
                    default:
                      throw Exception("Invalid index");
                  }
                  return MaterialPageRoute(builder: builder, settings: settings);
                },
              ),
            ),
          ),
        ],
      ),
      // BottomNavigationBar for smaller screens
      bottomNavigationBar: useNavigationRail
          ? null
          : BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}