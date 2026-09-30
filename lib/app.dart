import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/medication_repository.dart';
import 'features/favorites/cubit/favorites_cubit.dart';
import 'features/settings/cubit/locale_cubit.dart';
import 'l10n/app_localizations.dart';
import 'routing/app_router.dart';

class MedRefApp extends StatefulWidget {
  const MedRefApp({required this.prefs, super.key});

  final SharedPreferences prefs;

  @override
  State<MedRefApp> createState() => _MedRefAppState();
}

class _MedRefAppState extends State<MedRefApp> {
  late final MedicationRepository _medicationRepository;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _medicationRepository = MedicationRepository();
    _router = buildAppRouter();
  }

  @override
  void dispose() {
    _medicationRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _medicationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => FavoritesCubit(FavoritesRepository(widget.prefs)),
          ),
          BlocProvider(create: (_) => LocaleCubit()),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              title: 'MedRef',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.system,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
