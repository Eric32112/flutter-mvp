import 'package:get_it/get_it.dart';
import 'package:tempo_official/providers/auth_provider.dart';
import 'package:tempo_official/providers/planner_provider.dart';
import 'package:tempo_official/providers/social_provider.dart';
import 'package:tempo_official/screens/home/home_screen.dart';
import 'package:tempo_official/screens/home/tabs/planner/planner_tab.dart';
import 'package:tempo_official/services/file_picker.dart';

GetIt locator = GetIt.asNewInstance();

void setupLocator() {
  locator.reset();
  locator.registerLazySingleton(() => AuthProvider());
  locator.registerLazySingleton(() => PlannerProvider());
  locator.registerLazySingleton(() => PlannerTabProvider());
  locator.registerLazySingleton(() => HomeScreenProvider());
  locator.registerLazySingleton(() => SocialProvider());
  locator.registerLazySingleton(() => FilePickerService());
}
