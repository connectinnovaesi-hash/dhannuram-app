import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const DhannuramApp());
}

class DhannuramApp extends StatelessWidget {
  const DhannuramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dhannuram Sweets & Restaurant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: const HomeScreen(),
    );
  }
}

/// ---------- Mock Data ----------
enum Category { breakfast, lunch, dinner, chinese, sweets, snacks, beverages }

class MenuItem {
  final String id;
  final String name;
  final String description;
  final Category category;
  final int price; // in INR
  final bool isVeg;
  final double rating;
  final String image;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.isVeg,
    required this.rating,
    required this.image,
  });
}

final restaurantLocation = const LatLng(28.7503, 77.2901); // approx. Loni, Ghaziabad
const restaurantAddress =
    'Dhannuram Sweets & Restaurant, Loni, Ghaziabad';

final demoMenu = <MenuItem>[
  MenuItem(
    id: 'b1',
    name: 'Aloo Paratha with Curd',
    description: 'Tawa paratha + dahi + achar',
    category: Category.breakfast,
    price: 89,
    isVeg: true,
    rating: 4.5,
    image:
        'https://images.unsplash.com/photo-1604908813114-8f6b0d5f1c7a?w=800', // replace later
  ),
  MenuItem(
    id: 'b2',
    name: 'Chole Bhature',
    description: 'Classic Delhi style',
    category: Category.breakfast,
    price: 119,
    isVeg: true,
    rating: 4.6,
    image:
        'https://images.unsplash.com/photo-1625944526155-2c1a3f2f6f8a?w=800',
  ),
  MenuItem(
    id: 'l1',
    name: 'Paneer Butter Masala',
    description: 'Rich tomato & cream gravy',
    category: Category.lunch,
    price: 229,
    isVeg: true,
    rating: 4.7,
    image:
        'https://images.unsplash.com/photo-1625944573530-7b0c2e0c2f3a?w=800',
  ),
  MenuItem(
    id: 'd1',
    name: 'Dal Makhani (Family Pack)',
    description: 'Slow cooked overnight',
    category: Category.dinner,
    price: 249,
    isVeg: true,
    rating: 4.8,
    image:
        'https://images.unsplash.com/photo-1617191519400-9705f7a7f0a0?w=800',
  ),
  MenuItem(
    id: 'c1',
    name: 'Veg Hakka Noodles',
    description: 'Indo-Chinese style',
    category: Category.chinese,
    price: 149,
    isVeg: true,
    rating: 4.4,
    image:
        'https://images.unsplash.com/photo-1598866594230-a5aaf9d98f7b?w=800',
  ),
  MenuItem(
    id: 'c2',
    name: 'Chilli Paneer (Dry)',
    description: 'Crispy & spicy',
    category: Category.chinese,
    price: 189,
    isVeg: true,
    rating: 4.5,
    image:
        'https://images.unsplash.com/photo-1617191513222-9d7b8e07c7d8?w=800',
  ),
  MenuItem(
    id: 's1',
    name: 'Gulab Jamun (2 pc)',
    description: 'Kesar infused',
    category: Category.sweets,
    price: 59,
    isVeg: true,
    rating: 4.9,
    image:
        'https://images.unsplash.com/photo-1625944621161-9b3a1b6d9b36?w=800',
  ),
  MenuItem(
    id: 'sn1',
    name: 'Samosa (2 pc)',
    description: 'Punjabi style, chutney',
    category: Category.snacks,
    price: 39,
    isVeg: true,
    rating: 4.6,
    image:
        'https://images.unsplash.com/photo-1625944807829-010c0e0f5c7e?w=800',
  ),
  MenuItem(
    id: 'bev1',
    name: 'Masala Chai',
    description: 'Elaichi, adrak',
    category: Category.beverages,
    price: 25,
    isVeg: true,
    rating: 4.7,
    image:
        'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=800',
  ),
];

