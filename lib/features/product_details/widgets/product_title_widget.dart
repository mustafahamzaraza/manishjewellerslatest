// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_directionality_widget.dart';
// import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
// import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
// import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
// import 'package:flutter_sixvalley_ecommerce/helper/color_helper.dart';
// import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
// import 'package:flutter_sixvalley_ecommerce/helper/product_helper.dart';
// import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
// import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
// import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
// import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
// import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
// import 'package:flutter_sixvalley_ecommerce/common/basewidget/rating_bar_widget.dart';
// import 'package:provider/provider.dart';
// import '../domain/models/product_details_model.dart';
//
// class ProductTitleWidget extends StatefulWidget {
//   final ProductDetailsModel? productModel;
//   final String? averageRatting;
//
//   const ProductTitleWidget({super.key, required this.productModel, this.averageRatting});
//
//   @override
//   State<ProductTitleWidget> createState() => _ProductTitleWidgetState();
// }
//
// class _ProductTitleWidgetState extends State<ProductTitleWidget> {
//   // Default carat type
//   String selectedCarat = "24K";
//
//   // Carat-specific price map (Default prices provided)
//   final Map<String, double> caratPrices = {
//     "24K": 5000.0, // Price for 24 carat
//     "22K": 4000.0, // Price for 22 carat
//     "18K": 3000.0  // Price for 18 carat
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.productModel != null
//         ? Container(
//       padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
//       child: Consumer<ProductDetailsController>(
//         builder: (context, details, child) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Product Title
//               Text(widget.productModel!.name ?? '',
//                   style: titleRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 2),
//               const SizedBox(height: Dimensions.paddingSizeDefault),
//
//               // Dropdown for Carat Selection
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Select Carat:',
//                     style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
//                   ),
//                   const SizedBox(width: Dimensions.paddingSizeSmall),
//                   DropdownButton<String>(
//                     value: selectedCarat,
//                     items: caratPrices.keys.map((String carat) {
//                       return DropdownMenuItem<String>(
//                         value: carat,
//                         child: Text(carat, style: titilliumRegular),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedCarat = newValue!;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: Dimensions.paddingSizeDefault),
//
//               // Display Price Based on Selected Carat
//               Row(
//                 children: [
//                   CustomDirectionalityWidget(
//                     child: Text(
//                       '${PriceConverter.convertPrice(context, caratPrices[selectedCarat]!)}',
//                       style: titilliumBold.copyWith(
//                           color: ColorResources.getPrimary(context), fontSize: Dimensions.fontSizeLarge),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: Dimensions.paddingSizeSmall),
//
//               // Existing Product Information
//               Row(
//                 children: [
//                   RatingBar(
//                       rating: widget.productModel!.reviews != null
//                           ? widget.productModel!.reviews!.isNotEmpty
//                           ? double.parse(widget.averageRatting!)
//                           : 0.0
//                           : 0.0),
//                   Text('(${widget.productModel?.reviewsCount})'),
//                 ],
//               ),
//               const SizedBox(height: Dimensions.paddingSizeSmall),
//
//               // Additional Widgets (e.g., Reviews, Orders, Wishlist)
//               Consumer<ReviewController>(
//                 builder: (context, reviewController, _) {
//                   return Row(
//                     children: [
//                       Text.rich(TextSpan(children: [
//                         TextSpan(
//                             text:
//                             '${reviewController.reviewList != null ? reviewController.reviewList!.length : 0} ',
//                             style: textMedium.copyWith(
//                               color: Provider.of<ThemeController>(context, listen: false).darkTheme
//                                   ? Theme.of(context).hintColor
//                                   : Theme.of(context).primaryColor,
//                               fontSize: Dimensions.fontSizeDefault,
//                             )),
//                         TextSpan(
//                           text: '${getTranslated('reviews', context)} | ',
//                           style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
//                         )
//                       ])),
//                       Text.rich(TextSpan(children: [
//                         TextSpan(
//                             text: '${details.orderCount} ',
//                             style: textMedium.copyWith(
//                               color: Provider.of<ThemeController>(context, listen: false).darkTheme
//                                   ? Theme.of(context).hintColor
//                                   : Theme.of(context).primaryColor,
//                               fontSize: Dimensions.fontSizeDefault,
//                             )),
//                         TextSpan(
//                           text: '${getTranslated('orders', context)} | ',
//                           style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
//                         )
//                       ])),
//                       Text.rich(TextSpan(children: [
//                         TextSpan(
//                             text: '${details.wishCount} ',
//                             style: textMedium.copyWith(
//                               color: Provider.of<ThemeController>(context, listen: false).darkTheme
//                                   ? Theme.of(context).hintColor
//                                   : Theme.of(context).primaryColor,
//                               fontSize: Dimensions.fontSizeDefault,
//                             )),
//                         TextSpan(
//                           text: '${getTranslated('wish_listed', context)}',
//                           style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
//                         )
//                       ])),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//       ),
//     )
//         : const SizedBox();
//   }
// }



