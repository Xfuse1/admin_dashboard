/// Application string constants.
///
/// All user-facing strings should be defined here for easy localization.
abstract final class AppStrings {
  // ============================================
  // 🏷️ APP INFO
  // ============================================

  static const String appName = 'Admin Dashboard';
  static const String appTagline = 'Delivery Management System';

  // ============================================
  // 🔐 AUTH
  // ============================================

  static const String login = 'تسجيل الدخول';
  static const String logout = 'تسجيل الخروج';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String rememberMe = 'تذكرني';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String resetPassword = 'إعادة تعيين كلمة المرور';
  static const String welcomeBack = 'مرحباً بعودتك';
  static const String loginToContinue = 'سجل دخولك للمتابعة';

  // ============================================
  // 📍 NAVIGATION
  // ============================================

  static const String dashboard = 'لوحة التحكم';
  static const String orders = 'الطلبات';
  static const String rejectionRequests = 'طلبات الرفض';
  static const String driversStats = 'إحصائيات السائقين';
  static const String onboarding = 'طلبات الانضمام';
  static const String vendors = 'المتاجر';
  static const String accounts = 'الحسابات';
  static const String settings = 'الإعدادات';
  static const String simulatorSettings = 'إعدادات المحاكي';
  static const String manageAdmins = 'إدارة المسؤولين';

  // ============================================
  // 👥 ACCOUNTS
  // ============================================

  static const String customers = 'العملاء';
  static const String stores = 'المتاجر';
  static const String drivers = 'السائقين';
  static const String active = 'نشط';
  static const String inactive = 'غير نشط';
  static const String blocked = 'محظور';
  static const String online = 'متصل';
  static const String offline = 'غير متصل';

  // ============================================
  // 📦 ORDERS
  // ============================================

  static const String orderNew = 'جديد';
  static const String orderPreparing = 'قيد التجهيز';
  static const String orderReady = 'جاهز';
  static const String orderOnTheWay = 'في الطريق';
  static const String orderDelivered = 'تم التسليم';
  static const String orderCancelled = 'ملغي';
  static const String orderDetails = 'تفاصيل الطلب';
  static const String orderTimeline = 'مسار الطلب';

  // ============================================
  // 📝 ONBOARDING
  // ============================================

  static const String storeRequests = 'طلبات المتاجر';
  static const String driverRequests = 'طلبات السائقين';
  static const String approve = 'قبول';
  static const String reject = 'رفض';
  static const String pending = 'قيد المراجعة';
  static const String approved = 'مقبول';
  static const String rejected = 'مرفوض';

  // ============================================
  // 📊 DASHBOARD
  // ============================================

  static const String activeOrders = 'الطلبات الجارية';
  static const String onlineStores = 'المتاجر المفتوحة';
  static const String availableDrivers = 'السائقين المتاحين';
  static const String todayRevenue = 'مبيعات اليوم';
  static const String liveMap = 'الخريطة الحية';
  static const String salesChart = 'رسم المبيعات';

  // ============================================
  // ⚙️ SETTINGS
  // ============================================

  static const String deliveryZones = 'مناطق التوصيل';
  static const String commissionRate = 'نسبة العمولة';
  static const String notifications = 'الإشعارات';
  static const String darkMode = 'الوضع الداكن';
  static const String language = 'اللغة';

  // ============================================
  // 🔄 ACTIONS
  // ============================================

  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String search = 'بحث';
  static const String filter = 'فلتر';
  static const String export = 'تصدير';
  static const String refresh = 'تحديث';
  static const String viewAll = 'عرض الكل';
  static const String viewDetails = 'عرض التفاصيل';

  // ============================================
  // ✅ SUCCESS MESSAGES
  // ============================================

  static const String savedSuccessfully = 'تم الحفظ بنجاح';
  static const String deletedSuccessfully = 'تم الحذف بنجاح';
  static const String updatedSuccessfully = 'تم التحديث بنجاح';
  static const String approvedSuccessfully = 'تم القبول بنجاح';
  static const String rejectedSuccessfully = 'تم الرفض';

  // ============================================
  // ❌ ERROR MESSAGES
  // ============================================

  static const String errorOccurred = 'حدث خطأ';
  static const String tryAgain = 'حاول مرة أخرى';
  static const String noInternetConnection = 'لا يوجد اتصال بالإنترنت';
  static const String sessionExpired = 'انتهت الجلسة، يرجى تسجيل الدخول';
  static const String invalidCredentials = 'بيانات الدخول غير صحيحة';
  static const String fieldRequired = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صالح';
  static const String passwordTooShort = 'كلمة المرور قصيرة جداً';

  // ============================================
  // 📭 EMPTY STATES
  // ============================================

  static const String noOrders = 'لا توجد طلبات';
  static const String noResults = 'لا توجد نتائج';
  static const String noData = 'لا توجد بيانات';
  static const String noRequests = 'لا توجد طلبات انضمام';

  // ============================================
  // 📤 EXPORT
  // ============================================

  static const String exportExcel = 'تصدير Excel';
  static const String exportCsv = 'تصدير CSV';
  static const String exportPdf = 'تصدير PDF';

  // ============================================
  // 📊 STATISTICS
  // ============================================

  static const String totalOrders = 'إجمالي الطلبات';
  static const String totalRevenue = 'إجمالي المبيعات';
  static const String activeDrivers = 'السائقين النشطين';
  static const String totalCustomers = 'إجمالي العملاء';
}
