import 'package:project/pages/transactions_page.dart';
import 'package:project/pages/create_budget_page.dart';
import 'package:project/pages/my_budgets_page.dart';
import 'package:project/pages/profile_page.dart';
import 'package:project/pages/stats_page.dart';
import 'package:project/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;

  List<Widget> pages = [
    MyBudgetsPage(), // Index 0
    TransactionsPage(), // Index 1
    StatsPage(), // Index 2
    ProfilePage(), // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getFooter() {
    List<IconData> iconItems = [
      Ionicons.md_home, // Home icon
Ionicons.md_wallet, // Wallet icon
Ionicons.md_podium, // Analytics icon
Ionicons.md_settings, // Settings icon
    ];

    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: Colors.white,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // First two icons
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      iconItems[0],
                      color: pageIndex == 0
                          ? secondary1
                          : Colors.black.withOpacity(0.5),
                      size: 25,
                    ),
                    onPressed: () => selectedTab(0),
                  ),
                  IconButton(
                    icon: Icon(
                      iconItems[1],
                      color: pageIndex == 1
                          ? secondary1
                          : Colors.black.withOpacity(0.5),
                      size: 25,
                    ),
                    onPressed: () => selectedTab(1),
                  ),
                ],
              ),
            ),

            // Center button for Create Budget
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateBudgetPage()),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondary1,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/images/logo-homespend.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),

            // Last two icons
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      iconItems[2],
                      color: pageIndex == 2
                          ? secondary1
                          : Colors.black.withOpacity(0.5),
                      size: 25,
                    ),
                    onPressed: () => selectedTab(2),
                  ),
                  IconButton(
                    icon: Icon(
                      iconItems[3],
                      color: pageIndex == 3
                          ? secondary1
                          : Colors.black.withOpacity(0.5),
                      size: 25,
                    ),
                    onPressed: () => selectedTab(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectedTab(int index) {
    setState(() {
      pageIndex = index;
    });
  }
}
