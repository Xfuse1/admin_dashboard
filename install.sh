#!/bin/bash

# التحقق مما إذا كان Flutter محملاً بالفعل (لتسريع العملية في المرات القادمة)
if [ -d "flutter" ]; then
    echo "Flutter is already installed"
else
    # تحميل Flutter النسخة المستقرة
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# تفعيل الويب وتجهيز الأدوات
./flutter/bin/flutter config --enable-web
./flutter/bin/flutter pub get