import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';
import 'package:shop/services/product_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _shareApplied = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final applied = await _applySharedCartIfAny();
    if (!applied) {
      await _ensureCartLoaded();
    }
  }

  Future<void> _ensureCartLoaded() async {
    final userId = await AuthService.getUserId();
    if (!mounted || userId == null) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) {
      cart.setUser(userId);
    }
  }

  Future<bool> _applySharedCartIfAny() async {
    if (!kIsWeb || _shareApplied) return false;

    final fragment = Uri.base.fragment; // Exemple: /cart?items=...
    if (!fragment.startsWith('/$cartScreenRoute')) return false;

    final questionMarkIndex = fragment.indexOf('?');
    if (questionMarkIndex == -1 || questionMarkIndex == fragment.length - 1) {
      return false;
    }

    final queryString = fragment.substring(questionMarkIndex + 1);
    Map<String, String> params;
    try {
      params = Uri.splitQueryString(queryString);
    } catch (_) {
      return false;
    }

    final itemsParam = params['items'];
    if (itemsParam == null || itemsParam.isEmpty) return false;

    // itemsParam est un token encodé en base64Url contenant
    // une chaîne du type "idA:2,idB:1,...".
    String decodedItems;
    try {
      decodedItems = utf8.decode(base64Url.decode(itemsParam));
    } catch (_) {
      // Rétrocompatibilité si jamais itemsParam est déjà une chaîne brute
      decodedItems = itemsParam;
    }

    final entries = decodedItems.split(',');
    if (entries.isEmpty) return false;

    final cart = Provider.of<CartProvider>(context, listen: false);

    // On remplace le panier actuel par le panier partagé
    cart.clear();

    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;

      final productId = parts[0];
      final quantity = int.tryParse(parts[1]) ?? 1;

      final product = await ProductService.getProductById(productId);
      if (product == null) continue;

      // On reconstruit le panier partagé uniquement côté frontend,
      // sans re-synchroniser chaque ajout avec le backend pour éviter
      // les doublons éventuels.
      cart.addToCart(product, quantity: quantity, syncBackend: false);
    }

    _shareApplied = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        actions: [
          // Icône de recherche
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, searchScreenRoute);
            },
          ),
          // Icône de partage
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Partager le panier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        ListTile(
                          leading: SizedBox(
                            width: 24,
                            height: 24,
                            child: Image.network(
                              // PNG thumbnail of the Messenger logo (works on web)
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Facebook_Messenger_logo_2020.svg/240px-Facebook_Messenger_logo_2020.svg.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          title: const Text('Messenger'),
                          onTap: () {
                            // TODO: implémenter le partage via Messenger
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: SizedBox(
                            width: 24,
                            height: 24,
                            child: Image.network(
                              // PNG version of the WhatsApp logo to avoid flutter_svg
                              'https://upload.wikimedia.org/wikipedia/commons/5/5e/WhatsApp_icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          title: const Text('WhatsApp'),
                          onTap: () {
                            // TODO: implémenter le partage via WhatsApp
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/4/4e/Gmail_Icon.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          title: const Text('Email'),
                          onTap: () async {
                            final subjectText = 'Mon panier';
                            final buffer = StringBuffer();
                            buffer.writeln('Voici le contenu de mon panier :');
                            for (final item in cart.items) {
                              buffer.writeln(
                                  '- ${item.product.name} (x${item.quantity}) : ${item.totalPrice.toStringAsFixed(2)}');
                            }
                            buffer.writeln(
                                '\nTotal : ${cart.totalPrice.toStringAsFixed(2)}');

                            // Ajout d'un lien vers l'application (page Panier)
                            if (kIsWeb) {
                              final base = Uri.base;
                              // Exemple final: https://localhost:xxxxx/#/cart?items=<token_base64>

                              final rawItems = cart.items
                                  .map((item) => '${item.product.id}:${item.quantity}')
                                  .join(',');

                              final itemsToken =
                                  base64Url.encode(utf8.encode(rawItems));

                              final fragment =
                                  '/$cartScreenRoute?items=$itemsToken';

                              final cartUrl = Uri(
                                scheme: base.scheme,
                                host: base.host,
                                port: base.port,
                                fragment: fragment,
                              ).toString();
                              buffer.writeln('\nVoir ce panier dans l\'application :');
                              buffer.writeln(cartUrl);
                            }

                            final bodyText = buffer.toString();

                            Uri emailUri;
                            if (kIsWeb) {
                              // Sur le Web, ouvrir directement Gmail dans un nouvel onglet
                              emailUri = Uri.https(
                                'mail.google.com',
                                '/mail/',
                                {
                                  'view': 'cm',
                                  'fs': '1',
                                  'su': subjectText,
                                  'body': bodyText,
                                },
                              );
                            } else {
                              // Sur mobile / desktop natif, utiliser le schéma mailto:
                              emailUri = Uri(
                                scheme: 'mailto',
                                queryParameters: {
                                  'subject': subjectText,
                                  'body': bodyText,
                                },
                              );
                            }

                            if (await canLaunchUrl(emailUri)) {
                              await launchUrl(emailUri);
                            }

                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : ListView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: defaultPadding),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item.product.firstImage),
                    ),
                    title: Text(item.product.name),
                    subtitle: Text(
                        'Prix: ${item.product.price.toStringAsFixed(2)}  x ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            cart.removeOne(item.product);
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            cart.addToCart(item.product);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            cart.removeItem(item.product);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    cart.totalPrice.toStringAsFixed(2),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: implémenter la logique de "meilleur trajet" ici
                  },
                  child: const Text('Trouver le meilleur trajet'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
