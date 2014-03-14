# coding: utf-8
# author: Denis Medik / Денис Медик

require 'webrick' # подключаем веб сервер
require 'erb' # подключаем препроцессор
require './phoneBook' # подключаем класс PhoneBook

=begin
---------------------------------------------------------------------------------------- 
ОПИСАНИЕ:
Веб-интерфейс для записной книжки. Позволяет добавлять / удалять записи и просматривать содержимое из браузера.

ТРЕБОВАНИЯ:
	1) Просмотр данных из записной книжки
	2) Представление данных в виде html-страницы
	3) Манипуляция с данными записной книжки из таблицы

ПРИМЕР :
	http://localhost:8088/ 
	http://localhost:8088/get
	http://localhost:8088/get?name=Вася
=end

#------------------------------------------------------------------------------------------- 
# СЕРВЛЕТ
class PhoneBookServlet < WEBrick::HTTPServlet::AbstractServlet
	attr_accessor :name # для обращения к параметру внутри ERB-шаблона

	def do_GET (request, response) # обработка HTTP-запроса с типом GET
		result = nil
		case request.path
			when '/' # главная страница с данными записной книжки
				response.status = 200
				response.content_type = "text/html"
				index_html_template = IO.read('../views/index.html.erb') # шаблон для вывода главной страницы
				index_html_renderer = ERB.new(index_html_template.force_encoding("UTF-8"))
				response.body = index_html_renderer.result(binding) # возвращаем сгенерированный html
			when '/get' # поиск по имени
				@name = request.query["name"].force_encoding('utf-8')
				response.status = 200
				response.content_type = "text/html"
				search_html_template = IO.read('../views/search.html.erb') # шаблон для страницы поиска
				search_html_renderer = ERB.new(search_html_template.force_encoding("UTF-8"))
				response.body = search_html_renderer.result(binding) # возвращаем сгенерированный html
			else
			response.set_redirect(WEBrick::HTTPStatus::NotFound, '/') # не существующий адрес отправляем обратно на главную
		end
		
	end

	def do_POST(request, response)  # обработка HTTP-запроса с типом POST
	    result = nil
	    result = request.query["command"]
	    
	    case result
	    	when 'dump'
	    		$pb.dump
	    		response.set_redirect(WEBrick::HTTPStatus::Found, '/')
			when 'set'
				name = request.query["name"].force_encoding('utf-8')
				data = request.query["data"].force_encoding('utf-8')
				$pb.set(name, data) # обновили существующую запись
				response.set_redirect(WEBrick::HTTPStatus::Found, '/')
			when 'add'
				name = request.query["name"].force_encoding('utf-8')
				data = request.query["data"].force_encoding('utf-8')
				$pb.set(name, data) # добавили новую запись
				response.set_redirect(WEBrick::HTTPStatus::Found, '/')
			when 'del'
				name = request.query["name"].force_encoding('utf-8')
				$pb.del(name) # удалили запись
				response.set_redirect(WEBrick::HTTPStatus::Found, '/')
	    	else

			response.set_redirect(WEBrick::HTTPStatus::NotFound, '/')
	    end
	     
    end

end
#------------------------------------------------------------------------------------------- 
# создаём записную книжку
$pb = PhoneBook.new('../data/phonebook.txt') # то, что глобальная переменная это не хорошо! можно пропатчить SERVER?

# запуск экземпляра сервера на порту 8088
SERVER = WEBrick::HTTPServer.new(
	ServerName: 'PhoneBook',
	Port: 8088,
	BindAddress: 'localhost',
	DocumentRoot: '../public'
	)

SERVER.mount("/", PhoneBookServlet)
 
['INT', 'TERM'].each { |signal| trap(signal) {SERVER.shutdown} }
SERVER.start