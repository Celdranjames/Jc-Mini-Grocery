import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/user_grocery_items.dart';

// Added Global Cart List to store items across screens
List<Map<String, dynamic>> globalCart = [];

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  GroceryItems? groceryItems;
  bool isDataLoaded = false;
  String errorMessage = '';
  String? selectedCategory; // Tracks which category is clicked

  // Added variable to hold the search text
  String searchQuery = '';

  Future<void> getDataFromAPI() async {
    Uri uri = Uri.parse(
      'https://gist.githubusercontent.com/Celdranjames/67bd8e08f053d5f7c38164ad528d3bee/raw/79a09634c26dda49c5cdbec7cf9d0ce2ff884dca/grocery.json',
    ); // Keep your Gist URL here

    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        GroceryItems fetchedData = groceryItemsFromJson(response.body);
        setState(() {
          groceryItems = fetchedData;
          isDataLoaded = true;
        });
      } else {
        setState(() {
          errorMessage = '${response.statusCode}: ${response.body}';
          isDataLoaded = true;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isDataLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory == null ? 'Store Categories' : selectedCategory!,
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        // Add a back button if they are viewing items inside a category
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedCategory = null; // Go back to category list
                    searchQuery = ''; // Clear search when going back
                  });
                },
              )
            : null,
      ),
      body: isDataLoaded
          ? errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : groceryItems == null || groceryItems!.data.isEmpty
                ? const Center(child: Text('No Data Found'))
                : selectedCategory == null
                ? _buildCategoryList() // Step 1: Show Categories
                : _buildFilteredItemList() // Step 2: Show Items in Category
          : const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
    );
  }

  // Widget to display unique categories as cards
  Widget _buildCategoryList() {
    // Get unique categories from the API data list
    List<String> categories = groceryItems!.data
        .map((item) => item.category)
        .toSet()
        .toList();

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        String category = categories[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: const Icon(
              Icons.folder,
              color: Colors.deepPurple,
              size: 30,
            ),
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.deepPurple,
            ),
            onTap: () {
              setState(() {
                selectedCategory = category; // Filter items by this category
              });
            },
          ),
        );
      },
    );
  }

  // Widget to display only items belonging to the selected category
  Widget _buildFilteredItemList() {
    // Update to filter by BOTH the selected category AND the search query
    List<ItemData> filteredItems = groceryItems!.data
        .where(
          (item) =>
              item.category == selectedCategory &&
              item.itemName.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Column(
      children: [
        // Added Search Bar for Filtering
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value; // Update the list as the user types
              });
            },
          ),
        ),

        // Wrapped your existing ListView.builder in an Expanded widget
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.itemImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 30),
                    ),
                  ),
                  title: Text(
                    item.itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.category),
                  // Functional Add Button replaces the Check/X
                  trailing: item.inStock
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsPage(item: item),
                              ),
                            );
                          },
                          child: const Text(
                            'Add',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : const Text(
                          'Sold Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(item: item),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Product Details Page Class ---
class ProductDetailsPage extends StatefulWidget {
  final ItemData item;

  const ProductDetailsPage({super.key, required this.item});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.itemName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.item.itemImage,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.item.itemName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.inStock
                  ? 'In Stock - Ready to order'
                  : 'Out of Stock',
              style: TextStyle(
                fontSize: 16,
                color: widget.item.inStock ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) setState(() => quantity--);
                  },
                  icon: const Icon(
                    Icons.remove_circle,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => quantity++);
                  },
                  icon: const Icon(
                    Icons.add_circle,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.item.inStock
                    ? () {
                        // Cart Saving Logic
                        bool alreadyInCart = false;
                        for (var cartItem in globalCart) {
                          if (cartItem['item'].itemName ==
                              widget.item.itemName) {
                            cartItem['quantity'] += quantity;
                            alreadyInCart = true;
                            break;
                          }
                        }
                        if (!alreadyInCart) {
                          globalCart.add({
                            'item': widget.item,
                            'quantity': quantity,
                          });
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $quantity x ${widget.item.itemName} to cart!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- The Cart Display Screen ---
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: globalCart.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: globalCart.length,
                    itemBuilder: (context, index) {
                      final cartData = globalCart[index];
                      final item = cartData['item'] as ItemData;
                      final qty = cartData['quantity'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.itemImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item.itemName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Quantity: $qty'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                globalCart.removeAt(
                                  index,
                                ); // Remove item from cart
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          globalCart.clear();
                        }); // Empty the cart on checkout
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Checkout successful!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
