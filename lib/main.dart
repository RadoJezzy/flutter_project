import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[800]),
          bodyMedium: TextStyle(color: Colors.grey[600]),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.indigo),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Transaction> transactions = [];
  List<BudgetEntry> budgets = [];
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [],
      ),
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.selected,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline),
                  selectedIcon: Icon(Icons.add_circle),
                  label: Text('Add'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: Text('Report'),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardPage(
                  transactions: transactions,
                  budgets: budgets,
                  selectedMonth: selectedMonth,
                ),
                ManagePage(
                  transactions: transactions,
                  onAddTransaction: _addTransaction,
                  budgets: budgets,
                  onUpdateBudget: _updateBudget,
                ),
                ReportPage(transactions: transactions, budgets: budgets),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle),
                  label: 'Add',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Report',
                ),
              ],
            )
          : null,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
    });
  }

  void _updateBudget(double budget) {
    setState(() {
      budgets.add(BudgetEntry(amount: budget, date: DateTime.now()));
    });
  }
}

class DashboardPage extends StatelessWidget {
  final List<Transaction> transactions;
  final List<BudgetEntry> budgets;
  final DateTime selectedMonth;

  DashboardPage({
    required this.transactions,
    required this.budgets,
    required this.selectedMonth,
  });

  get widget => null;

  String _formatMonth(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = transactions
        .where((t) =>
            t.date.month == selectedMonth.month &&
            t.date.year == selectedMonth.year &&
            t.amount < 0)
        .fold(0, (sum, t) => sum + t.amount.abs());

    double currentBudget = budgets
        .where((budget) =>
            budget.date.month == selectedMonth.month &&
            budget.date.year == selectedMonth.year)
        .fold(0, (sum, budget) => sum + budget.amount);

    bool isOverBudget = totalExpenses > currentBudget;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 24),
          _buildExpenseCard(context, totalExpenses),
          SizedBox(height: 24),
          if (currentBudget > 0)
            _buildBudgetCard(
                context, totalExpenses, currentBudget, isOverBudget),
          SizedBox(height: 24),
          _buildStatusCard(context, isOverBudget),
          SizedBox(height: 24),
          _buildRecentTransactions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.indigo[800],
                fontWeight: FontWeight.bold,
              ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedMonth,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != selectedMonth) {
              // Update the selected month and rebuild the widget
              widget.onMonthSelected(picked);
            }
          },
          icon: Icon(Icons.calendar_today, size: 18),
          label: Text(_formatMonth(selectedMonth)),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.indigo,
            backgroundColor: Colors.indigo[50],
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(BuildContext context, double totalExpenses) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.indigo[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              '\$${totalExpenses.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, double totalExpenses,
      double currentBudget, bool isOverBudget) {
    double percentUsed = (totalExpenses / currentBudget).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentUsed,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
              minHeight: 8,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetInfo('Spent', totalExpenses, Colors.red),
                _buildBudgetInfo('Budget', currentBudget, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInfo(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isOverBudget) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isOverBudget ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isOverBudget ? Icons.warning : Icons.check_circle,
              color: isOverBudget ? Colors.red[700] : Colors.green[700],
              size: 32,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                isOverBudget
                    ? 'You have exceeded your budget.'
                    : 'You are within your budget.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isOverBudget ? Colors.red[700] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    List<Transaction> recentTransactions = transactions
        .where((t) =>
            t.date.month == selectedMonth.month &&
            t.date.year == selectedMonth.year)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.indigo[800],
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: recentTransactions.take(5).length,
          itemBuilder: (context, index) {
            final transaction = recentTransactions[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.amount < 0
                      ? Colors.red[100]
                      : Colors.green[100],
                  child: Icon(
                    transaction.amount < 0 ? Icons.remove : Icons.add,
                    color: transaction.amount < 0 ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(
                  transaction.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(transaction.category),
                trailing: Text(
                  '\$${transaction.amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.amount < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ManagePage extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onAddTransaction;
  final List<BudgetEntry> budgets;
  final Function(double) onUpdateBudget;

  ManagePage({
    required this.transactions,
    required this.onAddTransaction,
    required this.budgets,
    required this.onUpdateBudget,
  });

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final _expenseFormKey = GlobalKey<FormState>();
  final _budgetFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedCategory = 'Food';

  @override
  void initState() {
    super.initState();
    _budgetController.text =
        widget.budgets.isNotEmpty ? widget.budgets.last.amount.toString() : '0';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Expense',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.indigo[800],
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: _buildExpenseForm(),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Set Monthly Budget',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.indigo[800],
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: _buildBudgetForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    return Form(
      key: _expenseFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
            ),
            items: ['Food', 'Transportation', 'Entertainment', 'Bills', 'Other']
                .map((category) =>
                    DropdownMenuItem(value: category, child: Text(category)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitExpense,
            child: Text('Add Expense'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetForm() {
    return Form(
      key: _budgetFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _budgetController,
            decoration: InputDecoration(
              labelText: 'Monthly Budget',
              prefixIcon: Icon(Icons.account_balance_wallet),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a budget';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _updateBudget,
            child: Text('Update Budget'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  void _submitExpense() {
    if (_expenseFormKey.currentState!.validate()) {
      widget.onAddTransaction(Transaction(
        title: _titleController.text,
        category: _selectedCategory,
        amount: -double.parse(_amountController.text), // Negative for expenses
        date: DateTime.now(),
      ));
      _titleController.clear();
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully')),
      );
    }
  }

  void _updateBudget() {
    if (_budgetFormKey.currentState!.validate()) {
      widget.onUpdateBudget(double.parse(_budgetController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget updated successfully')),
      );
    }
  }
}

class ReportPage extends StatelessWidget {
  final List<Transaction> transactions;
  final List<BudgetEntry> budgets;

  ReportPage({required this.transactions, required this.budgets});

  @override
  Widget build(BuildContext context) {
    List<dynamic> allTransactions = [
      ...transactions,
      ...budgets.map((budget) => Transaction(
            title: 'Monthly Budget',
            category: 'Budget',
            amount: budget.amount,
            date: budget.date,
          )),
    ];

    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.indigo[800],
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: allTransactions.length,
              itemBuilder: (context, index) {
                final transaction = allTransactions[index];
                bool isExpense = transaction.amount < 0;
                bool isBudget = transaction.category == 'Budget';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isBudget
                          ? Colors.blue[100]
                          : (isExpense ? Colors.red[100] : Colors.green[100]),
                      child: Icon(
                        isBudget
                            ? Icons.account_balance_wallet
                            : (isExpense ? Icons.remove : Icons.add),
                        color: isBudget
                            ? Colors.blue[700]
                            : (isExpense ? Colors.red[700] : Colors.green[700]),
                      ),
                    ),
                    title: Text(
                      transaction.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${transaction.category} • ${transaction.date.toString().substring(0, 10)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      '\$${transaction.amount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isBudget
                            ? Colors.blue[700]
                            : (isExpense ? Colors.red[700] : Colors.green[700]),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  Transaction({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });
}

class BudgetEntry {
  final double amount;
  final DateTime date;

  BudgetEntry({required this.amount, required this.date});
}
