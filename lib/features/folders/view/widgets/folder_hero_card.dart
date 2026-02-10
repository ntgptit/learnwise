import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';

class FolderHeroCard extends StatelessWidget {
  const FolderHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foregroundColor = _resolveHeroForegroundColor(colorScheme);

    return Container(
      padding: const EdgeInsets.all(FolderScreenTokens.heroPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FolderScreenTokens.heroRadius),
        gradient: LinearGradient(
          colors: <Color>[colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.foldersHeroTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: FolderScreenTokens.heroTextGap),
          Text(
            l10n.foldersHeroDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foregroundColor.withValues(
                alpha: FolderScreenTokens.dimOpacity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _resolveHeroForegroundColor(ColorScheme colorScheme) {
  if (colorScheme.brightness == Brightness.dark) {
    return colorScheme.onSurface;
  }
  return colorScheme.onPrimary;
}
