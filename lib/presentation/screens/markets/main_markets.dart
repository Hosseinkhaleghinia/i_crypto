import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icrypto/core/constants/colors.dart';
import 'package:icrypto/presentation/screens/markets/pages_tabs/global/global_page.dart';
import 'package:icrypto/presentation/screens/markets/pages_tabs/i_crypto/i_crypto_list.dart';

class MainMarkets extends StatefulWidget {
  const MainMarkets({super.key});

  @override
  State<MainMarkets> createState() => _MainMarketsState();
}

class _MainMarketsState extends State<MainMarkets>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                  color: backgrand,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: TextField(
                cursorColor: Colors.black,
                controller: _textController,
                keyboardType: TextInputType.text,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'جستجو در لیست',
                  hintTextDirection: TextDirection.rtl,
                  suffixIconColor: Colors.black54,

                  suffixIcon: Transform.scale(
                    // از suffixIcon به جای prefixIcon استفاده می‌کنیم
                    scaleX: -1,
                    child: Icon(Icons.search, size: 24),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  // فاصله افقی برای متن
                  isDense: true,
                  // کمک می‌کند متن عمودی وسط قرار بگیرد
                  alignLabelWithHint:
                      true, // کمک می‌کند hint عمودی وسط قرار بگیرد
                ),
              ),
            ),
            SizedBox(
              width: width * 0.8,
              child: TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelColor: redSafaii,
                unselectedLabelColor: Colors.black87,
                indicator:
                    BoxDecoration(border: Border.all(style: BorderStyle.none)),
                padding: EdgeInsets.zero,
                // اضافه کردن این خط
                tabs: const [
                  Tab(text: 'جهانی'),
                  Tab(text: 'نوبیتکس'),
                  Tab(text: 'موردعلاقه‌ها'),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1.0,
              height: 1,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  GlobalList(),
                  CryptoList(),
                  Container(
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: backgrand,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'images/menu.svg',
                  )),
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'images/wallet.svg',
                  )),
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'images/maximize.svg',
                  )),
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'images/chart-.svg',
                  )),
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'images/dashboard.svg',
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
