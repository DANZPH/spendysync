import 'package:project/json/create_budget_json.dart';
import 'package:project/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class EditBudgetPage extends StatefulWidget {
  final Map<String, dynamic> budget;

  const EditBudgetPage({Key? key, required this.budget}) : super(key: key);

  @override
  _EditBudgetPageState createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  int activeCategory = 0;
  late TextEditingController _budgetName;
  late TextEditingController _budgetPrice;
  late TextEditingController _budgetNote;
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(locale: "en_PH", symbol: "₱");
  late String selectedFrequency;
  String selectedCategory = categories[0]['name'];

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    // Find the category index from categories json
    for (int i = 0; i < categories.length; i++) {
      if (categories[i]['name'] == widget.budget['category']) {
        activeCategory = i;
        break;
      }
    }

    // Initialize controllers with existing data
    _budgetName = TextEditingController(text: widget.budget['name'] ?? "");
    _budgetNote = TextEditingController(text: widget.budget['note'] ?? "");
    selectedFrequency = widget.budget['frequency'] ?? 'none';
    selectedCategory = widget.budget['category'] ?? categories[0]['name'];

    // Format the price with currency
    double price = (widget.budget['amount'] as num).toDouble();
    _budgetPrice = TextEditingController(text: currencyFormat.format(price));
    _setupPriceController();
  }

  void _setupPriceController() {
    _budgetPrice.addListener(() {
      final text = _budgetPrice.text;
      final selection = _budgetPrice.selection;

      if (text.isEmpty || selection.baseOffset == 0) {
        _budgetPrice.text = "₱";
        _budgetPrice.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetPrice.text.length),
        );
      } else if (text.length == 1 && text != "₱") {
        _budgetPrice.text = "₱$text";
        _budgetPrice.selection = TextSelection.fromPosition(
          TextPosition(offset: _budgetPrice.text.length),
        );
      } else if (!text.startsWith("₱")) {
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
    _budgetNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          elevation: 0.5,
          title: Text(
            "Edit Budget",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, false);
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
              color: Colors.white.withOpacity(0.5),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Budget Frequency",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedFrequency,
            items: ['none', 'Daily', 'Weekly', 'Monthly', 'Yearly']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: 16)),
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
            ),
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
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
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
        onPressed: _isLoading ? null : _updateBudget,
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
                "Update Budget",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _updateBudget() async {
    final name = _budgetName.text.trim();
    final note = _budgetNote.text.trim();

    String priceText = _budgetPrice.text;
    if (priceText.startsWith("₱")) {
      priceText = priceText.substring(1);
    }
    priceText = priceText.replaceAll(",", "").trim();

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

    setState(() {
      _isLoading = true;
    });

    try {
      final category = selectedCategory;
      final iconPath = categories[activeCategory]['icon'];

      await _supabase.from('budgets').update({
        'name': name,
        'amount': amount,
        'category': category,
        'icon_path': iconPath,
        'note': note,
        'frequency': selectedFrequency,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.budget['id']);

      _showSuccessMessage('Budget updated successfully!');
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      _showErrorMessage('Error: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
