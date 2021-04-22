import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../models/user_model.dart';
import '../../../models/app_const.dart';
import '../../../models/company_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanyPlanWidget extends StatefulWidget {
  final Function showMessage;
  final Function next;
  final Function done;
  CompanyPlanWidget({this.showMessage,this.next,this.done, Key key}):super(key: key);

  @override
  _CompanyPlanState createState() => _CompanyPlanState();
}

class _CompanyPlanState extends State<CompanyPlanWidget> {
  bool _isLoading = false;
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  ProductDetails selectedProduct;


  @override
  void initState() {
    Stream purchaseUpdated = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      widget.showMessage(error.toString());
      print('InAppPurchaseConnection.Error $error');
    });
    initStoreInfo();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _products = [];
      });
      return;
    }

    ProductDetailsResponse productDetailResponse = await _connection.queryProductDetails(subscriptionPlans.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        widget.showMessage(productDetailResponse.error.message);
        _products = productDetailResponse.productDetails;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _products = productDetailResponse.productDetails;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse = await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      widget.showMessage(purchaseResponse.error.message);
    }
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      verifiedPurchases.add(purchase);
    }
    setState(() {
      _products = productDetailResponse.productDetails;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if(purchaseDetails.status == PurchaseStatus.error){
        widget.showMessage(purchaseDetails.error.message);
      }
      if(purchaseDetails.status == PurchaseStatus.purchased){
        setState(() {_isLoading = true;});
        await createCompany();
        setState(() {_isLoading = false;});
        widget.done();
      }
    });
  }

  Future createCompany()async{
    try{
      String result = await context.read<CompanyModel>().createCompany();
      if(result!=null){
        widget.showMessage(result);
      }else{
        Company company = context.read<CompanyModel>().myCompany;
        context.read<UserModel>().user.companyId = company.id;
        await context.read<UserModel>().saveUserToLocal();
      }
    }catch(e){
      print("[CompanyPlanWidget.createCompany] $e");
    }
  }


  Widget companyPlanWidgets(Company myCompany){
    List<Widget> plans = [];
    _products.forEach((p) {
      plans.add(
        CheckboxListTile(
          value: selectedProduct==p,
          onChanged: (v){
            setState(() {selectedProduct=p;});
            context.read<CompanyModel>().setPlanMyCompany(subscriptionPlans.indexOf(p.id));
          },
          title: Text("${p.title}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
          controlAffinity: ListTileControlAffinity.leading,
          secondary: Text("${p.price}/mth",style: TextStyle(color: Color(primaryColor,),fontSize: 18,fontWeight: FontWeight.bold),),
          contentPadding: EdgeInsets.symmetric(horizontal: 30),
        )
      );
    });
    return Column(
      children: plans,
    );
  }

  @override
  Widget build(BuildContext context) {
    Company myCompany = context.watch<CompanyModel>().myCompany;
    return Container(
      child: Column(
        children: [
          SizedBox(height: 30,),
          Image.asset(
            "assets/images/logo.png",
            width: 100,
            height: 100,
          ),
          SizedBox(height: 10,),
          Text(
            "Please enter your Employee Range",
            style: TextStyle(color: Colors.black87,fontSize: 20,fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10,),
          CheckboxListTile(
              value: myCompany.plan==0,
              onChanged: (v){
                setState(() {
                  selectedProduct = null;
                });
                context.read<CompanyModel>().setPlanMyCompany(0);
              },
            title: Text("${companyPlans[0].minRange} ~ ${companyPlans[0].maxRange} Employees",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            controlAffinity: ListTileControlAffinity.leading,
            secondary: Text("Free",style: TextStyle(color: Color(primaryColor,),fontSize: 18,fontWeight: FontWeight.bold),),
            contentPadding: EdgeInsets.symmetric(horizontal: 30),
          ),
          companyPlanWidgets(myCompany),
          SizedBox(height: 20,),
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width-60,
            padding: EdgeInsets.all(8),
            splashColor: Color(primaryColor),
            child: RaisedButton(
              child: _isLoading?SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(backgroundColor: Colors.white,)
              ):Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("Next",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
              ),
              onPressed: ()async{
                if(!_isLoading){
                  if(selectedProduct==null){
                    setState(() {_isLoading = true;});
                    await createCompany();
                    setState(() {_isLoading = false;});
                    widget.done();
                  }else{
                    final user = Provider.of<UserModel>(context,listen: false).user;
                    PurchaseParam purchaseParam = PurchaseParam(
                        productDetails: selectedProduct,
                        applicationUserName: user.firstName+" "+user.lastName,
                        sandboxTesting: false);
                    _connection.buyNonConsumable(purchaseParam: purchaseParam);
                  }
                }
              },
              color: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }
}