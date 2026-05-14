# iOS — patches à appliquer après `flutter create .`

Après `flutter create .`, Flutter génère `ios/Runner/Info.plist`. Trois entrées
sont nécessaires pour BBCMS :

## 1. ATS (App Transport Security) — autoriser HTTP cleartext en dev

iOS bloque les requêtes HTTP non-TLS par défaut. Pour pouvoir attaquer un
backend local en dev, ajoutez dans `ios/Runner/Info.plist`, dans le `<dict>`
racine :

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
        <key>127.0.0.1</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

**Production** : retirez ces exceptions et déployez le backend en HTTPS.

## 2. Permissions caméra & galerie — pour `image_picker`

L'app permet aux membres de prendre/choisir une photo de profil et aux leaders
de photographier les réunions. Sans ces clés, iOS refuse l'accès et l'app
crashe au premier `image_picker`.

```xml
<key>NSCameraUsageDescription</key>
<string>BBCMS utilise la caméra pour les photos de profil et de réunion.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>BBCMS accède à votre galerie pour choisir une photo de profil ou de club.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>BBCMS enregistre les exports (cartes de membre, snapshots) dans votre galerie.</string>
```

## 3. Type d'app (orientation, etc.)

Le `main.dart` force l'orientation portrait — vérifiez que `Info.plist` n'expose
pas d'orientations conflictuelles. Par défaut Flutter génère les 4
orientations ; vous pouvez ne garder que `UIInterfaceOrientationPortrait`
dans `UISupportedInterfaceOrientations`.