//old
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_directionality_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/controllers/product_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/review/controllers/review_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/product_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/rating_bar_widget.dart';
import 'package:provider/provider.dart';

import '../../../manishecommerceinvestment/goldpriceserv.dart';
import '../../../utill/colornew.dart';




class ProductTitleWidget extends StatelessWidget {
  final ProductDetailsModel? productModel;
  final String? averageRatting;
  const ProductTitleWidget({super.key, required this.productModel, this.averageRatting});

  @override
  Widget build(BuildContext context) {
    ({double? end, double? start})? priceRange = ProductHelper.getProductPriceRange(productModel);
    double? startingPrice = priceRange.start;
    double? endingPrice = priceRange.end;
    double pricenew = productModel!.unitPrice! - productModel!.discount!.toInt();

    int? makingCharges = productModel!.makingCharges!;
    int? hallmarkCharges = productModel!.hallmarkCharges!;
    double? tax = productModel!.tax!;
    double? startingUP = pricenew - makingCharges.toDouble() - hallmarkCharges.toDouble() - tax;

    int? initPrice = startingUP.toInt();


    String? productName = productModel!.name!;
    String? productPurity = productModel!.metal;
    // double? weight = productModel!.choiceOptions.;
    //String? productColor = productModel.;


    String weight = '';

    final optionsList = productModel!.choiceOptions!;

    if (optionsList != null) {
      for (var item in optionsList) {
        if (item.title == 'Weight') {
          if (item.options != null && item.options!.isNotEmpty) {
            weight = item.options!.first;
          }
          break;
        }
      }
    }



    String carat = '';

    final optionsList2 = productModel!.choiceOptions!;

    if (optionsList2 != null) {
      for (var item in optionsList2) {
        if (item.title == 'carat') {
          if (item.options != null && item.options!.isNotEmpty) {
            carat = item.options!.first;
          }
          break;
        }
      }
    }



    final colors = productModel?.colors ?? [];

    String colorText = colors.map((e) => '${e.name} (${e.code})').join(', ');



    return productModel != null
        ? Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      child: Consumer<ProductDetailsController>(
        builder: (context, details, child) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Product Title
            Text(
              productModel!.name?.toUpperCase() ?? '',
              style: titleRegular.copyWith(
                fontSize: Dimensions.fontSizeOverLarge,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Main Price (New Price Highlighted)
            Row(
              children: [
                Icon(Icons.currency_rupee, size: 20, color: AppColors.yellowGold),
                Text(
                  "$pricenew",
                  style: TextStyle(
                    color: AppColors.yellowGold,
                    fontWeight: FontWeight.bold,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Discounted Price Range
            if (endingPrice != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_rounded, size: 18, color: AppColors.mutedGold),
                  const SizedBox(width: 4),
                  CustomDirectionalityWidget(
                    child: Text(
                      '${startingPrice != null ? PriceConverter.convertPrice(context, startingPrice, discount: productModel!.discount, discountType: productModel!.discountType) : ''}'
                          '${endingPrice != null ? ' - ${PriceConverter.convertPrice(context, endingPrice, discount: productModel!.discount, discountType: productModel!.discountType)}' : ''}',
                      style: titilliumBold.copyWith(
                        color: ColorResources.getPrimary(context),
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ),

                  if (productModel!.discount != null && productModel!.discount! > 0) ...[
                    const SizedBox(width: 8),
                    CustomDirectionalityWidget(
                      child: Text(
                        '${PriceConverter.convertPrice(context, startingPrice)}'
                            '${endingPrice != null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
                        style: titilliumRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          decoration: TextDecoration.lineThrough,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Rating Section
            Row(
              children: [
                Icon(Icons.star_rate_rounded, size: 20, color: Colors.amber),
                const SizedBox(width: 4),
                RatingBar(
                  rating: productModel!.reviews != null && productModel!.reviews!.isNotEmpty
                      ? double.tryParse(averageRatting!) ?? 0.0
                      : 0.0,
                ),
                const SizedBox(width: 6),
                Text(
                  '(${productModel?.reviewsCount ?? 0})',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            // PRICE BREAKUP UI
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price Breakup", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  //buildPriceRow("92300/-\nRate/10gms", weight, "₹${initPrice.toString()}"),
                  FutureBuilder<double?>(
                    future: GoldPriceService.fetch22kPrice(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading...", style: TextStyle(fontSize: 14));
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return const Text("Rate Error", style: TextStyle(fontSize: 14, color: Colors.red));
                      } else {
                        double price22k = snapshot.data!;
                        return buildPriceRow("22k Rate/10gms", "", "₹${price22k.toStringAsFixed(2)}");
                      }
                    },
                  ),

                  buildPriceRow("Product Rate", "$weight gms", "₹${initPrice.toString()}"),


                  buildPriceRow("Making Charges", "", "₹${makingCharges.toString()}"),
     //             buildPriceRow("Other Charges", "", "₹300"),
                  buildPriceRow("Hallmark Charges", "", "₹${hallmarkCharges.toString()}"),
                  buildPriceRow("GST", "", "₹${tax.toString()}", isHighlighted: true),
                  const Divider(),
                  buildPriceRow("Total", "", "₹$pricenew", isBold: true),
                ],
              ),
            ),

            // PRODUCT DETAILS UI
            const SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Product Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 12),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1.5),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        children: [
                          Padding(padding: EdgeInsets.all(6), child: Text("Product", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(6), child: Text("Purity", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(6), child: Text("Gross Weight", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(6), child: Text("Item type", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(6), child: Text("Tone", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                       TableRow(
                        children: [
                          Padding(padding: EdgeInsets.all(6), child: Text(productName)),
                          Padding(padding: EdgeInsets.all(6), child: Text("${carat}k")),
                          Padding(padding: EdgeInsets.all(6), child: Text(weight)),
                          Padding(padding: EdgeInsets.all(6), child: Text(productPurity.toString())),
                          Padding(padding: EdgeInsets.all(6), child: Text(colorText)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]);
        },
      ),
    )
        : const SizedBox();
  }

  Widget buildPriceRow(String title, String weight, String value, {bool isHighlighted = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: TextStyle(
              fontSize: 14,
              color: isHighlighted ? Colors.black87 : Colors.black54,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            )),
          ),
          Expanded(
            flex: 2,
            child: Text(weight, style: TextStyle(fontSize: 14, color: Colors.black54)),
          ),
          Expanded(
            flex: 2,
            child: Text(value, textAlign: TextAlign.end, style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.black : Colors.black87,
            )),
          ),
        ],
      ),
    );
  }
}



//
// class ProductTitleWidget extends StatelessWidget {
//   final ProductDetailsModel? productModel;
//   final String? averageRatting;
//   const ProductTitleWidget({super.key, required this.productModel, this.averageRatting});
//
//   @override
//   Widget build(BuildContext context) {
//
//     ({double? end, double? start})? priceRange = ProductHelper.getProductPriceRange(productModel);
//     double? startingPrice = priceRange.start;
//     double? endingPrice = priceRange.end;
//
//
//     double pricenew = productModel!.unitPrice! - productModel!.discount!.toInt();
//
//     return productModel != null? Container(
//       padding: const EdgeInsets.symmetric(horizontal : Dimensions.homePagePadding),
//       child: Consumer<ProductDetailsController>(
//         builder: (context, details, child) {
//           return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//
//             Text(
//               productModel!.name?.toUpperCase() ?? '',
//               style: titleRegular.copyWith(
//                 fontSize: Dimensions.fontSizeOverLarge,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.7,
//                 color: Colors.black,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//
//             const SizedBox(height: Dimensions.paddingSizeDefault),
//
//             // Main Price (New Price Highlighted)
//             Row(
//               children: [
//                 Icon(Icons.currency_rupee, size: 20, color: AppColors.yellowGold),
//                 Text(
//                   "$pricenew",
//                   style: TextStyle(
//                     color: AppColors.yellowGold,
//                     fontWeight: FontWeight.bold,
//                     fontSize: Dimensions.fontSizeLarge,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 8),
//
//             // Discounted Price Range
//             if (endingPrice != null)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Icon(Icons.local_offer_rounded, size: 18, color: AppColors.mutedGold),
//                   const SizedBox(width: 4),
//                   CustomDirectionalityWidget(
//                     child: Text(
//                       '${startingPrice != null ? PriceConverter.convertPrice(context, startingPrice, discount: productModel!.discount, discountType: productModel!.discountType) : ''}'
//                           '${endingPrice != null ? ' - ${PriceConverter.convertPrice(context, endingPrice, discount: productModel!.discount, discountType: productModel!.discountType)}' : ''}',
//                       style: titilliumBold.copyWith(
//                         color: ColorResources.getPrimary(context),
//                         fontSize: Dimensions.fontSizeLarge,
//                       ),
//                     ),
//                   ),
//
//                   // Original Price with Strikethrough
//                   if (productModel!.discount != null && productModel!.discount! > 0) ...[
//                     const SizedBox(width: 8),
//                     CustomDirectionalityWidget(
//                       child: Text(
//                         '${PriceConverter.convertPrice(context, startingPrice)}'
//                             '${endingPrice != null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
//                         style: titilliumRegular.copyWith(
//                           color: Theme.of(context).hintColor,
//                           decoration: TextDecoration.lineThrough,
//                           fontSize: Dimensions.fontSizeDefault,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//
//             const SizedBox(height: Dimensions.paddingSizeSmall),
//
//             // Ratings Row
//             Row(
//               children: [
//                 Icon(Icons.star_rate_rounded, size: 20, color: Colors.amber),
//                 const SizedBox(width: 4),
//                 RatingBar(
//                   rating: productModel!.reviews != null && productModel!.reviews!.isNotEmpty
//                       ? double.tryParse(averageRatting!) ?? 0.0
//                       : 0.0,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   '(${productModel?.reviewsCount ?? 0})',
//                   style: textRegular.copyWith(
//                     fontSize: Dimensions.fontSizeSmall,
//                     color: Theme.of(context).hintColor,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: Dimensions.paddingSizeSmall),
//
//
//             // Text(productModel!.name ?? '',
//             //     style: titleRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 2),
//             // const SizedBox(height: Dimensions.paddingSizeDefault),
//             //
//             //
//             //
//             // Row(
//             //   children: [
//             //
//             //       CustomDirectionalityWidget(
//             //         // child: Text("₹${productModel!.unitPrice.toString() ?? ''}"),
//             //         child: Text("₹${pricenew}",style: TextStyle(color: AppColors.yellowGold,fontWeight: FontWeight.bold),),
//             //       ),
//             //
//             // ],),
//             //
//             // Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
//             //   if(endingPrice !=null )
//             //   CustomDirectionalityWidget(
//             //     child: Text('${startingPrice != null ? PriceConverter.convertPrice(context, startingPrice,
//             //         discount: productModel!.discount, discountType: productModel!.discountType):''}'
//             //         '${endingPrice !=null ? ' - ${PriceConverter.convertPrice(context, endingPrice,
//             //         discount: productModel!.discount, discountType: productModel!.discountType)}' : ''}',
//             //         style: titilliumBold.copyWith(color: ColorResources.getPrimary(context),
//             //             fontSize: Dimensions.fontSizeLarge)),
//             //   ),
//             //
//             //   if(endingPrice !=null )
//             //   if(productModel!.discount != null && productModel!.discount! > 0)...[
//             //     const SizedBox(width: Dimensions.paddingSizeSmall),
//             //
//             //     CustomDirectionalityWidget(
//             //       child: Text('${PriceConverter.convertPrice(context, startingPrice)}'
//             //           '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
//             //           style: titilliumRegular.copyWith(color: Theme.of(context).hintColor,
//             //               decoration: TextDecoration.lineThrough)),
//             //     ),
//             //   ],
//             // ]),
//             //
//             // const SizedBox(height: Dimensions.paddingSizeSmall),
//             //
//             //
//             // Row(children: [
//             //    RatingBar(rating: productModel!.reviews != null ? productModel!.reviews!.isNotEmpty ?
//             //    double.parse(averageRatting!) : 0.0 : 0.0),
//             //   Text('(${productModel?.reviewsCount})')]),
//             // const SizedBox(height: Dimensions.paddingSizeSmall),
//
//
//
//
//
//             Consumer<ReviewController>(
//               builder: (context, reviewController, _) {
//                 final isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;
//                 final primaryColor = isDark ? Theme.of(context).hintColor : Theme.of(context).primaryColor;
//
//                 final reviewCount = reviewController.reviewList?.length ?? 0;
//                 final orderCount = details.orderCount ?? 0;
//                 final wishCount = details.wishCount ?? 0;
//
//                 TextSpan _buildStatSpan(String count, String label) {
//                   return TextSpan(
//                     children: [
//                       TextSpan(
//                         text: '$count ',
//                         style: textMedium.copyWith(
//                           color: primaryColor,
//                           fontSize: Dimensions.fontSizeDefault,
//                         ),
//                       ),
//                       TextSpan(
//                         text: '${getTranslated(label, context)}',
//                         style: textRegular.copyWith(
//                           fontSize: Dimensions.fontSizeDefault,
//                           color: isDark ? Colors.white70 : Colors.black87,
//                         ),
//                       ),
//                     ],
//                   );
//                 }
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   child: Wrap(
//                     spacing: 12,
//                     runSpacing: 8,
//                     children: [
//                       RichText(text: _buildStatSpan(reviewCount.toString(), 'reviews')),
//                       const Text('|', style: TextStyle(fontWeight: FontWeight.w300)),
//                       RichText(text: _buildStatSpan(orderCount.toString(), 'orders')),
//                       const Text('|', style: TextStyle(fontWeight: FontWeight.w300)),
//                       RichText(text: _buildStatSpan(wishCount.toString(), 'wish_listed')),
//                     ],
//                   ),
//                 );
//               },
//             ),
//
//
//             // Consumer<ReviewController>(
//             //   builder: (context, reviewController, _) {
//             //     return Row(children: [
//             //       Text.rich(TextSpan(children: [
//             //         TextSpan(text: '${reviewController.reviewList != null ? reviewController.reviewList!.length : 0} ',
//             //             style: textMedium.copyWith(
//             //             color: Provider.of<ThemeController>(context, listen: false).darkTheme?
//             //             Theme.of(context).hintColor : Theme.of(context).primaryColor,
//             //       fontSize: Dimensions.fontSizeDefault)),
//             //     TextSpan(text: '${getTranslated('reviews', context)} | ',
//             //         style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault,))])),
//             //
//             //
//             //       Text.rich(TextSpan(children: [
//             //         TextSpan(text: '${details.orderCount} ', style: textMedium.copyWith(
//             //             color: Provider.of<ThemeController>(context, listen: false).darkTheme?
//             //             Theme.of(context).hintColor : Theme.of(context).primaryColor,
//             //             fontSize: Dimensions.fontSizeDefault)),
//             //         TextSpan(text: '${getTranslated('orders', context)} | ',
//             //             style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault,))])),
//             //
//             //       Text.rich(TextSpan(children: [
//             //         TextSpan(text: '${details.wishCount} ', style: textMedium.copyWith(
//             //             color: Provider.of<ThemeController>(context, listen: false).darkTheme?
//             //             Theme.of(context).hintColor : Theme.of(context).primaryColor,
//             //             fontSize: Dimensions.fontSizeDefault)),
//             //         TextSpan(text: '${getTranslated('wish_listed', context)}',
//             //             style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault,))])),
//             //     ]);}),
//             const SizedBox(height: Dimensions.paddingSizeSmall),
//
//
//             productModel!.colors != null && productModel!.colors!.isNotEmpty
//                 ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Section Title with Icon
//                 // Row(
//                 //   children: [
//                 //    // Icon(Icons.palette_rounded, size: 18, color: Theme.of(context).primaryColor),
//                 //     const SizedBox(width: 6),
//                 //     Text(
//                 //       '${getTranslated('select_variant', context)}:',
//                 //       style: titilliumRegular.copyWith(
//                 //         fontSize: Dimensions.fontSizeLarge,
//                 //         color: Theme.of(context).textTheme.bodyLarge!.color,
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//
//
//                 Text(
//                   'Color',
//                   style: titilliumSemiBold.copyWith(
//                     fontSize: Dimensions.fontSizeLarge,
//                     color: Colors.black87,
//                     letterSpacing: 1.0,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//
//
//                 // Color Swatch Options
//                 SizedBox(
//                   height: 40,
//                   child: ListView.separated(
//                     itemCount: productModel!.colors!.length,
//                     scrollDirection: Axis.horizontal,
//                     separatorBuilder: (_, __) => const SizedBox(width: 12),
//                     itemBuilder: (context, index) {
//                       final colorCode = productModel!.colors![index].code;
//                       final color = ColorHelper.hexCodeToColor(colorCode);
//
//                       return Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Theme.of(context).primaryColor,
//                             width: 1.2,
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.08),
//                               blurRadius: 4,
//                               offset: const Offset(2, 2),
//                             ),
//                           ],
//                         ),
//                         child: Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: color,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             )
//                 : const SizedBox(),
//
//
//
//
//
//           //   productModel!.colors != null && productModel!.colors!.isNotEmpty ?
//           //   Row( children: [
//           //     Text('${getTranslated('select_variant', context)} : ',
//           //         style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
//           //     Expanded(child: SizedBox(height: 40,
//           //         child: ListView.builder(
//           //           itemCount: productModel!.colors!.length,
//           //           shrinkWrap: true,
//           //           scrollDirection: Axis.horizontal,
//           //
//           //           itemBuilder: (context, index) {
//           //             return Center(child: Container(
//           //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
//           //                 child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//           //                   child: Container(
//           //                     height: 20, width: 20,
//           //                     padding: const EdgeInsets.all( Dimensions.paddingSizeExtraSmall),
//           //                     alignment: Alignment.center,
//           //                     decoration: BoxDecoration(
//           //                       color: ColorHelper.hexCodeToColor(productModel?.colors?[index].code),
//           //                       borderRadius: BorderRadius.circular(30),
//           //                     ),
//           //                   ))));
//           //             },
//           //         ))),
//           //   ]) : const SizedBox(),
//           // productModel!.colors != null &&  productModel!.colors!.isNotEmpty ?
//           // const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
//
//
//
//
//             productModel!.choiceOptions!=null && productModel!.choiceOptions!.isNotEmpty?
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: productModel!.choiceOptions!.length,
//               physics: const NeverScrollableScrollPhysics(),
//               itemBuilder: (context, index) {
//                 final choice = productModel!.choiceOptions![index];
//                 final themeController = Provider.of<ThemeController>(context, listen: false);
//                 final isDark = themeController.darkTheme;
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       // Title in All Caps
//                       Text(
//                         choice.title!.toUpperCase(),
//                         style: titilliumSemiBold.copyWith(
//                           fontSize: Dimensions.fontSizeLarge,
//                           color: isDark ? Colors.white : Colors.black87,
//                           letterSpacing: 1.0,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//
//                       // Horizontal Option Chips
//                       SizedBox(
//                         height: 40,
//                         child: ListView.separated(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: choice.options!.length,
//                           separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeDefault),
//                           itemBuilder: (context, i) {
//                             final option = choice.options![i].trim();
//
//                             return Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                               decoration: BoxDecoration(
//                                 color: isDark ? Colors.grey[800] : Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(
//                                   color: Theme.of(context).primaryColor,
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   option,
//                                   style: textRegular.copyWith(
//                                     fontSize: Dimensions.fontSizeDefault,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ): SizedBox()
//
//             // ListView.builder(
//             //   shrinkWrap: true,
//             //   itemCount: productModel!.choiceOptions!.length,
//             //   physics: const NeverScrollableScrollPhysics(),
//             //   itemBuilder: (context, index) {
//             //     return Row(crossAxisAlignment: CrossAxisAlignment.center,
//             //         mainAxisAlignment: MainAxisAlignment.center, children: [
//             //
//             //       // Text('${getTranslated('available'.toUpperCase(), context)} ${productModel!.choiceOptions![index].title!.toUpperCase()} :', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
//             //
//             //           Text('${productModel!.choiceOptions![index].title!.toUpperCase()} :', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
//             //
//             //       const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//             //
//             //       Expanded(child: Padding(padding: const EdgeInsets.all(2.0),
//             //           child: SizedBox(height: 40,
//             //             child: ListView.builder(
//             //              scrollDirection: Axis.horizontal,
//             //               shrinkWrap: true,
//             //               itemCount: productModel!.choiceOptions![index].options!.length,
//             //               itemBuilder: (context, i) {
//             //                 return Center(
//             //                     child: Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
//             //                     child: Text(productModel!.choiceOptions![index].options![i].trim(), maxLines: 1,
//             //                         overflow: TextOverflow.ellipsis, style: textRegular.copyWith(
//             //                           fontSize: Dimensions.fontSizeLarge,
//             //                             color: Provider.of<ThemeController>(context, listen: false).darkTheme?
//             //                             const Color(0xFFFFFFFF) : Theme.of(context).primaryColor))));
//             //               })))),
//             //     ]);
//             //   },
//             // ):const SizedBox(),
//
//
//
//           ]);
//         },
//       ),
//     ):const SizedBox();
//   }
// }
