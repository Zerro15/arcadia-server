# Arcadia Echoes Of Power V2 Server Pack

Это server pack для Arcadia Echoes Of Power V2:

- Minecraft: `1.21.1`
- NeoForge: `21.1.221`
- Управление сервером: `arcadia`
- Сервер работает в `tmux`, поэтому консоль можно закрывать без остановки сервера.

## Публикация

1. Загрузите `Arcadia-ServerPack.zip` в GitHub Releases.
2. Загрузите `install.sh` и `arcadia` в GitHub repository, например в ветку `main`.
3. В release URL замените `USER`, `REPO` и `v1` на свои значения.

## Установка Одной Командой

```bash
PACK_URL="https://github.com/USER/REPO/releases/download/v1/Arcadia-ServerPack.zip" \
ACCEPT_EULA=true \
XMX=10G \
VOICE_PORT=24454 \
bash <(curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/install.sh)
```

Если `arcadia` лежит не рядом с `install.sh`, можно передать прямой URL:

```bash
ARCADIA_SCRIPT_URL="https://raw.githubusercontent.com/USER/REPO/main/arcadia"
```

Поддерживаемые переменные:

- `PACK_URL`: ссылка на `Arcadia-ServerPack.zip`, обязательна.
- `SERVER_DIR`: папка сервера, по умолчанию `$HOME/arcadia-server`.
- `XMS`: минимальная RAM, по умолчанию `6G`.
- `XMX`: максимальная RAM, по умолчанию `10G`.
- `PORT`: порт сервера, по умолчанию `25566`.
- `VOICE_PORT`: UDP порт Simple Voice Chat, по умолчанию `24454`.
- `ACCEPT_EULA`: `true` для принятия EULA.
- `AUTO_START`: `true`, если нужно запустить сервер сразу после установки.

Если `~/.local/bin` не в `PATH`, выполните:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Запуск И Управление

Открыть меню:

```bash
arcadia
```

Запустить сервер:

```bash
arcadia start
```

Открыть живую консоль:

```bash
arcadia console
```

Выйти из консоли и не выключить сервер:

```text
Ctrl+B, потом D
```

Остановить сервер:

```bash
arcadia stop
```

Сделать backup мира:

```bash
arcadia backup
```

Выдать OP:

```bash
arcadia op Nick
```

Добавить игрока в whitelist:

```bash
arcadia whitelist Nick
```

Посмотреть статус:

```bash
arcadia status
```

## Simple Voice Chat

На сервере и у игроков должен быть установлен Simple Voice Chat. По умолчанию используется UDP порт `24454`.

На Linux/VPS нужно открыть именно UDP порт:

```bash
sudo ufw allow 24454/udp
```

Если сервер размещён в панели хостинга, добавьте именно UDP allocation/port, не только TCP.

Проверка в игре:

```text
/voicechat test Nick
/voicechat info
```

Информация на сервере:

```bash
arcadia voice
```

## Create Aeronautics

На сервере и у всех игроков должны быть одинаковые jar:

- Create Aeronautics
- Sable
- Simple Voice Chat

Эти jar лежат в `client-addons` и в архиве `Arcadia-Client-Addons.zip`. Игроки должны скопировать содержимое `client-addons` в папку `mods` своей CurseForge-сборки.

Большие летающие конструкции могут заметно грузить сервер. Начинайте с маленьких тестов и проверяйте TPS/логи перед строительством больших машин.
