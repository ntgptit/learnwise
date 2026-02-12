import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../model/deck_constants.dart';
import '../../model/deck_models.dart';
import '../../viewmodel/deck_viewmodel.dart';
import '../validation/deck_form_schema.dart';

typedef DeckSubmitHandler =
    Future<DeckSubmitResult> Function(DeckUpsertInput input);

Future<bool> showDeckEditorDialog({
  required BuildContext context,
  required DeckItem? initialDeck,
  required DeckSubmitHandler onSubmit,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final FormGroup form = DeckFormSchema.build(initialDeck: initialDeck);
  final FormControl<String> nameControl = DeckFormSchema.resolveNameControl(
    form,
  );
  final FormControl<String> descriptionControl =
      DeckFormSchema.resolveDescriptionControl(form);
  final Map<String, ValidationMessageFunction> nameValidationMessages =
      <String, ValidationMessageFunction>{
        ValidationMessage.required: (_) => l10n.decksNameRequiredValidation,
        ValidationMessage.pattern: (_) => l10n.decksNameRequiredValidation,
        ValidationMessage.minLength: (_) =>
            l10n.decksNameMinLengthValidation(DeckConstants.nameMinLength),
        ValidationMessage.maxLength: (_) =>
            l10n.decksNameMaxLengthValidation(DeckConstants.nameMaxLength),
        DeckFormSchema.backendNameErrorKey: (Object error) {
          if (error is String) {
            return error;
          }
          return l10n.decksNameRequiredValidation;
        },
      };
  final Map<String, ValidationMessageFunction> descriptionValidationMessages =
      <String, ValidationMessageFunction>{
        ValidationMessage.maxLength: (_) =>
            l10n.decksDescriptionMaxLengthValidation(
              DeckConstants.descriptionMaxLength,
            ),
      };
  bool isSubmitting = false;

  final bool? isSubmitted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder:
            (
              BuildContext context,
              void Function(void Function()) setDialogState,
            ) {
              final double screenWidth = MediaQuery.sizeOf(context).width;
              final double preferredDialogWidth =
                  screenWidth * FolderScreenTokens.editorDialogWidthFactor;
              final double dialogWidth = preferredDialogWidth.clamp(
                FolderScreenTokens.editorDialogMinWidth,
                FolderScreenTokens.editorDialogMaxWidth,
              );

              return PopScope(
                canPop: !isSubmitting,
                child: AlertDialog(
                  title: Text(
                    initialDeck == null
                        ? l10n.decksCreateDialogTitle
                        : l10n.decksEditDialogTitle,
                  ),
                  content: SizedBox(
                    width: dialogWidth,
                    child: SingleChildScrollView(
                      child: ReactiveForm(
                        formGroup: form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ReactiveTextField<String>(
                              formControl: nameControl,
                              maxLength: DeckConstants.nameMaxLength,
                              onChanged: (_) {
                                DeckFormSchema.clearBackendNameError(form);
                              },
                              validationMessages: nameValidationMessages,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.decksNameLabel,
                                hintText: l10n.decksNameHint,
                              ),
                            ),
                            const SizedBox(
                              height: FolderScreenTokens.sectionSpacing,
                            ),
                            ReactiveTextField<String>(
                              formControl: descriptionControl,
                              maxLength: DeckConstants.descriptionMaxLength,
                              maxLines: FolderScreenTokens.descriptionMaxLines,
                              validationMessages: descriptionValidationMessages,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                labelText: l10n.decksDescriptionLabel,
                                hintText: l10n.decksDescriptionHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(dialogContext).pop(false),
                      child: Text(l10n.decksCancelLabel),
                    ),
                    FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final NavigatorState navigator = Navigator.of(
                                dialogContext,
                              );
                              final bool isFormValid = form.valid;
                              if (!isFormValid) {
                                form.markAllAsTouched();
                                return;
                              }
                              final DeckUpsertInput input =
                                  DeckFormSchema.toUpsertInput(form: form);
                              setDialogState(() {
                                isSubmitting = true;
                              });
                              DeckFormSchema.clearBackendNameError(form);
                              final DeckSubmitResult submitResult =
                                  await onSubmit(input);
                              if (submitResult.isSuccess) {
                                navigator.pop(true);
                                return;
                              }
                              setDialogState(() {
                                isSubmitting = false;
                              });
                              final String? nameErrorMessage =
                                  submitResult.nameErrorMessage;
                              if (nameErrorMessage == null) {
                                return;
                              }
                              setDialogState(() {
                                DeckFormSchema.setBackendNameError(
                                  form: form,
                                  message: nameErrorMessage,
                                );
                              });
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: FolderScreenTokens
                                  .editorDialogSubmitIndicatorSize,
                              height: FolderScreenTokens
                                  .editorDialogSubmitIndicatorSize,
                              child: CircularProgressIndicator(
                                strokeWidth: FolderScreenTokens
                                    .editorDialogSubmitIndicatorStrokeWidth,
                              ),
                            )
                          : Text(
                              initialDeck == null
                                  ? l10n.decksSaveLabel
                                  : l10n.decksUpdateLabel,
                            ),
                    ),
                  ],
                ),
              );
            },
      );
    },
  );
  form.dispose();
  if (isSubmitted != true) {
    return false;
  }
  return true;
}
