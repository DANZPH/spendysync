import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchButton extends StatefulWidget {
  const SearchButton({Key? key}) : super(key: key);

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
        _searchController.clear();
      }
    });
  }

  Future<void> _onSearch(String query) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('budgets')
          .select()
          .ilike('name', '%$query%'); // Case-insensitive search

      if (response.isNotEmpty) {
        print('Found budgets: $response');
      } else {
        print('No budgets found for "$query"');
      }
    } catch (error) {
      print('Search error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizeTransition(
          sizeFactor: _animation,
          axis: Axis.horizontal,
          axisAlignment: 1.0,
          child: Container(
            width: 200,
            margin: const EdgeInsets.only(right: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search budget name',
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onSubmitted: _onSearch,
            ),
          ),
        ),
        IconButton(
          onPressed: _toggleSearch,
          icon: AnimatedIcon(
            icon: AnimatedIcons.search_ellipsis,
            progress: _animation,
          ),
        ),
      ],
    );
  }
}
