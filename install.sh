#!/usr/bin/env bash
set -Eeuo pipefail

PACK_URL="${PACK_URL:-}"
SERVER_DIR="${SERVER_DIR:-$HOME/arcadia-server}"
XMS="${XMS:-4G}"
XMX="${XMX:-8G}"
PORT="${PORT:-25565}"
VOICE_PORT="${VOICE_PORT:-24454}"
ACCEPT_EULA="${ACCEPT_EULA:-false}"
AUTO_START="${AUTO_START:-false}"

if [[ -z "$PACK_URL" ]]; then
  echo "ERROR: PACK_URL is required."
  echo 'Example: PACK_URL="https://example.com/Arcadia-ServerPack.zip" ACCEPT_EULA=true bash install.sh'
  exit 1
fi

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_as_root() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    "$@"
  elif need_cmd sudo; then
    sudo "$@"
  else
    echo "ERROR: need root privileges for: $*"
    echo "Install sudo or run this script as root."
    exit 1
  fi
}

install_deps() {
  local pkgs=(curl unzip tmux)
  if need_cmd java; then
    local major
    major="$(java -version 2>&1 | awk -F '[\".]' '/version/ {print $2; exit}')"
    if [[ "$major" == "21" ]]; then
      echo "Java 21 already available."
    else
      pkgs+=(openjdk-21-jre-headless)
    fi
  else
    pkgs+=(openjdk-21-jre-headless)
  fi

  if need_cmd apt-get; then
    run_as_root apt-get update
    run_as_root apt-get install -y "${pkgs[@]}"
  elif need_cmd dnf; then
    run_as_root dnf install -y java-21-openjdk-headless curl unzip tmux
  elif need_cmd yum; then
    run_as_root yum install -y java-21-openjdk-headless curl unzip tmux
  else
    echo "WARNING: apt/dnf/yum not found. Install Java 21, curl, unzip and tmux manually."
  fi
}

write_jvm_args() {
  cat > "$SERVER_DIR/user_jvm_args.txt" <<EOF
-Xms${XMS}
-Xmx${XMX}
EOF
}

set_property() {
  local key="$1"
  local value="$2"
  local file="$SERVER_DIR/server.properties"
  touch "$file"
  if grep -qE "^${key}=" "$file"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >> "$file"
  fi
}

write_start_sh() {
  cat > "$SERVER_DIR/start.sh" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "$0")"
chmod +x run.sh
exec ./run.sh nogui
EOF
  chmod +x "$SERVER_DIR/start.sh"
  [[ -f "$SERVER_DIR/run.sh" ]] && chmod +x "$SERVER_DIR/run.sh"
}

write_voicechat_config() {
  local dir="$SERVER_DIR/config/voicechat"
  local file="$dir/voicechat-server.properties"
  mkdir -p "$dir"
  cat > "$file" <<EOF
port=${VOICE_PORT}
bind_address=
voice_host=
max_voice_distance=48
whisper_distance=24
enable_groups=true
allow_pings=true
force_voice_chat=false
EOF
}

configure_firewall() {
  echo "Для Simple Voice Chat нужно открыть UDP порт $VOICE_PORT в firewall/панели хостинга/роутере."
  if command -v ufw >/dev/null 2>&1; then
    if ufw status 2>/dev/null | grep -qi 'Status: active'; then
      run_as_root ufw allow "${PORT}/tcp" || echo "WARNING: не удалось открыть ${PORT}/tcp через ufw."
      run_as_root ufw allow "${VOICE_PORT}/udp" || echo "WARNING: не удалось открыть ${VOICE_PORT}/udp через ufw."
    else
      echo "ufw установлен, но не активен. Правила ufw не применялись."
    fi
  else
    echo "ufw не установлен. Проверьте firewall/панель хостинга вручную."
  fi
}

confirm_eula() {
  if [[ "$ACCEPT_EULA" == "true" ]]; then
    echo "eula=true" > "$SERVER_DIR/eula.txt"
    return
  fi

  echo "Minecraft EULA must be accepted before the server can start:"
  echo "https://aka.ms/MinecraftEULA"
  read -r -p "Type yes to accept EULA now: " answer
  if [[ "$answer" == "yes" ]]; then
    echo "eula=true" > "$SERVER_DIR/eula.txt"
  else
    echo "EULA not accepted. Server is installed but will not start until eula.txt contains eula=true."
  fi
}

