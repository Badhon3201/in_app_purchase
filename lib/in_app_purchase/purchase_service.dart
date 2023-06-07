import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'in_app_item_id.dart';
import 'in_app_purchase_store.dart';

class PurchaseService {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  var inAppPurchaseStore = InAppPurchaseStore;

  List<PurchaseDetails> _purchases = <PurchaseDetails>[];

  late final ProductDetailsResponse productDetailResponse;

  final bool kAutoConsume = Platform.isIOS || true;

  late StreamSubscription<List<PurchaseDetails>> subscription;

  List<String> notFoundIds = <String>[];

  List<ProductDetails> products = <ProductDetails>[];

  List<PurchaseDetails> purchases = <PurchaseDetails>[];

  List<String> consumabless = <String>[];

  bool isAvailables = false;

  bool purchasePending = false;

  bool loading = true;

  String? queryProductError;

  static getPurchaseHistory() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      InAppPurchaseAndroidPlatformAddition androidAddition = InAppPurchase
          .instance
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

      QueryPurchaseDetailsResponse response =
          await androidAddition.queryPastPurchases();

      debugPrint(
          "SplashCheck==>${InAppPurchaseStore.load().then((value) => value.length)}");
      if (response.pastPurchases.isNotEmpty) {
        await InAppPurchaseStore.save(InAppItemId.nonConsumableIdForAdRemove);
        await InAppPurchaseStore.load();

        debugPrint("PurchaseResponse");
      }
      debugPrint("responseHistoryData==>${response.pastPurchases.length}");
    } else {
      InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = InAppPurchase
          .instance
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());

      var a = await iosPlatformAddition.refreshPurchaseVerificationData();
      debugPrint(
          "${a?.source} ${a?.localVerificationData} + ${a?.serverVerificationData}");
    }
  }

  //on update purchase
  onUpgrade() {
    late PurchaseParam purchaseParam;

    final Map<String, PurchaseDetails> purchases =
        Map<String, PurchaseDetails>.fromEntries(
            _purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));

    if (Platform.isAndroid) {
      final GooglePlayPurchaseDetails? oldSubscription = getOldSubscription(
          productDetailResponse.productDetails[0], purchases);

      purchaseParam = GooglePlayPurchaseParam(
          productDetails: productDetailResponse.productDetails[0],
          changeSubscriptionParam: (oldSubscription != null)
              ? ChangeSubscriptionParam(
                  oldPurchaseDetails: oldSubscription,
                  prorationMode: ProrationMode.immediateWithTimeProration,
                )
              : null);
    } else {
      purchaseParam = PurchaseParam(
        productDetails: productDetailResponse.productDetails[0],
      );
    }

    if (productDetailResponse.productDetails[0].id ==
        InAppItemId.nonConsumableIdForAdRemove) {
      inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam, autoConsume: kAutoConsume);

      debugPrint(
          "onUpgradeConsumableProduct ${InAppItemId.nonConsumableIdForAdRemove}");
    } else {
      inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  //call initialState
  initStateInApp() {
    debugPrint("SubscribeData=>outer");
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        inAppPurchase.purchaseStream;
    subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      listenToPurchaseUpdated(purchaseDetailsList);
      debugPrint("SubscribeData=>inner");
    }, onDone: () {
      subscription.cancel();
      debugPrint("SubscribeData=>done");
    }, onError: (Object error) {
      // handle error here.
      debugPrint("SubscribeData=>error");
    });
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    debugPrint("SubscribeData=>StoreInfo");
    final bool isAvailable = await inAppPurchase.isAvailable();
    if (!isAvailable) {
      debugPrint("SubscribeData=>NotAvailable");
      isAvailables = isAvailable;
      products = <ProductDetails>[];
      purchases = <PurchaseDetails>[];
      notFoundIds = <String>[];
      consumabless = <String>[];
      purchasePending = false;
      loading = false;

      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    productDetailResponse = await inAppPurchase
        .queryProductDetails(InAppItemId.kProductIds.toSet());

    if (productDetailResponse.error != null) {
      queryProductError = productDetailResponse.error!.message;
      isAvailables = isAvailable;
      products = productDetailResponse.productDetails;
      purchases = <PurchaseDetails>[];
      notFoundIds = productDetailResponse.notFoundIDs;
      consumabless = <String>[];
      purchasePending = false;
      loading = false;

      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      queryProductError = null;
      isAvailables = isAvailable;
      products = productDetailResponse.productDetails;
      purchases = <PurchaseDetails>[];
      notFoundIds = productDetailResponse.notFoundIDs;
      consumabless = <String>[];
      purchasePending = false;
      loading = false;
      return;
    }

    final List<String> consumables = await InAppPurchaseStore.load();
    isAvailables = isAvailable;
    products = productDetailResponse.productDetails;
    notFoundIds = productDetailResponse.notFoundIDs;
    consumabless = consumables;
    purchasePending = false;
    loading = false;
    debugPrint("consumabless${consumabless.length}");
  }

  Future<void> listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint("purchaseHistory ${purchaseDetails.status}");
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await verifyPurchase(purchaseDetails);
          if (valid) {
            debugPrint("True");
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume &&
              purchaseDetails.productID ==
                  InAppItemId.nonConsumableIdForAdRemove) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
    debugPrint("purchaseDetails=====> ${purchaseDetailsList.first.status}");
  }

  void showPendingUI() {
    purchasePending = true;
  }

  void handleError(IAPError error) {
    purchasePending = false;
  }

  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == InAppItemId.nonConsumableIdForAdRemove) {
      await InAppPurchaseStore.save(purchaseDetails.purchaseID!);
      final List<String> consumables = await InAppPurchaseStore.load();

      purchasePending = false;
      consumabless = consumables;
    } else {
      purchases.add(purchaseDetails);
      purchasePending = false;
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  //call initialState
  Future<void> consume(String id) async {
    await InAppPurchaseStore.consume(id);
    final List<String> consumables = await InAppPurchaseStore.load();
    debugPrint("ConsumableListLen=>${consumables.length}");
  }

  //getOldSubscription
  GooglePlayPurchaseDetails? getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == InAppItemId.kSilverSubscriptionId &&
        purchases[InAppItemId.kGoldSubscriptionId] != null) {
      oldSubscription = purchases[InAppItemId.kGoldSubscriptionId]!
          as GooglePlayPurchaseDetails;
    } else if (productDetails.id == InAppItemId.kGoldSubscriptionId &&
        purchases[InAppItemId.kSilverSubscriptionId] != null) {
      oldSubscription = purchases[InAppItemId.kSilverSubscriptionId]!
          as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
