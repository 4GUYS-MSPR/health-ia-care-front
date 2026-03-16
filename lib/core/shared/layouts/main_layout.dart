import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../features/authentication/presentation/widgets/account_menu_button.dart';
import '../../extensions/l10n_extension.dart';
import '../../extensions/theme_extension.dart';

class AppNavigationDestination {
  final String destination;
  final IconData icon;

  AppNavigationDestination({
    required this.destination,
    required this.icon,
  });
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double _mobileNavigationBreakpoint = 900;

  List<AppNavigationDestination> _buildDestinations(BuildContext context) {
    return [
      AppNavigationDestination(
        destination: context.l10n.navigationDestinationHome,
        icon: Symbols.home,
      ),
      AppNavigationDestination(
        destination: context.l10n.navigationDestinationMembers,
        icon: Symbols.group,
      ),
      AppNavigationDestination(
        destination: context.l10n.navigationDestinationNutrition,
        icon: Symbols.nutrition,
      ),
      AppNavigationDestination(
        destination: context.l10n.navigationDestinationExercises,
        icon: Symbols.fitness_center,
      ),
      AppNavigationDestination(
        destination: context.l10n.navigationDestinationDiet,
        icon: Symbols.restaurant,
      ),
      AppNavigationDestination(
        destination: context.l10n.navigationDestinationSessions,
        icon: Symbols.timer,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileNavigation =
            constraints.maxWidth < _mobileNavigationBreakpoint;

        if (isMobileNavigation) {
          return Scaffold(
            appBar: AppBar(
              title: Text(destinations[navigationShell.currentIndex].destination),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: AccountMenuButton(),
                ),
              ],
            ),
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (value) => navigationShell.goBranch(value),
              destinations: destinations
                  .map(
                    (destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.destination,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              _MainLayoutNavigationRail(
                navigationShell: navigationShell,
                destinations: destinations,
              ),
              const VerticalDivider(width: 1),
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}

class _MainLayoutNavigationRail extends StatelessWidget {
  const _MainLayoutNavigationRail({
    required this.navigationShell,
    required this.destinations,
  });

  final StatefulNavigationShell navigationShell;
  final List<AppNavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final railDestinations = destinations
        .map(
          (destination) => NavigationRailDestination(
            icon: Icon(destination.icon),
            label: Text(destination.destination),
          ),
        )
        .toList(growable: false);

    return NavigationRail(
      selectedIndex: navigationShell.currentIndex,
      destinations: railDestinations,
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
