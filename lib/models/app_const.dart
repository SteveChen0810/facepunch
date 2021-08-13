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

  static final String getMyCompany = baseUrl+"get-my-company";
  static final String getCompanySettings = baseUrl+"get-company-settings";
  static final String updateCompanySettings = baseUrl+"update-company-settings";
  static final String updateCompany = baseUrl+"update-company";
  static final String addEditEmployee = baseUrl+"add-edit-employee";
  static final String deleteEmployee = baseUrl+"delete-employee";
  static final String getCompanyEmployees = baseUrl+"get-company-employees";
  // static final String punchWithFace = baseUrl+"punch-with-face";
  static final String punchWithFace = baseUrl+"face-punch";
  static final String getUserPunches = baseUrl+"get-user-punches";
  static final String getUserWorks = baseUrl+"get-user-works";
  static final String getEmployeePunches = baseUrl+"get-employee-punches";
  static final String getEmployeeWorks = baseUrl+"get-employee-works";
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
  static final String deleteHarvest = baseUrl+"delete-harvest";

  static final String createOrUpdateTask = baseUrl+"create-update-task";
  static final String getAllTasks = baseUrl+"get-tasks";
  static final String deleteTask = baseUrl+"delete-task";

  static final String getEmployeeHarvestStats = baseUrl+"get-employee-harvest-stats";
  static final String getCompanyHarvestStats = baseUrl+"get-company-harvest-stats";
  static final String getDateHarvestStats = baseUrl+"get-date-harvest-stats";

  static final String startWork = baseUrl+"start-work";
  static final String startSchedule = baseUrl+"start-schedule";
  static final String endSchedule = baseUrl+"end-schedule";
  static final String punchOut = baseUrl+"punch-out";
  static final String getProjectsAndTasks = baseUrl+"get-projects-tasks";

  static final String getDailySchedule = baseUrl+"get-daily-schedule";
  static final String getEmployeeSchedule = baseUrl+"get-employee-schedule";
  static final String deleteSchedule = baseUrl+"delete-schedule";
  static final String editSchedule = baseUrl+"edit-schedule";
  static final String addSchedule = baseUrl+"add-schedule";
  static final String editWork = baseUrl+"edit-work";
  static final String deleteWork = baseUrl+"delete-work";

}

class GlobalData{
  static String token;
}

const int primaryColor = 0xFF09d55b;