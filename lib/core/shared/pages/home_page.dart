import 'package:flutter/material.dart';
import '../../extensions/l10n_extension.dart';

import 'dashboards/home_dashboard.dart';
import 'dashboards/nutrition_dashboard.dart';
import 'dashboards/members_dashboard.dart';
import 'dashboards/exercises_dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.appTitle),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home),            text: context.l10n.navigationDestinationHome),
              Tab(icon: Icon(Icons.restaurant_menu), text: context.l10n.navigationDestinationNutrition),
              Tab(icon: Icon(Icons.people),          text: context.l10n.navigationDestinationMembers),
              Tab(icon: Icon(Icons.fitness_center),  text: context.l10n.navigationDestinationExercises),
            ],
          ),
        ),
        
        body: const TabBarView(
          children: [
            HomeDashboard(),     
            NutritionDashboard(), 
            MembersDashboard(),   
            ExercisesDashboard(),  
          ],
        ),
      ),
    );
  }
}