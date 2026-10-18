import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable form text field for WeTravel authentication screens.
class AuthTextField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final bool isOptional;
  final String? hintText;
  final String? hint;
  final String? helperText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.isOptional = false,
    this.hintText,
    this.hint,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.autovalidateMode,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Field Label with Visual Indicator for Mandatory or Optional
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: AppTypography.labelMedium(
                  color: AppColors.errorRed,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
            if (isOptional) ...[
              const SizedBox(width: 6),
              Text(
                '(optional)',
                style: AppTypography.bodySmall(
                  color: AppColors.textMuted,
                ).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: AppSpacing.xs + 2),

        // Text Form Field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autovalidateMode: autovalidateMode,
          validator: validator,
          autofillHints: autofillHints,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          enabled: enabled,
          style: AppTypography.bodyMedium(
            color: enabled ? AppColors.textPrimary : AppColors.textMuted,
          ).copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? hint,
            hintStyle: AppTypography.bodyMedium(
              color: AppColors.textMuted,
            ).copyWith(fontSize: 14),
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: AppTypography.bodySmall(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 11.5),
            errorStyle: AppTypography.bodySmall(
              color: AppColors.errorRed,
            ).copyWith(fontSize: 12),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 15.0,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(
                color: AppColors.borderWarm,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(
                color: AppColors.borderWarm,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(
                color: AppColors.primaryDeepTeal,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