install_arcadia_command() {
  local bin_dir="$HOME/.local/bin"
  mkdir -p "$bin_dir"
  if [[ -f "./arcadia" ]]; then
    cp ./arcadia "$bin_dir/arcadia"
  elif [[ -n "${ARCADIA_SCRIPT_URL:-}" ]]; then
    curl -fsSL "$ARCADIA_SCRIPT_URL" -o "$bin_dir/arcadia"
  else
    cat > "$bin_dir/arcadia" <<'ARCADIA_EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
SESSION="${ARCADIA_SESSION:-arcadia-server}"
SERVER_DIR="${ARCADIA_DIR:-$HOME/arcadia-server}"
BACKUP_DIR="${ARCADIA_BACKUPS:-$HOME/arcadia-backups}"
is_running(){ tmux has-session -t "$SESSION" 2>/dev/null; }
send_cmd(){ is_running || { echo "Сервер не запущен."; exit 1; }; tmux send-keys -t "$SESSION" "$*" C-m; }
start_server(){ if is_running; then echo "Сервер уже запущен."; return; fi; [[ -d "$SERVER_DIR" ]] || { echo "Не найдена папка сервера: $SERVER_DIR"; exit 1; }; chmod +x "$SERVER_DIR/start.sh"; tmux new-session -d -s "$SESSION" "cd \"$SERVER_DIR\" && ./start.sh"; echo "Сервер запущен."; }
stop_server(){ if ! is_running; then echo "Сервер уже остановлен."; return; fi; tmux send-keys -t "$SESSION" "say Сервер останавливается через 10 секунд." C-m; tmux send-keys -t "$SESSION" "save-all flush" C-m; sleep 10; tmux send-keys -t "$SESSION" "stop" C-m; echo "Команда stop отправлена."; }
restart_server(){ stop_server; for _ in $(seq 1 90); do if ! is_running; then start_server; return; fi; sleep 2; done; echo "Сессия не завершилась, проверьте arcadia console."; exit 1; }
console_server(){ is_running || { echo "Сервер не запущен. Запуск: arcadia start"; exit 1; }; echo "Чтобы выйти из консоли и НЕ выключить сервер: Ctrl+B, потом D"; sleep 1; tmux attach -t "$SESSION"; }
logs_server(){ local log="$SERVER_DIR/logs/latest.log"; [[ -f "$log" ]] || { echo "Лог пока не найден: $log"; exit 1; }; tail -n 200 -f "$log"; }
dir_size(){ [[ -d "$1" ]] && du -sh "$1" 2>/dev/null | awk '{print $1}' || echo "нет"; }
status_server(){ local state="остановлен"; is_running && state="запущен"; local port="не найден"; [[ -f "$SERVER_DIR/server.properties" ]] && port="$(awk -F= '$1=="server-port"{print $2}' "$SERVER_DIR/server.properties" | tail -n 1)"; local mods=0; [[ -d "$SERVER_DIR/mods" ]] && mods="$(find "$SERVER_DIR/mods" -maxdepth 1 -type f -name '*.jar' | wc -l | tr -d ' ')"; local ram="не найден"; [[ -f "$SERVER_DIR/user_jvm_args.txt" ]] && ram="$(grep -E '^-Xm[sx]' "$SERVER_DIR/user_jvm_args.txt" | tr '\n' ' ')"; echo "Статус: $state"; echo "Путь: $SERVER_DIR"; echo "Порт: ${port:-не найден}"; echo "Модов в mods: $mods"; echo "RAM: $ram"; echo "Размер world: $(dir_size "$SERVER_DIR/world")"; }
voice_info(){ local file="$SERVER_DIR/config/voicechat/voicechat-server.properties"; local port="24454"; [[ -f "$file" ]] && port="$(awk -F= '$1=="port"{print $2}' "$file" | tail -n 1)"; port="${port:-24454}"; echo "Simple Voice Chat UDP порт: $port"; echo "Нужен именно UDP, не TCP."; echo "ufw: sudo ufw allow ${port}/udp"; echo "В игре: /voicechat test <ник>"; echo "В игре: /voicechat info"; }
backup_server(){ local world="$SERVER_DIR/world"; [[ -d "$world" ]] || { echo "Папка world не найдена: $world"; exit 1; }; mkdir -p "$BACKUP_DIR"; local archive="$BACKUP_DIR/arcadia-world-$(date +%Y%m%d-%H%M%S).tar.gz"; if is_running; then tmux send-keys -t "$SESSION" "save-off" C-m; tmux send-keys -t "$SESSION" "save-all flush" C-m; sleep 5; tar -czf "$archive" -C "$SERVER_DIR" world; tmux send-keys -t "$SESSION" "save-on" C-m; else tar -czf "$archive" -C "$SERVER_DIR" world; fi; echo "Backup создан: $archive"; }
change_ram(){ mkdir -p "$SERVER_DIR"; read -r -p "Xms [4G]: " xms; read -r -p "Xmx [8G]: " xmx; xms="${xms:-4G}"; xmx="${xmx:-8G}"; printf -- '-Xms%s\n-Xmx%s\n' "$xms" "$xmx" > "$SERVER_DIR/user_jvm_args.txt"; echo "RAM обновлена: -Xms$xms -Xmx$xmx"; }
menu(){ while true; do printf '\nArcadia Echoes Of Power V2\n1) Запустить сервер\n2) Остановить сервер\n3) Перезапустить сервер\n4) Открыть живую консоль сервера\n5) Посмотреть логи\n6) Сделать backup мира\n7) Выдать OP игроку\n8) Добавить игрока в whitelist\n9) Посмотреть статус сервера\n10) Написать сообщение в чат сервера\n11) Отправить любую команду в консоль сервера\n12) Изменить RAM\n13) Информация по voice chat / UDP порту\n0) Выход\n'; read -r -p "Выбор: " c; case "$c" in 1) start_server;; 2) stop_server;; 3) restart_server;; 4) console_server;; 5) logs_server;; 6) backup_server;; 7) read -r -p "Nick: " n; send_cmd "op $n";; 8) read -r -p "Nick: " n; send_cmd "whitelist add $n"; send_cmd "whitelist reload";; 9) status_server;; 10) read -r -p "Текст: " t; send_cmd "say $t";; 11) read -r -p "Команда: " t; send_cmd "$t";; 12) change_ram;; 13) voice_info;; 0) exit 0;; *) echo "Неизвестный пункт.";; esac; done; }
cmd="${1:-menu}"; shift || true
case "$cmd" in menu) menu;; start) start_server;; stop) stop_server;; restart) restart_server;; console) console_server;; logs) logs_server;; status) status_server;; backup) backup_server;; voice) voice_info;; op) [[ $# -ge 1 ]] || { echo "Использование: arcadia op Nick"; exit 1; }; send_cmd "op $1";; whitelist) [[ $# -ge 1 ]] || { echo "Использование: arcadia whitelist Nick"; exit 1; }; send_cmd "whitelist add $1"; send_cmd "whitelist reload";; say) [[ $# -ge 1 ]] || { echo "Использование: arcadia say текст"; exit 1; }; send_cmd "say $*";; cmd) [[ $# -ge 1 ]] || { echo "Использование: arcadia cmd команда"; exit 1; }; send_cmd "$*";; ram) change_ram;; help|-h|--help) echo "arcadia start|stop|restart|console|logs|status|backup|voice|op|whitelist|say|cmd|ram";; *) echo "Неизвестная команда."; exit 1;; esac
ARCADIA_EOF
  fi
  chmod +x "$bin_dir/arcadia"
  echo "Installed command: $bin_dir/arcadia"
  case ":$PATH:" in
    *":$bin_dir:"*) ;;
    *)
      echo 'If arcadia is not found, run:'
      echo 'export PATH="$HOME/.local/bin:$PATH"'
      ;;
  esac
}

