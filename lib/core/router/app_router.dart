import 'package:go_router/go_router.dart';

import '../../features/food/domain/entities/food.dart';
import '../../features/food_management/presentation/pages/food_list_page.dart';
import '../../features/food_form/presentation/pages/food_form_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/result/presentation/pages/result_page.dart';

abstract class AppRoutes {
  static const home = '/';
  static const result = '/result';
  static const foods = '/foods';
  static const foodNew = '/foods/new';
  static const foodEdit = '/foods/edit';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) {
          final food = state.extra as Food?;
          if (food == null) {
            return const HomePage();
          }
          return ResultPage(food: food);
        },
      ),
      GoRoute(
        path: AppRoutes.foods,
        builder: (context, state) => const FoodListPage(),
      ),
      GoRoute(
        path: AppRoutes.foodNew,
        builder: (context, state) => const FoodFormPage(),
      ),
      GoRoute(
        path: '${AppRoutes.foodEdit}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FoodFormPage(foodId: id);
        },
      ),
    ],
  );
}
