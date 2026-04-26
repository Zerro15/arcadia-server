# Troubleshooting

## 1. Сервер Не Стартует

Смотреть:

- `~/arcadia-server/logs/latest.log`
- `~/arcadia-server/crash-reports`

## 2. Не Работает Voice Chat

Simple Voice Chat использует UDP `24454`, не TCP.

Проверить:

```bash
arcadia voice
```

В игре:

```text
/voicechat info
/voicechat test Nick
```

В firewall:

```bash
sudo ufw allow 24454/udp
```

В панели хостинга нужен именно UDP allocation/port.

## 3. Игрок Не Может Зайти

Проверьте:

- у игрока стоят client addons
- игрок добавлен в whitelist
- версия клиентской сборки совпадает с сервером

## 4. Missing Dependencies

Нужно скинуть `latest.log`.

Не пытайтесь наугад возвращать client-only моды. Сначала нужно понять, какой мод требует зависимость и нужен ли он dedicated server.

## 5. Лаги Сервера

Варианты:

- уменьшить `view-distance`
- уменьшить `simulation-distance`
- поставить `XMX=8G` или `XMX=10G`, если есть RAM
- не строить сразу огромные аэрокорабли Create Aeronautics