/// ---------- Cart State (In-memory) ----------
class CartItem {
  final MenuItem item;
  int qty;
  CartItem(this.item, this.qty);
}

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  List<CartItem> get items => _items.values.toList();

  void add(MenuItem item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.qty++;
    } else {
      _items[item.id] = CartItem(item, 1);
    }
    notifyListeners();
  }

  void removeOne(String id) {
    if (!_items.containsKey(id)) return;
    final ci = _items[id]!;
    if (ci.qty > 1) {
      ci.qty--;
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int get total {
    int t = 0;
    for (final ci in _items.values) {
      t += ci.item.price * ci.qty;
    }
    return t;
  }

  bool get isEmpty => _items.isEmpty;
}

/// ---------- UI ----------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CartModel cart = CartModel();
  Category selected = Category.breakfast;
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png', // put your logo here
                height: 32,
                width: 32,
                errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Dhannuram Sweets & Restaurant'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Directions',
            onPressed: _openDirections,
            icon: const Icon(Icons.directions),
          ),
          IconButton(
            tooltip: 'Call',
            onPressed: () => _dialNumber('+91-XXXXXXXXXX'),
            icon: const Icon(Icons.call),
          ),
        ],
      ),
      body: Column(
        children: [
          const _OpenBadge(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search dishes or sweets…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
            ),
          ),
          _CategoryChips(
            selected: selected,
            onChanged: (c) => setState(() => selected = c),
          ),
          Expanded(
            child: _MenuList(
              items: _filtered(),
              onAdd: cart.add,
            ),
          ),
        ],
      ),
      floatingActionButton: _CartFab(cart: cart),
    );
  }

  List<MenuItem> _filtered() {
    return demoMenu.where((m) {
      final matchCat = m.category == selected;
      final matchQuery =
          query.isEmpty || m.name.toLowerCase().contains(query);
      return matchCat && matchQuery;
    }).toList();
  }

  Future<void> _openDirections() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${restaurantLocation.lat},${restaurantLocation.lng}'
        '&destination_place_id=&travelmode=driving';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _dialNumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.timer_outlined),
          SizedBox(width: 8),
          Text('Open • 24 hours (Mon–Sun)'),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final Category selected;
  final ValueChanged<Category> onChanged;
  const _CategoryChips({required this.selected, required this.onChanged});

  static const labels = {
    Category.breakfast: 'Breakfast',
    Category.lunch: 'Lunch',
    Category.dinner: 'Dinner',
    Category.chinese: 'Chinese',
    Category.sweets: 'Sweets',
    Category.snacks: 'Snacks',
    Category.beverages: 'Beverages',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: Category.values.length,
        itemBuilder: (context, i) {
          final c = Category.values[i];
          final selectedBool = c == selected;
          return ChoiceChip(
            label: Text(labels[c]!),
            selected: selectedBool,
            onSelected: (_) => onChanged(c),
          );
        },
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final List<MenuItem> items;
  final Function(MenuItem) onAdd;
  const _MenuList({required this.items, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final m = items[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => ItemDetailScreen(item: m))),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  child: Image.network(
                    m.image,
                    height: 100, width: 110, fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(m.isVeg ? Icons.stop_circle : Icons.stop_circle_outlined,
                              size: 14, color: m.isVeg ? Colors.green : Colors.red),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(m.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(m.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 14),
                                  const SizedBox(width: 2),
                                  Text(m.rating.toStringAsFixed(1)),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text('₹${m.price}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => onAdd(m),
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ItemDetailScreen extends StatefulWidget {
  final MenuItem item;
  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final m = widget.item;
    return Scaffold(
      appBar: AppBar(title: Text(m.name)),
      body: ListView(
        children: [
          Image.network(m.image, height: 220, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(m.isVeg ? Icons.stop_circle : Icons.stop_circle_outlined,
                      size: 16, color: m.isVeg ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Text(m.name, style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                Text(m.description),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.star, size: 16),
                        const SizedBox(width: 4),
                        Text(m.rating.toStringAsFixed(1)),
                      ]),
                    ),
                    const Spacer(),
                    Text('₹${m.price}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(onPressed: () => setState(() { if (qty>1) qty--; }),
                        icon: const Icon(Icons.remove_circle_outline)),
                    Text('$qty', style: const TextStyle(fontSize: 18)),
                    IconButton(onPressed: () => setState(() { qty++; }),
                        icon: const Icon(Icons.add_circle_outline)),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $qty × ${m.name} to cart')),
                        );
                      },
                      child: const Text('Add to Cart'),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartFab extends StatelessWidget {
  final CartModel cart;
  const _CartFab({required this.cart});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CartScreen(cart: cart)),
      ),
      icon: const Icon(Icons.shopping_bag),
      label: Text(cart.isEmpty ? 'Cart' : '₹${cart.total} • View Cart'),
    );
  }
}

class CartScreen extends StatefulWidget {
  final CartModel cart;
  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final ci in cart.items)
                  Card(
                    child: ListTile(
                      title: Text(ci.item.name),
                      subtitle: Text('₹${ci.item.price} × ${ci.qty}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => setState(() => cart.removeOne(ci.item.id)),
                            icon: const Icon(Icons.remove),
                          ),
                          Text('${ci.qty}'),
                          IconButton(
                            onPressed: () => setState(() => cart.add(ci.item)),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                _PriceSummary(total: cart.total),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const CheckoutScreen(),
                    ));
                  },
                  icon: const Icon(Icons.lock),
                  label: Text('Checkout • ₹${cart.total}'),
                ),
              ],
            ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final int total;
  const _PriceSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    final gst = (total * 0.05).round();
    final grand = total + gst;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _row('Item Total', '₹$total'),
            _row('GST (5%)', '₹$gst'),
            const Divider(),
            _row('Grand Total', '₹$grand', bold: true),
          ],
        ),
      ),
    );
  }

  Row _row(String l, String r, {bool bold = false}) {
    return Row(
      children: [
        Text(l, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        const Spacer(),
        Text(r, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            title: Text('Delivery Address'),
            subtitle: Text('Add/Select your address'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Payment Method'),
            subtitle: Text('COD / UPI (coming soon)'),
            trailing: Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const OrderTrackingScreen()));
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Order Placed', Icons.receipt_long),
      ('Accepted by Restaurant', Icons.restaurant),
      ('Being Prepared', Icons.kitchen),
      ('Out for Delivery', Icons.delivery_dining),
      ('Delivered', Icons.home),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) => ListTile(
          leading: Icon(steps[i].$2),
          title: Text(steps[i].$1),
          subtitle: Text(i == 0 ? 'Just now' : 'Pending'),
        ),
      ),
    );
  }
}

/// --- Utility types ---
class LatLng {
  final double lat, lng;
  const LatLng(this.lat, this.lng);
}
