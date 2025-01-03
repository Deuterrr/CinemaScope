import 'package:cinema_application/widgets/customappbar.dart';
import 'package:flutter/material.dart';

class MyWishlistPage extends StatefulWidget {
  const MyWishlistPage({super.key});

  @override
  State<MyWishlistPage> createState() => _MyWishlistPageState();
}

class _MyWishlistPageState extends State<MyWishlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 253, 247),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: CustomAppBar(title: 'Wishlist', showBackButton: false,),
      ),
      body: Center(
        child: Text(
          "Favorite Pages"
        ),
      ),
    );
  }
}