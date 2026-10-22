# sanalyer mobil

Bu branch (`sanalyer`), Fluxer'ın Flutter istemcisinden sanalyer uygulamasını çıkarıyor.
Uygulama açılışta doğrudan https://sanalyer.com'a bağlanır, adı, ikonu ve rengi sanalyer'dir.

Repo: https://github.com/RadKod/sanalyer.com-mobile (eski adı RadKod/flutter_client, GitHub
eski adresi yönlendiriyor). Upstream: https://github.com/fluxerapp/flutter_client, branch
`canary`. Son senkron: upstream `e881d2808` (2026-10-22); fork'un `canary` branch'i bu commit'te,
`sanalyer` branch'ine merge edildi.

## Ne değişti

- **Instance.** Varsayılan sunucu `sanalyer.com` (API `https://sanalyer.com/api`, gateway
  `wss://sanalyer.com/gateway`). Bu değerler sunucunun `/.well-known/fluxer` belgesiyle aynı.
  Upstream'deki "resmi instance" listesinde artık yalnız `sanalyer.com` var. Giriş ekranındaki
  instance seçici yerinde duruyor; başka bir sunucu yazan kullanıcı oraya bağlanabilir, varsayılana
  dönüş düğmesi sanalyer'e döner.
- **Kimlikler.** Android `applicationId` ve iOS bundle id `com.sanalyer.mobile`. iOS eklentileri
  `.ShareExtension`, `.NotificationService`, `.BroadcastExtension` son ekini alıyor; canary
  `com.sanalyer.mobile.canary`. App group `group.com.sanalyer.mobile`, Apple takımı `9XYJ4H8U3Y`.
  Kotlin paketi `com.fluxer` olarak kaldı (upstream kodu, kullanıcı görmez).
- **Metinler.** 36 dil dosyasında kullanıcıya görünen "Fluxer" geçen her yer sanalyer oldu
  ("Fluxer Plutonium" yerine "sanalyer Premium"). Dart ve Swift'teki sabit metinler (bildirim
  başlığı, CallKit, Siri kısayolları, istemci adı) da değişti.
- **Görseller.** Android ve iOS uygulama ikonları, bildirim ikonu, uygulama içi sembol ve wordmark
  `sanalyer.com/branding/kit`'ten üretildi. Alternatif ikon seçicisi kapalı, çünkü upstream'in
  hazır ikonlarının hepsinde Fluxer logosu var.
- **Renk.** Marka rengi `#B5179E` (tema ailesi hsl 309, %77). Koyu temalarda tam bu renk; açık
  temada bir ton koyusu (açıklık 34), çünkü #B5179E açık zeminde marka renkli metinde AA
  kontrastını tutturamıyor.
- **Linkler.** Koşullar `sanalyer.com/kullanim-kosullari`, gizlilik `sanalyer.com/gizlilik`,
  destek `info@sanalyer.com`, indirme `sanalyer.com/indir`, geliştirici belgeleri
  `sanalyer.com/docs`. Fluxer durum sayfası sorgusu, Fluxer Labs ve geri bildirim girişleri kapalı.
  Uygulama linkleri (Android intent filter, iOS associated domains) `sanalyer.com` yollarını dinliyor.
- **Push.** Relay adresi `push.sanalyer.com`. Fluxer'ın relay'i bizim bundle id'mize bildirim
  teslim edemez, üstelik cihaz token'larını üçüncü bir tarafa taşırdı. Relay kurulana kadar push
  gelmez.

## Nasıl derlenir

Flutter'ın güncel stable sürümü gerekiyor (pubspec `sdk: ^3.12.0` istiyor). Homebrew'daki
Flutter 3.35.7 (Dart 3.9.2) yetmiyor. Bu Mac'te ayrı bir kopya var:
`~/.local/share/flutter-stable-sanalyer` (Flutter 3.47.7, Dart 3.13.5; `git clone --depth 1 --branch 3.47.7 https://github.com/flutter/flutter.git`). Eski yeri `~/.cache` temizlikte silindi.

