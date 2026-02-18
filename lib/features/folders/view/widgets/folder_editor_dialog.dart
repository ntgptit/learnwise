// quality-guard: allow-long-function - phase3 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../model/folder_constants.dart';
import '../../model/folder_models.dart';
import '../../viewmodel/folder_viewmodel.dart';
import '../validation/folder_form_schema.dart';
import 'folder_color_resolver.dart';

typedef FolderSubmitHandler =
    Future<FolderSubmitResult> Function(FolderUpsertInput input);

Future<bool> showFolderEditorDialog({
  required BuildContext context,
  required FolderItem? initialFolder,
  required FolderSubmitHandler onSubmit,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final FormGroup form = FolderFormSchema.build(initialFolder: initialFolder);
  final FormControl<String> nameControl = FolderFormSchema.resolveNameControl(
    form,
  );
  final FormControl<String> descriptionControl =
      FolderFormSchema.resolveDescriptionControl(form);
  final Map<String, ValidationMessageFunction> nameValidationMessages =
      <String, ValidationMessageFunction>{
        ValidationMessage.required: (_) => l10n.foldersNameRequiredValidation,
        ValidationMessage.pattern: (_) => l10n.foldersNameRequiredValidation,
        ValidationMessage.minLength: (_) =>
            l10n.foldersNameMinLengthValidation(FolderConstants.nameMinLength),
        ValidationMessage.maxLength: (_) =>
            l10n.foldersNameMaxLengthValidation(FolderConstants.nameMaxLength),
        FolderFormSchema.backendNameErrorKey: (Object error) {
          if (error is String) {
            return error;
          }
          return l10n.foldersNameRequiredValidation;
        },
      };
  final Map<String, ValidationMessageFunction> descriptionValidationMessages =
      <String, ValidationMessageFunction>{
        ValidationMessage.maxLength: (_) =>
            l10n.foldersDescriptionMaxLengthValidation(
              FolderConstants.descriptionMaxLength,
            ),
      };
  String selectedColorHex =
      initialFolder?.colorHex ?? FolderConstants.defaultColorHex;
  bool isSubmitting = false;

  final bool? isSubmitted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, void Function(void Function()) setDialogState) {
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
                initialFolder == null
                    ? l10n.foldersCreateDialogTitle
                    : l10n.foldersEditDialogTitle,
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
                          maxLength: FolderConstants.nameMaxLength,
                          onChanged: (_) {
                            FolderFormSchema.clearBackendNameError(form);
                          },
                          validationMessages: nameValidationMessages,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.foldersNameLabel,
                            hintText: l10n.foldersNameHint,
                          ),
                        ),
                        const SizedBox(
                          height: FolderScreenTokens.sectionSpacing,
                        ),
                        ReactiveTextField<String>(
                          formControl: descriptionControl,
                          maxLength: FolderConstants.descriptionMaxLength,
                          maxLines: FolderScreenTokens.descriptionMaxLines,
                          validationMessages: descriptionValidationMessages,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            labelText: l10n.foldersDescriptionLabel,
                            hintText: l10n.foldersDescriptionHint,
                          ),
                        ),
                        const SizedBox(
                          height: FolderScreenTokens.sectionSpacing,
                        ),
                        Text(
                          l10n.foldersColorLabel,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(
                          height: FolderScreenTokens.colorGridSpacing,
                        ),
                        Wrap(
                          spacing: FolderScreenTokens.colorGridSpacing,
                          runSpacing: FolderScreenTokens.colorGridSpacing,
                          children: FolderConstants.colorPresets.map((
                            colorHex,
                          ) {
                            final bool isSelected =
                                colorHex == selectedColorHex;
                            final Color color = resolveFolderColor(
                              colorHex,
                              Theme.of(context).colorScheme.primary,
                            );

                            return InkWell(
                              borderRadius: BorderRadius.circular(
                                FolderScreenTokens.colorBorderRadius,
                              ),
                              onTap: () {
                                setDialogState(() {
                                  selectedColorHex = colorHex;
                                });
                              },
                              child: Container(
                                width: FolderScreenTokens.colorItemSize,
                                height: FolderScreenTokens.colorItemSize,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(
                                    FolderScreenTokens.colorBorderRadius,
                                  ),
                                  border: Border.all(
                                    width:
                                        FolderScreenTokens.colorItemBorderWidth,
                                    color: isSelected
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
                  child: Text(l10n.foldersCancelLabel),
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
                          final FolderUpsertInput input =
                              FolderFormSchema.toUpsertInput(
                                form: form,
                                colorHex: selectedColorHex,
                                parentFolderId: initialFolder?.parentFolderId,
                              );
                          setDialogState(() {
                            isSubmitting = true;
                          });
                          FolderFormSchema.clearBackendNameError(form);
                          final FolderSubmitResult submitResult =
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
                            FolderFormSchema.setBackendNameError(
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
                          initialFolder == null
                              ? l10n.foldersSaveLabel
                              : l10n.foldersUpdateLabel,
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
