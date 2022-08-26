import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notification/auth/otp.dart';
import 'package:notification/globals.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final GlobalKey<FormState> loginkey = GlobalKey<FormState>();
  bool sentloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: loginkey,
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: mobile,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Phone number cannot be empty';
                    } else if (!RegExp(r'(^(?:[+0]9)?[0-9]{10}$)')
                        .hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.deny(' ')],
                  style: TextStyle(
                    fontFamily: "Medium",
                    fontSize: 20,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    /*focusColor: Colors.white,
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.3), width: 2),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                                disabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),*/
                    filled: false,
                    fillColor: Colors.white.withOpacity(0.1),
                    /*suffixIcon: Icon(
                                  Icons.error,
                                  size: 15,
                                  color: Colors.red.withOpacity(emailOpacity),
                                ),*/
                    hintText: 'Mobile Number',
                    hintStyle: TextStyle(
                      fontFamily: "Medium",
                      fontSize: 20, //16,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                  elevation: 0,
                  splashColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  onPressed: () async {
                    if (loginkey.currentState!.validate()) {
                      setState(() {
                        sentloading = true;
                      });
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: '+91 ${mobile.text}',
                        verificationCompleted:
                            (PhoneAuthCredential credential) async {},
                        codeAutoRetrievalTimeout: (String verificationId) {},
                        codeSent:
                            (String verificationId, int? forceResendingToken) {
                          showToast('OTP sent');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => OTPScreen(
                                        verificationId: verificationId,
                                        phone: mobile.text,
                                      ))));
                        },
                        verificationFailed: (FirebaseAuthException error) {
                          //Navigator.pop(context);
                          setState(() {
                            sentloading = false;
                          });
                          showToast(
                              'Error Verifying\nPlease check your Mobile Number and try again');
                        },
                      );
                    }
                  },
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Container(
                    height: 60,
                    width: 140,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.red),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                            child: sentloading
                                ? Container(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('Next')),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
