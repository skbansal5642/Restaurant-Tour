import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_tour/models/business_list_model.dart';
import 'package:restaurant_tour/providers/restaurant_provider.dart';
// import 'package:restaurant_tour/utils/constants.dart';

// ignore: must_be_immutable
class RestaurantDetailScreen extends HookWidget {
  RestaurantDetailScreen({super.key, required this.business});

  final Business business;
  late RestaurantProvider restaurantProvider;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final screenSize = MediaQuery.of(context).size;
    restaurantProvider = Provider.of<RestaurantProvider>(context);
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            centerTitle: true,
            elevation: 3,
            scrolledUnderElevation: 3,
            shadowColor: const Color(0xFFD2DBDB),
            title: Text(business.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                key: Key("${business.id}_favourite"),
                icon: Icon(business.isFavourite ? Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  if (business.isFavourite) {
                    restaurantProvider.removeFavourite(business.id);
                  } else {
                    restaurantProvider.addFavourite(business.id);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (business.photos.isNotEmpty)
                  SizedBox(
                    height: screenSize.height * 3 / 7,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: business.photos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: screenSize.width - (business.photos.length > 1 ? 20 : 0),
                          padding: const EdgeInsets.all(10),
                          child: Image.network(
                            business.photos[index].toString(),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Text("\$${business.price.toString()} ${<String>{
                              ...business.categories.map<String>((category) => category.title)
                            }.join(" | ")}"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              business.isClosed ? 'Closed' : 'Open Now',
                              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.circle,
                              color: business.isClosed ? Colors.red : Colors.green,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(10.0), child: Divider(color: Colors.grey[300])),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Address', style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: '${business.location?.address1?.isNotEmpty == true ? '${business.location!.address1!} ' : ''}'
                                    '${business.location?.address2?.isNotEmpty == true ? '${business.location!.address2!} ' : ''}'
                                    '${business.location?.address3?.isNotEmpty == true ? '${business.location!.address3!} ' : ''}'),
                            const TextSpan(
                              text: '\n',
                            ),
                            TextSpan(
                              text: '${business.location?.state?.isNotEmpty == true ? '${business.location!.state!} ' : ''}'
                                  '${business.location?.city?.isNotEmpty == true ? '${business.location!.city!} ' : ''}'
                                  '${business.location?.country?.isNotEmpty == true ? '${business.location!.country!}, ' : ''}'
                                  '${business.location?.postalCode?.isNotEmpty == true ? business.location!.postalCode! : ''}',
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(10.0), child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Rating',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.normal),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            business.rating.toString(),
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.all(10.0), child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                  child: Text(
                    '${business.reviewCount.toString()} Reviews',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 8),
                // Query(
                //   options: QueryOptions(
                //     document: gql(kReviewListQuery),
                //     variables: {
                //       'nBusinessId': business.id,
                //     },
                //     pollInterval: const Duration(hours: 24),
                //     cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
                //   ),
                //   builder: (result, {fetchMore, refetch}) {
                //     if (result.isLoading) {
                //       return const Center(
                //         child: CircularProgressIndicator(),
                //       );
                //     }
                //     if (result.hasException) {
                //       return Container(
                //         child: Text(result.exception.toString()),
                //       );
                //     }
                //     List<Review> reviews = [];
                //     if (result.data != null) {
                //       reviews = List<Review>.from(result.data!["reviews"]["review"].map((x) => Review.fromJson(x)));
                //     }

                //     final opts = FetchMoreOptions(
                //       updateQuery: (previousResultData, fetchMoreResultData) => fetchMoreResultData,
                //     );

                //     useEffect(() {
                //       scrollController.addListener(() {
                //         if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 &&
                //             !scrollController.position.outOfRange) {
                //           if (fetchMore != null) {
                //             fetchMore(opts);
                //           }
                //         }
                //       });

                //       // Clean up listener when the widget is disposed
                //       return () => scrollController.removeListener(() {});
                //     }, [scrollController]);

                //     return
                ReviewList(reviews: business.reviews),
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewList extends StatelessWidget {
  final List<Review> reviews;

  const ReviewList({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  ...List.generate(
                    review.rating,
                    (index) => const Icon(Icons.star, color: Colors.amber, size: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                review.text,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: (review.user.imageUrl != null)
                        ? Image.network(
                            review.user.imageUrl.toString(),
                            fit: BoxFit.cover,
                            height: 40,
                            width: 40,
                          )
                        : const Icon(Icons.person),
                  ),
                  const SizedBox(width: 8),
                  Text(review.user.name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[300]),
            ],
          ),
        );
      },
    );
  }
}
