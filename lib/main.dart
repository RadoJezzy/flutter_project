import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseTrackerApp()); // Entry point of the Flutter application
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Primary color theme
        brightness: Brightness.light, // Light theme
        scaffoldBackgroundColor: Colors.grey[100], // Background color
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[800]), // Text color for large body text
          bodyMedium: TextStyle(color: Colors.grey[600]), // Text color for medium body text
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // AppBar background color
          foregroundColor: Colors.indigo, // AppBar text color
          elevation: 0, // No shadow
          iconTheme: IconThemeData(color: Colors.indigo), // Icon color in AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Button text color
            backgroundColor: Colors.indigo, // Button background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Button corner radius
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Button padding
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Input field corner radius
            borderSide: BorderSide(color: Colors.grey[300]!), // Input field border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Focused input field corner radius
            borderSide: BorderSide(color: Colors.indigo, width: 2), // Focused input field border color
          ),
          fillColor: Colors.white, // Input field fill color
          filled: true, // Enable fill color
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Input field padding
        ),
        cardTheme: CardTheme(
          elevation: 2, // Card shadow elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Card corner radius
          ),
          color: Colors.white, // Card background color
        ),
      ),
      home: HomePage(), // Home page of the app
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); // Create the state for the home page
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index of the selected tab
  List<Transaction> transactions = []; // List of transactions
  List<BudgetEntry> budgets = []; // List of budgets
  DateTime selectedMonth = DateTime.now(); // Currently selected month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker',
            style: TextStyle(fontWeight: FontWeight.bold)), // AppBar title
        actions: [], // No actions in AppBar
      ),
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600) // Check if the screen width is greater than 600
            NavigationRail(
              selectedIndex: _selectedIndex, // Index of the selected item
              onDestinationSelected: _onItemTapped, // Handle item selection
              labelType: NavigationRailLabelType.selected, // Show label only for selected item
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined), // Icon for dashboard
                  selectedIcon: Icon(Icons.dashboard), // Selected icon for dashboard
                  label: Text('Dashboard'), // Label for dashboard
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline), // Icon for add
                  selectedIcon: Icon(Icons.add_circle), // Selected icon for add
                  label: Text('Add'), // Label for add
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined), // Icon for report
                  selectedIcon: Icon(Icons.bar_chart), // Selected icon for report
                  label: Text('Report'), // Label for report
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex, // Index of the displayed page
              children: [
                DashboardPage(
                  transactions: transactions, // Pass transactions to dashboard page
                  budgets: budgets, // Pass budgets to dashboard page
                  selectedMonth: selectedMonth, // Pass selected month to dashboard page
                ),
                ManagePage(
                  transactions: transactions, // Pass transactions to manage page
                  onAddTransaction: _addTransaction, // Callback for adding a transaction
                  budgets: budgets, // Pass budgets to manage page
                  onUpdateBudget: _updateBudget, // Callback for updating budget
                ),
                ReportPage(transactions: transactions, budgets: budgets), // Pass transactions and budgets to report page
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600 // Check if the screen width is less than or equal to 600
          ? BottomNavigationBar(
              currentIndex: _selectedIndex, // Index of the selected item
              onTap: _onItemTapped, // Handle item tap
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined), // Icon for dashboard
                  activeIcon: Icon(Icons.dashboard), // Active icon for dashboard
                  label: 'Dashboard', // Label for dashboard
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline), // Icon for add
                  activeIcon: Icon(Icons.add_circle), // Active icon for add
                  label: 'Add', // Label for add
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined), // Icon for report
                  activeIcon: Icon(Icons.bar_chart), // Active icon for report
                  label: 'Report', // Label for report
                ),
              ],
            )
          : null, // No bottom navigation bar if screen width is greater than 600
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction); // Add new transaction to the list
    });
  }

  void _updateBudget(double budget) {
    setState(() {
      budgets.add(BudgetEntry(amount: budget, date: DateTime.now())); // Add new budget entry to the list
    });
  }
}

class DashboardPage extends StatelessWidget {
  final List<Transaction> transactions; // List of transactions
  final List<BudgetEntry> budgets; // List of budgets
  final DateTime selectedMonth; // Selected month

  DashboardPage({
    required this.transactions, // Required parameter for transactions
    required this.budgets, // Required parameter for budgets
    required this.selectedMonth, // Required parameter for selected month
  });

  get widget => null; // Placeholder for widget, not used

