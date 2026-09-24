import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../l10n/app_localizations.dart';
import '../../search/cubit/search_cubit.dart';
import '../../search/cubit/search_state.dart';
import '../../shared_widgets/empty_state_widget.dart';
import '../../shared_widgets/error_state_widget.dart';
import '../../shared_widgets/loading_widget.dart';
import '../cubit/medication_list_cubit.dart';
import '../cubit/medication_list_state.dart';
import 'medication_list_item.dart';

class MedicationListScreen extends StatelessWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MedicationListCubit(sl())..fetchMedications(),
        ),
        BlocProvider(create: (_) => SearchCubit(sl())),
      ],
      child: const _MedicationListView(),
    );
  }
}

class _MedicationListView extends StatefulWidget {
  const _MedicationListView();

  @override
  State<_MedicationListView> createState() => _MedicationListViewState();
}

class _MedicationListViewState extends State<_MedicationListView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Triggers pagination when the user nears the bottom of the list.
  void _onScroll() {
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<MedicationListCubit>().fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                l10n.medicationListTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    context.read<SearchCubit>().onQueryChanged(value),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  // Clear button, only visible while the field has text.
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: l10n.searchClear,
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchCubit>().onQueryChanged('');
                            },
                          ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, searchState) {
                  final isSearching = searchState is! SearchInitial;
                  // IndexedStack keeps the list alive so its scroll position survives a search.
                  return IndexedStack(
                    index: isSearching ? 1 : 0,
                    children: [
                      _MedicationListBody(scrollController: _scrollController),
                      isSearching
                          ? _SearchResultsBody(searchState: searchState)
                          : const SizedBox.shrink(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The normal paginated list, shown when the search field is empty.
class _MedicationListBody extends StatelessWidget {
  final ScrollController scrollController;

  const _MedicationListBody({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationListCubit, MedicationListState>(
      builder: (context, state) {
        return switch (state) {
          MedicationListInitial() ||
          MedicationListLoading() => const LoadingWidget(),
          MedicationListEmpty() => const EmptyStateWidget(),
          MedicationListError(:final failure) => ErrorStateWidget(
            failure: failure,
            onRetry: () =>
                context.read<MedicationListCubit>().fetchMedications(),
          ),
          MedicationListLoaded(
            :final items,
            :final hasReachedMax,
            :final loadMoreError,
          ) =>
            RefreshIndicator(
              onRefresh: () =>
                  context.read<MedicationListCubit>().fetchMedications(),
              child: _MedicationCard(
                scrollController: scrollController,
                itemCount: items.length + (hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= items.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: loadMoreError == null
                          ? const LoadingWidget()
                          : ErrorStateWidget(
                              failure: loadMoreError,
                              onRetry: () => context
                                  .read<MedicationListCubit>()
                                  .retryFetchMore(),
                            ),
                    );
                  }
                  return MedicationListItem(
                    medication: items[index],
                    onTap: () =>
                        context.push('/medications/${items[index].id}'),
                  );
                },
              ),
            ),
        };
      },
    );
  }
}

/// Search results, shown while the search field has text.
class _SearchResultsBody extends StatelessWidget {
  final SearchState searchState;

  const _SearchResultsBody({required this.searchState});

  @override
  Widget build(BuildContext context) {
    return switch (searchState) {
      SearchInitial() || SearchLoading() => const LoadingWidget(),
      SearchEmpty() => const EmptyStateWidget(),
      SearchError(:final failure) => ErrorStateWidget(
        failure: failure,
        onRetry: () => context.read<SearchCubit>().retry(),
      ),
      SearchLoaded(:final items) => _MedicationCard(
        itemCount: items.length,
        itemBuilder: (context, index) => MedicationListItem(
          medication: items[index],
          onTap: () => context.push('/medications/${items[index].id}'),
        ),
      ),
    };
  }
}

/// Shared rounded white card wrapper for a list of medications.
class _MedicationCard extends StatelessWidget {
  final ScrollController? scrollController;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _MedicationCard({
    this.scrollController,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: itemCount,
          separatorBuilder: (_, _) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}