```sh
export PATH=~/.local/share/flutter-stable-sanalyer/bin:$PATH
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # *.g.dart repoda yok
flutter analyze
flutter test
```

Android'de flavor iki boyutlu: ortam (`stable`, `beta`, `canary`) ve push (`fcm`, `unifiedpush`).
Firebase dosyası olmadığı için yerelde `unifiedpush` ile derlenir:

```sh
dart tool/configure_build.dart --profile=oss && flutter pub get
flutter build apk --debug --flavor stableUnifiedpush \
  --dart-define-from-file=tool/dart_defines/stable.json --dart-define=PUSH_PROVIDER=unifiedpush
```

iOS'ta şema adı flavor olarak verilir:

```sh
dart tool/configure_build.dart --profile=ios-store && flutter pub get
flutter build ios --no-codesign --flavor stable \
  --dart-define-from-file=tool/dart_defines/stable.json --dart-define=PUSH_PROVIDER=apns
```

`configure_build.dart` pubspec'i değiştirir; işin bitince `dart tool/restore_pubspec.dart`.
Markdown ayrıştırıcısı Rust'la derleniyor (`packages/fluxer_markdown_native`), hedef platformun
Rust target'ı kurulu olmalı: iOS için `rustup target add aarch64-apple-ios aarch64-apple-ios-sim`,
Android için `aarch64-linux-android armv7-linux-androideabi x86_64-linux-android`.

## Bu Mac'te deneme sonuçları

2026-10-16, Flutter 3.47.7 ile:

- `flutter pub get`, `build_runner`: sorunsuz.
- `flutter analyze`: 14 bulgu (2 warning grubu, gerisi info), hata yok. Hiçbiri bu branch'te
  değişen dosyalarda değil.
- `flutter test`: 7108 geçti, 34 atlandı, 92 kaldı. Aynı test dosyaları upstream commit'inde
  (22196fd93) koşunca hepsi geçiyor, yani kalanlar bizim değişikliklerden. Biri gerçek sorundu
  (açık temada tepki çipi kontrastı), düzeltildi. Kalan 87 testin hepsi Fluxer'a özgü beklenti
  taşıyor: `fluxer.com`/`fluxer.gg`/`fluxerusercontent.com` host'ları, "Fluxer" geçen metinler,
  `support@fluxer.com`, Fluxer durum sayfası, eski marka rengi. Testleri upstream'de bıraktık;
  değiştirmek her merge'de çakışma çıkarır. İki senkronizasyon testi tam koşuda düştü, tek
  başına koşunca geçti (yük altında kararsız).
- `flutter build apk --debug`: Android SDK yok (`ANDROID_HOME=~/Library/Android/sdk` ama klasör
  yok). Android Studio ya da command-line tools kurulmalı.
- `flutter build ios --no-codesign`: `pod install` düşüyor. Yerel CocoaPods 1.16.2, projenin
  Podfile.lock'u 1.17.0 ile üretilmiş ve Xcode projesi `objectVersion = 70`; 1.16.2'nin xcodeproj
  sürümü bunu okuyamıyor (`ArgumentError - [Xcodeproj] Unable to find compatibility version
  string for object version 70`). CocoaPods 1.17 gerekiyor. Ayrıca markdown ayrıştırıcısı için
  `rustup target add aarch64-apple-ios` kurulu değil, pod sorunu çözülünce sıradaki engel o
  olacak.

## Mağazaya çıkmak için eksikler

1. **Android imzası.** `android/key.properties` yok; yoksa release build debug anahtarıyla
   imzalanır ve Play kabul etmez. Yeni bir upload keystore üretilip `key.properties`
   (storeFile, storePassword, keyAlias, keyPassword) yazılmalı, keystore repoya girmemeli.
   Play Console'da `com.sanalyer.mobile` uygulaması açılmalı.
