import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/settings/cubit/locale_cubit.dart';
import '../l10n/app_localizations.dart';

Future<void> showLanguageSheet(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    barrierColor: scheme.scrim,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      final current = sheetContext.watch<LocaleCubit>().state;
      Widget option(Locale locale, String label) {
        return ListTile(
          title: Text(label),
          trailing:
              current.languageCode == locale.languageCode
                  ? Icon(Icons.check, color: scheme.primary)
                  : null,
          onTap: () {
            sheetContext.read<LocaleCubit>().setLocale(locale);
            Navigator.of(sheetContext).pop();
          },
        );
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.language,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
            ),
            option(const Locale('en'), l10n.languageEnglish),
            option(const Locale('id'), l10n.languageIndonesian),
          ],
        ),
      );
    },
  );
}
