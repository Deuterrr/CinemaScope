import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:cinema_application/data/helpers/apihelper.dart';
import 'package:cinema_application/data/helpers/sharedprefsutil.dart';

import 'package:cinema_application/pages/flows/booking/detailmoviepages.dart';
import 'package:cinema_application/pages/flows/booking/exploremovies.dart';
import 'package:cinema_application/pages/flows/booking/searchpage.dart';

import 'package:cinema_application/data/models/listmovie.dart';
import 'package:cinema_application/data/models/film.dart';

import 'package:cinema_application/widgets/customappbar.dart';
import 'package:cinema_application/widgets/customiconbutton.dart';
import 'package:cinema_application/widgets/locationpanel.dart';
import 'package:cinema_application/widgets/moviecard.dart';
import 'package:cinema_application/widgets/sectionicon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentLocation = 'All Cinemas';
  List<dynamic>? allNowPlaying;
  List<dynamic>? allUpcoming;
  late List<MovieList> listmoviefirst;
  late List<AllMovie> allmovie;
  late List<AllMovie> upcomingMovies;

  final apiHelper = ApiHelper();

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadNowPlayingMovies();
    _loadUpcomingMovies();
    listmoviefirst = MovieList.getList();
    allmovie = AllMovie.getList();
    upcomingMovies = AllMovie.getUpcoming();
  }

  Future<void> _loadLocation() async {
    final location = await LocationService.getLocation();
    setState(() {
      currentLocation = location;
    });
  }

  Future<List<dynamic>> _loadNowPlayingMovies() async {
    try {
      final nowPlayingRows = await apiHelper
        .getDesireMoviesByCityandSchedule('now_playing', currentLocation);
      allNowPlaying = nowPlayingRows;
      return nowPlayingRows;
    } catch (e) {
      throw Exception('Failed to fetch movies.');
    }
  }

  Future<List<dynamic>> _loadUpcomingMovies() async {
    try {
      final upcomingRows = await apiHelper
        .getDesireMoviesByCityandSchedule('upcoming', currentLocation);
      allUpcoming = upcomingRows;
      return upcomingRows;
    } catch (e) {
      throw Exception('Failed to fetch movies.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // White
      appBar: CustomAppBar(
        useAppTitle: true,
        centerText: "",
        showBackButton: false,
        showBottomBorder: true,
        trailingButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Location button
            CustomIconButton(
              icon: Icons.location_on_outlined,
              onPressed: () => locationPanel(context),
              usingText: true,
              theText: currentLocation,
            ),

            SizedBox(width: 6),

            // Search button
            CustomIconButton(
              icon: Icons.search_rounded,
              onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
              usingText: false
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // displaying ads
                    adsSlider(),

                    // sementara ngga dipakai dulu
                    // displaying vouchers and coupons
                    displayVoucher(),

                    // displaying now showing movies in box
                    nowPlayingMovie(),

                    // displaying upcoming movies in box
                    upcomingMovie(),
                    contoh(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // image slider box
  Widget adsSlider() {
  return LayoutBuilder(
    builder: (context, constraints) {
      // calculate aspect ratio by max height
      double maxHeight = 180;
      double aspectRatio = constraints.maxWidth / maxHeight;

      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 1.2,
            ),
          ),
        ),
        child: CarouselSlider.builder(
          itemCount: listmoviefirst.length,
          itemBuilder: (context, index, realIndex) {
            final movie = listmoviefirst[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white
                  ),
                ),

                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 5,
                  child: Text(
                    movie.nameMovie,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: aspectRatio, // Dynamic aspect ratio
            viewportFraction: 1.0,
          ),
        ),
      );
    },
  );
}

                // The Panel
  locationPanel(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "BlurredDialog",
      transitionDuration: Duration(milliseconds: 190),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            // Static blur background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 3.0),
                child: Container(
                  color: Color(0xFFFFFFFF).withOpacity(0.35),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 1),
                  end: Offset(0, 0),
                ).animate(CurvedAnimation(
                  parent: anim1,
                  curve: Curves.easeOut,
                )),

                // The Panel
                child: LocationPanel(
                  onSelect: (selectedLocation) {
                    setState(() {
                      currentLocation = selectedLocation;
                    });
                  }
                )
              ),
            ),
          ],
        );
      },
    );
  }


  // display users voucher
  Widget displayVoucher() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 220, 85, 94),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionWithIcon(
                title: 'Level',
                value: ' Classic',
                haveIcon: false,),
            SizedBox(width: 6),
            SectionWithIcon(
                title: 'Points',
                value: ' 0',
                haveIcon: false,),
            SizedBox(width: 6),
            SectionWithIcon(
                title: 'Vouchers',
                value: ' 0',
                haveIcon: true,
                icon: 'assets/icon/coupunicon.svg'),
            SizedBox(width: 6),
            SectionWithIcon(
                title: 'Coupons',
                value: ' 0',
                haveIcon: true,
                icon: 'assets/icon/discount.svg')
          ],
        ),
      )
    );
  }

  // list popular movie
  Widget nowPlayingMovie() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Now Playing",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0E2522), // Black
                    fontWeight: FontWeight.w700,
                    fontFamily: "Montserrat",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExploreMovies()));
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat",
                      color: Color(0xFF4A6761) // Dark Tosca
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 4),

          SizedBox(
            height: 378,
            child: allNowPlaying == null
                ? FutureBuilder<List<dynamic>>(
                    future: _loadNowPlayingMovies(),
                    builder: (context, snapshot) {
                      // if still loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      // if failed to retrieve the data
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Please ensure network is available',
                            style: const TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0E2522),
                            ),
                          ),
                        );
                      } else {
                        allNowPlaying = snapshot.data!;
                        return buildMovieList(allNowPlaying!, true);
                      }
                    },
                  )
                : buildMovieList(allNowPlaying!, true),
          )
        ],
      ),
    );
  }

  // list upcoming movie
  Widget upcomingMovie() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Upcoming",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0E2522), // Black
                    fontWeight: FontWeight.w700,
                    fontFamily: "Montserrat",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExploreMovies()));
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat",
                      color: Color(0xFF4A6761) // Dark Tosca
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 4),

          SizedBox(
            height: 260,
            child: allUpcoming == null
                ? FutureBuilder<List<dynamic>>(
                    future: _loadUpcomingMovies(),
                    builder: (context, snapshot) {
                      // if still loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator()
                        );
                      // if failed to retrieve the data
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Please ensure network is available',
                            style: const TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0E2522),
                            ),
                          ),
                        );
                      } else {
                        allUpcoming = snapshot.data!;
                        return buildMovieList(allUpcoming!, false);
                      }
                    },
                  )
                : buildMovieList(allUpcoming!, false),
          )
        ],
      ),
    );
  }

  Widget buildMovieList(List desiredMovies, bool isBig) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: desiredMovies.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return VerticalMovieCard(
          bigSize: isBig,
          movieTitle: desiredMovies[index]['m_title'],
          movieImage: desiredMovies[index]['m_imageurl'],
          movieGenre: desiredMovies[index]['m_genre'],
        );
      },
    );
  }


  Widget contoh() {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Colors.black,
            width: 1.2
          ),
        )
      ),
      child: Container(
        height: 280,
        width: 450,
        color: Color(0xffA7D4CB),
        padding: EdgeInsets.fromLTRB(12, 7, 12, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Upcoming",
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(255, 14, 37, 34), //blak
                      fontWeight: FontWeight.w700,
                      fontFamily: "Montserrat",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExploreMovies()));
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat",
                        color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Movie ListView
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allmovie.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Moviedetail(
                            movieTitle: allmovie[index].moviename,
                            movieDescription: allmovie[index].synopsis,
                            movieImage: allmovie[index].images,
                            movieRating: allmovie[index].rate,
                            movieYears: allmovie[index].years,
                            movieDuration: allmovie[index].time,
                            movieGenre: allmovie[index].genre,
                            movieWatchlist: allmovie[index].watchlist,
                          ),
                        ),
                      );
                    },
                    child: movieCard(allmovie[index]),
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }

  // Movie Card Widget
  Widget movieCard(AllMovie movie) {
    for (int i = 0; i < allmovie.length; i++) {}
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 10, bottom: 3),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 14, 37, 34),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              offset: const Offset(1, 2),
              color: Colors.black.withOpacity(1),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        8), // Adjust the radius value as needed
                    topRight: Radius.circular(8),
                  ),
                  child: Image.asset(
                    movie.images,
                    fit: BoxFit.cover,
                    height: 140,
                    width: double.infinity,
                  ),
                ),

                // Movie Title and Genre
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 196, 64),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(1, 2),
                          color: Colors.black.withOpacity(1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 8, 0, 5),
                          child: Text(
                            movie.moviename,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFamily: "Montserrat",
                              letterSpacing: 0.12),
                          ),
                        ),
                        Text(
                          movie.genre,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 14, 37, 34),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}