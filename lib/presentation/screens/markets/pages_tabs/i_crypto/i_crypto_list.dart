// crypto_list.dart (Updated with missing methods)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icrypto/presentation/providers/crypto_data_provider.dart';
import 'package:provider/provider.dart';
import 'filter.dart';
import 'crypto_list_item.dart';
import 'package:icrypto/core/constants/colors.dart';
import 'market_map.dart';

class CryptoList extends StatefulWidget {
  const CryptoList({super.key});

  @override
  State<CryptoList> createState() => _CryptoListState();
}

class _CryptoListState extends State<CryptoList>
    with SingleTickerProviderStateMixin {
  late TabController? _tabController;
  Timer? _refreshTimer;
  final Map<String, CryptoFilterButton> _filterButtons = {
    '24h تغییر': CryptoFilterButton('24h تغییر'),
    'آخرین قیمت': CryptoFilterButton('آخرین قیمت'),
    'حجم': CryptoFilterButton('حجم'),
    'رمزارز': CryptoFilterButton('رمزارز'),
  };

  @override
  void initState() {
    super.initState();
    _setupInitialState();
  }

  void _setupInitialState() {
    _tabController = TabController(length: 2, vsync: this);
    _setupTabListener();
    _setupDataFetching();
  }

  void _setupTabListener() {
    _tabController?.addListener(() {
      if (_tabController?.indexIsChanging ?? false) {
        final provider = Provider.of<CryptoDataProvider>(context, listen: false);
        provider.setSelectedCurrency(
            _tabController?.index == 0 ? CurrencyType.tether : CurrencyType.irt);
      }
    });
  }

  void _setupDataFetching() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CryptoDataProvider>();
      provider.fetchCoins();

      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (mounted) {
          provider.fetchCoins();
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Widget _buildHeader(double width, CryptoDataProvider cryptoProvider) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MarketMapWidget(
                    currencyType: _tabController!.index == 0
                        ? CurrencyType.tether
                        : CurrencyType.irt,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_sharp,
                  size: 14,
                  color: Colors.black,
                ),
                SizedBox(width: 4),
                Text(
                  'نقشه بازار',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: (width - 20) * 0.5,
            child: TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('تتری'),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'images/usdt.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('تومانی'),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'images/iran.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
              controller: _tabController,
              labelColor: blue20Safaii,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                border: Border.all(style: BorderStyle.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<CryptoDataProvider>(context, listen: false);
    await provider.fetchCoins();
  }

  Widget _buildTabContent(double width, bool isTether) {
    return Consumer<CryptoDataProvider>(
      builder: (context, provider, child) {
        final cryptoList = isTether ? provider.tetherStream : provider.irtStream;
        return StreamBuilder(
          stream: cryptoList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              final cryptos = snapshot.data!;
              if (cryptos.isEmpty) {
                return const Center(child: Text('داده‌ای موجود نیست'));
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    CryptoFilters(
                      filterButtons: _filterButtons,
                      onFilterTap: (button) => _handleFilterTap(button, provider),
                      width: width,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshData,
                        child: ListView.builder(
                          itemCount: cryptos.length,
                          itemBuilder: (context, index) {
                            return CryptoListItem(
                              width: width,
                              crypto: cryptos[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: SpinKitCircle(
                size: 70,
                color: blue100Safaii,
              ),
            );
          },
        );
      },
    );
  }

  void _handleFilterTap(CryptoFilterButton button, CryptoDataProvider provider) {
    setState(() {
      // Reset all other buttons
      _filterButtons.forEach((key, filterButton) {
        if (filterButton != button) {
          filterButton.state = FilterState.none;
        }
      });

      // Update clicked button state
      switch (button.state) {
        case FilterState.none:
          button.state = FilterState.ascending;
          break;
        case FilterState.ascending:
          button.state = FilterState.descending;
          break;
        case FilterState.descending:
          button.state = FilterState.none;
          break;
      }

      // Apply appropriate filter
      final order = _convertFilterStateToSortOrder(button.state);
      switch (button.title) {
        case 'آخرین قیمت':
          provider.sortByPrice(order);
          break;
        case '24h تغییر':
          provider.sortByDayChange(order);
          break;
        case 'حجم':
          provider.sortByVolume(order);
          break;
        case 'رمزارز':
          provider.sortByName(order);
          break;
      }
    });
  }

  SortOrder _convertFilterStateToSortOrder(FilterState state) {
    switch (state) {
      case FilterState.none:
        return SortOrder.none;
      case FilterState.ascending:
        return SortOrder.ascending;
      case FilterState.descending:
        return SortOrder.descending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Consumer<CryptoDataProvider>(
      builder: (context, cryptoProvider, child) {
        return Column(
          children: [
            _buildHeader(width, cryptoProvider),
            const Divider(
              color: Colors.grey,
              thickness: 1.0,
              height: 1,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent(width, true),
                  _buildTabContent(width, false),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}