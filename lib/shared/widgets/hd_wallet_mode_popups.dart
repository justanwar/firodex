import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/analytics/analytics_bloc.dart';
import 'package:web_dex/bloc/analytics/analytics_repo.dart';
import 'package:web_dex/bloc/hd_wallet_dialog/hd_wallet_dialog.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/dispatchers/popup_dispatcher.dart';

class HdLegacyOfferPopup extends StatelessWidget {
  const HdLegacyOfferPopup({
    super.key,
    this.onSkip,
    this.onSwitch,
  });

  final VoidCallback? onSkip;
  final VoidCallback? onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              LocaleKeys.hdWalletLegacyOfferTitle.tr(),
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            // Simplified description
            Text(
              LocaleKeys.hdWalletSimplifiedDescription.tr(),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Benefits section (expandable)
            Theme(
              data: theme.copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 8),
                leading: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: colorScheme.primary,
                ),
                title: Text(
                  LocaleKeys.hdWalletBenefitsTitle.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBenefitItem(context, Icons.privacy_tip,
                            LocaleKeys.hdWalletBenefitPrivacy.tr()),
                        _buildBenefitItem(context, Icons.folder,
                            LocaleKeys.hdWalletBenefitHistory.tr()),
                        _buildBenefitItem(context, Icons.security,
                            LocaleKeys.hdWalletBenefitSecurity.tr()),
                        _buildBenefitItem(context, Icons.swap_horiz,
                            LocaleKeys.hdWalletBenefitSwitching.tr()),
                        const SizedBox(height: 8),
                        Text(
                          LocaleKeys.hdWalletFundsSafetyNote.tr(),
                          style: textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Technical details section (expandable)
            Theme(
              data: theme.copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 8),
                leading: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  LocaleKeys.showTechnicalDetails.tr(),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      LocaleKeys.hdWalletTechnicalDetailsDescription.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: UiUnderlineTextButton(
                    text: LocaleKeys.hdWalletLegacyOfferSkip.tr(),
                    onPressed: () {
                      // Track user choice with analytics
                      if (context.mounted) {
                        context.read<AnalyticsBloc>().logEvent(
                              HdModeOfferEvent(action: 'skipped'),
                            );

                        // Use callback if provided (legacy), otherwise use BLoC
                        if (onSkip != null) {
                          onSkip!();
                        } else {
                          context.read<HdWalletDialogBloc>().add(
                                const HdWalletDialogLegacyOfferSkipped(),
                              );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: UiPrimaryButton(
                    text: LocaleKeys.hdWalletLegacyOfferChange.tr(),
                    onPressed: () {
                      // Track user choice with analytics
                      if (context.mounted) {
                        context.read<AnalyticsBloc>().logEvent(
                              HdModeOfferEvent(action: 'accepted'),
                            );

                        // Use callback if provided (legacy), otherwise use BLoC
                        if (onSwitch != null) {
                          onSwitch!();
                        } else {
                          context.read<HdWalletDialogBloc>().add(
                                const HdWalletDialogLegacyOfferAccepted(),
                              );
                        }
                      }
                    },
                    height: 36,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the HD legacy offer dialog using BLoC state management.
///
/// This function should be called after starting the HdWalletDialogBloc
/// and checking that [HdWalletDialogState.shouldShowLegacyOffer] is true.
///
/// Returns true if the user accepted the offer, false if skipped.
Future<bool> showHdLegacyOfferDialog(BuildContext context) async {
  if (!context.mounted) return false;

  try {
    late PopupDispatcher dispatcher;
    bool isOpen = true;
    bool result = false;

    void close() {
      dispatcher.close();
      isOpen = false;
    }

    // Listen to BLoC state changes to handle dialog closing
    final streamSubscription =
        context.read<HdWalletDialogBloc>().stream.listen((state) {
      if (state.status == HdWalletDialogStatus.legacyOfferAccepted) {
        result = true;
        close();
      } else if (state.status == HdWalletDialogStatus.legacyOfferSkipped) {
        result = false;
        close();
      }
    });

    dispatcher = PopupDispatcher(
      barrierColor: Colors.black87,
      context: context,
      popupContent: const HdLegacyOfferPopup(),
    );

    dispatcher.show();

    while (isOpen) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    await streamSubscription.cancel();
    return result;
  } catch (e) {
    // Log error and return safe default
    return false;
  }
}

/// Legacy function for backward compatibility.
///
/// @deprecated Use [showHdLegacyOfferDialog] with BLoC state management instead.
Future<bool> showHdLegacyOffer(BuildContext context) async {
  if (!context.mounted) return false;

  try {
    late PopupDispatcher dispatcher;
    bool isOpen = true;
    bool result = false;

    void close() {
      dispatcher.close();
      isOpen = false;
    }

    dispatcher = PopupDispatcher(
      barrierColor: Colors.black87,
      context: context,
      popupContent: HdLegacyOfferPopup(
        onSkip: () {
          result = false;
          close();
        },
        onSwitch: () {
          result = true;
          close();
        },
      ),
    );

    dispatcher.show();

    while (isOpen) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return result;
  } catch (e) {
    // Log error and return safe default
    return false;
  }
}

class HdModeWarningPopup extends StatefulWidget {
  const HdModeWarningPopup({
    super.key,
    this.onRevert,
    this.onContinue,
  });

  final VoidCallback? onRevert;
  final VoidCallback? onContinue;

  @override
  State<HdModeWarningPopup> createState() => _HdModeWarningPopupState();
}

class _HdModeWarningPopupState extends State<HdModeWarningPopup> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              LocaleKeys.hdWalletHdWarningTitle.tr(),
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            // Main description
            Text(
              LocaleKeys.hdWalletHdWarningDescription.tr(),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Fund safety reassurance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      LocaleKeys.hdWalletWarningFundsSafety.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: UiUnderlineTextButton(
                    text: LocaleKeys.hdWalletHdWarningRevert.tr(),
                    onPressed: () {
                      // Track user choice with analytics
                      if (context.mounted) {
                        context.read<AnalyticsBloc>().logEvent(
                              HdModeWarningEvent(action: 'reverted'),
                            );

                        // Use callback if provided (legacy), otherwise use BLoC
                        if (widget.onRevert != null) {
                          widget.onRevert!();
                        } else {
                          context.read<HdWalletDialogBloc>().add(
                                const HdWalletDialogHdWarningReverted(),
                              );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: UiPrimaryButton(
                    text: LocaleKeys.hdWalletHdWarningContinue.tr(),
                    onPressed: () {
                      // Track user choice with analytics
                      if (context.mounted) {
                        context.read<AnalyticsBloc>().logEvent(
                              HdModeWarningEvent(action: 'continued'),
                            );

                        // Use callback if provided (legacy), otherwise use BLoC
                        if (widget.onContinue != null) {
                          widget.onContinue!();
                        } else {
                          context.read<HdWalletDialogBloc>().add(
                                const HdWalletDialogHdWarningContinued(),
                              );
                        }
                      }
                    },
                    height: 36,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// Shows the HD warning dialog using BLoC state management.
///
/// This function should be called after starting the HdWalletDialogBloc
/// and checking that [HdWalletDialogState.shouldShowHdWarning] is true.
///
/// Returns true if the user continued with HD mode, false if reverted to legacy.
Future<bool> showHdModeWarningDialog(BuildContext context) async {
  if (!context.mounted) return true;

  try {
    late PopupDispatcher dispatcher;
    bool isOpen = true;
    bool result = true;

    void close() {
      dispatcher.close();
      isOpen = false;
    }

    // Listen to BLoC state changes to handle dialog closing
    final streamSubscription =
        context.read<HdWalletDialogBloc>().stream.listen((state) {
      if (state.status == HdWalletDialogStatus.hdWarningContinued) {
        result = true;
        close();
      } else if (state.status == HdWalletDialogStatus.hdWarningReverted) {
        result = false;
        close();
      }
    });

    dispatcher = PopupDispatcher(
      barrierColor: Colors.black87,
      context: context,
      popupContent: const HdModeWarningPopup(),
    );

    dispatcher.show();

    while (isOpen) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    await streamSubscription.cancel();
    return result;
  } catch (e) {
    // Log error and return safe default
    return true;
  }
}

/// Legacy function for backward compatibility.
///
/// @deprecated Use [showHdModeWarningDialog] with BLoC state management instead.
Future<bool> showHdModeWarning(BuildContext context) async {
  if (!context.mounted) return false;

  try {
    late PopupDispatcher dispatcher;
    bool isOpen = true;
    bool result = true;

    void close() {
      dispatcher.close();
      isOpen = false;
    }

    dispatcher = PopupDispatcher(
      barrierColor: Colors.black87,
      context: context,
      popupContent: HdModeWarningPopup(
        onRevert: () {
          result = false;
          close();
        },
        onContinue: () {
          result = true;
          close();
        },
      ),
    );

    dispatcher.show();

    while (isOpen) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return result;
  } catch (e) {
    // Log error and return safe default
    return true;
  }
}

// Analytics event classes
class HdModeOfferEvent implements AnalyticsEventData {
  const HdModeOfferEvent({required this.action});

  final String action;

  @override
  String get name => 'hd_mode_offer_interaction';

  @override
  Map<String, dynamic> get parameters => {
        'action': action,
      };
}

class HdModeWarningEvent implements AnalyticsEventData {
  const HdModeWarningEvent({required this.action});

  final String action;

  @override
  String get name => 'hd_mode_warning_interaction';

  @override
  Map<String, dynamic> get parameters => {
        'action': action,
      };
}
