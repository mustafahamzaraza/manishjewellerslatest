class RegisterModel {
  String? email;
  String? password;
  String? fName;
  String? lName;
  String? phone;
  String? socialId;
  String? loginMedium;
  String? referCode;
  String? fcmToken;

  RegisterModel({this.email, this.password, this.fName, this.lName, this.socialId,this.loginMedium, this.referCode,this.fcmToken});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    socialId = json['social_id'];
    loginMedium = json['login_medium'];
    referCode = json['referral_code'];
    fcmToken = json['cm_firebase_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['social_id'] = socialId;
    data['login_medium'] = loginMedium;
    data['referral_code'] = referCode;
    data['cm_firebase_token'] = fcmToken;
    return data;
  }
}
