// quality-guard: allow-long-function - phase3 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../model/flashcard_constants.dart';
import '../../model/flashcard_models.dart';
import '../../model/language_models.dart';
import '../../viewmodel/flashcard_viewmodel.dart';
import '../validation/flashcard_form_schema.dart';

typedef FlashcardSubmitHandler =
    Future<FlashcardSubmitResult> Function(FlashcardUpsertInput input);

Future<bool> showFlashcardEditorDialog({
  required BuildContext context,
  required FlashcardItem? initialFlashcard,
  required FlashcardSubmitHandler onSubmit,
  required List<LanguageItem> languages,
  required String? termLangCode,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final FormGroup form = FlashcardFormSchema.build(
    initialFlashcard: initialFlashcard,
  );
  final FormControl<String> frontTextControl =
      FlashcardFormSchema.resolveFrontTextControl(form);
  final FormControl<String> backTextControl =
      FlashcardFormSchema.resolveBackTextControl(form);
  final FormControl<String?> frontLangControl =
      FlashcardFormSchema.resolveFrontLangCodeControl(form);
  final FormControl<String?> backLangControl =
      FlashcardFormSchema.resolveBackLangCodeControl(form);
  if (termLangCode != null) {
    frontLangControl.patchValue(termLangCode);
    frontLangControl.markAsDisabled();
  }
  final List<DropdownMenuItem<String?>> langItems = <DropdownMenuItem<String?>>[
    DropdownMenuItem<String?>(
      value: null,
      child: Text(l10n.flashcardsLangAutoDetect),
    ),
    for (final LanguageItem lang in languages)
      DropdownMenuItem<String?>(
        value: lang.code,
        child: Text('${lang.name} (${lang.nativeName})'),
      ),
  ];
  final Map<String, ValidationMessageFunction> frontValidationMessages =
      <String, ValidationMessageFunction>{
        ValidationMessage.required: (_) =>
            l10n.flashcardsFrontRequiredValidation,
        ValidationMessage.pattern: (_) =>
            l10n.flashcardsFrontRequiredValidation,
        ValidationMessage.minLength: (_) =>
            l10n.flashcardsFrontRequiredValidation,
        ValidationMessage.maxLength: (_) =>
            l10n.flashcardsFrontMaxLengthValidation(
              FlashcardConstants.frontTextMaxLength,
            ),
      };
  final Map<String, ValidationMessageFunction> backValidationMessages =
      <String, ValidationMessageFunction>{
        ValidationMessage.required: (_) =>
            l10n.flashcardsBackRequiredValidation,
        ValidationMessage.pattern: (_) => l10n.flashcardsBackRequiredValidation,
        ValidationMessage.minLength: (_) =>
            l10n.flashcardsBackRequiredValidation,
        ValidationMessage.maxLength: (_) =>
            l10n.flashcardsBackMaxLengthValidation(
              FlashcardConstants.backTextMaxLength,
            ),
      };
  bool isSubmitting = false;
  String? formErrorMessage;

  final bool? isSubmitted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, void Function(void Function()) setDialogState) {
          final double screenWidth = MediaQuery.sizeOf(context).width;
          final double preferredDialogWidth =
              screenWidth * FlashcardScreenTokens.editorDialogWidthFactor;
          final double dialogWidth = preferredDialogWidth
              .clamp(
                FlashcardScreenTokens.editorDialogMinWidth,
                FlashcardScreenTokens.editorDialogMaxWidth,
              )
              .toDouble();

          return PopScope(
            canPop: !isSubmitting,
            child: AlertDialog(
              title: Text(
                initialFlashcard == null
                    ? l10n.flashcardsCreateDialogTitle
                    : l10n.flashcardsEditDialogTitle,
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
                        if (formErrorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: FlashcardScreenTokens.sectionSpacing,
                            ),
                            child: Text(
                              formErrorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                        ReactiveTextField<String>(
                          formControl: frontTextControl,
                          maxLength: FlashcardConstants.frontTextMaxLength,
                          onChanged: (_) {
                            if (formErrorMessage == null) {
                              return;
                            }
                            setDialogState(() {
                              formErrorMessage = null;
                            });
                          },
                          validationMessages: frontValidationMessages,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.flashcardsFrontLabel,
                            hintText: l10n.flashcardsFrontHint,
                          ),
                        ),
                        const SizedBox(
                          height: FlashcardScreenTokens.sectionSpacing,
                        ),
                        ReactiveDropdownField<String?>(
                          formControl: frontLangControl,
                          decoration: InputDecoration(
                            labelText: l10n.flashcardsLangFrontLabel,
                          ),
                          items: langItems,
                        ),
                        const SizedBox(
                          height: FlashcardScreenTokens.sectionSpacing,
                        ),
                        ReactiveTextField<String>(
                          formControl: backTextControl,
                          maxLength: FlashcardConstants.backTextMaxLength,
                          maxLines: FlashcardScreenTokens.backTextMaxLines,
                          onChanged: (_) {
                            if (formErrorMessage == null) {
                              return;
                            }
                            setDialogState(() {
                              formErrorMessage = null;
                            });
                          },
                          validationMessages: backValidationMessages,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            labelText: l10n.flashcardsBackLabel,
                            hintText: l10n.flashcardsBackHint,
                          ),
                        ),
                        const SizedBox(
                          height: FlashcardScreenTokens.sectionSpacing,
                        ),
                        ReactiveDropdownField<String?>(
                          formControl: backLangControl,
                          decoration: InputDecoration(
                            labelText: l10n.flashcardsLangBackLabel,
                          ),
                          items: langItems,
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
                      : () => dialogContext.pop(false),
                  child: Text(l10n.flashcardsCancelLabel),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!form.valid) {
                            form.markAllAsTouched();
                            return;
                          }
                          final FlashcardUpsertInput input =
                              FlashcardFormSchema.toUpsertInput(form: form);
                          setDialogState(() {
                            isSubmitting = true;
                            formErrorMessage = null;
                          });
                          final FlashcardSubmitResult submitResult =
                              await onSubmit(input);
                          if (submitResult.isSuccess) {
                            // ignore: use_build_context_synchronously
                            dialogContext.pop(true);
                            return;
                          }
                          setDialogState(() {
                            isSubmitting = false;
                            formErrorMessage = submitResult.formErrorMessage;
                          });
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: FlashcardScreenTokens
                              .editorDialogSubmitIndicatorSize,
                          height: FlashcardScreenTokens
                              .editorDialogSubmitIndicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: FlashcardScreenTokens
                                .editorDialogSubmitIndicatorStrokeWidth,
                          ),
                        )
                      : Text(
                          initialFlashcard == null
                              ? l10n.flashcardsSaveLabel
                              : l10n.flashcardsUpdateLabel,
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
