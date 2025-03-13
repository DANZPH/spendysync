import 'package:project/json/create_budget_json.dart';
import 'package:project/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({Key? key}) : super(key: key);

  @override
  _CreateBudgetPageState createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  int activeCategory = 0;
  final TextEditingController _budgetName = TextEditingController();
  final TextEditingController _budgetPrice = TextEditingController(text: "₱");
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");
  String selectedFrequency = 'none';
  String selectedCategory = categories[0]['name'];

  // Reference to Supabase client
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _setupPriceController();
  }

  void _setupPriceController() {
    _budgetPrice.addListener(() {
      final text = _budgetPrice.text;
      final selection = _budgetPrice.selection;

      if (text.isEmpty || selection.baseOffset == 0) {
        // Always ensure the peso sign is present at the beginning
        _budgetPrice.text = "₱";
        _budgetPrice.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetPrice.text.length),
        );
      } else if (text.length == 1 && text != "₱") {
        // If user deletes the peso sign, put it back
        _budgetPrice.text = "₱$text";
        _budgetPrice.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetPrice.text.length),
        );
      } else if (!text.startsWith("₱")) {
        // Ensure it always starts with ₱
        _budgetPrice.text = "₱$text";
        _budgetPrice.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetPrice.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _budgetName.dispose();
    _budgetPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context, false); // Return false when back button is pressed
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF121212), // Dark background color
        appBar: AppBar(
          backgroundColor: Color(0xFF1E1E1E), // Darker app bar color
          elevation: 0.5,
          title: Text(
            "Create budget",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text color
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(
                  context, false); // Return false when close button is pressed
            },
          ),
        ),
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryDropdown(),
          SizedBox(height: 30),
          _buildFormSection(),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Category",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['name'],
                child: Text(category['name'],
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCategory = newValue!;
                activeCategory = categories
                    .indexWhere((category) => category['name'] == newValue);
              });
            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              filled: true,
              fillColor: Color(0xFF1E1E1E),
            ),
            dropdownColor: Color(0xFF1E1E1E),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: "Budget Name",
            hint: "Enter Budget Name",
            controller: _budgetName,
            isBold: true,
          ),
          SizedBox(height: 20),
          Text(
            "Budget Amount",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: TextField(
              controller: _budgetPrice,
              keyboardType: TextInputType.number,
              cursorColor: Colors.white,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Enter Amount",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Budget Frequency",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.white70),
          ),
          DropdownButtonFormField<String>(
            value: selectedFrequency,
            items: ['none', 'Daily', 'Weekly', 'Monthly', 'Yearly']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedFrequency = newValue!;
              });
            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              filled: true,
              fillColor: Color(0xFF1E1E1E),
            ),
            dropdownColor: Color(0xFF1E1E1E),
          ),
          SizedBox(height: 40),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isBold = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        TextField(
          controller: controller,
          cursorColor: Colors.white,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 17,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            filled: true,
            fillColor: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : _submitBudget,
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Submit Budget",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _submitBudget() async {
    // Validate inputs
    final name = _budgetName.text.trim();

    // Handle currency amount extraction
    String priceText = _budgetPrice.text;
    if (priceText.startsWith("₱")) {
      priceText = priceText.substring(1); // Remove peso sign
    }
    priceText = priceText.replaceAll(",", "").trim(); // Remove commas

    if (name.isEmpty) {
      _showErrorMessage('Budget name is required');
      return;
    }

    double amount = 0;
    try {
      amount = double.parse(priceText);
    } catch (e) {
      _showErrorMessage('Please enter a valid amount');
      return;
    }

    if (amount <= 0) {
      _showErrorMessage('Amount must be greater than zero');
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      await _saveBudgetToSupabase(name, amount, ''); // Pass empty note

      // Fetch updated budgets
      await fetchBudgets();

      // Show success message
      _showSuccessMessage('Budget added successfully!');

      // Wait for the snackbar to be visible
      await Future.delayed(Duration(milliseconds: 500));

      // Reset form
      _resetForm();

      // Navigate back with true result to indicate success and refresh
      if (mounted) {
        Navigator.pop(context, true);
        await fetchBudgets();
      }
    } catch (error) {
      _showErrorMessage('Error: ${error.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchBudgets() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch budgets data from Supabase
      final data = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // This is just for logging, since this method is called within CreateBudgetPage
      // and you likely don't have budgets or totalBudget variables in this class
      print('Fetched ${data.length} budgets');

      // Calculate total for logging purposes
      double total = 0;
      for (var budget in data) {
        total += (budget['amount'] as num).toDouble();
      }
      print('Total budget amount: $total');

      // Note: Since this is in CreateBudgetPage, you would typically
      // not be setting state variables like budgets and totalBudget here
      // Those would be in your DailyPage or parent component
    } catch (error) {
      print('Error fetching budgets: ${error.toString()}');
      // Don't show error message here since we're just refreshing in the background
    }
  }

  Future<void> _saveBudgetToSupabase(
      String name, double amount, String note) async {
    // Get current user ID to associate budget with user
    final userId = _supabase.auth.currentUser?.id;

    // Check if user is authenticated
    if (userId == null) {
      throw Exception('You must be logged in to create a budget');
    }

    // Get selected category
    final category = selectedCategory;
    final iconPath = categories[activeCategory]['icon'];

    // Create budget data
    final budgetData = {
      'user_id': userId,
      'name': name,
      'amount': amount,
      'category': category,
      'icon_path': iconPath,
      'note': note,
      'frequency': selectedFrequency,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      // Use the correct insert method based on your Supabase version
      await _supabase.from('budgets').insert(budgetData);
      print('Budget saved successfully');
    } catch (e) {
      print('Supabase error: $e');
      throw Exception('Failed to save budget: $e');
    }
  }

  void _resetForm() {
    _budgetName.clear();
    _budgetPrice.text = "₱";
    setState(() {
      activeCategory = 0;
    });
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
    }
  }
}
