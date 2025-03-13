import 'package:project/theme/colors.dart';
import 'package:project/data/transaction_categories.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  // Update filter variables
  String selectedFilter = 'All';
  final List<String> filters = ['Income', 'All', 'Expense'];

  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> transactions = [];
  bool _isLoading = false;
  String selectedType = 'expense';
  String? selectedCategoryId;
  final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final data = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        transactions = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      _showErrorMessage('Error loading transactions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddTransactionDialog() {
    final TextEditingController amountController = TextEditingController();
    String dialogSelectedType = selectedType;
    String? dialogSelectedCategoryId;
    final PageController pageController = PageController(viewportFraction: 0.3);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Transaction'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'expense',
                        label: Text('Expense'),
                      ),
                      ButtonSegment(
                        value: 'income',
                        label: Text('Income'),
                      ),
                    ],
                    selected: {dialogSelectedType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setDialogState(() {
                        dialogSelectedType = newSelection.first;
                        dialogSelectedCategoryId = null;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Category Selection Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Category:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 100,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: TransactionCategories.getByType(dialogSelectedType).length,
                          onPageChanged: (index) {
                            setDialogState(() {
                              dialogSelectedCategoryId = TransactionCategories.getByType(dialogSelectedType)[index].id;
                            });
                          },
                          itemBuilder: (context, index) {
                            final category = TransactionCategories.getByType(dialogSelectedType)[index];
                            final isSelected = category.id == dialogSelectedCategoryId;
                            
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? primary.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? primary : Colors.grey.withOpacity(0.5),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? primary : Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          dialogSelectedCategoryId != null
                              ? TransactionCategories.getById(dialogSelectedCategoryId!)?.name ?? ''
                              : 'Swipe to select a category',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₱',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (amountController.text.isEmpty) {
                  _showErrorMessage('Please enter an amount');
                  return;
                }
                if (dialogSelectedCategoryId == null) {
                  _showErrorMessage('Please select a category');
                  return;
                }

                try {
                  final amount = double.parse(amountController.text);
                  final userId = _supabase.auth.currentUser?.id;

                  if (userId == null) throw Exception('User not authenticated');

                  await _supabase.from('transactions').insert({
                    'user_id': userId,
                    'amount':
                        dialogSelectedType == 'expense' ? -amount : amount,
                    'type': dialogSelectedType,
                    'category_id': dialogSelectedCategoryId,
                  });

                  Navigator.pop(context);
                  _loadTransactions();
                  _showSuccessMessage('Transaction added successfully');
                } catch (e) {
                  _showErrorMessage('Error adding transaction: $e');
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(Map<String, dynamic> transaction) {
    final TextEditingController amountController = TextEditingController(
      text: transaction['amount'].abs().toString(),
    );
    String editType = transaction['type'];
    DateTime selectedDate =
        DateTime.parse(transaction['created_at']); // Add this line

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // Change to StatefulBuilder
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add Date Selection
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Transaction Date'),
                  subtitle: Text(
                    DateFormat('MMM d, y').format(selectedDate),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                Divider(),
                SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₱',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            // Update the onPressed of FilledButton
            FilledButton(
              onPressed: () async {
                try {
                  final amount = double.parse(amountController.text);

                  await _supabase.from('transactions').update({
                    'amount': editType == 'expense' ? -amount : amount,
                    'type': editType,
                    'created_at':
                        selectedDate.toIso8601String(), // Add this line
                    'updated_at': DateTime.now().toIso8601String(),
                  }).eq('id', transaction['id']);

                  Navigator.pop(context);
                  _loadTransactions();
                  _showSuccessMessage('Transaction updated successfully');
                } catch (e) {
                  _showErrorMessage('Error updating transaction: $e');
                }
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(int transactionId) async {
    try {
      await _supabase.from('transactions').delete().eq('id', transactionId);
      _loadTransactions();
      _showSuccessMessage('Transaction deleted successfully');
    } catch (e) {
      _showErrorMessage('Error deleting transaction: $e');
    }
  }

  // Add method to filter transactions
  List<Map<String, dynamic>> get filteredTransactions {
    List<Map<String, dynamic>> filtered = transactions;
    if (selectedFilter != 'All') {
      filtered = filtered.where((transaction) {
        final amount = transaction['amount'] as num;
        return selectedFilter == 'Income' ? amount > 0 : amount < 0;
      }).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description = transaction['description']?.toLowerCase() ?? '';
        return description.contains(searchQuery.toLowerCase());
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212), // Dark background color
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E1E1E), // Darker app bar color
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Transaction Type Filter
          Padding(
            padding: const EdgeInsets.all(15),
            child: DropdownButtonFormField<String>(
              value: selectedFilter,
              items: filters.map((filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedFilter = newValue!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              dropdownColor: Color(0xFF1E1E1E),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
              ),
            ),
          ),

          // Total Budget Card
          Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E), // Darker card color
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          currencyFormat.format(
                            filteredTransactions.fold<double>(
                              0,
                              (sum, transaction) =>
                                  sum + (transaction['amount'] as num),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primary))
                : filteredTransactions.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTransactions.length,
                        padding: EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          final amount = transaction['amount'] as num;
                          final isExpense = amount < 0;
                          final category = TransactionCategories.getById(
                              transaction['category_id'] ?? 'others');

                          return GestureDetector(
                            onTap: () =>
                                _showEditTransactionDialog(transaction),
                            child: Card(
                              elevation: 2,
                              color: Color(0xFF1E1E1E), // Darker card color
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      isExpense ? Colors.red : Colors.green,
                                ),
                                title: Text(
                                  currencyFormat.format(amount.abs()),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category?.name ?? 'Others',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      DateFormat('MMM d, y').format(
                                        DateTime.parse(
                                            transaction['created_at']),
                                      ),
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                                trailing: GestureDetector(
                                  onTap: () =>
                                      _deleteTransaction(transaction['id']),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.delete_outline,
                                        size: 18, color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        backgroundColor: primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }
}