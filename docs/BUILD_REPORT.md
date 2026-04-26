# Arcadia Echoes Of Power V2 Server Pack Report

## Что Создано

- Рабочая структура: `server`, `publish`, `tools`, `reports`.
- NeoForge installer: `tools/neoforge-21.1.221-installer.jar`.
- NeoForge server установлен в `server`.
- Из клиентской сборки скопированы: `mods`, `config`, `defaultconfigs`, `kubejs`.
- Созданы серверные файлы: `user_jvm_args.txt`, `server.properties`, `start.sh`, `start.bat`.
- Созданы файлы публикации: `publish/install.sh`, `publish/arcadia`, `publish/README_LINUX.md`.

## Моды

- Скопировано jar из оригинальной сборки: `441`.
- Осталось активных jar в `server/mods`: `425`.
- Перемещено client-only кандидатов: `16`.

## Перемещено В server-disabled-client-mods

- `BetterF3-11.0.3-NeoForge-1.21.1.jar`
- `Controlling-neoforge-1.21.1-19.0.5.jar`
- `entityculling-neoforge-1.10.1-mc1.21.1.jar`
- `fancymenu_neoforge_3.8.1_MC_1.21.1.jar`
- `ImmediatelyFast-NeoForge-1.6.10+1.21.1.jar`
- `iris-neoforge-1.8.12+mc1.21.1.jar`
- `MouseTweaks-neoforge-mc1.21-2.26.1.jar`
- `reeses-sodium-options-neoforge-1.8.3+mc1.21.4.jar`
- `sodium-neoforge-0.6.13+mc1.21.1.jar`
- `sodiumextras-neoforge-1.0.8-1.21.1.jar`
- `sodiumleafculling-neoforge-1.0.1-1.21.1.jar`
- `sodiumoptionsapi-neoforge-1.0.10-1.21.1.jar`
- `sodiumoptionsmodcompat-neoforge-1.0.0-1.21.1.jar`
- `spiffyhud_neoforge_3.1.0_MC_1.21.1.jar`
- `ResourcePackOverrides-v21.1.0-1.21.1-NeoForge.jar`
- `appleskin-neoforge-mc1.21-3.0.9.jar`

## Итоговый Архив

Архив находится здесь:

`C:\Users\Bogdan\Arcadia-Echoes-Of-Power-V2-serverpack-work\publish\Arcadia-ServerPack.zip`

В архиве лежит содержимое `server`, без внешней папки `server`.

Размер архива после первой проверки: `1000723655` байт.

Проверено наличие ключевых путей в архиве:

- `mods/`
- `config/`
- `defaultconfigs/`
- `kubejs/`
- `libraries/`
- `run.sh`
- `user_jvm_args.txt`
- `server.properties`
- `start.sh`

## Что Делать Дальше

1. Загрузить `publish/Arcadia-ServerPack.zip` в GitHub Releases.
2. Загрузить `publish/install.sh` и `publish/arcadia` в GitHub repository.
3. Передать другу команду установки из `publish/README_LINUX.md`.
4. Первый запуск лучше делать через `arcadia start`, затем смотреть `arcadia logs` и `arcadia console`.

## Возможные Проблемы При Первом Запуске

- Некоторые оставленные моды могут оказаться client-only и упасть на dedicated server.
- `Jade`, `JadeAddons`, `resourcefulconfig`, `resourcefullib`, `VisualWorkbench`, `clientcrafting` специально оставлены до проверки по логам.
- Возможны ошибки зависимостей после удаления Sodium/Iris stack, если какой-то мод жестко зависит от них.
- Возможны ошибки KubeJS/serverconfig, если клиентская сборка рассчитывала на файлы вне скопированных папок.
- Если сервер падает, смотреть `server/logs/latest.log` и `server/crash-reports`.

## Проверка Скриптов

`bash -n` из текущей Windows-среды не удалось выполнить через `C:\Windows\System32\bash.exe`: WSL вернул `E_ACCESSDENIED`. Синтаксис shell-файлов нужно дополнительно проверить на Linux или в рабочем WSL.

## Добавление Create Aeronautics, Sable И Simple Voice Chat

Добавлены моды:

- Create Aeronautics `1.1.3+mc1.21.1`
- Sable `1.1.3+mc1.21.1`
- Simple Voice Chat `2.6.16` для NeoForge `1.21.1`

Скачанные jar:

- `downloads/create-aeronautics-bundled-1.21.1-1.1.3.jar`
- `downloads/sable-neoforge-1.21.1-1.1.3.jar`
- `downloads/voicechat-neoforge-1.21.1-2.6.16.jar`

Server jar положены в:

- `server/mods/create-aeronautics-bundled-1.21.1-1.1.3.jar`
- `server/mods/sable-neoforge-1.21.1-1.1.3.jar`
- `server/mods/voicechat-neoforge-1.21.1-2.6.16.jar`

