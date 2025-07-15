import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/title_row_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banners_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/footer_banner_slider_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/single_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/screens/brands_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/widgets/brand_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/controllers/category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/widgets/category_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/featured_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/controllers/flash_deal_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/screens/featured_deal_screen_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/screens/flash_deal_screen_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/featured_deal_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/deal/widgets/flash_deals_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/flash_deal_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/announcement_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/aster_theme/find_what_you_need_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/featured_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/widgets/search_home_page_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/home_category_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/latest_product_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/products_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/recommended_product_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/screens/search_product_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/controllers/shop_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/screens/all_shop_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/widgets/top_seller_view.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/manishecommerceinvestment/payment/phonepestepone.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../manishecommerceinvestment/goldratescreen.dart';
import '../../../manishecommerceinvestment/investmentPlans.dart';
import '../../../manishecommerceinvestment/payment/phonepg.dart';
import '../../../manishecommerceinvestment/pp.dart';
import '../../../utill/colornew.dart';
import '../../auth/screens/login_screen.dart';
import '../../gold/goldpricescreen.dart';
import '../../gold/goldpurchaseplanscreen.dart';
import 'drawer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static Future<void> loadData(bool reload) async {
    final flashDealController = Provider.of<FlashDealController>(Get.context!, listen: false);
    final shopController = Provider.of<ShopController>(Get.context!, listen: false);
    final categoryController = Provider.of<CategoryController>(Get.context!, listen: false);
    final bannerController = Provider.of<BannerController>(Get.context!, listen: false);
    final addressController = Provider.of<AddressController>(Get.context!, listen: false);
    final productController = Provider.of<ProductController>(Get.context!, listen: false);
    final brandController = Provider.of<BrandController>(Get.context!, listen: false);
    final featuredDealController = Provider.of<FeaturedDealController>(Get.context!, listen: false);
    final notificationController = Provider.of<NotificationController>(Get.context!, listen: false);
    final cartController = Provider.of<CartController>(Get.context!, listen: false);
    final profileController = Provider.of<ProfileController>(Get.context!, listen: false);

    if(flashDealController.flashDealList.isEmpty || reload) {
      // await flashDealController.getFlashDealList(reload, false);
    }



    categoryController.getCategoryList(reload);
      ///


    bannerController.getBannerList(reload);
      ///

      shopController.getTopSellerList(reload, 1, type: "top");


      shopController.getAllSellerList(reload, 1, type: "all");


    if(addressController.addressList == null || (addressController.addressList != null && addressController.addressList!.isEmpty) || reload) {
        addressController.getAddressList();
      }


       cartController.getCartData(Get.context!);



       productController.getHomeCategoryProductList(reload);
       ///



       brandController.getBrandList(reload);
       ///



      featuredDealController.getFeaturedDealList(reload);
      ///

      productController.getLProductList('1', reload: reload);
      ///

      productController.getLatestProductList(1, reload: reload);
      ///


      productController.getFeaturedProductList('1', reload: reload);
      ///


      productController.getRecommendedProduct();
      ///


      if(notificationController.notificationModel == null ||
          (notificationController.notificationModel != null
              && notificationController.notificationModel!.notification!.isEmpty)
          || reload) {
        notificationController.getNotificationList(1);
      }

      if(Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn() && profileController.userInfoModel == null){
        profileController.getUserInfo(Get.context!);
      }


    }


}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  final ScrollController _scrollController = ScrollController();



  void passData(int index, String title) {
    index = index;
    title = title;
  }

  bool singleVendor = false;


  late Future<String> _buttonLabelAndAction;

  Future<String> getButtonLabelAndAction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      return 'purchase'; // No token — treat like no plan (show Purchase Plan option)
    }

    var headers = {
      'Authorization': 'Bearer $token',
    };

    var url = Uri.parse('https://manish-jewellers.com/api/v1/installment-payment/check-user-active-plan');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print('Plan Details of User ${data.toString()}');
      return data['status'] == true ? 'myplans' : 'purchase';
    } else {
      // If API error, fallback to purchase
      return 'purchase';
    }
  }



  @override
  void initState() {
    super.initState();
   // checkUserActivePlan();
    WidgetsBinding.instance.addObserver(this);
    getButtonLabelAndAction();
    _buttonLabelAndAction = getButtonLabelAndAction();
    singleVendor = Provider.of<SplashController>(context, listen: false).configModel!.businessMode == "single";
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    if (state == AppLifecycleState.resumed) {
      // App is back from PhonePe
      final prefs = await SharedPreferences.getInstance();
      //  await prefs.getString('mandate');

      final mandate = prefs.getString('mandate');

      await Future.delayed(Duration(seconds: 3));

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Resumed on HomeScreen Init with mandate id $mandate')),
      // );
      checkMandateStatus(mandate.toString());
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Returns the token or null if not found
  }

  Future<void> checkMandateStatus(String mandateId) async {
    final url = Uri.parse(
        'https://manish-jewellers.com/api/v1/phonepe/subscription/status/$mandateId');

    try {
      String? token = await getToken();
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Mandate Status Success: $data");

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("✅ Payment Flow Completed with proper mandateid")),
        // );
      } else {
        print("Mandate check failed: ${response.statusCode}");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //         "❌ Payment process failed (${response.statusCode})"),
        //     backgroundColor: Colors.red,
        //     duration: Duration(seconds: 3),
        //   ),
        // );
      }
    } catch (e) {
      print("Mandate check error: $e");
    }
  }

  Future<bool> checkUserActivePlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    var headers = {
      'Authorization': 'Bearer $token',
    };

    var url = Uri.parse('https://manish-jewellers.com/api/v1/installment-payment/check-user-active-plan');

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print('Plans : $data');
      return data['status']; // true if plan exists, false if not
    } else {
      throw Exception('Failed to check plan status');
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;

    List<String?> types =[getTranslated('new_arrival', context),getTranslated('top_product', context),
      getTranslated('best_selling', context),  getTranslated('discounted_product', context)];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const GoldThemeDrawer(),
      body: SafeArea(child: RefreshIndicator(
        onRefresh: () async {
          await HomePage.loadData(true);
        },

        child: CustomScrollView(controller: _scrollController, slivers: [
          // SliverAppBar(
          //   floating: true,
          //   elevation: 0,
          //   centerTitle: false,
          //   automaticallyImplyLeading: false,
          //   backgroundColor: Theme.of(context).highlightColor,
          //   title: Image.asset(Images.logoWithNameImage, height: 35),
          // ),




          SliverToBoxAdapter(child: Provider.of<SplashController>(context, listen: false).configModel!.announcement!.status == '1'?
          Consumer<SplashController>(
              builder: (context, announcement, _){
                return (announcement.configModel!.announcement!.announcement != null && announcement.onOff)?
                AnnouncementWidget(announcement: announcement.configModel!.announcement):const SizedBox();
              }):const SizedBox(),),

          SliverPersistentHeader(pinned: true, delegate: SliverDelegate(
            child: InkWell(
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: const Hero(tag: 'search', child: Material(child: SearchHomePageWidget())),
            ),
          )),

          SliverToBoxAdapter(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              const BannersWidget(),

              const SizedBox(height: Dimensions.paddingSizeDefault),


              //if(configModel?.brandSetting == "1")
                TitleRowWidget(
                title: getTranslated('brand', context),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandsView())),
              ),

              SizedBox(height: configModel?.brandSetting == "1" ? Dimensions.paddingSizeSmall: 0),

              //if(configModel!.brandSetting == "1") ...[
                const BrandListWidget(isHomePage: true),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              //],


              const CategoryListWidget(isHomePage: true),
              const SizedBox(height: Dimensions.paddingSizeDefault),



              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: GestureDetector(
                  onTap: () {
                    getButtonLabelAndAction();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoldPriceScreenT(),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.primaryMedium,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.amber.shade700,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's Gold Price",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Stay updated with the latest gold rates. Tap here to view.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: FutureBuilder<String>(
                  future: _buttonLabelAndAction,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      final action = snapshot.data ?? 'login';

                      return InkWell(
                          onTap: () async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String? token = prefs.getString('auth_token');

                            if (token == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            }
                            else if (token!= null && action == 'myplans') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PaymentHistoryList()),
                              );
                            }
                            else if (token != null && action == 'purchase'){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RemainingPlansScreen()),
                              );
                            }
                          }

                          // onTap: () async {
                        //   if (action == 'login') {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const LoginScreen()),
                        //     );
                        //   } else if (action == 'myplans') {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const PaymentHistoryList()),
                        //     );
                        //   } else {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const RemainingPlansScreen()),
                        //     );
                        //   }
                        // },
                        ,child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.roseGold,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.card_membership,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      action == 'myplans'
                                          ? "My Plans"
                                          : "Purchase Investment Plans",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      action == 'myplans' ? "View your active investment plans and track your progress."
                                     : "Invest in secure gold plans and grow your wealth.",
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              //
              //
              // FutureBuilder<bool>(
              //   future: checkUserActivePlan(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const CircularProgressIndicator();
              //     } else if (snapshot.hasError) {
              //       return Text("Error: ${snapshot.error}");
              //     } else {
              //       final hasPlan = snapshot.data ?? false;
              //
              //       return ElevatedButton(
              //         onPressed: () {
              //           if (hasPlan) {
              //             // Navigate to My Plans
              //             Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryList()));
              //           } else {
              //             // Navigate to New Plan
              //             Navigator.push(context, MaterialPageRoute(builder: (_) => const RemainingPlansScreen()));
              //           }
              //         },
              //         child: Text(hasPlan ? "My Plans" : "New Plan"),
              //       );
              //     }
              //   },
              // ),
              //
              //
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //   child: InkWell(
              //
              //     onTap: () async {
              //       SharedPreferences prefs = await SharedPreferences.getInstance();
              //       String? token = prefs.getString('auth_token');
              //
              //       if (token == null) {
              //         // Navigate to SigninScreen if token is null
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(builder: (context) => const LoginScreen()),
              //         );
              //       } else {
              //         // Navigate to RemainingPlansScreen if token exists
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(builder: (context) => const RemainingPlansScreen()),
              //         );
              //       }
              //     },
              //
              //     child: Container(
              //       padding: const EdgeInsets.all(16),
              //       decoration: BoxDecoration(
              //         color: AppColors.roseGold,
              //         borderRadius: BorderRadius.circular(12),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.grey.withOpacity(0.3),
              //             spreadRadius: 2,
              //             blurRadius: 5,
              //             offset: const Offset(0, 3),
              //           ),
              //         ],
              //       ),
              //       child: Row(
              //         children: [
              //           const Icon(
              //             Icons.card_membership,
              //             color: Colors.white,
              //             size: 40,
              //           ),
              //           const SizedBox(width: 16),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   "Purchase Investment Plans",
              //                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 4),
              //                 Text(
              //                   "Invest in secure gold plans and grow your wealth.",
              //                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //                     color: Colors.white70,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           const Icon(
              //             Icons.arrow_forward_ios,
              //             color: Colors.white,
              //             size: 20,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              Consumer<FlashDealController>(builder: (context, megaDeal, child) {
                return  megaDeal.flashDeal == null ? const FlashDealShimmer(
                ) : megaDeal.flashDealList.isNotEmpty ? Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: TitleRowWidget(
                      title: getTranslated('flash_deal', context)?.toUpperCase(),
                      eventDuration: megaDeal.flashDeal != null ? megaDeal.duration : null,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashDealScreenView()));
                      },
                      isFlash: true,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Text(getTranslated('hurry_up_the_offer_is_limited_grab_while_it_lasts', context)??'',
                      style: textRegular.copyWith(color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                      Theme.of(context).hintColor : Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  const FlashDealsListWidget()]) : const SizedBox.shrink();
              }),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Consumer<FeaturedDealController>(
                builder: (context, featuredDealProvider, child) {
                  return  featuredDealProvider.featuredDealProductList != null? featuredDealProvider.featuredDealProductList!.isNotEmpty ?
                  Column(
                    children: [
                      Stack(children: [



                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),

                        Column(children: [

                          // Text("check price",style: TextStyle(fontSize: 30),),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                            child: TitleRowWidget(
                              title: '${getTranslated('featured_deals', context)}',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeaturedDealScreenView())),
                            ),
                          ), const FeaturedDealsListWidget(),
                        ]),
                      ]),

                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],
                  ) : const SizedBox.shrink() : const FindWhatYouNeedShimmer();}),


              Consumer<BannerController>(builder: (context, footerBannerProvider, child){
                return footerBannerProvider.footerBannerList != null && footerBannerProvider.footerBannerList!.isNotEmpty?
                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: SingleBannersWidget( bannerModel : footerBannerProvider.footerBannerList?[0])):
                const SizedBox();
              }),
              const SizedBox(height: Dimensions.paddingSizeDefault),


              Consumer<ProductController>(builder: (context, productController,_) {
                  return FeaturedProductWidget();
                }
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //   child: InkWell(
              //     onTap: () {
              //       // Navigate to GoldPlansScreen
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => const GoldPurchasePlansScreen()),
              //       );
              //     },
              //     child: Container(
              //       padding: const EdgeInsets.all(16),
              //       decoration: BoxDecoration(
              //         color: Colors.blueAccent.shade100,
              //         borderRadius: BorderRadius.circular(12),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.grey.withOpacity(0.3),
              //             spreadRadius: 2,
              //             blurRadius: 5,
              //             offset: const Offset(0, 3),
              //           ),
              //         ],
              //       ),
              //       child: Row(
              //         children: [
              //           const Icon(
              //             Icons.card_membership,
              //             color: Colors.white,
              //             size: 40,
              //           ),
              //           const SizedBox(width: 16),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   "Purchase Gold Plans Now",
              //                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 4),
              //                 Text(
              //                   "Invest in secure gold plans and grow your wealth.",
              //                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //                     color: Colors.white70,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           const Icon(
              //             Icons.arrow_forward_ios,
              //             color: Colors.white,
              //             size: 20,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              singleVendor? const SizedBox() :
              Consumer<ShopController>(
                builder: (context, topSellerProvider, child) {
                  return (topSellerProvider.sellerModel != null && (topSellerProvider.sellerModel!.sellers!=null && topSellerProvider.sellerModel!.sellers!.isNotEmpty))?
                  TitleRowWidget(title: getTranslated('top_seller', context),
                      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      const AllTopSellerScreen( title: 'top_stores',)))):
                  const SizedBox();
                }),
              singleVendor?const SizedBox(height: 0):const SizedBox(height: Dimensions.paddingSizeSmall),

              singleVendor?const SizedBox():
              Consumer<ShopController>(
                  builder: (context, topSellerProvider, child) {
                    return (topSellerProvider.sellerModel != null && (topSellerProvider.sellerModel!.sellers!=null && topSellerProvider.sellerModel!.sellers!.isNotEmpty))?
                    Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                        child: SizedBox(height: ResponsiveHelper.isTab(context)? 170 : 165, child: TopSellerView(isHomePage: true, scrollController: _scrollController,))):const SizedBox();}),



              const Padding(padding: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  child: RecommendedProductWidget()),



              const Padding(padding: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  child: LatestProductListWidget()),



              // if(configModel?.brandSetting == "1") TitleRowWidget(
              //   title: getTranslated('brand', context),
              //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrandsView())),
              // ),
              //
              // SizedBox(height: configModel?.brandSetting == "1" ? Dimensions.paddingSizeSmall: 0),
              //
              // if(configModel!.brandSetting == "1") ...[
              //   const BrandListWidget(isHomePage: true),
              //   const SizedBox(height: Dimensions.paddingSizeDefault),
              // ],


             // Text("check price",style: TextStyle(fontSize: 30),),


              const HomeCategoryProductWidget(isHomePage: true),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              const FooterBannerSliderWidget(),
              const SizedBox(height: Dimensions.paddingSizeDefault),


              // InkWell(
              //   onTap: (){
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => GoldPriceScreen()),
              //     );
              //   },
              //   child: Container(
              //       height: 200,
              //       width: MediaQuery.of(context).size.width,
              //       alignment: Alignment.center,
              //       child: Text("Check Gold Price",style: TextStyle(fontSize: 20),)),
              // ),


              Consumer<ProductController>(
                builder: (ctx,prodProvider,child) {
                  return Container(decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSecondaryContainer),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeSmall, 0),
                            child: Row(children: [
                              Expanded(child: Text(prodProvider.title == 'xyz' ? getTranslated('new_arrival',context)!:
                              prodProvider.title!, style: titleHeader)),
                              prodProvider.latestProductList != null ?
                              PopupMenuButton(
                                padding: const EdgeInsets.all(0),
                                itemBuilder: (context) {
                                  return [



                                    PopupMenuItem(
                                      value: ProductType.newArrival,
                                      child: Text(getTranslated('new_arrival',context)??'', style: textRegular.copyWith(
                                        color: prodProvider.productType == ProductType.newArrival ? Theme.of(context).primaryColor :  Theme.of(context).textTheme.bodyLarge?.color,
                                      )),
                                    ),

                                    PopupMenuItem(
                                      value: ProductType.topProduct,
                                      child: Text(getTranslated('top_product',context)??'', style: textRegular.copyWith(
                                        color: prodProvider.productType == ProductType.topProduct ? Theme.of(context).primaryColor :  Theme.of(context).textTheme.bodyLarge?.color,
                                      )),
                                    ),

                                    PopupMenuItem(
                                      value: ProductType.bestSelling,
                                      child: Text(getTranslated('best_selling',context)??'', style: textRegular.copyWith(
                                        color: prodProvider.productType == ProductType.bestSelling ? Theme.of(context).primaryColor :  Theme.of(context).textTheme.bodyLarge?.color,
                                      )),
                                    ),

                                    PopupMenuItem(
                                      value: ProductType.discountedProduct,
                                      child: Text(getTranslated('discounted_product',context)??'',  style: textRegular.copyWith(
                                        color: prodProvider.productType == ProductType.discountedProduct ? Theme.of(context).primaryColor :  Theme.of(context).textTheme.bodyLarge?.color,
                                      )),
                                    ),
                                  ];
                                },
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
                                child: Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeExtraSmall,
                                    Dimensions.paddingSizeSmall,
                                    Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeSmall ),
                                    child: Image.asset(Images.dropdown, scale: 3)),
                                onSelected: (ProductType value) {
                                  if(value == ProductType.newArrival){
                                    Provider.of<ProductController>(context, listen: false).changeTypeOfProduct(value, types[0]);
                                  }else if(value == ProductType.topProduct){
                                    Provider.of<ProductController>(context, listen: false).changeTypeOfProduct(value, types[1]);
                                  }else if(value == ProductType.bestSelling){
                                    Provider.of<ProductController>(context, listen: false).changeTypeOfProduct(value, types[2]);
                                  }else if(value == ProductType.discountedProduct){
                                    Provider.of<ProductController>(context, listen: false).changeTypeOfProduct(value, types[3]);
                                  }
                                 //  Provider.of<ProductController>(context, listen: false).getLatestProductList(1, reload: true);
                                },
                              ) : const SizedBox()])),

                        Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: ProductListWidget(isHomePage: false, productType: ProductType.newArrival,
                              scrollController: _scrollController),),
                        const SizedBox(height: Dimensions.homePagePadding)]));}),






            ],
            ),
          )
        ],
        ),
      ),
      ),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  SliverDelegate({required this.child, this.height = 70});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
