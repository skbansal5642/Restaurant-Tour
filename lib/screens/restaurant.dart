import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_tour/models/business_list_model.dart';
import 'package:restaurant_tour/providers/restaurant_provider.dart';

class Restaurant extends StatelessWidget {
  const Restaurant({
    super.key,
    required this.screenSize,
    required this.business,
    required this.index,
  });

  final Size screenSize;
  final Business business;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushNamed(context, "restaurant_details", arguments: business);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(0, 0),
                blurRadius: 2,
                spreadRadius: 2,
              ),
            ],
          ),
          margin: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                width: screenSize.width / 4,
                height: screenSize.width / 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.network(
                  business.photos.first,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
                child: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: screenSize.width / 7,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                business.name,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
                                if (business.isFavourite) {
                                  restaurantProvider.removeFavourite(business.id);
                                } else {
                                  restaurantProvider.addFavourite(business.id);
                                }
                              },
                              child: Icon(
                                key: Key("${business.id}_favourite"),
                                business.isFavourite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              children: [
                                Text(business.price),
                                const SizedBox(width: 5),
                                Text(business.categories.first.title),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RatingStars(
                                  value: business.rating,
                                  starCount: 5,
                                  starSize: 10,
                                  maxValue: 5,
                                  starSpacing: 2,
                                  valueLabelVisibility: false,
                                  starOffColor: const Color(0xffe7e8ea),
                                  starColor: Colors.amber,
                                ),
                                RichText(
                                  text: TextSpan(
                                      text: business.isClosed ? "Closed" : "Open",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        overflow: TextOverflow.ellipsis,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      children: [
                                        const WidgetSpan(child: SizedBox(width: 5)),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.aboveBaseline,
                                          baseline: TextBaseline.alphabetic,
                                          child: Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: business.isClosed ? Colors.red : Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
