<<<<<<< HEAD
﻿Windows Store Parser парсит отзывы пользователей (имя, рейтинг и комментарий).\n
Если что то не указано то заменяется словом "Не указан".\n
Чтобы добавить другие языки (по умолчанию поддерживаются Русский и Английский) настройте Windows Store на нужный язык, затем вытаскивайте ссылку на нужный xml через прокси Fiddler.\n
Launcher.sh - необходим для запуска по крону с сохранением переменной окружения пользователя (по умолчанию root).\n
Все настройки задаются непосредственно в скрипте wsp.pl.\n
=======
#Windows Store Parser
Парсит отзывы пользователей (имя, рейтинг и комментарий).  
Если что то не указано то заменяется словом "Не указан".  
Чтобы добавить другие языки (по умолчанию поддерживаются Русский и Английский) настройте Windows Store на нужный язык, затем вытаскивайте ссылку на нужный xml через прокси Fiddler (http://www.telerik.com/fiddler).  
Launcher.sh - необходим для запуска по крону с сохранением переменной окружения пользователя (по умолчанию root).  
Все настройки задаются непосредственно в скрипте wsp.pl.  
Пример запуска по крону:  
1. * */1 * * * /root/bin/launcher.sh parse - парсим комментарии один раз в час  
2. 0 11 * * * /root/bin/launcher.sh send - отправляем комментарии один раз в сутки
>>>>>>> origin/master
