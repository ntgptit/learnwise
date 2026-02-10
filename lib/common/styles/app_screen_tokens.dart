import 'package:flutter/material.dart';

import 'app_opacities.dart';
import 'app_sizes.dart';

class DashboardScreenTokens {
  const DashboardScreenTokens._();

  static const double headerBorderRadius = 28;
  static const double metricCardRadius = 22;
  static const double sectionSpacing = 22;
  static const double headerPadding = 22;
  static const double contentPadding = 18;
  static const double metricGridSpacing = 14;
  static const double quickActionSpacing = 10;
  static const double focusCardHeight = 132;
  static const double metricCardMinHeight = 106;
  static const double recentCardPadding = 14;
  static const double dimOpacity = AppOpacities.muted70;
  static const double softOpacity = AppOpacities.soft15;

  static const double heroGapSmall = AppSizes.spacingXs;
  static const double heroGapLarge = 18;
  static const double heroChipPadding = AppSizes.spacingSm;
  static const double heroChipRadius = AppSizes.radiusLg;
  static const double heroChipSpacing = AppSizes.spacingXs;

  static const double sectionTitleGap = AppSizes.spacingSm;
  static const double metricColumns = 2;
  static const double metricCardPadding = 14;
  static const double metricIconSize = 18;
  static const double metricIconGap = AppSizes.spacingXs;
  static const double metricBodyGap = 10;
  static const double metricBodyGapSmall = 6;

  static const double focusCardPadding = AppSizes.spacingMd;
  static const double focusIconSize = 34;
  static const double focusIconGap = 14;
  static const double focusTextGap = AppSizes.spacingXs;

  static const double recentItemGap = 10;
  static const double recentCardRadius = AppSizes.radiusLg;
  static const double recentProgressGap = AppSizes.spacingXs;
}

class FolderScreenTokens {
  const FolderScreenTokens._();

  static const double screenPadding = AppSizes.spacingMd;
  static const double sectionSpacing = AppSizes.spacingMd;
  static const double heroRadius = 24;
  static const double heroPadding = 20;
  static const double cardRadius = 20;
  static const double cardPadding = AppSizes.spacingMd;
  static const double cardSpacing = AppSizes.spacingSm;
  static const double colorDotSize = AppSizes.spacingSm;
  static const double colorItemSize = 34;
  static const double colorItemBorderWidth = 2;
  static const double breadcrumbSpacing = AppSizes.spacingXs;

  static const int descriptionMaxLines = 3;
  static const double heroTextGap = AppSizes.spacingXs;
  static const double dimOpacity = AppOpacities.muted82;
  static const double outlineOpacity = AppOpacities.outline26;
  static const double colorDotTopMargin = 6;
  static const double colorDotRadius = 999;
  static const double cardHorizontalGap = AppSizes.spacingSm;
  static const double cardMetaGap = 6;
  static const double colorGridSpacing = AppSizes.spacingXs;
  static const double colorBorderRadius = 10;
  static const double folderHeaderIconContainerSize = AppSizes.size72;
  static const double folderHeaderIconContainerRadius = AppSizes.radiusMd;
  static const double folderHeaderIconSize = AppSizes.size34;
  static const double folderHeaderTitleTopGap = AppSizes.spacingSm;
  static const double primaryActionGap = AppSizes.spacingSm;
  static const double sortLabelIconGap = AppSizes.spacing2Xs;
  static const double searchFieldHorizontalPadding = AppSizes.spacingXs;
  static const double listItemHorizontalPadding = AppSizes.spacingSm;
  static const double listItemVerticalPadding = AppSizes.spacingSm;
  static const double listItemLeadingSize = AppSizes.size40;
  static const double listItemLeadingRadius = AppSizes.radiusMd;
  static const double listItemLeadingIconSize = AppSizes.size22;
  static const double listItemHorizontalGap = AppSizes.spacingSm;
  static const double listItemTitleMetaGap = AppSizes.spacing2Xs;
  static const int nameMaxLines = 1;
  static const double surfaceSoftOpacity = AppOpacities.soft20;
}

class TtsScreenTokens {
  const TtsScreenTokens._();

  static const EdgeInsets screenPadding = EdgeInsets.all(AppSizes.spacingMd);
  static const double sectionSpacing = AppSizes.spacingSm;
  static const double subsectionSpacing = AppSizes.spacingXs;
  static const double actionSpacing = AppSizes.spacingMd;

  static const int inputMinLines = 4;
  static const int inputMaxLines = 8;
  static const double sliderLabelWidth = 72;
  static const double sliderValueWidth = 40;

  static const OutlineInputBorder formBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
  );
}
