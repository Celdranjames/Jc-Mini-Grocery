import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'items_page.dart'; // Added import for your new API page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Sign-out function
  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Updated AppBar to Deep Purple
      appBar: AppBar(
        title: const Text(
          'JC Mini Mart',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      // 2. Updated Navigation Drawer with Flowchart Features
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Store Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.deepPurple),
              title: Text('Home'),
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.deepPurple),
              title: Text('My Cart (Quick Order)'), // From Flowchart
            ),
            ListTile(
              leading: Icon(Icons.stars, color: Colors.deepPurple),
              title: Text('Earn & Spend Points'), // Unique Service
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.deepPurple),
              title: Text('Order History'),
            ),
          ],
        ),
      ),

      // 3. Main Body with Welcome Message and Custom Cards
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // --- Centered Welcome Message ---
            const Center(
              child: Text(
                'Welcome to JC Mini Mart!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                'Shop smart. Earn points. Pay with points.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            // --- Upgraded Points Card (Unique Service) ---
            Card(
              elevation: 6,
              shadowColor: Colors.deepPurple.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade800,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(20.0),
                child: const Column(
                  children: [
                    Text(
                      'Current Points Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '500 pts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Browse Categories Card (Now Clickable) ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.deepPurple.shade50,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  // Navigates to your API Items Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ItemsPage()),
                  );
                },
                child: const ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  leading: Icon(
                    Icons.fastfood,
                    color: Colors.deepPurple,
                    size: 30,
                  ),
                  title: Text(
                    'Browse Snacks, Drinks & Household Items',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 4. Updated Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          debugPrint("Cart Opened!");
        },
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
    );
  }
}
