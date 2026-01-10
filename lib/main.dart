import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'core/constants/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KuranGunluguApp());
}

class KuranGunluguApp extends StatefulWidget {
  const KuranGunluguApp({super.key});

  @override
  State<KuranGunluguApp> createState() => _KuranGunluguAppState();
}

class _KuranGunluguAppState extends State<KuranGunluguApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kuran Günlüğü',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
