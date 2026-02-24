import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../features/authentication/presentation/widgets/account_menu_button.dart';
import '../../extensions/l10n_extension.dart';
import '../../extensions/theme_extension.dart';

class NavigationDestination {
  final String destination;
  final IconData icon;

  NavigationDestination({
    required this.destination,
    required this.icon,
  });
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _MainLayoutNavigationRail(navigationShell: navigationShell),
          VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _MainLayoutNavigationRail extends StatelessWidget {
  const _MainLayoutNavigationRail({
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final List<NavigationDestination> destinations = [
      NavigationDestination(
        destination: context.l10n.navigationDestinationHome,
        icon: Symbols.home,
      ),
      NavigationDestination(
        destination: context.l10n.navigationDestinationNutrition,
        icon: Symbols.nutrition,
      ),
    ];

    List<NavigationRailDestination> getDestinations(List<NavigationDestination> destinations) {
      return List.generate(
        destinations.length,
        (index) {
          final destination = destinations[index];
          return NavigationRailDestination(
            icon: Icon(destination.icon),
            label: Text(destination.destination),
          );
        },
      );
    }

    return NavigationRail(
      selectedIndex: navigationShell.currentIndex,
      destinations: getDestinations(destinations),
      onDestinationSelected: (value) => navigationShell.goBranch(value),
      labelType: .selected,
      backgroundColor: context.colorScheme.surfaceContainer,
      trailingAtBottom: true,
      leading: _NavigationRailLeading(),
      trailing: _NavigationRailTrailing(),
    );
  }
}

class _NavigationRailLeading extends StatelessWidget {
  const _NavigationRailLeading();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Symbols.cardiology,
      color: context.colorScheme.primary,
      size: 50,
    );
  }
}

class _NavigationRailTrailing extends StatelessWidget {
  const _NavigationRailTrailing();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: AccountMenuButton(),
    );
  }
}
