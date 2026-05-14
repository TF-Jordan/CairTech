# Android — patches à appliquer après `flutter create .`

Quand vous exécutez `flutter create .` pour générer l'arborescence Android,
Flutter crée un `AndroidManifest.xml` standard qui **manque** deux choses pour
BBCMS :

1. La permission INTERNET (Flutter l'ajoute en debug seulement)
2. La référence au `network_security_config.xml` (déjà fourni dans
   `android/app/src/main/res/xml/`) qui autorise le HTTP cleartext vers
   `10.0.2.2`, `localhost` et `127.0.0.1` en dev.

## À ajouter dans `android/app/src/main/AndroidManifest.xml`

Sous la racine `<manifest>` (avant `<application>`) :

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Sur la balise `<application ...>` ajouter :

```xml
android:networkSecurityConfig="@xml/network_security_config"
android:usesCleartextTraffic="true"
```

Exemple complet de la balise :

```xml
<application
    android:label="BBCMS"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:networkSecurityConfig="@xml/network_security_config"
    android:usesCleartextTraffic="true">
    ...
</application>
```

## Min SDK requis par les dépendances

`flutter_secure_storage` requiert `minSdkVersion 23` (Android 6.0+).
Dans `android/app/build.gradle` (section `defaultConfig`) :

```gradle
minSdkVersion 23
```
