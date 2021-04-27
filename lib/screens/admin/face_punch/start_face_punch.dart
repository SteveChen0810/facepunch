import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/widgets/dialogs.dart';
import 'face_punch.dart';
import '../../../models/app_const.dart';
import '../../../models/company_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartFacePunch extends StatefulWidget {
  final Function showMessage;

  StartFacePunch({this.showMessage});

  @override
  _StartFacePunchState createState() => _StartFacePunchState();
}

class _StartFacePunchState extends State<StartFacePunch> {
  Company selectedCompany;
  bool hasError=false;

  checkCompanyDialog(context)async{
    bool result = await pinCodeCheckDialog(selectedCompany.pin, context);
    if(result){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>FacePunchScreen(company: selectedCompany,)));
    }else{
      widget.showMessage(S.of(context).pinCodeNotCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Company> companies = context.watch<CompanyModel>().companies;
    if(selectedCompany!=null){
      selectedCompany = companies.firstWhere((c) => c.id==selectedCompany.id,orElse: ()=>null);
    }
    return Container(
      width: width,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(S.of(context).facePunch,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Column(
            children: [
              Text("Select your Company",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
              SizedBox(height: 4,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black87)
                ),
                height: 40,
                child: DropdownButton<Company>(
                  items: companies.map((Company value) {
                    return DropdownMenuItem<Company>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 8),
                        child: Text(value.name),
                      ),
                    );
                  }).toList(),
                  underline: SizedBox(),
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black87),
                  hint: Text("Choose Company"),
                  isExpanded: true,
                  onChanged: (v) {
                    setState(() {
                      selectedCompany = v;
                    });
                  },
                  value: selectedCompany,
                ),
              )
            ],
          ),
          SizedBox(height: 10,),
          Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/images/overlay.png",width: width*0.6,),
                  Image.asset("assets/images/person.png",width: width*0.6,),
                ],
              )
          ),
          SizedBox(height: 10,),
          ButtonTheme(
            minWidth: width*0.6,
            height: 40,
            splashColor: Color(primaryColor),
            child: RaisedButton(
              onPressed: (){
                if(selectedCompany!=null){
                  checkCompanyDialog(context);
                }else{
                  widget.showMessage(S.of(context).selectCompany);
                }
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.black87,
              child: Text(S.of(context).startFacePunch.toUpperCase(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }

}