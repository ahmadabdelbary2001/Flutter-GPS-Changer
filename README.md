&#x202b;

# مشروع Dummy-Based smart phone Location Anonymization

## وصف المشروع

يهدف هذا المشروع إلى تطوير تطبيق موبايل متكامل يوفر ميزات متقدمة للتعامل مع الموقع الجغرافي، بما في ذلك تزييف الموقع، وعرض الخرائط التفاعلية، وإدارة المسارات الجغرافية. يستخدم التطبيق إطار عمل Flutter لتوفير تجربة مستخدم سلسة ومتعددة المنصات، مع تكامل عميق مع نظام Android من خلال استخدام لغة Kotlin للتعامل مع خدمة تزييف الموقع.


## هيكلية المشروع

المشروع هو كتلة وحيدة والمجلد الرئيسي هو *GPS-Changer*
```
GPS-Changer/
│
├── android/
│   ├── app/
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── kotlin/com/example/google_maps/MainActivity.kt
│   │   │   │   └── ... 
│   │   └── build.gradle
│   └── ... 
│
├── lib/
│   ├── main.dart
│   ├── controllers/
│   │   ├── google_maps_controller.dart
│   │   ├── route_settings_controller.dart
│   │   └── route_controller.dart
│   ├── services/
│   │   ├── location_service.dart
│   │   └── mock_location_service.dart
│   ├── widgets/
│   │   ├── google_maps_widget.dart
│   │   ├── menu.dart
│   │   └── route_settings_dialog.dart
│   └── provider/
│       ├── app_bloc.dart
│       └── shared_state.dart
│
├── assets/
│   └── ...
│
├── test/
│   └── ...
│
├── pubspec.yaml
└── README.md
```

### تفاصيل الملفات والمجلدات

| الملف/المجلد         | الوصف                                                  |
| -------------------- | ------------------------------------------------------------- |
| lib                | يحتوي على الكود الرئيسي لتطبيق Flutter بما في ذلك واجهات المستخدم، المتحكمات وإدارة الحالة والخدمات.   |
| assets             | يخزن الصور، أنماط الخرائط، والموارد الثابتة الأخرى المستخدمة في التطبيق.            |
| test               | يحتوي على اختبارات الوحدة والويدجيت للتطبيق.                               |
| android            | يحتوي على الكود الأصلي الخاص بنظام Android الذي يتكامل مع Flutter.         |

### هيكل مجلد android

| الملف/المجلد         | الوصف                                                  |
| ------------------------------------------------------------- | ----------------------------------------- |
| app/src/main/kotlin/com/example/google_maps/MainActivity.kt | يحتوي على الكود الخاص بالتفاعل مع نظام Android لإدارة الموقع الوهمي عبر Flutter. |

### هيكل مجلد lib

| الملف/المجلد         | الوصف                                                  |
| -------------------- | ------------------------------------------------------------- |
| main.dart          | نقطة الدخول الرئيسية للتطبيق.                                          |
| controller         | يحتوي على المتحكمات.                                              |
| provider           | إدارة الحالة المستخدم في جميع أنحاء التطبيق.                                |
| widgets            | عناصر واجهة المستخدم تستخدم في جميع أنحاء التطبيق.                         |
| services           | الخدمات المسؤولة عن معالجة الموقع الجغرافي وتزييف الموقع.                     |


## تشغيل المشروع

### إضافة خريطة إلى التطبيق
احصل على مفتاح واجهة برمجة التطبيقات على https://cloud.google.com/maps-platform/.

قم بتمكين SDK لخرائط Google لكل منصة.
   - انتقل إلى وحدة تحكم مطوري Google.
   - اختر المشروع الذي تريد تمكين خرائط Google عليه.
   - حدد قائمة التنقل ثم حدد "خرائط Google".
   - حدد "APIs" ضمن قائمة خرائط Google.
   - لتمكين خرائط Google لنظام Android، حدد "SDK لخرائط Android" في قسم "APIs الإضافية"، ثم حدد "تمكين".
   - تأكد من أن APIs التي قمت بتمكينها موجودة ضمن قسم "APIs الممكّنة".

### في android/app/src/main/AndroidManifest.xml داخل وسم Application، أضف مفتاحك


<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>

### البرمجيات والأدوات:
   - Flutter SDK: إصدار 3.0.0 أو أعلى.
   - Dart SDK: إصدار 2.17.0 أو أعلى.
   - Android SDK: استهداف إصدار SDK 34، مع حد أدنى لإصدار SDK 21.
   - Kotlin: إصدار 1.8.10.
