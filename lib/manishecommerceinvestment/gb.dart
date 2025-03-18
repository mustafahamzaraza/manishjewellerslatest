class GlobalPlan {
  static final GlobalPlan _instance = GlobalPlan._internal();

  String planName = "";
  int months = 0;

  factory GlobalPlan() {
    return _instance;
  }

  GlobalPlan._internal();

  void setPlanDetails(int planId) {
    if (planId == 1) {
      planName = "First Plan";
      months = 12;
    } else if (planId == 2) {
      planName = "Second Plan";
      months = 18;
    } else {
      planName = "Third Plan";
      months = 24;
    }
  }
}