  String _formatMonth(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ]; // List of month names
    return '${months[date.month - 1]} ${date.year}'; // Format month and year
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = transactions
        .where((t) =>
            t.date.month == selectedMonth.month &&
            t.date.year == selectedMonth.year &&
            t.amount < 0) // Filter transactions for the selected month and expenses
        .fold(0, (sum, t) => sum + t.amount.abs()); // Calculate total expenses

    double currentBudget = budgets
        .where((budget) =>
            budget.date.month == selectedMonth.month &&
            budget.date.year == selectedMonth.year) // Filter budgets for the selected month
        .fold(0, (sum, budget) => sum + budget.amount); // Calculate current budget

    bool isOverBudget = totalExpenses > currentBudget; // Check if expenses exceed budget

    return SingleChildScrollView(
      padding: EdgeInsets.all(24), // Page padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
        children: [
          _buildHeader(context), // Build header
          SizedBox(height: 24), // Spacer
          _buildExpenseCard(context, totalExpenses), // Build expense card
          SizedBox(height: 24), // Spacer
          if (currentBudget > 0)
            _buildBudgetCard(
                context, totalExpenses, currentBudget, isOverBudget), // Build budget card if budget is greater than 0
          SizedBox(height: 24), // Spacer
          _buildStatusCard(context, isOverBudget), // Build status card
          SizedBox(height: 24), // Spacer
          _buildRecentTransactions(context), // Build recent transactions list
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between header elements
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold), // Dashboard title style
        ),
        OutlinedButton.icon(
          onPressed: () {
            _selectMonth(context); // Select month when button is pressed
          },
          icon: Icon(Icons.calendar_today_outlined), // Calendar icon
          label: Text(_formatMonth(selectedMonth)), // Formatted month label
        ),
      ],
    );
  }

  Widget _buildExpenseCard(BuildContext context, double totalExpenses) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16), // Card padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
          children: [
            Text(
              'Total Expenses',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.grey[700],
                  ), // Total expenses label style
            ),
            SizedBox(height: 8), // Spacer
            Text(
              '\$${totalExpenses.toStringAsFixed(2)}', // Formatted total expenses
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(color: Colors.red, fontWeight: FontWeight.bold), // Total expenses value style
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, double totalExpenses,
      double currentBudget, bool isOverBudget) {
    double remainingBudget = currentBudget - totalExpenses; // Calculate remaining budget
    double progress = (totalExpenses / currentBudget)
        .clamp(0.0, 1.0); // Calculate progress percentage

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16), // Card padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
          children: [
            Text(
              'Budget Overview',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.grey[700],
                  ), // Budget overview label style
            ),
            SizedBox(height: 8), // Spacer
            Text(
              '\$${remainingBudget.toStringAsFixed(2)} remaining', // Formatted remaining budget
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: isOverBudget ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ), // Remaining budget value style
            ),
            SizedBox(height: 16), // Spacer
            LinearProgressIndicator(
              value: progress, // Progress percentage
              backgroundColor: Colors.grey[300], // Progress bar background color
              color: isOverBudget ? Colors.red : Colors.green, // Progress bar color
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isOverBudget) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16), // Card padding
        child: Row(
          children: [
            Icon(
              isOverBudget ? Icons.warning_amber_outlined : Icons.check_circle_outline,
              color: isOverBudget ? Colors.red : Colors.green, // Status icon color
              size: 32, // Status icon size
            ),
            SizedBox(width: 16), // Spacer
            Expanded(
              child: Text(
                isOverBudget
                    ? 'You are over budget this month.'
                    : 'You are within budget this month.',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: isOverBudget ? Colors.red : Colors.green,
                    ), // Status message style
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final recentTransactions = transactions
        .where((t) =>
            t.date.month == selectedMonth.month &&
            t.date.year == selectedMonth.year)
        .toList(); // Filter transactions for the selected month

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16), // Card padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.grey[700],
                  ), // Recent transactions label style
            ),
            SizedBox(height: 8), // Spacer
            ...recentTransactions
                .map((transaction) => ListTile(
                      title: Text(transaction.description), // Transaction description
                      subtitle: Text(transaction.date.toString()), // Transaction date
                      trailing: Text(
                        '\$${transaction.amount.toStringAsFixed(2)}', // Formatted transaction amount
                        style: TextStyle(
                          color: transaction.amount < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ), // Transaction amount style
                      ),
                    ))
                .toList(), // Map transactions to list tiles
          ],
        ),
      ),
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth, // Initial date is the selected month
      firstDate: DateTime(2000), // First date for the date picker
      lastDate: DateTime(2100), // Last date for the date picker
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo, // Primary color for the date picker
              onPrimary: Colors.white, // Text color on primary color
              onSurface: Colors.indigo, // Text color on surface color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedMonth) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month); // Update selected month
      });
    }
  }
}

