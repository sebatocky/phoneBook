#PhoneBook
 https://github.com/sebatocky/phoneBook/

*Учебное приложение для обучения Ruby*

-(author: Denis Medik / Денис Медик)-
- - -
###ЦЕЛИ:
* Освоение синтаксиса и конструкций Ruby
* Знакомство с Ruby Standard Library
* Знакомство с принципами работы и архитектурой веб-приложений


###ОПИСАНИЕ:
Небольшая база данных для хранения записей о контактах. Идентификатором (уникальным) является имя контакта. Управление и пользовательский интерфейс из браузера.

###Структура проекта
	./data  - хранение данных записной книжки, файл данных
	./lib   - исходные коды, они же исполняемые файлы приложения
	./public - каталог для публичных ресурсов (*.css *.js)
	./tests - тесты
	./views - шаблоны html страниц

- - -
###Class PhoneBook (phoneBook.rb)
Инкапсуляция сущности "Записная книжка"

###ТРЕБОВАНИЯ:
	1. Сохранеие данных во внешнюю память (файл).
	2. Буферезация записи данных на диск.
	3. Веб-интерфейс для доступа и управления данными.

##ПРИМЕР:3	Пример типичной записи в книжку: {'Вася', "Телефон 8-812-527-34-12, пр. Стачек 108"}
<<<<<<< HEAD
	key: {"Вася": индекс "В", идентификатор: "Вася"} value: {"Телефон 8-812-527-34-12, пр. Стачек 108"}
=======

Реализация базовой функциональности записной книжки. Базовый интерфейс для сохранения и извлечения данных (CRUD):
* open()
* set(name, data)
* get(name)
* del(name)
* close()
- - -

###SERVER (server.rb)
Пользовательский веб-интерфейс для доступа и управления данными.

####ТРЕБОВАНИЯ:
	1. Доступ и манипуляция данными через HTTP (GET и POST)
	2. Использование шаблонов для формирования html (ERB)
	3. Простой и удобный пользовательский интерфейс

####ПРИМЕР:
	http://localhost:8088/ 
	http://localhost:8088/get
	http://localhost:8088/get?name=Вася

- - -
###P.S.
Проект не претендует на вершины мастерства или на реальную эксплуатацию, так как предназначен исключительно для целей обучения.