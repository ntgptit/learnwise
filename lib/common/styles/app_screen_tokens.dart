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
  static const double editorDialogWidthFactor = 0.92;
  static const double editorDialogMinWidth = 320;
  static const double editorDialogMaxWidth = 520;
  static const double editorDialogSubmitIndicatorSize = AppSizes.size18;
  static const double editorDialogSubmitIndicatorStrokeWidth = 2;
  static const double loadingOverlayEdgeInset = 0;
}

class FlashcardScreenTokens {
  const FlashcardScreenTokens._();

  static const double screenPadding = AppSizes.spacingMd;
  static const double toolbarHeight = AppSizes.size72;
  static const double sectionSpacing = AppSizes.spacingMd;
  static const double sectionSpacingLarge = AppSizes.spacingLg;
  static const double sectionHeaderBottomGap = AppSizes.spacingMd;
  static const double sectionHeaderActionGap = AppSizes.spacingSm;
  static const double sectionHeaderSubtitleGap = AppSizes.spacing2Xs;
  static const double sectionHeaderTitleSize = AppSizes.size20;
  static const double sectionHeaderSubtitleSize = AppSizes.size14;
  static const double sectionHeaderSubtitleOpacity = AppOpacities.muted70;

  static const double heroCardHeight = AppSizes.size240;
  static const double heroCardRadius = AppSizes.radiusLg;
  static const double heroCardPadding = AppSizes.spacingLg;
  static const double heroCardItemSpacing = AppSizes.spacingXs;
  static const double heroViewportFraction = 0.94;
  static const double heroPagerGap = AppSizes.spacingSm;
  static const double heroDotSize = AppSizes.size6;
  static const double heroDotSpacing = AppSizes.spacing2Xs;
  static const int heroMaxIndicatorDots = 7;
  static const double heroCardDarkModeOpacity = AppOpacities.soft35;
  static const double heroDotInactiveDarkModeOpacity = AppOpacities.muted55;

  static const double metadataAvatarSize = AppSizes.size34;
  static const double metadataGap = AppSizes.spacingSm;
  static const double metadataHorizontalGap = AppSizes.spacingXs;
  static const double metadataTitleSize = AppSizes.size24;
  static const double metadataTitleLineHeight = 1.25;
  static const double metadataTitleBottomGap = AppSizes.spacingXs;
  static const double metadataLineSize = AppSizes.size14;
  static const double metadataLineOpacity = AppOpacities.muted70;
  static const double metadataOwnerCardRadius = AppSizes.radiusMd;
  static const double metadataOwnerCardHorizontalPadding = AppSizes.spacingSm;
  static const double metadataOwnerCardVerticalPadding = AppSizes.spacingXs;
  static const double metadataOwnerCardPrimaryOpacity = AppOpacities.soft35;
  static const double metadataOwnerCardSecondaryOpacity = AppOpacities.soft20;
  static const double metadataOwnerCardShadowOpacity = AppOpacities.soft15;
  static const double metadataOwnerCardShadowBlur = 10;
  static const double metadataOwnerCardShadowOffsetY = 4;
  static const double metadataAvatarHaloPadding = AppSizes.spacing2Xs;
  static const double metadataAvatarHaloOpacity = AppOpacities.soft35;
  static const double metadataOwnerNameMaxWidth = 180;
  static const double metadataCountChipRadius = AppSizes.radiusPill;
  static const double metadataCountChipHorizontalPadding = AppSizes.spacingSm;
  static const double metadataCountChipVerticalPadding = AppSizes.spacingXs;
  static const double metadataCountChipIconSize = AppSizes.size14;
  static const double metadataCountChipIconGap = AppSizes.spacing2Xs;

  static const double bannerHeight = AppSizes.size40;
  static const double bannerRadius = AppSizes.radiusSm;
  static const double bannerInnerGap = AppSizes.spacingXs;

