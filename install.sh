#!/bin/bash

#bash <(wget -qO- https://raw.githubusercontent.com/USER/REPO/main/install.sh) --port=443 --ip=203.0.113.10 --domain=google.com --workers=1

#прежде чем качать другие инсталляторы посмотри код оф сайта
#в них это не учтено, а это критически важные моменты
#после копания в исходниках мне пришлось писать свой инсталятор
#https://github.com/TelegramMessenger/MTProxy/commit/0613f7616c7094725d71224b221b90c17b7e23ed
#https://github.com/TelegramMessenger/MTProxy/blob/master/mtproto/mtproto-proxy.c#L2199C9-L2199C71

#set -euo pipefail
#set -e

show_help() {
  cat <<'EOF'
Использование:
  ./script.sh [ПАРАМЕТРЫ]

Параметры:
  --port=PORT         Порт прокси. По умолчанию: 443
  --ip=IP             Внешний IP сервера. По умолчанию определяется автоматически
  --domain=DOMAIN     Домен для Fake-TLS. По умолчанию: github.com
  --workers=N         Количество воркеров. По умолчанию: 1
  --help              Показать эту справку

Примеры:
  ./script.sh
  ./script.sh --port=443
  ./script.sh --ip=203.0.113.10 --domain=google.com
  ./script.sh --port=8443 --ip=203.0.113.10 --domain=google.com --workers=1

Примечания:
  - Параметры можно передавать в любом порядке
  - Формат параметров: только --имя=значение
  - Если параметр передан несколько раз, будет использовано последнее значение
EOF
}

show_error() {
  echo "Ошибка: $1" >&2
  echo >&2
  show_help >&2
  exit 1
}

FAKE_DOMAIN="github.com"
#SERVER_IP="111.222.333.444"
SERVER_IP=$(curl -fsSL https://api.ipify.org || curl -fsSL https://ifconfig.me || curl -fsSL https://checkip.amazonaws.com)
PORT=443
WORKERS=1

#разбор аргументов
for arg in "$@"; do
  case "$arg" in
    --help)
      show_help
      exit 0
      ;;
    --port=*)
      PORT="${arg#*=}"
      ;;
    --ip=*)
      SERVER_IP="${arg#*=}"
      ;;
    --domain=*)
      FAKE_DOMAIN="${arg#*=}"
      ;;
    --workers=*)
      WORKERS="${arg#*=}"
      ;;
    *)
      show_error "Неизвестный параметр: $arg"
      ;;
  esac
done

[[ -n "$PORT" ]] || show_error "Порт не может быть пустым"
[[ -n "$SERVER_IP" ]] || show_error "IP не может быть пустым"
[[ -n "$FAKE_DOMAIN" ]] || show_error "Домен не может быть пустым"
[[ -n "$WORKERS" ]] || show_error "Количество воркеров не может быть пустым"

echo -e "\033[1;32m"
cat << "EOF"
• ▌ ▄ ·. ▄▄▄▄▄ ▄▄▄·▄▄▄        ▐▄• ▄  ▄· ▄▌
·██ ▐███▪•██  ▐█ ▄█▀▄ █·▪      █▌█▌▪▐█▪██▌
▐█ ▌▐▌▐█· ▐█.▪ ██▀·▐▀▀▄  ▄█▀▄  ·██· ▐█▌▐█▪
██ ██▌▐█▌ ▐█▌·▐█▪·•▐█•█▌▐█▌.▐▌▪▐█·█▌ ▐█▀·.
▀▀  █▪▀▀▀ ▀▀▀ .▀   .▀  ▀ ▀█▄▀▪•▀▀ ▀▀  ▀ • 
EOF
echo -e "\033[0m"

echo -e "\033[1;32mПротестировано на Debian 12 на чистом серваке\033[0m"
echo -e "\033[1;32mУстановлю докер и скомпилирую в нем mtproxy из официальных исходников\033[0m"
echo -e "\033[1;32mУстанавлю сразу все варианты прокси, выдам список в конце установки\033[0m"
echo -e "\033[1;32mСделаю автозагрузку обнов конфигов телеги раз в 6 часов нужных для mtproxy\033[0m"
echo -e "\033[1;31mЧтобы продолжить, нажмите Enter...\033[0m"
read && echo
#exit 1

wait_for_apt() {
  echo "Жду освобождения apt, он занят потому что сервер новый..."
  while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
        fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
        fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    sleep 3
  done
}

wait_for_apt
dpkg --configure -a

apt-get update && apt-get install -y curl xxd
apt-get install -y cron
systemctl enable --now cron
#curl -fsSL https://get.docker.com | sh
apt-get install -y docker.io
systemctl enable --now docker
docker --version

#отрубаю ipv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

