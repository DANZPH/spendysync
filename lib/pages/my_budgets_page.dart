// ignore_for_file: deprecated_member_use

import 'package:project/pages/create_budget_page.dart';
import 'package:project/pages/edit_budget_page.dart';
import 'package:project/widget/searchButton.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:intl/intl.dart';
import 'package:project/theme/colors.dart';
import 'package:project/json/day_month.dart';

class MyBudgetsPage extends StatefulWidget {
  @override
  _MyBudgetsPageState createState() => _MyBudgetsPageState();
}

class _MyBudgetsPageState extends State<MyBudgetsPage> {
  List<dynamic> allBudgets = []; // Store all fetched budgets
  List<dynamic> filteredBudgets = []; // Store filtered budgets to display
  bool isLoading = true;
  double totalBudget = 0;
  final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");
  final supabase = Supabase.instance.client;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String? username;
  double totalTransactions = 0;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    fetchBudgets();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text;
      applyFilters();
    });
  }

  Future<void> fetchUserDetails() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not logged in!")),
      );
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No profile found. Please update your details.")),
        );
        return;
      }

      if (mounted) {
        setState(() {
          username = response['full_name'] ?? "Unknown User";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: ${e.toString()}")),
      );
    }
  }

  Future<void> fetchBudgets() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        _showErrorMessage('You are not logged in.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Fetch budgets
      final budgetData = await supabase
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Fetch transactions
      final transactionData = await supabase
          .from('transactions')
          .select('amount')
          .eq('user_id', userId);

      double totalTrans = 0;
      for (var transaction in transactionData) {
        totalTrans += (transaction['amount'] as num).toDouble();
      }

      setState(() {
        allBudgets = budgetData;
        totalTransactions = totalTrans;
        applyFilters();
        isLoading = false;
      });

      // Check if total budget is higher than total transactions
      if (totalBudget > totalTransactions) {
        _showWarningNotification(
            'Warning: Total budget is higher than your Onhand Cash!');
      }
    } catch (error) {
      print('Error fetching budgets: ${error.toString()}');
      setState(() {
        isLoading = false;
      });
      _showErrorMessage('Error fetching budgets: ${error.toString()}');
    }
  }

  // New method to apply filters based on the search query
  void applyFilters() {
    List<dynamic> filtered = List.from(allBudgets);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((budget) {
        return budget['name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Calculate total budget for filtered list
    double total = 0;
    for (var budget in filtered) {
      total += (budget['amount'] as num).toDouble();
    }

    setState(() {
      filteredBudgets = filtered;
      totalBudget = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), // Dark background color
      body: getBody(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: fetchBudgets,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E), // Darker header color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 10,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 60, right: 20, left: 20, bottom: 25),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          username != null ? "Hi, $username" : "",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const Text(
                          "",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Search bar
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search budgets...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            // Total Budget Summary Card
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E), // Darker card color
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 10,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Budget",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isLoading
                            ? "Loading..."
                            : currencyFormat.format(totalBudget),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Onhand Cash",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isLoading
                            ? "Loading..."
                            : currencyFormat.format(totalTransactions),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Budget List Section Title
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 25, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Budgets",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Budget List or Loading/Empty State
            isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: CircularProgressIndicator(color: secondary1),
                    ),
                  )
                : filteredBudgets.isEmpty
                    ? _emptyBudgetMessage()
                    : _buildBudgetList(MediaQuery.of(context).size,
                        filteredBudgets, _editBudget, _deleteBudget),

            const SizedBox(height: 60), // Space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _emptyBudgetMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              AntDesign.wallet,
              size: 60,
              color: grey,
            ),
            const SizedBox(height: 10),
            Text(
              "No budgets found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Start by adding your first budget",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList(Size size, List<dynamic> budgets,
      Function _editBudget, Function _deleteBudget) {
    final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(budgets.length, (index) {
          final budget = budgets[index];
          final iconPath = budget['icon_path'] ?? 'assets/images/budget.png';
          final budgetId = budget['id'] is int
              ? budget['id']
              : int.tryParse(budget['id'].toString()) ?? 0;

          return GestureDetector(
            onTap: () => _editBudget(budget), // Change this line
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E), // Darker card color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.15),
                        ),
                        child: Center(
                          child: Image.asset(
                            iconPath,
                            width: 30,
                            height: 30,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(AntDesign.wallet,
                                  color: Colors.white70);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: (size.width - 140) * 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget['name'] ?? 'Unnamed Budget',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              budget['category'] ?? 'Uncategorized',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (budget['note'] != null &&
                                budget['note'].toString().isNotEmpty)
                              Text(
                                'Note: ${budget['note']}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (budget['frequency'] != null)
                              Text(
                                'Time Period: ${budget['frequency']}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.blueGrey),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(budget['amount'] ?? 0),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green),
                      ),
                      GestureDetector(
                        onTap: () => _deleteBudget(budgetId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _editBudget(Map<String, dynamic> budget) async {
    // Navigate to edit budget page with the budget data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBudgetPage(budget: budget),
      ),
    );

    if (result == true) {
      fetchBudgets(); // Refresh budgets if edited
      _showSuccessMessage('Budget updated successfully');
    }
  }

  Future<void> _deleteBudget(int budgetId) async {
    // Check if budgetId is valid
    if (budgetId == 0) {
      _showErrorMessage('Invalid budget ID');
      return;
    }
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Delete the budget from Supabase
      await supabase.from('budgets').delete().eq('id', budgetId);

      // Refresh budgets
      await fetchBudgets();
      _showSuccessMessage('Budget deleted successfully');
    } catch (error) {
      _showErrorMessage('Error deleting budget: ${error.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ));
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  void _showWarningNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 3),
    ));
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 2),
    ));
  }
}
