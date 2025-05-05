import 'package:are_mart/features/admin/model/cart_item_model.dart';
import 'package:are_mart/features/admin/model/order_models.dart';
import 'package:are_mart/features/admin/model/product_sizes_model.dart';
import 'package:are_mart/features/admin/model/products_model.dart';
import 'package:are_mart/features/authorized/screens/order_success_screen.dart';
import 'package:are_mart/features/common/widgets/cart/cart_price_bottom_sheet.dart';
import 'package:are_mart/utils/controllers/auth_controller.dart';
import 'package:are_mart/utils/helpers/network_manager.dart';
import 'package:are_mart/utils/local_storage/storage_utility.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:are_mart/utils/services/order_service.dart';
import 'package:are_mart/utils/services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  @override
  void onInit() {
    loadCartItemFromLocalStorage();
    super.onInit();
  }

  ProductsModel? openProduct;
  Rx<ProductsSizesModel?> selectedSize = Rx<ProductsSizesModel?>(null);
  RxList<CartItemModel> cartItems = RxList<CartItemModel>([]);
  RxMap<String, int> itemCount = RxMap<String, int>({});
  RxDouble totalAmount = RxDouble(0.0);
  RxDouble totalMrp = RxDouble(0.0);
  RxDouble handlingChage = RxDouble(0.0);
  RxDouble shippingChage = RxDouble(0.0);

  RxBool isPlacingOrder = RxBool(false);

  loadCartItemFromLocalStorage() {
    List<dynamic>? localdata = TLocalStorage.readData("quickgrocart");
    TLoggerHelper.customPrint("Local Data: $localdata");

    if (localdata != null) {
      for (var i = 0; i < localdata.length; i++) {
        itemCount[localdata[i]["id"]] = localdata[i]["quantity"];
        cartItems.add(CartItemModel.fromJson({...localdata[i], "quantity": 0}));
        totalAmount.value = totalAmount.value + localdata[i]["price"];
        totalMrp.value = totalMrp.value + localdata[i]["mrp"];
      }
    }
  }

  void initViewModel(ProductsModel product, ProductsSizesModel size) {
    openProduct = product;
    selectedSize.value = size;
  }

  void setSelectedSize(ProductsSizesModel size) => selectedSize.value = size;

  void onCloseModel() {
    openProduct = null;
    selectedSize.value = null;
  }

  void addItemToCart({
    required ProductsModel product,
    required ProductsSizesModel size,
  }) {
    if (size.quantity == 0) {
      TLoaders.errorSnackBar(
        title: "Error",
        message: "${product.name} is out of stock",
      );
      return;
    }
    if (itemCount[product.docId + size.size] != null) {
      TLoaders.warningSnackBar(title: "Info", message: "Item already in cart");
      return;
    }

    final dataId = product.docId + size.size;
    final data = CartItemModel.fromJson({
      "id": dataId,
      "productId": product.docId,
      "productQuantity": size.quantity,
      "productLimitPerOrder": size.limitPerOrder,
      "image": product.image,
      "name": product.name,
      "category": product.category,
      "categoryId": product.categoryId,
      "price": size.discountPrice,
      "mrp": size.mrp,
      "quantity": 0,
      "size": size.size,
    });

    var localdata = TLocalStorage.readData("quickgrocart");
    final localitem = {...data.toJson(), "quantity": 1};
    if (localdata == null) {
      localdata = [localitem];
    } else {
      localdata.add(localitem);
    }
    TLocalStorage.saveData(key: "quickgrocart", value: localdata);

    cartItems.add(data);
    itemCount[dataId] = 1;
    itemCount.refresh();
    cartItems.refresh();
    totalAmount.value = totalAmount.value + data.price;
    totalMrp.value = totalMrp.value + data.mrp;
    TLoggerHelper.customPrint(
      "Total Amount: ${totalAmount.value} and total MRP: ${totalMrp.value}",
    );
  }

  void decrement(String itemId) {
    final item = cartItems.firstWhere((element) => element.id == itemId);
    List<dynamic> localdata = TLocalStorage.readData("quickgrocart");
    if (itemCount[itemId] == 1) {
      itemCount.remove(itemId);
      cartItems.removeWhere((element) => element.id == itemId);
      localdata.removeWhere((item) => item["id"] == itemId);
    } else {
      itemCount[itemId] = itemCount[itemId]! - 1;
      final index = localdata.indexWhere((item) => item["id"] == itemId);
      localdata[index]["quantity"] = localdata[index]["quantity"] - 1;
    }
    TLocalStorage.saveData(key: "quickgrocart", value: localdata);

    itemCount.refresh();
    totalAmount.value = totalAmount.value - item.price;
    totalMrp.value = totalMrp.value - item.mrp;

    totalAmount.refresh();
    totalMrp.refresh();
  }

  void increment(String itemId, int quantity, int limitPerOrder) {
    List<dynamic> localdata = TLocalStorage.readData("quickgrocart");
    if (itemCount[itemId]! == quantity) {
      TLoaders.warningSnackBar(title: "Info", message: "item quantity left 0");
      return;
    }
    if (itemCount[itemId]! == limitPerOrder) {
      TLoaders.warningSnackBar(
        title: "Info",
        message: "User can only order $limitPerOrder items per order",
      );
      return;
    }
    itemCount[itemId] = itemCount[itemId]! + 1;
    final index = localdata.indexWhere((item) => item["id"] == itemId);
    localdata[index]["quantity"] = localdata[index]["quantity"] + 1;

    TLocalStorage.saveData(key: "quickgrocart", value: localdata);

    itemCount.refresh();
    final item = cartItems.firstWhere((element) => element.id == itemId);
    totalAmount.value = totalAmount.value + item.price;
    totalMrp.value = totalMrp.value + item.mrp;
  }

  void showCartPriceBottomSheet(BuildContext context) {
    // final totalAmount = subtotal + shippingChage.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: CartPriceBottomSheetState(
              mrp: totalMrp.value,
              cartItems: cartItems,
              totalAmount: totalAmount.value,
              discount: (totalMrp.value - totalAmount.value),
              deliveryCharge: shippingChage.value,
            ),
          ),
    );
  }

  Future<void> placeOrder() async {
    if (!await NetworkManager.instance.isConnected()) {
      TLoaders.errorSnackBar(title: "Error", message: "Check Your Network");
      return;
    }
    final orderId = Uuid().v4();
    final currentUser = FirebaseAuth.instance.currentUser;

    List<OrderProduct> orderProducts = [];
    var remainingQuantity = [];

    for (var i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];

      final pro = await ProductService.getProductById(item.productId);
      if (pro == null) {
        TLoaders.errorSnackBar(title: "Error", message: "Product not found");
        return;
      }
      final indexOfVarient = pro.size.indexWhere(
        (element) => element.size == item.size,
      );
      if (indexOfVarient == -1) {
        TLoaders.errorSnackBar(title: "Error", message: "Product not found");
        return;
      }
      final itemSize = pro.size[indexOfVarient];
      if (itemSize.quantity == 0) {
        TLoaders.errorSnackBar(
          title: "Error",
          message: "${pro.name} is out of stock, Remove from cart",
        );
        return;
      }
      if (itemSize.quantity < itemCount[item.id]!) {
        TLoaders.errorSnackBar(
          title: "Error",
          message: "Only ${itemSize.quantity} is left of ${pro.name}",
        );
        return;
      }

      remainingQuantity.add(itemSize.quantity - itemCount[item.id]!);

      orderProducts.add(
        OrderProduct(
          productsId: item.productId,
          name: item.name,
          image: item.image,
          category: item.category,
          varient: item.size,
          quantity: itemCount[item.id]!,
          price: item.price,
          totalPrice: itemCount[item.id]! * item.price,
        ),
      );
    }

    TLoggerHelper.customPrint("All items are available in stock");

    //
    if (currentUser == null) {
      TLoaders.errorSnackBar(title: "Error", message: "Session TimeOut");
      AuthController.instance.logout();
      return;
    }
    isPlacingOrder.value = true;
    final userAddress = AuthController.instance.user.value!.address[0];
    final order = OrderModel(
      id: orderId,
      userId: AuthController.instance.user.value!.userId,
      userName: AuthController.instance.user.value!.name,
      number: AuthController.instance.user.value!.number,
      orderTotalAmount: totalAmount.value,
      address:
          "${userAddress.address} ${userAddress.city}, ${userAddress.state}-${userAddress.pincode}",
      products: orderProducts,
      status: "Pending",
      orderDate: DateTime.now(),
    );

    // TLoggerHelper.customPrint(order.toJson());
    await OrderService().createOrder(order);
    for (var i = 0; i < cartItems.length; i++) {
      final item = cartItems[i];
      await ProductService.updateProductQuantity(
        productId: item.productId,
        size: item.size,
        quantity: remainingQuantity[i],
      );
    }
    TLocalStorage.removeData("quickgrocart");
    isPlacingOrder.value = false;
    Get.to(() => OrderSuccessScreen(orderId: orderId));
    Future.delayed(Duration(seconds: 1), () {
      itemCount.clear();
      cartItems.clear();
      totalAmount.value = 0;
      totalMrp.value = 0;
    });
  }
}
