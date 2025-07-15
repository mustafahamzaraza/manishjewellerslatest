import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/bouncy_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/order_details/screens/order_details_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/domain/models/config_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/update/screen/update_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/screens/wallet_screen.dart';
import 'package:flutter_sixvalley_ecommerce/helper/network_info.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/push_notification/models/notification_body.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/screens/inbox_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/maintenance/maintenance_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/screens/notification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/onboarding/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  // late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getToken();
    // bool firstTime = true;
    // _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   if(!firstTime) {
    //     bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
    //     isNotConnected ? const SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       backgroundColor: isNotConnected ? Colors.red : Colors.green,
    //       duration: Duration(seconds: isNotConnected ? 6000 : 3),
    //       content: Text(isNotConnected ? getTranslated('no_connection', context)! : getTranslated('connected', context)!,
    //         textAlign: TextAlign.center)));
    //     if(!isNotConnected) {
    //       _route();
    //     }
    //   }
    //   firstTime = false;
    // });

    _initializeAsync();
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
      //   SnackBar(content: Text('Resumed on Splash Screen Init with mandate id $mandate')),
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
        //  SnackBar(content: Text("✅ Payment Flow Completed with proper mandateid")),
        //);
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






  Future<void> _initializeAsync() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    _route();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // _onConnectivityChanged.cancel();
  }

  void _route() {
    NetworkInfo.checkConnectivity(context);
    Provider.of<SplashController>(context, listen: false).initConfig(
      context,
      (ConfigModel? configModel) {
        String? minimumVersion = "0";
        UserAppVersionControl? appVersion = Provider.of<SplashController>(Get.context!, listen: false).configModel?.userAppVersionControl;
        if(Platform.isAndroid) {
          minimumVersion =  appVersion?.forAndroid?.version ?? '0';
        } else if(Platform.isIOS) {
          minimumVersion = appVersion?.forIos?.version ?? '0';
        }
        Provider.of<SplashController>(Get.context!, listen: false).initSharedPrefData();
        // Timer(const Duration(seconds: 2), () {
          final config = Provider.of<SplashController>(Get.context!, listen: false).configModel;

          Future.delayed(const Duration(milliseconds: 0)).then((_) {
            if(compareVersions(minimumVersion!, AppConstants.appVersion) == 1) {
              Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const UpdateScreen()));
            } else if(
            config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1
                && !Provider.of<SplashController>(context, listen: false).isConfigCall) {
              Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
                builder: (_) => const MaintenanceScreen(),
                settings: const RouteSettings(name: 'MaintenanceScreen'),
              ));
            } else if(Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn()) {
              Provider.of<AuthController>(Get.context!, listen: false).updateToken(Get.context!);
              if(widget.body != null){
                if (widget.body!.type == 'order') {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>
                      OrderDetailsScreen(orderId: widget.body!.orderId)));
                } else if(widget.body!.type == 'notification') {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>
                  const NotificationScreen()));
                } else if(widget.body!.type == 'wallet') {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const WalletScreen()));
                } else  if (widget.body!.type == 'chatting') {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>
                      InboxScreen(isBackButtonExist: true, fromNotification: true,  initIndex: widget.body!.messageKey ==  'message_from_delivery_man' ? 0 : 1)));
                } else if(widget.body!.type == 'product_restock_update') {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>  ProductDetails(productId: int.parse(widget.body!.productId!), slug: widget.body!.slug, isNotification: true)));
                } else {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>  const NotificationScreen(fromNotification: true,)));
                }
              }else{
                Navigator.of(Get.context!).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                    transitionDuration: Duration.zero, // Removes transition duration
                    reverseTransitionDuration: Duration.zero, // Removes reverse transition
                    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                  ),
                );
              }
            }

            else if(Provider.of<SplashController>(Get.context!, listen: false).showIntro()!){
              Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => OnBoardingScreen(
                  indicatorColor: ColorResources.grey, selectedIndicatorColor: Theme.of(context).primaryColor)));
            }
            else{
              if(Provider.of<AuthController>(context, listen: false).getGuestToken() != null &&
                  Provider.of<AuthController>(context, listen: false).getGuestToken() != '1'){
                Navigator.of(Get.context!).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                    transitionDuration: Duration.zero, // Removes transition duration
                    reverseTransitionDuration: Duration.zero, // Removes reverse transition
                    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                  ),
                );
              }else{
                Provider.of<AuthController>(context, listen: false).getGuestIdUrl();

                Navigator.of(Get.context!).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const DashBoardScreen(),
                    transitionDuration: Duration.zero, // Removes transition duration
                    reverseTransitionDuration: Duration.zero, // Removes reverse transition
                    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                  ),
                );
              }
            }
          });
       //  });
      },


      (ConfigModel? configModel) {
        String? minimumVersion = "0";
        UserAppVersionControl? appVersion = Provider.of<SplashController>(Get.context!, listen: false).configModel?.userAppVersionControl;
        if(Platform.isAndroid) {
          minimumVersion =  appVersion?.forAndroid?.version ?? '0';
        } else if(Platform.isIOS) {
          minimumVersion = appVersion?.forIos?.version ?? '0';
        }
        Provider.of<SplashController>(Get.context!, listen: false).initSharedPrefData();
        // Timer(const Duration(seconds: 1), () {
          final config = Provider.of<SplashController>(Get.context!, listen: false).configModel;
          if(compareVersions(minimumVersion, AppConstants.appVersion) == 1) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const UpdateScreen()));
          } else if(
            config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1
            && !config!.localMaintenanceMode!
          ) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
              builder: (_) => const MaintenanceScreen(),
              settings: const RouteSettings(name: 'MaintenanceScreen'),
            ));
          } else if(Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn() && !configModel!.hasLocaldb!) {
            Provider.of<AuthController>(Get.context!, listen: false).updateToken(Get.context!);
            if(widget.body != null) {
              if (widget.body!.type == 'order') {
                Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>
                    OrderDetailsScreen(orderId: widget.body!.orderId)));
              } else if(widget.body!.type == 'notification') {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>
                const NotificationScreen()));
              } else if(widget.body!.type == 'wallet') {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const WalletScreen()));
              } else  if (widget.body!.type == 'chatting') {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>
                    InboxScreen(isBackButtonExist: true, fromNotification: true,  initIndex: widget.body!.messageKey ==  'message_from_delivery_man' ? 0 : 1)));
              } else if(widget.body!.type == 'product_restock_update') {
                Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>  ProductDetails(productId: int.parse(widget.body!.productId!), slug: widget.body!.slug, isNotification: true)));
              } else {
                Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>  const NotificationScreen(fromNotification: true,)));
              }
            }else{
              Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const DashBoardScreen()));
            }
          }

          else if(Provider.of<SplashController>(Get.context!, listen: false).showIntro()! &&  !configModel!.hasLocaldb!){
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => OnBoardingScreen(
                indicatorColor: ColorResources.grey, selectedIndicatorColor: Theme.of(context).primaryColor)));
          }
          else if(!configModel!.hasLocaldb! || (configModel.hasLocaldb! && configModel.localMaintenanceMode! && !(config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.customerApp == 1))){
            if(Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != null &&
                Provider.of<AuthController>(Get.context!, listen: false).getGuestToken() != '1'){
              Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const DashBoardScreen()));
            }else{
              Provider.of<AuthController>(Get.context!, listen: false).getGuestIdUrl();
              Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const DashBoardScreen()), (route) => false);
            }
          }
        // });
      }


    ).then((bool isSuccess) {
      if(isSuccess) {

      }
    });
  }


  int compareVersions(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');
    for (int i = 0; i < v1Components.length; i++) {
      int v1Part = int.parse(v1Components[i]);
      int v2Part = int.parse(v2Components[i]);
      if (v1Part > v2Part) {
        return 1;
      } else if (v1Part < v2Part) {
        return -1;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double iconSize = size.width * 0.50; // MJ icon scales with screen width
    final double circularSize = size.width * 0.15; // Circular icon scales too
    final double textSize = size.width * 0.08; // Adjust text size dynamically
    final double buttonHeight = size.height * 0.07; // Button adapts to screen

    return Scaffold(
      backgroundColor: Colors.white,
      key: _globalKey,
      //     body: Provider.of<SplashController>(context).hasConnection ?
      body:

      Provider.of<SplashController>(context).hasConnection ?  SingleChildScrollView(

        child: Column(
          children: [
            SizedBox(
              height: size.height, // Full-screen height
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // MJ Icon (Main)
                  Positioned(
                    top: size.height * 0.07, // Dynamic positioning
                    child: Image.asset(
                      // 'assets/images/mjicon.jpg',
                      'assets/images/mjicon.jpg',
                      height: iconSize,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Small circular icon
                  Positioned(
                    top: size.height * 0.32,
                    right: size.width * 0.2,
                    child: Container(
                      width: circularSize,
                      height: circularSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Image.asset(
                        'assets/images/circular.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Second circular image
                  Positioned(
                    top: size.height * 0.4,
                    left: size.width * 0.1,
                    child: Container(
                      width: size.width * 0.6, // Scales with screen width
                      height: size.width * 0.6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        'assets/images/cur2.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),

                  // Text Section
                  Positioned(
                    bottom: size.height * 0.2,
                    left: size.width * 0.1,
                    right: size.width * 0.1,
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // Prevents text overflow
                      child: Text(
                        // "\tEmpowering\nYour\nGold\nInvestments",
                        "Shop Smart,\n Shop Easy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.1,
                            fontSize: MediaQuery.of(context).size.height/34
                        ),
                      ),
                    ),
                  ),

                  // "Manage.Track.Grow." Button
                  Positioned(
                    bottom: size.height * 0.08,
                    left: size.width * 0.1,
                    right: size.width * 0.1,
                    child: SizedBox(
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber, // Adjusted to gold
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Manage.Track.Grow.",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_right_alt_sharp,
                              size: 30,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ) : const NoInternetOrDataScreenWidget(isNoInternet: true, child: SplashScreen()),


    );
  }


  // @override
  // Widget build(BuildContext context) {
  //
  //   return Scaffold(
  //   //  backgroundColor: Colors.amber[400],  // Golden color
  //     key: _globalKey,
  //     body: Provider.of<SplashController>(context).hasConnection ?
  //     // Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
  //     //   BouncyWidget(
  //     //       duration: const Duration(milliseconds: 2000), lift: 50, ratio: 0.5, pause: 0.25,
  //     //       child: SizedBox(width: 150,
  //     //           child: Image.asset(
  //     //               Images.white,
  //     //               width: 150.0))),
  //     //   Text(AppConstants.appName,style: textRegular.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Colors.white)),
  //     //   Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
  //     //       child: Text(AppConstants.slogan,style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white)))]),
  //     // )
  //     // FittedBox(
  //     //   child: Image.asset(Images.green, // Replace with your image path
  //     //     fit: BoxFit.contain, // Ensures the image fills the entire screen
  //     //   ),
  //     // )
  //     Image.asset(
  //       Images.green,// Replace with your image path
  //       width: double.infinity,
  //       height: double.infinity,
  //       fit: BoxFit.cover, // Ensures the image fills the screen
  //     )
  //         : const NoInternetOrDataScreenWidget(isNoInternet: true, child: SplashScreen()),
  //   );
  // }
}
