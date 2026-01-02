import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/search/views/components/search_form.dart';
import 'package:shop/services/product_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<ProductModel>> _productsFuture;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _loadProducts() async {
    final products = await ProductService.getProducts();
    _allProducts = products;
    _filteredProducts = products;
    return products;
  }

  void _onSearchChanged(String? query) {
    final q = (query ?? '').trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((p) {
          final name = p.name.toLowerCase();
          final brand = (p.brand ?? '').toLowerCase();
          return name.contains(q) || brand.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchForm(
              autofocus: true,
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erreur de chargement des produits'),
                    );
                  }

                  if (_filteredProducts.isEmpty) {
                    return const Center(
                      child: Text('Aucun produit trouvé'),
                    );
                  }

                  return ListView.separated(
                    itemCount: _filteredProducts.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final p = _filteredProducts[index];
                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            productDetailsScreenRoute,
                            arguments: p,
                          );
                        },
                        leading: SizedBox(
                          width: 56,
                          height: 56,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            child: Image.network(
                              p.firstImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          (p.brand ?? 'Unknown') +
                              ' • ' +
                              (p.categoryName ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '\$${(p.discountedPrice ?? p.price).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF31B0D8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
