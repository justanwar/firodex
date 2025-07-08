import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/shared/constants.dart';

/// A data type holding user feedback consisting of a feedback type and free-form text
class CustomFeedback {
  CustomFeedback({
    this.feedbackType,
    this.feedbackText,
    this.contactMethod,
    this.contactDetails,
  });

  FeedbackType? feedbackType;
  String? feedbackText;
  ContactMethod? contactMethod;
  String? contactDetails;

  @override
  String toString() {
    return {
      'feedback_type': feedbackType.toString(),
      'feedback_text': feedbackText,
      'contact_method': contactMethod?.name,
      'contact_details': contactDetails,
    }.toString();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'feedback_type': feedbackType.toString(),
      'feedback_text': feedbackText,
      'contact_method': contactMethod?.name,
      'contact_details': contactDetails,
    };
  }

  /// Creates a properly formatted description for agent review
  String toFormattedDescription() {
    final buffer = StringBuffer();
    
    // Header with feedback type
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('📋 ${feedbackType?.description ?? 'Unknown'}'.toUpperCase());
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln();
    
    // User feedback content
    buffer.writeln('💬 USER FEEDBACK:');
    buffer.writeln('─' * 40);
    if (feedbackText?.trim().isNotEmpty == true) {
      // Split into paragraphs and format nicely
      final paragraphs = feedbackText!.trim().split('\n');
      for (int i = 0; i < paragraphs.length; i++) {
        final paragraph = paragraphs[i].trim();
        if (paragraph.isNotEmpty) {
          buffer.writeln('   $paragraph');
          if (i < paragraphs.length - 1) buffer.writeln();
        }
      }
    } else {
      buffer.writeln('   [No feedback text provided]');
    }
    buffer.writeln();
    
    // Contact information section
    buffer.writeln('📞 CONTACT INFORMATION:');
    buffer.writeln('─' * 40);
    if (contactMethod != null && contactDetails?.trim().isNotEmpty == true) {
      final contact = contactDetails!.trim();
      
      switch (contactMethod!) {
        case ContactMethod.email:
          buffer.writeln('   📧 Email: $contact');
          break;
        case ContactMethod.discord:
          buffer.writeln('   🎮 Discord: $contact');
          break;
        case ContactMethod.telegram:
          buffer.writeln('   📱 Telegram: ${contact.startsWith('@') ? contact : '@$contact'}');
          break;
        case ContactMethod.matrix:
          buffer.writeln('   🔗 Matrix: $contact');
          break;
      }
      
      // Add priority indicator for support requests
      if (feedbackType == FeedbackType.support) {
        buffer.writeln('   ⚠️  PRIORITY: Contact details provided for support request');
      }
    } else {
      buffer.writeln('   ❌ No contact information provided');
      if (feedbackType == FeedbackType.support) {
        buffer.writeln('   ⚠️  WARNING: Support request without contact details!');
      }
    }
    
    return buffer.toString();
  }
}

/// What type of feedback the user wants to provide.
enum FeedbackType {
  bugReport,
  featureRequest,
  support,
  other;

  // TODO: Localisation
  String get description {
    switch (this) {
      case bugReport:
        return 'Bug Report';
      case featureRequest:
        return 'Feature Request';
      case support:
        return 'Support Request';
      case other:
        return 'Other';
    }
  }
}

/// A form that prompts the user for the type of feedback they want to give and free form text feedback.
/// The submit button is disabled until the user provides the feedback type. All other fields are optional.
class CustomFeedbackForm extends StatefulWidget {
  const CustomFeedbackForm({
    super.key,
    required this.onSubmit,
    required this.scrollController,
  });

  final OnSubmit onSubmit;
  final ScrollController? scrollController;

  static FeedbackBuilder get feedbackBuilder =>
      (context, onSubmit, scrollController) => CustomFeedbackForm(
            onSubmit: onSubmit,
            scrollController: scrollController,
          );