Client addons jar положены в:

- `client-addons/create-aeronautics-bundled-1.21.1-1.1.3.jar`
- `client-addons/sable-neoforge-1.21.1-1.1.3.jar`
- `client-addons/voicechat-neoforge-1.21.1-2.6.16.jar`

Создан архив для игроков:

`C:\Users\Bogdan\Arcadia-Echoes-Of-Power-V2-serverpack-work\publish\Arcadia-Client-Addons.zip`

После добавления модов активных jar в `server/mods`: `427`.

Актуальный server pack:

`C:\Users\Bogdan\Arcadia-Echoes-Of-Power-V2-serverpack-work\publish\Arcadia-ServerPack.zip`

Актуальный размер server pack: `1063028941` байт.

Размер client-addons архива: `62306400` байт.

Simple Voice Chat использует UDP порт `24454`. Его нужно открыть в firewall, панели хостинга и роутере, если сервер находится за NAT.

Конфиг создан здесь:

`server/config/voicechat/voicechat-server.properties`

Первый запуск с добавленными модами ещё нужно проверить на Linux. При ошибках смотреть:

- `server/logs/latest.log`
- `server/crash-reports`

## Лёгкий smoke-test на слабом ПК

Дата: `2026-04-26`

Перед smoke-test из `server/mods` в `server/server-disabled-client-mods` перенесены:

- `drippyloadingscreen_neoforge_3.1.0_MC_1.21.1.jar`
- `colorwheel-neoforge-1.2.4+mc1.21.1.jar`

Причина: эти моды тянут клиентские визуальные зависимости:

- `drippyloadingscreen` требует `fancymenu`
- `colorwheel` требует `iris`

`fancymenu` и `iris` не возвращались на dedicated server.

Для локального smoke-test RAM временно снижена в `server/user_jvm_args.txt`:

- `-Xms1G`
- `-Xmx5G`

Лог smoke-test:

`C:\Users\Bogdan\Arcadia-Echoes-Of-Power-V2-serverpack-work\test-runs\smoke-test-20260426-153430.log`

Результат анализа:

- Missing dependency по `fancymenu`/`iris` больше не повторился.
- Новый crash-report после smoke-test не появился.
- В `server/logs/latest.log` нет нового `FATAL`, `ModLoadingException`, `Failed to start` или `Missing or unsupported mandatory dependencies`.
- Сервер дошёл дальше этапа dependency resolution: `Launching target 'forgeserver'`, mixin/coremod loading.
- До `Done` локальный smoke-test не дошёл.
- Smoke-test скрипт слишком агрессивно отметил `CRASH` на строке уровня `WARN` с `ClassNotFoundException` в mixin; по `latest.log` это не подтверждённый hard crash.

Полноценный тест до `Done` лучше делать уже на Linux-сервере друга или на более мощной машине. После подтверждения состава server pack нужно пересобрать `Arcadia-ServerPack.zip`, потому что текущий zip ещё не включает перенос `drippyloadingscreen` и `colorwheel` в disabled.

## Финальная упаковка

Дата: `2026-04-26`

Финальная RAM в `server/user_jvm_args.txt` возвращена:

- `-Xms4G`
- `-Xmx8G`

Из активных `server/mods` исключены:

- `drippyloadingscreen_neoforge_3.1.0_MC_1.21.1.jar`
- `colorwheel-neoforge-1.2.4+mc1.21.1.jar`

Также в активных `server/mods` отсутствуют клиентские зависимости:

- `fancymenu_neoforge_3.8.1_MC_1.21.1.jar`
- `iris-neoforge-1.8.12+mc1.21.1.jar`

Финальный архив собран через staging-папку:

`C:\Users\Bogdan\Arcadia-Echoes-Of-Power-V2-serverpack-work\zip-staging`

В финальный `Arcadia-ServerPack.zip` не включены:

- `server-disabled-client-mods`
- `world`
- `logs`
- `crash-reports`
- `eula.txt`
- `*.log`
- временные файлы

Финальный server pack:

`C:\Users\Bogdan\Arcadia-Echoes-Of-Power-V2-serverpack-work\publish\Arcadia-ServerPack.zip`

Размер финального server pack: `1051135649` байт.

Проверка zip:

- обязательные пути присутствуют
- запрещённые runtime/client-only пути не найдены
- внешней папки `server/` внутри архива нет

Для Simple Voice Chat нужен UDP порт `24454`.

Игрокам нужен:

`C:\Users\Bogdan\Arcadia-Echoes-Of-Power-V2-serverpack-work\publish\Arcadia-Client-Addons.zip`

Полноценный тест до `Done` лучше делать на Linux-сервере друга.