  static const double actionTileSpacing = AppSizes.spacingSm;
  static const double cardSpacing = AppSizes.spacingMd;
  static const double cardPadding = AppSizes.spacingMd;
  static const double cardRadius = AppSizes.size20;
  static const double cardElevation = AppSizes.size1;
  static const double cardHeaderGap = AppSizes.spacingSm;
  static const double cardHeaderIconGap = AppSizes.spacingXs;
  static const double cardTextGap = AppSizes.spacingSm;
  static const double cardPrimaryTextSize = AppSizes.size20;
  static const double cardSecondaryTextSize = AppSizes.size14;
  static const double cardPrimarySecondaryGap = AppSizes.spacing2Xs;
  static const double cardDescriptionTextSize = AppSizes.size14;
  static const double cardDescriptionOpacity = AppOpacities.muted82;
  static const int cardDescriptionMaxLines = 2;
  static const int cardSecondaryMaxLines = 3;
  static const double cardActionIconSize = AppSizes.size20;
  static const double cardActionTapTargetSize = AppSizes.size40;
  static const double cardActionIconSpacing = AppSizes.spacingSm;
  static const double cardPressedScale = 1.01;
  static const int loadingSkeletonCount = 3;
  static const int loadingMoreSkeletonCount = 2;
  static const double skeletonLinePrimaryWidthFactor = 0.68;
  static const double skeletonLineSecondaryWidthFactor = 0.52;
  static const double skeletonLineDescriptionWidthFactor = 0.84;
  static const double skeletonLinePrimaryHeight = AppSizes.size20;
  static const double skeletonLineSecondaryHeight = AppSizes.size14;
  static const double skeletonLineDescriptionHeight = AppSizes.size14;
  static const double skeletonLineGap = AppSizes.spacing2Xs;
  static const double skeletonActionDotSize = AppSizes.size20;
  static const double skeletonActionDotRadius = AppSizes.radiusPill;
  static const int skeletonActionCount = 4;
  static const double overlayEdgeInset = 0;

  static const double bottomCtaTopSpacing = AppSizes.spacingMd;
  static const double bottomCtaHeight = AppSizes.size48;
  static const double bottomCtaRadius = AppSizes.radiusPill;
  static const double bottomListPadding = AppSizes.size72;

  static const double outlineOpacity = AppOpacities.outline26;
  static const double surfaceSoftOpacity = AppOpacities.soft20;
  static const double mutedTextOpacity = AppOpacities.muted82;
  static const double listMetadataGap = AppSizes.spacing2Xs;
  static const int previewMaxLines = 2;
  static const int backTextMaxLines = 8;

  static const double editorDialogWidthFactor = 0.92;
  static const double editorDialogMinWidth = 320;
  static const double editorDialogMaxWidth = 560;
  static const double editorDialogSubmitIndicatorSize = AppSizes.size18;
  static const double editorDialogSubmitIndicatorStrokeWidth = 2;
}

class FlashcardFlipStudyTokens {
  const FlashcardFlipStudyTokens._();

  static const double screenPadding = AppSizes.spacingMd;
  static const double topRowGap = AppSizes.spacingMd;
  static const double progressBarTopGap = AppSizes.spacingSm;
  static const double progressBarBottomGap = AppSizes.spacingLg;
  static const double progressBarHeight = AppSizes.spacing2Xs;
  static const double progressBarRadius = AppSizes.radiusPill;
  static const double scoreRowBottomGap = AppSizes.spacingLg;
  static const double scoreChipHeight = AppSizes.size48;
  static const double scoreChipMinWidth = AppSizes.size72;
  static const double scoreChipHorizontalPadding = AppSizes.spacingLg;
  static const double scoreChipBorderWidth = AppSizes.size2;
  static const double scoreChipTextOpacity = AppOpacities.soft35;
  static const double cardBorderWidth = AppSizes.size2;
  static const double cardContentHorizontalPadding = AppSizes.spacingLg;
  static const double cardContentTopPadding = AppSizes.spacingLg;
  static const double cardContentBottomPadding = AppSizes.spacingLg;
  static const double cardHeaderIconGap = AppSizes.spacingSm;
  static const double cardBodyTopGap = AppSizes.spacingLg;
  static const double cardBodyBottomGap = AppSizes.spacingLg;
  static const double bottomBarTopGap = AppSizes.spacingLg;
  static const double bottomBarBottomGap = AppSizes.spacingSm;
  static const double bottomBarHorizontalPadding = AppSizes.spacingSm;
  static const double centerTitleOpacity = AppOpacities.muted82;
  static const double scoreWrongOpacity = AppOpacities.soft35;
  static const double scoreCorrectOpacity = AppOpacities.soft35;
  static const double progressTrackOpacity = AppOpacities.soft20;
  static const double progressValueOpacity = AppOpacities.muted82;
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
