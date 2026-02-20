import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/tv_provider.dart';
import '../widgets/country_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_view.dart';
import 'channel_list_screen.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key});

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Consumer<TvProvider>(
          builder: (context, prov, _) {
            if (prov.loadState == LoadState.loading) {
              return const LoadingShimmer();
            }
            if (prov.loadState == LoadState.error) {
              return ErrorView(
                  message: prov.errorMessage ?? 'Unknown error',
                  onRetry: prov.initialize);
            }

            final all = prov.availableCountries;
            final countries = _query.isEmpty
                ? all
                : all
                    .where((c) =>
                        c.name.toLowerCase().contains(_query) ||
                        c.code.toLowerCase().contains(_query))
                    .toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppTheme.bg,
                  title: const Text(
                    'Countries',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: TextField(
                        controller: _searchCtrl,
                        style:
                            const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search countries…',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppTheme.textMuted, size: 20),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      color: AppTheme.textMuted, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          isDense: true,
                        ),
                        onChanged: (v) =>
                            setState(() => _query = v.toLowerCase().trim()),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      _query.isEmpty
                          ? '${countries.length} countries available'
                          : '${countries.length} result${countries.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ),
                ),
                if (countries.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.public_off_rounded,
                              size: 52, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No countries match "$_query"',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final country = countries[i];
                          return CountryCard(
                            country: country,
                            channelCount:
                                prov.channelCountForCountry(country.code),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChannelListScreen(
                                  countryCode: country.code,
                                  countryName: country.name,
                                  flag: country.flag,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: countries.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
