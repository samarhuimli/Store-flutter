import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/components/Banner/M/banner_m_style_1.dart';
import 'package:shop/components/Banner/M/banner_m_style_2.dart';
import 'package:shop/components/Banner/M/banner_m_style_3.dart';
import 'package:shop/components/Banner/M/banner_m_style_4.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/components/dot_indicators.dart';

import '../../../../constants.dart';

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({
    super.key,
  });

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  // Offers List
  late final List<Widget> offers;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);

    // Initialise les bannières avec navigation
    offers = [
      BannerMStyle1(
        image: 'assets/images/bons_plans_noel.jpg',
        text: "BONS PLANS \nNOL",
        press: () {
          Navigator.pushNamed(context, discoverScreenRoute);
        },
      ),
      BannerMStyle2(
        // 2ᵉ slide : image locale, à partir de l’URL Pinterest que tu as donnée
        image: 'assets/images/carousel_2.jpg',
        title: "Black \nfriday",
        subtitle: "Collection",
        discountParcent: 50,
        press: () {
          Navigator.pushNamed(context, onSaleScreenRoute);
        },
      ),
      BannerMStyle3(
        // 3ᵉ slide : image locale, à partir de l’URL pinimg que tu as donnée
        image: 'assets/images/carousel_3.jpg',
        title: "Grab \nyours now",
        discountParcent: 50,
        press: () {
          Navigator.pushNamed(context, onSaleScreenRoute);
        },
      ),
      BannerMStyle4(
        title: "SUMMER \nSALE",
        subtitle: "SPECIAL OFFER",
        discountParcent: 80,
        press: () {
          Navigator.pushNamed(context, onSaleScreenRoute);
        },
      ),
    ];
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_selectedIndex < offers.length - 1) {
        _selectedIndex++;
      } else {
        _selectedIndex = 0;
      }

      _pageController.animateToPage(
        _selectedIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.87,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: offers.length,
            onPageChanged: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            itemBuilder: (context, index) => offers[index],
          ),
          FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: List.generate(
                    offers.length,
                    (index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: defaultPadding / 4),
                        child: DotIndicator(
                          isActive: index == _selectedIndex,
                          activeColor: Colors.white70,
                          inActiveColor: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
