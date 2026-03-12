import 'package:flutter/material.dart';
import 'package:health_ia_care_app/core/shared/pages/dashboards/exercises_dashboard.dart';

import 'dashboards/home_dashboard.dart';
import 'dashboards/nutrition_dashboard.dart';
import 'dashboards/members_dashboard.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE PRINCIPALE
// Shell minimaliste : juste le TabBar + TabBarView.
// Chaque onglet délègue à son propre dashboard.
// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HealthAI Coach'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home),            text: 'Accueil'),
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Nutrition'),
              Tab(icon: Icon(Icons.people),          text: 'Members'),
              Tab(icon: Icon(Icons.fitness_center),  text: 'Exercices'),
            ],
          ),
        ),
        
        body: const TabBarView(
          children: [
            HomeDashboard(),     
            NutritionDashboard(), 
            MembersDashboard(),   
            ExercicesDashboard(),   
          ],
        ),
      ),
    );
  }
}