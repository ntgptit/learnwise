import 'package:flutter/material.dart';

import 'app_sizes.dart';

/// Screen-level layout tokens (structure only).
///
/// Rules:
/// - Declaration:
///   - Keep `static const` tokens grouped by screen/module.
///   - Prefer reuse from `BaseScreenTokens`, `BaseCardTokens`, `BaseListTokens`.
/// - Value setting:
///   - Screen tokens are for spacing/radius/size/layout constraints only.
///   - Do not define per-screen typography/opacity/duration/elevation tokens.
/// - Data flow:
///   - Screen tokens are read-only constants and must not carry runtime state.
///   - Runtime UI decisions belong to widgets/viewmodels, not token layer.
/// - Material 3 constraints:
///   - Typography comes from `Theme.of(context).textTheme`.
///   - Color comes from `Theme.of(context).colorScheme` (with shared
///     `AppOpacities` when alpha is needed).
///   - Motion comes from `AppDurations`/`AppMotionCurves`.
///   - Elevation follows Theme/AppCard defaults.
/// - Value source:
///   - Aggregated from approved design values and normalized into AppSizes
///     scales; avoid introducing new magic numbers without design rationale.
class BaseScreenTokens {
  const BaseScreenTokens._();

  static const double screenPadding = AppSizes.spacingMd;
  static const double sectionSpacing = AppSizes.spacingMd;
  static const double sectionSpacingLarge = AppSizes.spacingLg;
}

class BaseCardTokens {
  const BaseCardTokens._();

  static const double spacingSm = AppSizes.spacingSm;
  static const double spacingMd = AppSizes.spacingMd;
  static const double paddingMd = AppSizes.spacingMd;
  static const double paddingLg = AppSizes.spacingLg;
  static const double radiusMd = AppSizes.radiusMd;
  static const double radiusLg = AppSizes.radiusLg;
  static const double radiusXl = AppSizes.size20;
  static const double radius2Xl = AppSizes.size28;
}

class BaseListTokens {
  const BaseListTokens._();

  static const double itemGapXs = AppSizes.spacingXs;
  static const double itemGapSm = AppSizes.spacingSm;
  static const double itemMetaGap = AppSizes.spacing2Xs;
}

class DashboardScreenTokens {
  const DashboardScreenTokens._();

  static const double headerBorderRadius = AppSizes.size36;
  static const double metricCardRadius = AppSizes.size24;
  static const double sectionSpacing = BaseScreenTokens.sectionSpacingLarge;
  static const double headerPadding = AppSizes.spacingLg;
  static const double contentPadding = BaseScreenTokens.screenPadding;
  static const double metricGridSpacing = BaseListTokens.itemGapSm;
  static const double quickActionSpacing = BaseListTokens.itemGapSm;
  static const double focusCardHeight = 132;
  static const double metricCardMinHeight = 106;
  static const double recentCardPadding = BaseCardTokens.spacingSm;

  static const double heroGapSmall = AppSizes.spacingXs;
  static const double heroGapLarge = AppSizes.spacingMd;
  static const double heroChipPadding = BaseCardTokens.spacingSm;
  static const double heroChipRadius = AppSizes.radiusLg;
  static const double heroChipSpacing = AppSizes.spacingXs;
  static const double heroIconSize = AppSizes.size56;
  static const double heroIconContainerSize = AppSizes.size72;
  static const double heroShadowBlur = AppSizes.size24;
  static const double heroShadowOffsetY = AppSizes.size8;
  static const double heroIconShadowBlur = AppSizes.size16;
  static const double heroIconShadowOffsetY = AppSizes.size4;

  static const double sectionTitleGap = BaseCardTokens.spacingSm;
  static const double metricColumns = 2;
  static const double metricCardPadding = BaseCardTokens.spacingSm;
  static const double metricIconSize = AppSizes.size16;
  static const double metricIconGap = AppSizes.spacingXs;
  static const double metricBodyGap = BaseListTokens.itemGapSm;
  static const double metricBodyGapSmall = BaseListTokens.itemMetaGap;
  static const double metricProgressHeight = AppSizes.size8;

  static const double focusCardPadding = BaseCardTokens.paddingMd;
  static const double focusIconSize = 34;
  static const double focusIconGap = BaseListTokens.itemGapSm;
  static const double focusTextGap = AppSizes.spacingXs;

  static const double recentItemGap = BaseListTokens.itemGapSm;
  static const double recentCardRadius = AppSizes.radiusLg;
  static const double recentProgressGap = AppSizes.spacingXs;
}

class FolderScreenTokens {
  const FolderScreenTokens._();

