# Установка Arcadia Server

## Требования

- Linux/VPS
- Java 21
- curl
- unzip
- tmux
- `install.sh` попробует поставить зависимости сам

## Порты

Откройте порты:

- `25566/tcp` для Minecraft
- `24454/udp` для Simple Voice Chat

Пример для `ufw`:

```bash
sudo ufw allow 25566/tcp
sudo ufw allow 24454/udp
```

## Команда Установки

```bash
PACK_URL="https://github.com/Zerro15/arcadia-server/releases/download/1.0.0/Arcadia-ServerPack.zip" \
ACCEPT_EULA=true \
XMX=10G \
VOICE_PORT=24454 \
bash <(curl -fsSL https://raw.githubusercontent.com/Zerro15/arcadia-server/main/install.sh)
```

## Управление

```bash
arcadia
arcadia start
arcadia logs
arcadia console
arcadia voice
arcadia stop
arcadia backup
arcadia op Nick
arcadia whitelist Nick
```

Чтобы выйти из консоли и не выключить сервер:

```text
Ctrl+B, потом D
```

## Для Игроков

Игрокам нужно скачать `Arcadia-Client-Addons.zip` из Releases и распаковать jar-файлы в папку `mods` клиентской CurseForge-сборки.

Внутри должны быть:

- Create Aeronautics
- Sable
- Simple Voice Chat
