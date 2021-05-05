class AppConst{
  // static final String domainURL = "http://192.168.3.28/";
  static final String domainURL = "https://facepunch.app/";
  static final String baseUrl = domainURL+"api/";

  static final String adminRegister = baseUrl+"admin-register";
  static final String adminLogin = baseUrl+"admin-login";
  static final String loginWithFace = baseUrl+"login-with-face";
  static final String updateAdmin = baseUrl+"update-admin";
  static final String emailVerify = baseUrl+"email-verify";
  static final String sendVerifyAgain = baseUrl+"send-verify-again";
  static final String recoverPassword = baseUrl+"recover-password";
  static final String notificationSetting = baseUrl+"notification-setting";

  static final String getAllCompanies = baseUrl+"get-all-company";
  static final String getCompanySettings = baseUrl+"get-company-settings";
  static final String updateCompanySettings = baseUrl+"update-company-settings";
  static final String createCompany = baseUrl+"create-company";
  static final String updateCompany = baseUrl+"update-company";
  static final String addEditEmployee = baseUrl+"add-edit-employee";
  static final String deleteEmployee = baseUrl+"delete-employee";
  static final String getCompanyEmployees = baseUrl+"get-company-employees";
  static final String punchWithFace = baseUrl+"punch-with-face";
  static final String getUserPunches = baseUrl+"get-user-punches";
  static final String getEmployeePunches = baseUrl+"get-employee-punches";
  static final String editPunch = baseUrl+"edit-punch";
  static final String deletePunch = baseUrl+"delete-punch";
  static final String punchByAdmin= baseUrl+"punch-by-admin";

  static final String sendTimeRevisionRequest = baseUrl+"send-time-revision";
  static final String getRevisionRequest = baseUrl+"get-time-revisions";
  static final String acceptRevision = baseUrl+"accept-revision";
  static final String declineRevision = baseUrl+"decline-revision";
  static final String deleteRevision = baseUrl+"delete-revision";

  static final String createOrUpdateFiled = baseUrl+"update-create-field";
  static final String getAllFields = baseUrl+"get-fields";
  static final String deleteField = baseUrl+"delete-field";

  static final String getAllContainers = baseUrl+"get-containers";
  static final String createOrUpdateContainer = baseUrl+"update-create-container";
  static final String deleteContainer = baseUrl+"delete-container";

  static final String getHarvestsOfDate = baseUrl+"get-harvests-of-date";
  static final String addHarvest = baseUrl+"add-harvest";


}

class GlobalData{
  static String token;
}

List<CompanyPlan> companyPlans = [
  CompanyPlan(price: 0.0,maxRange: 5,minRange: 1),
  CompanyPlan(price: 45.00,maxRange: 50,minRange: 6),
  CompanyPlan(price: 98.00,maxRange: 100,minRange: 51),
  CompanyPlan(price: 168.00,maxRange: 9999,minRange: 100),
];

class CompanyPlan{
  int minRange;
  int maxRange;
  double price;
  CompanyPlan({this.maxRange,this.minRange,this.price});
}

const int primaryColor = 0xFF09d55b;
const List<String> subscriptionPlans = <String>['free','facepunch_plan_1','facepunch_plan_2','facepunch_plan_3'];