  static const double screenPadding = BaseScreenTokens.screenPadding;
  static const double sectionSpacing = BaseScreenTokens.sectionSpacing;
  static const double heroRadius = 24;
  static const double heroPadding = 20;
  static const double cardRadius = BaseCardTokens.radiusXl;
  static const double cardPadding = BaseCardTokens.paddingMd;
  static const double cardSpacing = BaseListTokens.itemGapSm;
  static const double colorDotSize = BaseListTokens.itemGapSm;
  static const double colorItemSize = 34;
  static const double colorItemBorderWidth = 2;
  static const double breadcrumbSpacing = AppSizes.spacingXs;

  static const int descriptionMaxLines = 3;
  static const double heroTextGap = AppSizes.spacingXs;
  static const double colorDotTopMargin = AppSizes.spacing2Xs;
  static const double colorDotRadius = AppSizes.radiusPill;
  static const double cardHorizontalGap = BaseListTokens.itemGapSm;
  static const double cardMetaGap = BaseListTokens.itemMetaGap;
  static const double colorGridSpacing = AppSizes.spacingXs;
  static const double colorBorderRadius = AppSizes.radiusMd;
  static const double folderHeaderIconContainerSize = AppSizes.size72;
  static const double folderHeaderIconContainerRadius = AppSizes.radiusMd;
  static const double folderHeaderIconSize = AppSizes.size34;
  static const double folderHeaderTitleTopGap = BaseListTokens.itemGapSm;
  static const double primaryActionGap = BaseListTokens.itemGapSm;
  static const double sortLabelIconGap = BaseListTokens.itemMetaGap;
  static const double searchFieldHorizontalPadding = AppSizes.spacingXs;
  static const double listItemHorizontalPadding = BaseListTokens.itemGapSm;
  static const double listItemVerticalPadding = BaseListTokens.itemGapSm;
  static const double listItemLeadingSize = AppSizes.size40;
  static const double listItemLeadingRadius = AppSizes.radiusMd;
  static const double listItemLeadingIconSize = AppSizes.size22;
  static const double listItemHorizontalGap = BaseListTokens.itemGapSm;
  static const double listItemTitleMetaGap = BaseListTokens.itemMetaGap;
  static const int nameMaxLines = 1;
  static const double editorDialogWidthFactor = 0.92;
  static const double editorDialogMinWidth = 320;
  static const double editorDialogMaxWidth = 520;
  static const double editorDialogSubmitIndicatorSize = AppSizes.size18;
  static const double editorDialogSubmitIndicatorStrokeWidth = 2;
  static const double loadingOverlayEdgeInset = 0;
}

class FlashcardScreenTokens {
  const FlashcardScreenTokens._();

  static const double screenPadding = BaseScreenTokens.screenPadding;
  static const double toolbarHeight = AppSizes.size72;
  static const double sectionSpacing = BaseScreenTokens.sectionSpacing;
  static const double sectionSpacingLarge =
      BaseScreenTokens.sectionSpacingLarge;
  static const double sectionHeaderBottomGap = BaseCardTokens.paddingMd;
  static const double sectionHeaderActionGap = BaseListTokens.itemGapSm;
  static const double sectionHeaderSubtitleGap = BaseListTokens.itemMetaGap;

  static const double heroCardHeight = AppSizes.size240;
  static const double heroCardRadius = BaseCardTokens.radiusLg;
  static const double heroCardPadding = BaseCardTokens.paddingLg;
  static const double heroCardItemSpacing = AppSizes.spacingXs;
  static const double heroViewportFraction = 0.94;
  static const double heroPagerGap = BaseListTokens.itemGapSm;
  static const double heroDotSize = AppSizes.size6;
  static const double heroDotSpacing = BaseListTokens.itemMetaGap;
  static const double heroExpandButtonInset = BaseListTokens.itemGapSm;
  static const int heroMaxIndicatorDots = 7;

  static const double metadataAvatarSize = AppSizes.size34;
  static const double metadataGap = BaseListTokens.itemGapSm;
  static const double metadataHorizontalGap = AppSizes.spacingXs;
  static const double metadataTitleBottomGap = AppSizes.spacingXs;
  static const double metadataOwnerCardRadius = BaseCardTokens.radiusMd;
  static const double metadataOwnerCardHorizontalPadding =
      BaseListTokens.itemGapSm;
  static const double metadataOwnerCardVerticalPadding = AppSizes.spacingXs;
  static const double metadataOwnerCardShadowBlur = BaseListTokens.itemGapSm;
  static const double metadataOwnerCardShadowOffsetY = 4;
  static const double metadataAvatarHaloPadding = BaseListTokens.itemMetaGap;
  static const double metadataOwnerNameMaxWidth = 180;
  static const double metadataCountChipRadius = AppSizes.radiusPill;
  static const double metadataCountChipHorizontalPadding =
      BaseListTokens.itemGapSm;
  static const double metadataCountChipVerticalPadding = AppSizes.spacingXs;
  static const double metadataCountChipIconSize = AppSizes.size14;
  static const double metadataCountChipIconGap = BaseListTokens.itemMetaGap;

