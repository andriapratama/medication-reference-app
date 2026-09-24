import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/medication_detail.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared_widgets/error_state_widget.dart';
import '../../shared_widgets/loading_widget.dart';
import '../cubit/medication_detail_cubit.dart';
import '../cubit/medication_detail_state.dart';

const _accentBlue = Color(0xFF007AFF);
const _warningColor = Color(0xFFB45309);
const _pageBackground = Color(0xFFF2F2F7);

class MedicationDetailScreen extends StatelessWidget {
  final String id;

  const MedicationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicationDetailCubit(
        getMedicationDetail: sl(),
        addFavorite: sl(),
        removeFavorite: sl(),
      )..fetchDetail(id),
      child: _MedicationDetailView(id: id),
    );
  }
}

class _MedicationDetailView extends StatelessWidget {
  final String id;

  const _MedicationDetailView({required this.id});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leadingWidth: 120,
        leading: TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: _accentBlue),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          label: Text(l10n.detailBack, style: const TextStyle(fontSize: 17)),
          // Falls back to the list when the page was opened directly (no history to pop).
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/medications'),
        ),
        actions: const [_FavoriteButton()],
      ),
      body: BlocBuilder<MedicationDetailCubit, MedicationDetailState>(
        builder: (context, state) => switch (state) {
          MedicationDetailInitial() ||
          MedicationDetailLoading() => const LoadingWidget(),
          MedicationDetailError(:final failure) => ErrorStateWidget(
            failure: failure,
            onRetry: () =>
                context.read<MedicationDetailCubit>().fetchDetail(id),
          ),
          MedicationDetailLoaded(:final detail) => _DetailContent(
            detail: detail,
          ),
        },
      ),
      // White background extends under the home indicator; SafeArea keeps the text above it.
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Text(
              l10n.medicalDisclaimer,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }
}

/// Star button in the app bar; hidden until the detail is loaded.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<MedicationDetailCubit, MedicationDetailState>(
      builder: (context, state) {
        if (state is! MedicationDetailLoaded) return const SizedBox.shrink();
        final isFavorite = state.detail.isFavorite;
        return IconButton(
          tooltip: isFavorite
              ? l10n.detailRemoveFavorite
              : l10n.detailAddFavorite,
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: _accentBlue,
            size: 28,
          ),
          onPressed: () =>
              context.read<MedicationDetailCubit>().toggleFavorite(),
        );
      },
    );
  }
}

/// Header (name, generic, manufacturer, badge) followed by the collapsible sections card.
class _DetailContent extends StatelessWidget {
  final MedicationDetail detail;

  const _DetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    // OTC labels use `purpose`, prescription labels `indications_and_usage`; show whichever exist.
    final purpose = [
      detail.purpose,
      detail.indicationsAndUsage,
    ].whereType<String>().join('\n\n');

    final sections = <_SectionData>[
      _SectionData((l) => l.sectionPurpose, purpose, initiallyExpanded: true),
      _SectionData((l) => l.sectionDosage, detail.dosageAndAdministration),
      _SectionData(
        (l) => l.sectionActiveIngredients,
        detail.activeIngredients.join('\n'),
      ),
      _SectionData(
        (l) => l.sectionWarnings,
        detail.warnings,
        isWarning: true,
        initiallyExpanded: true,
      ),
      _SectionData(
        (l) => l.sectionInactiveIngredients,
        detail.inactiveIngredients.join('\n'),
      ),
    ].where((s) => s.body != null && s.body!.trim().isNotEmpty).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.brandName ?? l10n.medicationNameUnavailable,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (detail.genericName != null) ...[
            const SizedBox(height: 4),
            Text(
              detail.genericName!,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            detail.manufacturer ?? l10n.manufacturerUnavailable,
            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
          ),
          if (detail.type != null) ...[
            const SizedBox(height: 10),
            _TypeBadge(type: detail.type!),
          ],
          const SizedBox(height: 20),
          if (sections.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < sections.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
                    _DetailSection(data: sections[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Green "OTC" or blue "Rx" pill under the manufacturer name.
class _TypeBadge extends StatelessWidget {
  final MedicationType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOtc = type == MedicationType.otc;
    final color = isOtc ? Colors.green.shade800 : Colors.blue.shade800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOtc ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOtc ? l10n.badgeOtc : l10n.badgePrescription,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Everything needed to render one collapsible section.
class _SectionData {
  // Picks the title from a given localization, so we can read both the current and English one.
  final String Function(AppLocalizations) title;
  final String? body;
  final bool isWarning;
  final bool initiallyExpanded;

  const _SectionData(
    this.title,
    this.body, {
    this.isWarning = false,
    this.initiallyExpanded = false,
  });
}

/// One tappable section row that expands to show its text.
class _DetailSection extends StatefulWidget {
  final _SectionData data;

  const _DetailSection({required this.data});

  @override
  State<_DetailSection> createState() => _DetailSectionState();
}

class _DetailSectionState extends State<_DetailSection> {
  late bool _expanded = widget.data.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.data;
    final title = data.title(l10n);
    // Show the original English (FDA) section name as a hint when the app isn't in English.
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final englishTitle = isEnglish
        ? null
        : data.title(lookupAppLocalizations(const Locale('en')));
    final titleColor = data.isWarning ? _warningColor : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                if (data.isWarning) ...[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: _warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      children: [
                        if (englishTitle != null)
                          TextSpan(
                            text: ' · $englishTitle',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
        // Animates the height change when the section opens/closes.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    data.body!,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
