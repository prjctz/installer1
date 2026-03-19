# installer MTProxy
# Debian 12

##Скрипт собирает в докер из исходников [https://github.com/TelegramMessenger/MTProxy](https://github.com/TelegramMessenger/MTProxy)

### Полный пример
`bash <(wget -qO- https://raw.githubusercontent.com/prjctz/installer1/refs/heads/main/install.sh) --port=443 --ip=203.0.113.10 --domain=google.com --workers=1`

 ### Это
`bash <(wget -qO- https://raw.githubusercontent.com/prjctz/installer1/refs/heads/main/install.sh) --port=443`

 ### Мануал
`bash <(wget -qO- https://raw.githubusercontent.com/prjctz/installer1/refs/heads/main/install.sh) --help`

Протестировал работает, все разворачивается, при перезагрузке все поднимается.
Выдает прокси 3-х уровней:
1. обычный
2. защищенный
3. fake tls - у меня он не подключился в андроиде, код правильный, ищем причину вместе

##fake tls формат не заработает, его реализации нет в исходниках от телеграма