  static const double bannerHeight = AppSizes.size40;
  static const double bannerRadius = AppSizes.radiusSm;
  static const double bannerInnerGap = AppSizes.spacingXs;

  static const double actionTileSpacing = BaseListTokens.itemGapSm;
  static const double cardSpacing = BaseCardTokens.spacingMd;
  static const double cardPadding = BaseCardTokens.paddingMd;
  static const double cardRadius = BaseCardTokens.radiusXl;
  static const double cardHeaderGap = BaseListTokens.itemGapSm;
  static const double cardHeaderIconGap = AppSizes.spacingXs;
  static const double cardTextGap = BaseListTokens.itemGapSm;
  static const double cardPrimarySecondaryGap = BaseListTokens.itemMetaGap;
  static const int cardDescriptionMaxLines = 2;
  static const int cardSecondaryMaxLines = 3;
  static const double cardActionIconSize = AppSizes.size20;
  static const double cardActionTapTargetSize = AppSizes.size40;
  static const double cardActionIconSpacing = BaseListTokens.itemGapSm;
  static const double cardPressedScale = 1.01;
  static const int loadingSkeletonCount = 3;
  static const int loadingMoreSkeletonCount = 2;
  static const double skeletonLinePrimaryWidthFactor = 0.68;
  static const double skeletonLineSecondaryWidthFactor = 0.52;
  static const double skeletonLineDescriptionWidthFactor = 0.84;
  static const double skeletonLinePrimaryHeight = AppSizes.size20;
  static const double skeletonLineSecondaryHeight = AppSizes.size14;
  static const double skeletonLineDescriptionHeight = AppSizes.size14;
  static const double skeletonLineGap = BaseListTokens.itemMetaGap;
  static const double skeletonActionDotSize = AppSizes.size20;
  static const double skeletonActionDotRadius = AppSizes.radiusPill;
  static const int skeletonActionCount = 4;
  static const double overlayEdgeInset = 0;

  static const double bottomCtaTopSpacing = BaseScreenTokens.sectionSpacing;
  static const double bottomCtaHeight = AppSizes.size48;
  static const double bottomCtaRadius = AppSizes.radiusPill;
  static const double bottomListPadding = AppSizes.size72;

  static const double listMetadataGap = BaseListTokens.itemMetaGap;
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

  static const double screenPadding = BaseScreenTokens.screenPadding;
  static const double topIconSize = AppSizes.size24;
  static const double topIconTapTargetSize = AppSizes.size48;
  static const double topRowGap = BaseScreenTokens.sectionSpacing;
  static const double progressBarTopGap = AppSizes.spacingLg;
  static const double progressBarBottomGap = AppSizes.spacingLg;
  static const double progressBarHeight = AppSizes.spacing2Xs;
  static const double progressBarRadius = AppSizes.radiusPill;

  static const double cardOuterVerticalInset = AppSizes.size32;
  static const double cardRadius = BaseCardTokens.radius2Xl;
  static const double cardContentHorizontalPadding = AppSizes.spacingLg;
  static const double cardContentTopPadding = AppSizes.spacingLg;
  static const double cardContentBottomPadding = AppSizes.spacingLg;
  static const double cardActionIconSize = AppSizes.size24;
  static const double cardActionTapTargetSize = AppSizes.size48;
  static const double cardActionSpacing = BaseListTokens.itemGapSm;
  static const double cardBodyTopGap = AppSizes.spacingLg;
  static const double cardBodyBottomGap = AppSizes.spacingLg;
  static const int backPrimaryMaxLines = 6;
  static const int backDescriptionMaxLines = 4;
  static const double bottomBarTopGap = AppSizes.size32;
  static const double bottomBarBottomGap = AppSizes.spacingLg;
  static const double bottomBarHorizontalPadding = AppSizes.spacingLg;
  static const double bottomBarIconSize = AppSizes.size28;
  static const double bottomBarTapTargetSize = AppSizes.size48;
}

class FlashcardStudySessionTokens {
  const FlashcardStudySessionTokens._();

