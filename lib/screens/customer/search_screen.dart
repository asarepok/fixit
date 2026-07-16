import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants.dart';
import '../../models/user_model.dart';
import '../../providers/artisan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/artisan_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});
  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  String _query = '';
  bool _nearestFirst = true;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<UserModel> _filtered(List<UserModel> artisans) {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return artisans;
    return artisans
        .where(
          (artisan) => '${artisan.name} ${artisan.profession ?? ''}'
              .toLowerCase()
              .contains(needle),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final artisans = ref.watch(artisansProvider);
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Text(
            _nearestFirst ? 'Sorted by nearest' : 'Sorted by rating',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search artisans or services',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Nearest'),
                selected: _nearestFirst,
                onSelected: (_) => setState(() => _nearestFirst = true),
              ),
              ChoiceChip(
                label: const Text('Top rated'),
                selected: !_nearestFirst,
                onSelected: (_) => setState(() => _nearestFirst = false),
              ),
            ],
          ),
          const SizedBox(height: 18),
          artisans.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(36),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) =>
                const Center(child: Text('Unable to load artisans.')),
            data: (list) {
              final results = _filtered(
                list,
              ).where((artisan) => artisan.uid != currentUser?.uid).toList();
              if (!_nearestFirst) {
                results.sort(
                  (a, b) =>
                      (b.averageRating ?? 0).compareTo(a.averageRating ?? 0),
                );
              }
              return results.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: Text('No artisans match your search.'),
                      ),
                    )
                  : Column(
                      children: results
                          .map(
                            (artisan) => ArtisanCard(
                              artisan: artisan,
                              onTap: () => context.push(
                                AppRoutes.artisanProfile,
                                extra: artisan,
                              ),
                            ),
                          )
                          .toList(),
                    );
            },
          ),
        ],
      ),
    );
  }
}
