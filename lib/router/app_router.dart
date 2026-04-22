import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/screens.dart';
import '../models/models.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/pets',
            name: 'pets',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PetsScreen(),
            ),
          ),
          GoRoute(
            path: '/book',
            name: 'book',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookScreen(),
            ),
          ),
          GoRoute(
            path: '/ai-chat',
            name: 'ai-chat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiChatScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/add-pet',
        name: 'add-pet',
        builder: (context, state) => const AddPetScreen(),
      ),
      GoRoute(
        path: '/pet-detail/:id',
        name: 'pet-detail',
        builder: (context, state) {
          final petId = state.pathParameters['id']!;
          return PetDetailScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/pet-medical',
        name: 'pet-medical',
        builder: (context, state) => const PetMedicalRecordScreen(),
      ),
      GoRoute(
        path: '/pet-medical-detail',
        name: 'pet-medical-detail',
        builder: (context, state) {
          final pet = state.extra as Pet;
          return PetMedicalDetailScreen(pet: pet);
        },
      ),
    ],
  );
}