2. **Android push.** FCM flavor'ı için `com.sanalyer.mobile` paketli bir Firebase projesi ve
   `google-services.json` gerekiyor (`tool/write_firebase_options.dart` CI'da yazıyor).
   Firebase istemiyorsak yalnız `unifiedpush` flavor'ı dağıtılır, kullanıcı ntfy gibi bir
   dağıtıcı kurar.
3. **iOS hesabı.** 9XYJ4H8U3Y takımında dört App ID (`com.sanalyer.mobile` ve üç eklenti),
   `group.com.sanalyer.mobile` app group'u, Push Notifications, Associated Domains ve
   Communication Notifications yetenekleri açılmalı; bunlara göre provisioning profilleri
   üretilmeli. App Store Connect'te uygulama kaydı açılınca TestFlight'a `fastlane` ile
   yüklenebilir (lane'ler bundle id'leri artık sanalyer'e göre bekliyor, `APPLE_TEAM_ID` ve
   profil UUID'leri env'den okunuyor).
4. **Push relay.** iOS bildirimleri ve FCM bildirimleri sunucudan doğrudan değil, Fluxer'ın
   relay servisi üzerinden gidiyor. `push.sanalyer.com` üzerinde bu relay'in bizim APNs
   anahtarımız ve FCM hesabımızla kurulması gerekiyor. Kurulmadan push gelmez.
5. **Uygulama linkleri.** `https://sanalyer.com/invite/...` gibi linklerin uygulamada açılması için
   sanalyer.com'da `/.well-known/assetlinks.json` (yeni keystore'un SHA-256 parmak izi) ve
   `/.well-known/apple-app-site-association` (9XYJ4H8U3Y.com.sanalyer.mobile) yayınlanmalı.
6. **Mağaza metinleri ve görseller.** Store açıklaması, ekran görüntüleri ve gizlilik formu bu
   repoda yok; Play Console ve App Store Connect'te elle girilecek.

## iOS TestFlight (2026-10-16)

İlk sürüm TestFlight'ta: `com.sanalyer.mobile` 1.0.0 (20261016.1007). App Store Connect'te uygulama
`sanalyer` (Apple ID 6823436012, SKU `sanalyer-mobile`, birincil dil Türkçe). Ekip içi test grubu
"sanalyer ekibi", otomatik dağıtım açık.

Apple tarafında kayıtlı olanlar (takım 9XYJ4H8U3Y):

- App Group `group.com.sanalyer.mobile`.
- App ID'ler: `com.sanalyer.mobile` (App Groups, Associated Domains, Communication Notifications),
  `.ShareExtension` ve `.BroadcastExtension` (App Groups), `.NotificationService` (App Groups,
  Communication Notifications, Push Notifications), eklentilerde Push yok.
- Apple Distribution sertifikası `JRVM9YYNHH` ve dört App Store profili (fastlane üretti).
- App Store Connect API anahtarı `sanalyer-mobile` (Admin).

Yerel dosyalar, hiçbiri repoda değil: `~/.config/sanalyer/asc.env` (ASC_KEY_ID, ASC_ISSUER_ID),
`~/.config/sanalyer/asc_key.p8`, `~/.config/sanalyer/signing/` (sertifika, CSR, p12, profiller).
Sertifikanın özel anahtarı login keychain'de; codesign'ın her dosyada şifre sormaması için bir kez
`security set-key-partition-list -S apple-tool:,apple:,codesign: -s ~/Library/Keychains/login.keychain-db`
çalıştırıldı.

Eklentiler kapatılmadı: Share, Broadcast ve NotificationService ilk sürümde de imzalanıp gidiyor.

### Yeni build göndermek

```sh
export LANG=en_US.UTF-8
export PATH=~/.local/share/flutter-stable-sanalyer/bin:~/.local/share/gem/ruby/3.4.0/bin:/opt/homebrew/opt/ruby/bin:~/.cargo/bin:$PATH
dart tool/configure_build.dart --profile=ios-store && flutter pub get
dart run build_runner build --delete-conflicting-outputs
(cd ios && pod install)
APPLE_TEAM_ID=9XYJ4H8U3Y fastlane ios sanalyer_testflight
```