  @override
  State<CustomFeedbackForm> createState() => _CustomFeedbackFormState();
}

// TODO: Refactor into a bloc and show validation errors.
class _CustomFeedbackFormState extends State<CustomFeedbackForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CustomFeedback _customFeedback = CustomFeedback();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  /// Validates feedback text
  String? _validateFeedbackText(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return LocaleKeys.feedbackValidatorEmptyError.tr();
    }
    if (trimmedValue.length > feedbackMaxLength) {
      return LocaleKeys.feedbackValidatorMaxLengthError.tr(
        args: [feedbackMaxLength.toString()],
      );
    }
    return null;
  }

  /// Validates contact details based on selected method
  String? _validateContactDetails(String? value) {
    final trimmedValue = value?.trim() ?? '';
    final hasContactMethod = _customFeedback.contactMethod != null;
    final hasContactDetails = trimmedValue.isNotEmpty;

    // For support requests, contact details are required
    if (_customFeedback.feedbackType == FeedbackType.support) {
      if (!hasContactMethod || !hasContactDetails) {
        return LocaleKeys.contactRequiredError.tr();
      }
    } else {
      // For other types, if one is provided, both must be provided
      if ((hasContactMethod && !hasContactDetails) ||
          (!hasContactMethod && hasContactDetails)) {
        return LocaleKeys.contactRequiredError.tr();
      }
    }

    // If no contact details provided, validation passes
    if (!hasContactDetails) {
      return null;
    }

    // Check maximum length
    if (trimmedValue.length > contactDetailsMaxLength) {
      return 'Contact details must be ${contactDetailsMaxLength} characters or less';
    }

    // Validate based on contact method
    if (_customFeedback.contactMethod != null) {
      switch (_customFeedback.contactMethod!) {
        case ContactMethod.email:
          if (!_isValidEmail(trimmedValue)) {
            return LocaleKeys.emailValidatorError.tr();
          }
          break;
        case ContactMethod.discord:
          if (!_isValidDiscordUsername(trimmedValue)) {
            return 'Please enter a valid Discord username (2-32 characters, letters, numbers, dots, underscores)';
          }
          break;
        case ContactMethod.telegram:
          if (!_isValidTelegramUsername(trimmedValue)) {
            return 'Please enter a valid Telegram username (5-32 characters, letters, numbers, underscores)';
          }
          break;
        case ContactMethod.matrix:
          if (!_isValidMatrixId(trimmedValue)) {
            return 'Please enter a valid Matrix ID (e.g., @username:server.com)';
          }
          break;
      }
    }

    return null;
  }

  /// Sanitizes input text by removing potentially harmful content
  String _sanitizeInput(String input) {
    return input
        .trim()
        // Remove HTML tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Remove script content
        .replaceAll(
            RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
                caseSensitive: false),
            '')
        // Remove javascript: protocols
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        // Remove data: protocols that could contain scripts
        .replaceAll(RegExp(r'data:[^,]*script[^,]*,', caseSensitive: false), '')
        // Limit line breaks to prevent excessive formatting
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  /// Determines if the feedback form is valid and can be submitted
  bool isFormValid() {
    // Use form validation instead of manual checks
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formValid = _customFeedback.feedbackType != null && !_isLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (widget.scrollController != null)
                  const FeedbackSheetDragHandle(),
                ListView(
                  controller: widget.scrollController,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    widget.scrollController != null ? 20 : 16,
                    16,
                    0,
                  ),
                  children: [
                    Text(
                      'What kind of feedback do you want to give?',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<FeedbackType>(
                      isExpanded: true,
                      value: _customFeedback.feedbackType,
                      items: FeedbackType.values
                          .map(
                            (type) => DropdownMenuItem<FeedbackType>(
                              value: type,

                              // TODO: l10n
                              child: Text(type.description),
                            ),
                          )
                          .toList(),
                      onChanged: _isLoading
                          ? null
                          : (feedbackType) => setState(
                                () =>
                                    _customFeedback.feedbackType = feedbackType,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please describe your feedback:',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    UiTextFormField(
                      controller: _feedbackController,
                      maxLines: 3,
                      maxLength: feedbackMaxLength,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      enabled: !_isLoading,
                      hintText: 'Enter your feedback here...',
                      validator: _validateFeedbackText,
                      validationMode: InputValidationMode.eager,
                      onChanged: (value) {
                        _customFeedback.feedbackText =
                            _sanitizeInput(value ?? '');
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _customFeedback.feedbackType == FeedbackType.support
                          ? "How can we contact you?"
                          : "How can we contact you? (Optional)",
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 130,
                          child: DropdownButtonFormField<ContactMethod>(
                            isExpanded: true,
                            value: _customFeedback.contactMethod,
                            hint: const Text('Select'),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: ContactMethod.values
                                .map(
                                  (method) => DropdownMenuItem<ContactMethod>(
                                    value: method,
                                    child: Text(method.label),
                                  ),
                                )
                                .toList(),
                            onChanged: _isLoading
                                ? null
                                : (contactMethod) {
                                    setState(() {
                                      _customFeedback.contactMethod =
                                          contactMethod;
                                    });
                                    // Revalidate contact details when method changes
                                    _formKey.currentState?.validate();
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: UiTextFormField(
                            controller: _contactController,
                            enabled: !_isLoading,
                            maxLength: contactDetailsMaxLength,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            hintText: _getContactHint(
                              _customFeedback.contactMethod,
                            ),
                            validator: _validateContactDetails,
                            validationMode: InputValidationMode.eager,
                            onChanged: (value) {
                              _customFeedback.contactDetails =
                                  _sanitizeInput(value ?? '');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: formValid ? () => _submitFeedback() : null,
                  child: const Text('SUBMIT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitFeedback() {
    // Validate the form first
    if (!isFormValid()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Ensure we're using sanitized data for submission
    final sanitizedFeedback =
        _sanitizeInput(_customFeedback.feedbackText ?? '');
    final sanitizedContactDetails = _customFeedback.contactDetails != null
        ? _sanitizeInput(_customFeedback.contactDetails!)
        : null;

    final submissionData = CustomFeedback(
      feedbackType: _customFeedback.feedbackType,
      feedbackText: sanitizedFeedback,
      contactMethod: _customFeedback.contactMethod,
      contactDetails: sanitizedContactDetails,
    );    // Call the onSubmit callback provided by BetterFeedback
    widget
        .onSubmit(
          submissionData.toFormattedDescription(),
          extras: submissionData.toMap(),
        )
        .then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
  }

  bool _isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  bool _isValidDiscordUsername(String username) {
    return discordUsernameRegex.hasMatch(username);
  }

  bool _isValidTelegramUsername(String username) {
    // Remove @ prefix if present
    final cleanUsername =
        username.startsWith('@') ? username.substring(1) : username;
    return telegramUsernameRegex.hasMatch(cleanUsername);
  }

  bool _isValidMatrixId(String matrixId) {
    return matrixIdRegex.hasMatch(matrixId);
  }

  String _getContactHint(ContactMethod? method) {
    switch (method) {
      case ContactMethod.discord:
        return 'Discord username (e.g., username123)';
      case ContactMethod.matrix:
        return 'Matrix ID (e.g., @user:matrix.org)';
      case ContactMethod.telegram:
        return 'Telegram username (e.g., @username)';
      case ContactMethod.email:
        return 'Your email address';
      default:
        return 'Enter your contact details';
    }
  }
}

/// Contact methods available for feedback follow-up
enum ContactMethod {
  discord,
  matrix,
  telegram,
  email;

  String get label {
    switch (this) {
      case discord:
        return 'Discord';
      case matrix:
        return 'Matrix';
      case telegram:
        return 'Telegram';
      case email:
        return 'Email';
    }
  }
}
