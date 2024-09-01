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
│   │   ├── live_location_cubit.dart
│   │   ├── route_settings_controller.dart
│   │   └── route_controller.dart
│   ├── services/
│   │   ├── current_location_service.dart
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

### هيكل مجلد lib/controllers

| الملف/المجلد         | الوصف                                                  |
| -------------------- | ------------------------------------------------------------- |
| live_location_cubit.dart          | إدارة تحديثات الموقع الحي باستخدام Cubit من BLoC.                                          |
| route_controller.dart         | إدارة مسار الجغرافيا وحساب المسافات والنقاط الفرعية.                                              |
| route_settings_controller.dart           | إدارة إعدادات المسار مثل السرعة والدقة ووضع الحلقة.                                |

#### التوابع
1. live_location_cubit.dart
   - startService: تقوم ببدء خدمة الموقع إذا لم تكن مفعلة بالفعل.
   - closeService: تقوم بإيقاف خدمة الموقع.
   - updateUserLocation: تقوم بتحديث الموقع الحالي للمستخدم وإضافته إلى قائمة المواقع، كما تقوم بإرسال الموقع الجديد كحالة (state) جديدة.
2. route_controller.dart
   - add: لإضافة نقطة جديدة إلى المسار.
   - clear: لمسح جميع النقاط في المسار.
   - removeLast: لإزالة النقطة الأخيرة من المسار.
   - _calculateDistance: لحساب المسافة بين نقطتين جغرافيتين.
   - findSubCoordinates: لإيجاد النقاط الفرعية على المسار بناءً على السرعة المحددة.
   - findSubCoordinatesWithOffset: لإيجاد النقاط الفرعية مع إضافة إزاحة لجعل المسار أكثر دقة.
   - addOffset: لإضافة إزاحة عشوائية إلى النقاط الفرعية على المسار.
3. route_settings_controller.dart
   - updateSpeed: لتحديث سرعة الحركة وتعيين الوضع الحالي (سير على الأقدام، ركوب الدراجة، قيادة).
   - updateInaccuracy: لتحديث دقة المسار.
   - updateLoopMode: لتحديث وضع الحلقة (loop mode).

### هيكل مجلد lib/provider

| الملف/المجلد         | الوصف                                                  |
| -------------------- | ------------------------------------------------------------- |
| app_bloc.dart          | إدارة الحالة المشتركة للتطبيق باستخدام ChangeNotifier.                                          |
| shared_state.dart         | إدارة مركزية لـ Bloc في التطبيق باستخدام BlocProvider.                                              |

#### الخصائص
1. shared_state.dart
   - _isMoving: تعبر عن ما إذا كان المستخدم في حالة حركة.
   - _speed: السرعة الحالية للمستخدم.
   - _inaccuracy: مقدار عدم الدقة في الموقع.
   - _loopMode: وضع الحلقة الحالي (مثل "إيقاف").
2. app_bloc.dart
   - liveLocationCubit: كائن وحيد من LiveLocationCubit يستخدم لتتبع الموقع الحي.
   - providers: قائمة تحتوي على BlocProvider لتمكين توفير liveLocationCubit عبر التطبيق.


### هيكل مجلد lib/services


| الملف/المجلد         | الوصف                                                  |
| -------------------- | ------------------------------------------------------------- |
| mock_location_service.dart          | خدمة محاكاة بيانات الموقع باستخدام MethodChannel.                                          |
| current_location_servic.dart         | خدمة للحصول على الموقع الحالي من خلال الـ GPS والتعامل مع الأذونات.                                              |

#### التوابع

1. mock_location_service.dart
   - fakeLocation: لإعداد وتحديث موقع ثابت بشكل دوري.
   - fakeMovingLocation: لمحاكاة حركة عبر مسار محدد باستخدام RouteController.
   - stopFakeLocation: لإيقاف عملية المحاكاة.
2. current_location_service.dart
   - startService: لبدء خدمة الموقع والتحقق من الأذونات المطلوبة.
   - checkLocationPermission: للتحقق من أذونات الموقع ومنحها إذا لم تكن موجودة.





### هيكل مجلد lib/widgets

| الملف/المجلد         | الوصف                                                  |
| -------------------- | ------------------------------------------------------------- |
| google_maps_widget.dart          | واجهة تمثل خريطة Google Maps مع ميزات إضافية للتحكم بالمؤشرات والخطوط المتعددة وأنماط الخريطة.          |
| menu.dart         | واجهة صغيرة تستخدم PopupMenuButton لتقديم خيارات بين نوعي المسارات "Fixed" و "Moving".                |
| route_settings_dialog.dart           | Dialog يسمح للمستخدم بضبط إعدادات تشغيل المسار مثل السرعة والدقة ووضع التكرار.                          |

#### التوابع
1. google_maps_widget.dart
   - _loadMapStyles: تحميل أنماط الخريطة (الليلية والنهارية) من الملفات.
   - handleMapTap: التعامل مع نقرات الخريطة وإضافة مؤشرات على النقاط المحددة.
   - drawLine: رسم خط بين نقطتين على الخريطة.
   - _moveCamera: تحريك الكاميرا إلى موقع محدد.
   - _setMapStyle: ضبط نمط الخريطة بناءً على الوضع الحالي.
   - _updateUserMarker: تحديث موقع المستخدم على الخريطة.
   - _clearMapData: مسح البيانات (المؤشرات والخطوط) من الخريطة.
   - _removeLastPoint: إزالة آخر نقطة تم إضافتها على الخريطة.
2. menu.dart
   - _onTrackTypeSelected: تحديث نوع المسار المحدد وتعديل سلوك الخريطة وفقاً لذلك.
3. route_settings_dialog.dart
   - _buildSpeedRow: بناء صف لضبط السرعة وعرضها.
   - _buildIconsRow: بناء صف يحتوي على الأيقونات لتمثيل حالات المشي، ركوب الدراجة، والقيادة.
   - _buildSpeedSlider: بناء منزلق لضبط السرعة.
   - _buildInaccuracyRow: بناء صف لضبط الدقة وعرضها.
   - _buildInaccuracySlider: بناء منزلق لضبط الدقة.
   - _buildLoopModeSection: بناء القسم الخاص بإعدادات وضع التكرار (مثل التوقف، العكس، أو إعادة التشغيل).
   - showRouteSettings: عرض الـ dialog الخاص بضبط إعدادات المسار وإعداداته الأولية.



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
