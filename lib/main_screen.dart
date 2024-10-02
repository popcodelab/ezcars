import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../main.dart';
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

  // A list of keys for managing each Navigator independently, allowing for maintaining separate navigation stacks
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    3,
    (index) => GlobalKey<NavigatorState>(),
  );

  @override
  Widget build(BuildContext context) {
    // Listen to MyAppState's locale to trigger rebuilds when the language changes
    final locale = Provider.of<MyAppState>(context).locale;

    return Scaffold(
      body: SafeArea(
        child: Navigator(
          key: _navigatorKeys[_selectedIndex],
          onGenerateRoute: _generateRoute,
        ),
      ),
      // BottomNavigationBar used for navigation between screens
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Handles item selection for the BottomNavigationBar
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Builds the BottomNavigationBar
  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onDestinationSelected,
      items: [
        _buildBottomNavigationBarItem(
          icon: Icons.home,
          label: AppLocalizations.of(context)!.navHome,
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.settings,
          label: AppLocalizations.of(context)!.navSettings,
        ),
        _buildBottomNavigationBarItem(
          icon: Icons.person,
          label: AppLocalizations.of(context)!.navProfile,
        ),
      ],
    );
  }

  // Builds a BottomNavigationBar item
  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required IconData icon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  // Generates routes for different tabs in the Navigator
  MaterialPageRoute _generateRoute(RouteSettings settings) {
    WidgetBuilder builder;
    switch (_selectedIndex) {
      case 0:
        // HomeScreen with injected AnimalService dependency
        final animalService = AnimalService();
        builder = (BuildContext _) => HomeScreen(animalService: animalService);
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
  }
}
