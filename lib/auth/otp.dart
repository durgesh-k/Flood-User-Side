import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notification/auth/details.dart';
import 'package:notification/city.dart';
import 'package:notification/globals.dart';
import 'package:notification/main.dart';

class OTPScreen extends StatefulWidget {
  final String? verificationId;
  final String? phone;
  const OTPScreen({Key? key, this.phone, this.verificationId})
      : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  final TextEditingController _fieldFive = TextEditingController();
  final TextEditingController _fieldSix = TextEditingController();
  String? _otp;
  bool? loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Container(
            height: getHeight(context) * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: getHeight(context) * 0.1,
                    ),
                    Container(
                      width: getWidth(context) * 0.76,
                      child: Text(
                        'Verify OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Bold',
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 30),
                      ),
                    ),
                    SizedBox(
                      height: getHeight(context) * 0.02,
                    ),
                    Container(
                      width: getWidth(context) * 0.7,
                      child: Text(
                        'Please enter the OTP sent to ${widget.phone}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Regular',
                            color: Colors.black.withOpacity(0.2),
                            fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: getHeight(context) * 0.1,
                    ),
                    Container(
                      width: getWidth(context),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OtpInput(_fieldOne, true),
                            OtpInput(_fieldTwo, false),
                            OtpInput(_fieldThree, false),
                            OtpInput(_fieldFour, false),
                            OtpInput(_fieldFive, false),
                            OtpInput(_fieldSix, false)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                /*SizedBox(
                  height: getHeight(context) * 0.35,
                ),*/
                MaterialButton(
                    elevation: 0,
                    splashColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                        _otp = _fieldOne.text +
                            _fieldTwo.text +
                            _fieldThree.text +
                            _fieldFour.text +
                            _fieldFive.text +
                            _fieldSix.text;
                      });
                      FirebaseAuth _auth = FirebaseAuth.instance;

                      try {
                        AuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: widget.verificationId!,
                                smsCode: _otp!);

                        var result =
                            await _auth.signInWithCredential(credential);

                        var user = result.user;
                        if (user != null) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Info(),
                              ),
                              ((route) => false));
                        } else {
                          setState(() {
                            loading = false;
                          });
                          showToast('Incorrect OTP\nPlease try again');
                        }
                      } catch (e) {
                        setState(() {
                          loading = false;
                        });
                        showToast('Error\nPlease try again');
                      }
                    },
                    color: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 0.0),
                    child: Container(
                      height: 50,
                      width: getWidth(context),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.transparent),
                      child: Center(
                          child: loading!
                              ? CircularProgressIndicator()
                              : Text(
                                  'Next',
                                  style: TextStyle(
                                    fontFamily: 'Bold',
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                )),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  const OtpInput(this.controller, this.autoFocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.13,
      child: Center(
        child: TextField(
          autofocus: autoFocus,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          controller: controller,
          maxLength: 1,
          cursorColor: Colors.orange,
          style: TextStyle(
            fontFamily: "SemiBold",
            fontSize: 32,
            color: Colors.black.withOpacity(0.8),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 0.0, color: Colors.grey.shade50),
            ),
            disabledBorder: InputBorder.none,
            counterText: '',
          ),
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ),
    );
  }
}
