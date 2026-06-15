# 🎮 MTA Server Panel

Мобільний та десктопний додаток для керування MTA сервером через Pterodactyl API.

## 📱 Завантаження

Після того як GitHub Actions збере проект, файли з'являться у вкладці **Releases**:
- `app-arm64-v8a-release.apk` — для Android
- `mta-panel-windows.zip` — для Windows

## ⚙️ Налаштування

### 1. Встановлення Lua скрипта на MTA сервер

1. Скопіюй папку `lua-script` на сервер як `resources/mta_panel/`
2. Відкрий `server.lua` і змін `your_secret_key_here` на свій ключ
3. Запусти ресурс: `start mta_panel`

### 2. Налаштування MTA сервера (mtaserver.conf)

Переконайся що HTTP сервер увімкнений:
```xml
<httpserver>1</httpserver>
<httpport>22005</httpport>
```

### 3. Перевірка

Відкрий у браузері:
```
http://g1.qniks.me:22005/mta_panel/info
```
(з заголовком `X-Secret-Key: your_key`)

## 🚀 Функції

| Функція | Статус |
|---------|--------|
| Старт/Стоп/Рестарт сервера | ✅ Pterodactyl |
| CPU / RAM моніторинг | ✅ Pterodactyl |
| Список гравців онлайн | ✅ Lua скрипт |
| Кік гравців | ✅ Lua скрипт |
| Бан гравців | ✅ Lua скрипт |
| Консоль / команди | ✅ Pterodactyl |

## 🔧 Збірка самостійно

```bash
flutter pub get
flutter build apk --release
flutter build windows --release
```