for iface in /proc/sys/net/ipv6/conf/*/disable_ipv6; do
  echo 1 > "$iface"
done

CONF="/etc/sysctl.d/99-disable-ipv6.conf"

cat > "$CONF" <<EOF
# Disable IPv6 (managed by script)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl --system

#

SECRET=$(head -c 16 /dev/urandom | xxd -ps)
DD="dd$SECRET"
EE="ee${SECRET}$(echo -n "$FAKE_DOMAIN" | xxd -p)"


echo "FAKE_DOMAIN=$FAKE_DOMAIN"
echo "SERVER_IP=$SERVER_IP"
echo "PORT=$PORT"
echo "WORKERS=$WORKERS"

echo "SECRET=$SECRET"
echo "DD=$DD"
echo "EE=$EE"


#apt install git curl build-essential libssl-dev zlib1g-dev
#git clone https://github.com/TelegramMessenger/MTProxy
#cd MTProxy
#make && cd objs/bin
##make clean
#curl -s https://core.telegram.org/getProxySecret -o proxy-secret
#curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

#./mtproto-proxy -u nobody -p 8888 -H $PORT -S "$SECRET" --aes-pwd proxy-secret proxy-multi.conf -M 1

#создаём временную директорию с рандомными цифрами
TEMP="/tmp/mtproxy_$(tr -dc '0-9' </dev/urandom | head -c 8)"
mkdir -p "$TEMP"

#cat > "$TEMP/Dockerfile" <<'EOF'
#FROM debian:12-slim

#RUN apt-get update && apt-get install -y \
#    git curl build-essential libssl-dev zlib1g-dev

#WORKDIR /opt

#RUN git clone https://github.com/TelegramMessenger/MTProxy \
# && cd MTProxy \
# && make \
# && cd objs/bin \
# && curl -fsSL https://core.telegram.org/getProxySecret -o proxy-secret \
# && curl -fsSL https://core.telegram.org/getProxyConfig -o proxy-multi.conf

#WORKDIR /opt/MTProxy/objs/bin

##CMD ["/bin/sh", "-c", "./mtproto-proxy -u nobody -p 8888 -H ${PORT} -S \"${SECRET}\" --aes-pwd proxy-secret proxy-multi.conf -M ${WORKERS}"]
#CMD ["/bin/sh", "-c", "curl -fsSL https://core.telegram.org/getProxySecret -o proxy-secret && curl -fsSL https://core.telegram.org/getProxyConfig -o proxy-multi.conf && ./mtproto-proxy -u nobody -p 8888 -H ${PORT} -S \"${SECRET}\" --aes-pwd proxy-secret proxy-multi.conf -M ${WORKERS}"]
#EOF

cat > "$TEMP/Dockerfile" <<'EOF'
FROM debian:12-slim AS builder

RUN apt-get update && apt-get install -y \
    git curl build-essential libssl-dev zlib1g-dev

WORKDIR /opt

RUN git clone https://github.com/TelegramMessenger/MTProxy \
 && cd MTProxy \
 && make

#пересобираю в меньший размер

FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    curl libssl3 zlib1g \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/MTProxy/objs/bin

# копируем только бинарник
COPY --from=builder /opt/MTProxy/objs/bin/mtproto-proxy .

CMD ["/bin/sh", "-c", "curl -fsSL https://core.telegram.org/getProxySecret -o proxy-secret && curl -fsSL https://core.telegram.org/getProxyConfig -o proxy-multi.conf && ./mtproto-proxy -u nobody -p 8888 -H ${PORT} -S \"${SECRET}\" --aes-pwd proxy-secret proxy-multi.conf -M ${WORKERS}"]
EOF


docker build -t mtproxy "$TEMP"

docker rm -f mtproxy 2>/dev/null || true

#docker run -d \
#  --name mtproxy \
#  -e SECRET="$SECRET" \
#  -e PORT="$PORT" \
#  -e WORKERS="$WORKERS" \
#  -p "$PORT:$PORT" \
#  --restart unless-stopped \
#  mtproxy

docker run -d \
  --name mtproxy \
  --network host \
  -e SECRET="$SECRET" \
  -e PORT="$PORT" \
  -e WORKERS="$WORKERS" \
  -p "$PORT:$PORT" \
  --restart unless-stopped \
  mtproxy

rm -rf "$TEMP"

echo "Ждем 5 сек"
sleep 5

docker inspect -f '{{.State.Status}}' mtproxy 2>/dev/null | grep -q running \
  || show_error "Докер не запустился"

#добавляем рестарт каждые 6 часов чтобы подгрузились обновы конфигов с телеграма
(crontab -l 2>/dev/null | grep -v "docker restart mtproxy"; echo "0 */6 * * * /usr/bin/docker restart mtproxy") | crontab -

#docker run -d \
#  --name mtproxy \
#  -e SECRET="$SECRET" \
#  -e PORT=443 \
#  -p 443:443 \
#  -p 8888:8888 \
#  mtproxy

# base64 из EE
EE_B64=$(echo -n "$EE" | xxd -r -p | base64 | tr -d '\n')
EE_B64_URLSAFE=$(echo -n "$EE_B64" | tr '+/' '-_' | tr -d '=')

echo
echo "===== TG LINKS ====="
echo "Normal:"
echo "tg://proxy?server=$SERVER_IP&port=$PORT&secret=$SECRET"
echo
echo "Secure:"
echo "tg://proxy?server=$SERVER_IP&port=$PORT&secret=$DD"
echo
echo "Fake-TLS hex:"
echo "tg://proxy?server=$SERVER_IP&port=$PORT&secret=$EE"
echo
echo "Fake-TLS URL-safe base64:"
echo "tg://proxy?server=$SERVER_IP&port=$PORT&secret=$EE_B64_URLSAFE"
echo
echo "Fake-TLS base64:"
echo "tg://proxy?server=$SERVER_IP&port=$PORT&secret=$EE_B64"

echo
echo "===== HTTPS LINKS ====="
echo "Normal:"
echo "https://t.me/proxy?server=$SERVER_IP&port=$PORT&secret=$SECRET"
echo
echo "Secure:"
echo "https://t.me/proxy?server=$SERVER_IP&port=$PORT&secret=$DD"
echo
echo "Fake-TLS hex:"
echo "https://t.me/proxy?server=$SERVER_IP&port=$PORT&secret=$EE"
echo
echo "Fake-TLS URL-safe base64:"
echo "https://t.me/proxy?server=$SERVER_IP&port=$PORT&secret=$EE_B64_URLSAFE"
echo
echo "Fake-TLS base64:"
echo "https://t.me/proxy?server=$SERVER_IP&port=$PORT&secret=$EE_B64"