class ManagePage extends StatefulWidget {
  final List<Transaction> transactions; // List of transactions
  final Function(Transaction) onAddTransaction; // Callback for adding a transaction
  final List<BudgetEntry> budgets; // List of budgets
  final Function(double) onUpdateBudget; // Callback for updating budget

  ManagePage({
    required this.transactions, // Required parameter for transactions
    required this.onAddTransaction, // Required parameter for adding a transaction
    required this.budgets, // Required parameter for budgets
    required this.onUpdateBudget, // Required parameter for updating budget
  });

  @override
  _ManagePageState createState() => _ManagePageState(); // Create the state for the manage page
}

class _ManagePageState extends State<ManagePage> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _amountController = TextEditingController(); // Controller for amount input
  final _descriptionController = TextEditingController(); // Controller for description input
  DateTime _selectedDate = DateTime.now(); // Selected date

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24), // Page padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
        children: [
          Text(
            'Manage Expenses',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.bold), // Manage expenses title style
          ),
          SizedBox(height: 24), // Spacer
          Form(
            key: _formKey, // Form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
              children: [
                TextFormField(
                  controller: _amountController, // Controller for amount input
                  decoration: InputDecoration(
                    labelText: 'Amount', // Label for amount input
                    prefixText: '\$', // Prefix for amount input
                  ),
                  keyboardType: TextInputType.number, // Keyboard type for number input
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount'; // Validation message for empty amount
                    }
                    return null; // No validation message
                  },
                ),
                SizedBox(height: 16), // Spacer
                TextFormField(
                  controller: _descriptionController, // Controller for description input
                  decoration: InputDecoration(
                    labelText: 'Description', // Label for description input
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description'; // Validation message for empty description
                    }
                    return null; // No validation message
                  },
                ),
                SizedBox(height: 16), // Spacer
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _selectDate(context); // Select date when button is pressed
                        },
                        icon: Icon(Icons.calendar_today_outlined), // Calendar icon
                        label: Text(
                            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'), // Formatted selected date
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24), // Spacer
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final double amount = double.tryParse(_amountController.text) ?? 0;
                      final String description = _descriptionController.text;

                      final newTransaction = Transaction(
                        amount: amount,
                        description: description,
                        date: _selectedDate,
                      ); // Create new transaction

                      widget.onAddTransaction(newTransaction); // Call callback to add transaction

                      _amountController.clear(); // Clear amount input
                      _descriptionController.clear(); // Clear description input
                      setState(() {
                        _selectedDate = DateTime.now(); // Reset selected date
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Transaction added successfully')),
                      ); // Show success message
                    }
                  },
                  child: Text('Add Transaction'), // Button label
                ),
              ],
            ),
          ),
          SizedBox(height: 32), // Spacer
          Text(
            'Manage Budget',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.bold), // Manage budget title style
          ),
          SizedBox(height: 24), // Spacer
          Form(
            key: _formKey, // Form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
              children: [
                TextFormField(
                  controller: _amountController, // Controller for amount input
                  decoration: InputDecoration(
                    labelText: 'Budget Amount', // Label for budget amount input
                    prefixText: '\$', // Prefix for budget amount input
                  ),
                  keyboardType: TextInputType.number, // Keyboard type for number input
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget amount'; // Validation message for empty amount
                    }
                    return null; // No validation message
                  },
                ),
                SizedBox(height: 16), // Spacer
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final double budgetAmount =
                          double.tryParse(_amountController.text) ?? 0;

                      widget.onUpdateBudget(budgetAmount); // Call callback to update budget

                      _amountController.clear(); // Clear amount input

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Budget updated successfully')),
                      ); // Show success message
                    }
                  },
                  child: Text('Update Budget'), // Button label
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Initial date is the selected date
      firstDate: DateTime(2000), // First date for the date picker
      lastDate: DateTime(2100), // Last date for the date picker
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo, // Primary color for the date picker
              onPrimary: Colors.white, // Text color on primary color
              onSurface: Colors.indigo, // Text color on surface color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update selected date
      });
    }
  }
}

class Transaction {
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.amount,
    required this.description,
    required this.date,
  });
}

class BudgetEntry {
  final double amount;
  final DateTime date;

  BudgetEntry({
    required this.amount,
    required this.date,
  });
}

void main() {
  runApp(ExpenseTrackerApp());
}
