import 'package:go_router/go_router.dart';
import '../screens/screens.dart';

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
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/pets',
            name: 'pets',
            pageBuilder: (context, state) => const NoTransitionPage(child: PetsScreen()),
          ),
          GoRoute(
            path: '/book',
            name: 'book',
            pageBuilder: (context, state) => const NoTransitionPage(child: BookScreen()),
          ),
          GoRoute(
            path: '/ai-chat',
            name: 'ai-chat',
            pageBuilder: (context, state) => const NoTransitionPage(child: AiChatScreen()),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
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
        builder: (context, state) {
          final petId = state.extra as int?;
          return AddPetScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/pet-detail/:id',
        name: 'pet-detail',
        builder: (context, state) {
          final petId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return PetDetailScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/pet-edit/:id',
        name: 'pet-edit',
        builder: (context, state) {
          final petId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return EditPetScreen(petId: petId);
        },
      ),
      GoRoute(
        path: '/pet-medical',
        name: 'pet-medical',
        builder: (context, state) => const PetMedicalRecordScreen(),
      ),
      GoRoute(
        path: '/my-appointments',
        name: 'my-appointments',
        builder: (context, state) => const MyAppointmentsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/:type',
        name: 'settings-edit',
        builder: (context, state) {
          final type = state.pathParameters['type'];
          return SettingsEditScreen(editType: settingsEditTypeFromPath(type));
        },
      ),
    ],
  );
}
