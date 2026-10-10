# Carta Facile

تطبيق للمهاجرين في إيطاليا: دليل الوثائق، شرح الرسائل بالذكاء الاصطناعي، تتبع المواعيد، ودروس الإيطالية. بأربع لغات: العربية، الفرنسية، الإيطالية، الإنجليزية.

## محتوى المشروع

```
lib/
  main.dart                  تشغيل التطبيق
  core/theme.dart            الألوان والخطوط
  core/strings.dart          نصوص الواجهة بأربع لغات
  core/app_state.dart        الحفظ في الهاتف (اللغة، المواعيد، الدروس، عدد المسحات)
  core/content.dart          قراءة الدليل والدروس
  screens/                   الشاشات الخمس
  services/ai_service.dart   الاتصال بوظيفة الذكاء الاصطناعي
  services/notification_service.dart  التذكيرات
  widgets/ad_banner.dart     إعلانات AdMob (النسخة المجانية فقط)
assets/content/
  guides.json                دليل الوثائق (4 لغات)
  lessons.json               10 دروس إيطالية
supabase/functions/explain-letter/
  index.ts                   الخادم الذي يرسل الصورة للذكاء الاصطناعي
```

## 1) التشغيل لأول مرة

يلزم تثبيت Flutter على الحاسوب: https://docs.flutter.dev/get-started/install

```bash
cd carta_facile
flutter create . --org com.cartafacile --project-name carta_facile --platforms android,ios
flutter pub get
flutter run
```

الأمر `flutter create .` يُنشئ مجلدي `android/` و `ios/` فقط، ولا يمس ملفات `lib/`.

## 2) إعدادات أندرويد

في `android/app/src/main/AndroidManifest.xml`:

داخل `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

داخل `<application>` (هذا معرّف AdMob تجريبي، غيّره بمعرّفك قبل النشر):
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

في `android/app/build.gradle.kts` (مطلوب لمكتبة التذكيرات):
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

## 3) إعدادات آيفون

في `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
<key>NSCameraUsageDescription</key>
<string>Carta Facile uses the camera to photograph letters you want explained.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Carta Facile lets you choose a photo of a letter from your gallery.</string>
```

## 4) الذكاء الاصطناعي (Supabase)

مفتاح الذكاء الاصطناعي لا يوضع أبدًا داخل التطبيق، بل في الخادم:

```bash
supabase functions deploy explain-letter
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
```

ثم شغّل التطبيق مع عنوان المشروع:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR-PUBLISHABLE-KEY
```

## 5) قبل النشر

- استبدال معرّفات AdMob التجريبية بمعرّفاتك (`widgets/ad_banner.dart` و Manifest و Info.plist).
- مراجعة محتوى `guides.json` من طرف شخص يعرف الإجراءات الإيطالية.
- صفحة سياسة الخصوصية وصفحة الدعم (على cvprontoitalia.com).
- الاشتراك المدفوع (النسخة القادمة): حاليًا `isPremium` دائمًا false، وحد المسح المجاني (3 في الشهر) محفوظ في الهاتف فقط، ويجب نقله إلى الخادم لاحقًا.