  static const double screenPadding = BaseScreenTokens.screenPadding;
  static const double sectionSpacing = BaseScreenTokens.sectionSpacing;
  static const double cardRadius = BaseCardTokens.radius2Xl;
  static const double cardPadding = BaseCardTokens.paddingLg;
  static const double answerSpacing = BaseListTokens.itemGapSm;
  static const double fillProgressToModeGap = AppSizes.spacing2Xs;
  static const double fillHeaderToContentGap = AppSizes.spacingXmd;
  static const double completedActionButtonWidth = AppSizes.size240;
  static const double progressHeight = AppSizes.size2;
  static const double progressRadius = AppSizes.radiusPill;
  static const double bottomActionGap = BaseListTokens.itemGapSm;
  static const double iconSize = AppSizes.size24;
  static const double modeTileGap = AppSizes.spacing2Xs;
  static const double reviewCardMinHeight = AppSizes.size240;
  static const double reviewAppBarIconTapTarget = AppSizes.size48;
  static const double reviewCardActionTopGap = BaseListTokens.itemGapSm;
  static const double reviewBodyBottomGap = AppSizes.spacingLg;
  static const double reviewPageViewportFraction = 0.94;
  static const double reviewPageHorizontalGap = AppSizes.spacingXs;
  static const double matchRowSpacing = AppSizes.spacingXs;
  static const double matchCardRadius = BaseCardTokens.radiusMd;
  static const double matchCardPadding = BaseListTokens.itemGapSm;
  static const double matchCardMinHeight = AppSizes.size72;
  static const double matchRowHeightBase = AppSizes.size72;
  static const double matchRowHeight = AppSizes.size144;
  static const int matchVisiblePairCount = 5;
  static const double matchSuccessBorderWidth = AppSizes.size2;
  static const int guessOptionCount = 5;
  static const int guessPromptMaxLines = 5;
  static const int guessOptionMaxLines = 2;
  static const int guessPromptFlex = 32;
  static const int guessOptionsFlex = 68;
  static const double guessPromptHorizontalPadding = BaseListTokens.itemGapSm;
  static const double guessOptionVerticalPadding = AppSizes.spacingXs;
  static const double guessPromptActionOuterPadding = AppSizes.spacing2Xs;
  static const double guessPromptActionInnerPadding = AppSizes.spacing2Xs;
  static const double guessPromptActionRadius = AppSizes.radiusPill;
  static const double cycleProgressItemHeight = AppSizes.size32;
  static const double cycleProgressItemGap = AppSizes.spacingXs;
  static const double cycleProgressItemRadius = AppSizes.radiusPill;
  static const double cycleProgressIconSize = AppSizes.size16;
  static const double cycleProgressStatusIconSize = AppSizes.size8;
  static const int matchPromptMaxLines = 5;
  static const int matchAnswerMaxLines = 3;
  static const int matchSemanticsMaxLength = 90;
  static const int recallPromptFlex = 1;
  static const int recallAnswerFlex = 1;
  static const int recallPromptMaxLines = 7;
  static const int recallAnswerMaxLines = 6;
  static const double recallCardGap = BaseListTokens.itemGapSm;
  static const double recallButtonHeight = AppSizes.size52;
  static const double recallButtonWidthFactor = 0.68;
  static const double recallActionButtonsWidthFactor = 0.84;
  static const double recallActionButtonsGap = BaseListTokens.itemGapSm;
  static const double recallButtonBottomGap = AppSizes.spacingXs;
  static const int fillPromptFlex = 54;
  static const int fillAnswerFlex = 42;
  static const int fillPromptFlexWhenKeyboardVisible = 56;
  static const int fillAnswerFlexWhenKeyboardVisible = 40;
  static const int fillPromptMaxLines = 6;
  static const int fillInputMaxLines = 1;
  static const double fillCardGap = AppSizes.spacingMd;
  static const double fillCardGapWhenKeyboardVisible = BaseListTokens.itemGapSm;
  static const double fillPromptIconSize = AppSizes.size20;
  static const double fillInputWidthFactor = 0.92;
  static const double fillInputMinHeight = AppSizes.size56;
  static const double fillActionButtonHeight = AppSizes.size56;
  static const double fillActionButtonRadius = AppSizes.radiusPill;
  static const double fillActionTopGap = AppSizes.spacingXmd;
  static const double fillActionBottomPadding = AppSizes.spacingXs;
}

class TtsScreenTokens {
  const TtsScreenTokens._();

  static const EdgeInsets screenPadding = EdgeInsets.all(
    BaseScreenTokens.screenPadding,
  );
  static const double sectionSpacing = BaseListTokens.itemGapSm;
  static const double subsectionSpacing = AppSizes.spacingXs;
  static const double actionSpacing = BaseScreenTokens.sectionSpacing;

  static const int inputMinLines = 4;
  static const int inputMaxLines = 8;
  static const double sliderLabelWidth = 72;
  static const double sliderValueWidth = 40;

  static const OutlineInputBorder formBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
  );
}
