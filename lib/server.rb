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
# СЕРВЛЕТ: обслуживает клиентские запросы на стороне сервера
class PhoneBookServlet < WEBrick::HTTPServlet::AbstractServlet
	attr_accessor :name # для обращения к параметру внутри ERB-шаблона

	def do_GET (request, response) # обработка HTTP-запроса с типом GET
		result = nil
		case request.path
			when '/' # главная страница с данными записной книжки
				response.status = 200
				response.content_type = "text/html"
				response.body = TEMPLATES['index_html_renderer'].result(binding) # возвращаем сгенерированный html
			
			when '/get' # поиск по имени
				if request.query["name"]
					@name = request.query["name"].force_encoding('utf-8')
					response.status = 200
					response.content_type = "text/html"
					response.body = TEMPLATES['search_html_renderer'].result(binding) # возвращаем сгенерированный html
				end
			
			when '/404' # кастомизированная страничка 404
				response.content_type = "text/html"
				response.body = FILES['page_404_html']
				response.status = 404
			
			when /(.css)$/ # по типу файла, *.js и прочую статику аналогично
				response.content_type = "text/css"
				response.status = 200
				response.body = FILES[request.path]
				
			else
			response.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, '/404') # не существующий адрес отправляем обратно на главную

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
				name, data = nil
				name = request.query["name"].force_encoding('utf-8')
				data = request.query["data"].force_encoding('utf-8')
				if name && data
					$pb.set(name, data) # обновили существующую запись
					response.set_redirect(WEBrick::HTTPStatus::Found, '/')
				else
					raise WEBrick::HTTPStatus::Error
				end

			when 'add'
				name, data = nil
				name = request.query["name"].force_encoding('utf-8')
				data = request.query["data"].force_encoding('utf-8')
				if name && data
					$pb.set(name, data) # добавили новую запись
					response.set_redirect(WEBrick::HTTPStatus::Found, '/')
				else
					raise WEBrick::HTTPStatus::Error
				end

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

begin
	# ОКРУЖЕНИЕ
	FILES = Hash.new # чтобы лишний раз не перечитывать файлы
	FILES['index_html_template'] = IO.read('../views/index.html.erb').force_encoding('utf-8')
	FILES['search_html_template'] = IO.read('../views/search.html.erb').force_encoding('utf-8')
	FILES['page_404_html'] = IO.read('../public/html/404.html').force_encoding('utf-8')
	FILES['/css/main.css'] = IO.read('../public/css/main.css').force_encoding('utf-8')

	TEMPLATES = Hash.new # чтобы лишний раз не создавать объектов ERB.new
	TEMPLATES['index_html_renderer'] = ERB.new(FILES['index_html_template'])
	TEMPLATES['search_html_renderer'] = ERB.new(FILES['search_html_template'])

	# БИЗНЕС-ЛОГИКА
	$pb = PhoneBook.new('../data/phonebook.txt') # то, что глобальная переменная это не хорошо! можно пропатчить SERVER?

rescue 
	raise "Not initialized environment!"
	
end
# ВЕБ-СЕРВЕР
SERVER = WEBrick::HTTPServer.new(
	ServerName: 'PhoneBook',
	Port: 8088,
	BindAddress: 'localhost',
	DocumentRoot: '../public'
	)

SERVER.mount("/", PhoneBookServlet)
 
['INT', 'TERM'].each { |signal| trap(signal) {SERVER.shutdown} }
SERVER.start