Lane (`fastlane/Fastfile`, `sanalyer_testflight`) API anahtarını `~/.config/sanalyer`'den okur,
sertifika ve profilleri gerekirse üretir, `aps-environment`'ı yalnız derleme süresince `production`
yapar ve bitince proje ile entitlements dosyasını eski hâline döndürür. App ID yeteneği değişirse
bir kez `SANALYER_REFRESH_PROFILES=1` ile çalıştırılır.

PATH'te Anaconda varsa önce çıkarılır (`export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v anaconda | paste -sd: -)`).
Anaconda'nın eski `ld`'si native asset hook'larının derlediği kütüphaneleri (webcrypto gibi) link'lerse
Apple yüklemeyi 90125 hatasıyla reddeder ("not built with Apple's linker"). Hook cache'i
`.dart_tool/hooks_runner/` altındadır; bozuk bir derleme olduysa ilgili klasör silinir.
Sürüm `SANALYER_VERSION` (varsayılan 1.0.0), build numarası `SANALYER_BUILD_NUMBER` (varsayılan
`YYYYMMDD.HHMM`). CocoaPods 1.17 ve fastlane, Homebrew Ruby 3.4 ile `gem install --user-install` kuruldu.

### Bu turda düzeltilenler

- `packages/fluxer_markdown_native/hook/build.dart`: Xcode altında PATH toolchain'in çıplak
  clang'ıyla başlıyor, macOS SDK'sını bulamadığı için Rust build script'leri (serde, proc-macro2...)
  link edilemiyordu. Mac hedefinin linker'ı `/usr/bin/cc` yapıldı.
- `Podfile.lock`: yalnız Podfile checksum'ı güncellendi.

### Push

Relay `https://push.sanalyer.com` (sunucuda `push-relay` container'ı, RadKod/sanalyer.com
`deploy/fluxer/push-relay.compose.yml`). Uygulama APNs token'ını `/relay/v1/apns/stable/production/<token>`
adresiyle kaydeder; sunucunun push servisi oraya Web Push gönderir, relay APNs'e iletir, içeriği
NotificationService eklentisi çözer. APNs anahtarı `K88329YUQ7`: yalnız production ve yalnız
`com.sanalyer.mobile` konusu (takımda team-scoped anahtar sınırı dolu). Debug build'ler development APNs
kullandığı için bildirim almaz; VoIP (`.voip` konusu) bu anahtarla çalışmayabilir, doğrulanmadı.
İlk push'lu build 20261016.1752.

## Bilerek bırakılanlar

- Paket adı `fluxer_app`, Kotlin paketi `com.fluxer`, `fluxer://` URL şeması, asset dosya
  adları (`fluxer-symbol.svg` gibi) ve kod içi sınıf adları upstream'le aynı. Kullanıcı bunları
  görmüyor; değiştirmek her upstream merge'de çakışma demek.
- README ve CONTRIBUTING upstream'in. AGPL gereği kaynak `github.com/RadKod/flutter_client`.
- Upstream merge'den sonra `lib/l10n/*.arb` değerlerinde ve Dart/Swift metinlerinde yeniden Fluxer
  taraması yapılmalı. `b06250ca8` merge'ünde gelen yeni metinler: çökme raporlama ayarı (iki arb
  metni, geliştirici araçlarındaki açıklama) ve hediye linki host listesi
  (`gift_code_utils.dart`). Çökme raporları Measure'a gidiyor; bizim build'lerde Measure anahtarı
  olmadığı için ayar açılsa da rapor gönderilmez.

## Upstream senkron rutini

```sh
git fetch upstream --tags
git checkout canary && git merge --ff-only upstream/canary && git push origin canary
git checkout sanalyer && git merge upstream/canary
git submodule update --init --recursive
flutter pub get && dart run build_runner build --delete-conflicting-outputs
# marka taraması, flutter analyze, değişen dosyaların testleri
```
