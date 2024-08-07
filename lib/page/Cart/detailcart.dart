import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/sqlite.dart';
import '../../model/cart.dart';
import 'checkout.dart';

class Detailcart extends StatefulWidget {
  const Detailcart({super.key});

  @override
  State<Detailcart> createState() => _DetailcartState();
}

class _DetailcartState extends State<Detailcart> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Cart>> _getProducts() async {
    return await _databaseHelper.products();
  }

  Future<double> _getTotalAmount() async {
    List<Cart> products = await _getProducts();
    double totalAmount =
        products.fold(0, (sum, item) => sum + (item.price * item.count));
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: FutureBuilder<List<Cart>>(
              future: _getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Không có sản phẩm nào trong giỏ hàng'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final itemProduct = snapshot.data![index];
                            return _buildProduct(itemProduct, context);
                          },
                        ),
                      ),
                      FutureBuilder<double>(
                        future: _getTotalAmount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData) {
                            return const Text('Không thể tính tổng thanh toán');
                          }

                          final totalAmount = snapshot.data ?? 0.0;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tổng thanh toán:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  NumberFormat('###,###.0').format(totalAmount),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                List<Cart> cartItems = await _getProducts();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Checkout(cartItems: cartItems),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Thanh toán',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProduct(Cart product, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (product.img.isNotEmpty && product.img != 'Null')
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Image.network(
                  product.img,
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      product.img,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: Colors.red);
                      },
                    );
                  },
                ),
              )
            else
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Mô tả: ${product.des}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        const Text(
                          'Số lượng: ',
                          style: TextStyle(fontSize: 12),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (product.count < 2) {
                                _databaseHelper.deleteProduct(product);
                                setState(() {});
                              }
                              _databaseHelper.minus(product);
                            });
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                        Text(
                          '${product.count}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _databaseHelper.add(product);
                            });
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Đơn giá: ${product.price.toString()}đ',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Tổng giá: ${product.price * product.count}đ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _databaseHelper.deleteProduct(product);
                setState(() {});
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
