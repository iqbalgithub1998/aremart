import 'package:are_mart/binding/general_binding.dart';
import 'package:are_mart/features/admin/screens/dashboard_page.dart';
import 'package:are_mart/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392, 856),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return GetMaterialApp(
          defaultTransition: Transition.cupertino,
          title: "Quick Gro",
          themeMode: ThemeMode.light,
          theme: TAppTheme.lightTheme,
          // darkTheme: TAppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          initialBinding: GeneralBindings(),
          // home: NavigationMenu(),
          // home: DashboardPage(),
          home: Center(child: CircularProgressIndicator()),
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(0.9)),
                child: child!,
              ),
        );
      },
    );
  }
}

// 27.0.12077973
