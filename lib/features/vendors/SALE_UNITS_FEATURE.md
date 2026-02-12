# ميزة وحدات البيع المتعددة للمتاجر

## نظرة عامة
تم إضافة ميزة تسمح للمتاجر باختيار وحدات بيع متعددة (كيلو، جرام، قطعة، أو وحدات مخصصة) لمنتجاتهم.

## الملفات المضافة/المعدلة

### الملفات الجديدة
1. **`presentation/utils/sale_units_utils.dart`** - دوال مساعدة لوحدات البيع
2. **`presentation/widgets/multi_select_dropdown.dart`** - قائمة منسدلة متعددة الاختيارات قابلة لإعادة الاستخدام

### الملفات المعدلة
1. **`domain/entities/vendor_entity.dart`**
   - إضافة enum `SaleUnitType` (kilogram, gram, piece, custom)
   - إضافة حقول `saleUnits` و `customSaleUnits`
   - إضافة method `getSaleUnitsLabels()`

2. **`data/datasources/vendors_firebase_datasource.dart`**
   - قراءة وحفظ `sale_units` و `custom_sale_units` من/إلى Firebase

3. **`presentation/bloc/vendors_event.dart`**
   - إضافة event `UpdateVendorSaleUnitsEvent`

4. **`presentation/bloc/vendors_bloc.dart`**
   - إضافة handler `_onUpdateVendorSaleUnits`

5. **`presentation/widgets/vendor_details_panel.dart`**
   - إضافة قسم `_SaleUnitsSection` 
   - إضافة dialog `_AddCustomUnitDialog`
   - تحديث `_ProductCard` لعرض وحدات البيع

## كيفية الاستخدام

### في واجهة الإدارة
1. افتح تفاصيل أي متجر
2. اذهب إلى قسم "وحدات البيع" (يظهر بعد معلومات التواصل)
3. انقر على القائمة المنسدلة لاختيار الوحدات:
   - ✅ كيلو
   - ✅ جرام
   - ✅ قطعة
4. لإضافة وحدة مخصصة:
   - انقر على "إضافة وحدة مخصصة"
   - أدخل اسم الوحدة (مثل: لتر، صندوق، علبة)
   - انقر "إضافة"
5. احفظ التغييرات

### في Firebase
البيانات تُحفظ في مسار: `users/{userId}/store/`
```json
{
  "sale_units": ["kilogram", "gram"],
  "custom_sale_units": ["لتر", "صندوق"]
}
```

## المزايا
- ✅ اختيار متعدد للوحدات
- ✅ إضافة وحدات مخصصة
- ✅ عرض الوحدات في بطاقات المنتجات
- ✅ حذف الوحدات بسهولة عبر الـ Chips
- ✅ Backward compatibility مع المتاجر القديمة
- ✅ Validation لأسماء الوحدات المخصصة

## التحديثات المستقبلية المحتملة
- [ ] ربط وحدة البيع بكل منتج على حدة (بدلاً من المتجر بالكامل)
- [ ] تحويل بين الوحدات (1 كيلو = 1000 جرام)
- [ ] تسعير مختلف لكل وحدة
- [ ] فلترة المنتجات حسب الوحدة

## تاريخ الإضافة
فبراير 2026
