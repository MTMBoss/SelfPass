import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef SymbolSelectedCallback = void Function(IconData icon, Color? color);

class SymbolFamiliesSelector extends StatefulWidget {
  final SymbolSelectedCallback onSymbolSelected;

  const SymbolFamiliesSelector({super.key, required this.onSymbolSelected});
  @override
  SymbolFamiliesSelectorState createState() => SymbolFamiliesSelectorState();
}

class SymbolFamiliesSelectorState extends State<SymbolFamiliesSelector> {
  final PageController _pageController = PageController();

  // Define symbol families with icons
  final Map<String, List<IconData>> _symbolFamilies = {
    'Letters': [
      Icons.filter_1,
      Icons.filter_2,
      Icons.filter_3,
      Icons.filter_4,
      Icons.filter_5,
      Icons.filter_6,
      Icons.filter_7,
      Icons.filter_8,
      Icons.filter_9,
      Icons.filter_9_plus,
      Icons.ac_unit,
      Icons.access_alarm,
      Icons.accessibility,
      Icons.account_balance,
      Icons.ad_units,
      Icons.add_alert,
      Icons.airplanemode_active,
      Icons.album,
      Icons.all_inbox,
      Icons.anchor,
    ],
    'Numbers': [
      Icons.looks_one,
      Icons.looks_two,
      Icons.looks_3,
      Icons.looks_4,
      Icons.looks_5,
      Icons.looks_6,
      Icons.exposure_plus_1,
      Icons.exposure_plus_2,
      Icons.exposure_neg_1,
      Icons.exposure_neg_2,
      Icons.exposure_minus_1,
      Icons.exposure_minus_2,
    ],
    'Finance': [
      Icons.attach_money,
      Icons.money_off,
      Icons.account_balance_wallet,
      Icons.credit_card,
      Icons.savings,
      Icons.trending_up,
      Icons.pie_chart,
      Icons.bar_chart,
      Icons.show_chart,
    ],
    'Internet': [
      Icons.language,
      Icons.wifi,
      Icons.cloud,
      Icons.cloud_queue,
      Icons.cloud_off,
      Icons.cloud_done,
      Icons.http,
      Icons.router,
      Icons.phonelink,
      Icons.phonelink_off,
    ],
    'Various': [
      Icons.cake,
      Icons.local_cafe,
      Icons.local_dining,
      Icons.local_bar,
      Icons.local_florist,
      Icons.local_gas_station,
      Icons.local_hospital,
      Icons.local_library,
      Icons.local_mall,
      Icons.local_movies,
    ],
    'Personal': [
      Icons.person,
      Icons.person_add,
      Icons.person_outline,
      Icons.face,
      Icons.child_care,
      Icons.pregnant_woman,
      Icons.accessibility_new,
      Icons.family_restroom,
      Icons.wc,
    ],
    'Technology': [
      Icons.computer,
      Icons.smartphone,
      Icons.tablet,
      Icons.watch,
      Icons.headset,
      Icons.videogame_asset,
      Icons.memory,
      Icons.router,
      Icons.usb,
    ],
    'Transport': [
      Icons.directions_car,
      Icons.directions_bike,
      Icons.directions_boat,
      Icons.directions_bus,
      Icons.directions_railway,
      Icons.directions_subway,
      Icons.airplanemode_active,
      Icons.local_taxi,
      Icons.train,
    ],
    'FontAwesome': [
      FontAwesomeIcons.addressBook,
      FontAwesomeIcons.sprayCanSparkles,
      FontAwesomeIcons.anchor,
      FontAwesomeIcons.appleWhole,
      FontAwesomeIcons.basketball,
      FontAwesomeIcons.bell,
      FontAwesomeIcons.bicycle,
      FontAwesomeIcons.bolt,
      FontAwesomeIcons.bomb,
      FontAwesomeIcons.book,
      FontAwesomeIcons.bug,
      FontAwesomeIcons.mugSaucer,
      FontAwesomeIcons.couch,
      FontAwesomeIcons.dog,
      FontAwesomeIcons.dove,
      FontAwesomeIcons.feather,
      FontAwesomeIcons.jetFighter,
      FontAwesomeIcons.fire,
      FontAwesomeIcons.fish,
      FontAwesomeIcons.frog,
      FontAwesomeIcons.gamepad,
      FontAwesomeIcons.gem,
      FontAwesomeIcons.gift,
      FontAwesomeIcons.champagneGlasses,
      FontAwesomeIcons.burger,
      FontAwesomeIcons.heart,
      FontAwesomeIcons.house,
      FontAwesomeIcons.horse,
      FontAwesomeIcons.iceCream,
      FontAwesomeIcons.joint,
      FontAwesomeIcons.key,
      FontAwesomeIcons.leaf,
      FontAwesomeIcons.lemon,
      FontAwesomeIcons.lightbulb,
      FontAwesomeIcons.lock,
      FontAwesomeIcons.moon,
      FontAwesomeIcons.motorcycle,
      FontAwesomeIcons.music,
      FontAwesomeIcons.paperPlane,
      FontAwesomeIcons.paw,
      FontAwesomeIcons.plane,
      FontAwesomeIcons.robot,
      FontAwesomeIcons.rocket,
      FontAwesomeIcons.star,
      FontAwesomeIcons.sun,
      FontAwesomeIcons.tree,
      FontAwesomeIcons.truck,
      FontAwesomeIcons.umbrella,
      FontAwesomeIcons.user,
      FontAwesomeIcons.wineBottle,
      FontAwesomeIcons.wrench,
    ],
  };

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildFamilyPage(String familyName, List<IconData> icons) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            familyName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              children:
                  icons.map((iconData) {
                    return IconButton(
                      icon: Icon(iconData, size: 32),
                      onPressed: () {
                        widget.onSymbolSelected(iconData, null);
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children:
                  _symbolFamilies.entries
                      .map((entry) => _buildFamilyPage(entry.key, entry.value))
                      .toList(),
            ),
          ),
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_symbolFamilies.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