main() {
  echo "Installing Arcadia Echoes Of Power V2 server pack"
  install_deps

  mkdir -p "$SERVER_DIR"
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  echo "Downloading server pack..."
  curl -fL "$PACK_URL" -o "$tmp/Arcadia-ServerPack.zip"

  echo "Unpacking into $SERVER_DIR..."
  unzip -q "$tmp/Arcadia-ServerPack.zip" -d "$tmp/unpack"
  shopt -s dotglob nullglob
  local entries=("$tmp"/unpack/*)
  if [[ "${#entries[@]}" -eq 1 && -d "${entries[0]}" && ! -d "$tmp/unpack/mods" ]]; then
    cp -a "${entries[0]}"/. "$SERVER_DIR"/
  else
    cp -a "$tmp"/unpack/. "$SERVER_DIR"/
  fi
  shopt -u dotglob nullglob

  write_jvm_args
  set_property "online-mode" "true"
  set_property "white-list" "true"
  set_property "allow-flight" "true"
  set_property "view-distance" "8"
  set_property "simulation-distance" "5"
  set_property "max-players" "6"
  set_property "server-port" "$PORT"
  set_property "motd" "Arcadia Echoes Of Power V2 Server"
  write_voicechat_config
  write_start_sh
  confirm_eula
  install_arcadia_command
  configure_firewall

  echo
  echo "Install complete."
  echo "Next commands:"
  echo "  arcadia start"
  echo "  arcadia console"
  echo "Console detach: Ctrl+B, then D"

  if [[ "$AUTO_START" == "true" ]]; then
    arcadia start
  fi
}

main "$@"
