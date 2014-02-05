# coding: utf-8
# author: Denis Medik / Денис Медик

require "unicode" #для операции над строками(крилица)

class PhoneBook
=begin
----------------------------------------------------------------------------------------
ОПИСАНИЕ:
Небольшая учебная база данных для хранения записей о контактах. Идентификатором (уникальным) является имя контакта

ТРЕБОВАНИЯ:
	1) Сохранеие данных во внешнюю память (файл)
	2) Индексирование данных по разделам (индексы по буквам алфавита от "А...Я")
	3) буферезация записи данных на диск
	
ПРИМЕР:
	Пример типичной записи в книжку: {'Вася', "Телефон 8-812-527-34-12, пр. Стачек 108"}
		key: {"Вася": индекс "В", идентификатор: "Вася"}
		value: {"Телефон 8-812-527-34-12, пр. Стачек 108"}
TODO

----------------------------------------------------------------------------------------	
=end
	# ПЕРЕМЕННЫЕ КЛАССА 
	@@max_size = 100 # максимальное количество записей в книжке
	@@key_length = 35 # ограничение на размер ключа
	@@data_length = 80 # ограничение на размер данных
	@@buffer_size = 5 # размер буфера (количество операций до сохранения данных на диск)
	#-------------------------------------------------------------------------------------------
	def initialize (file_name = "data.txt")
		record = lambda{|h,k| h[k] = Hash.new(&record)}
		@pages = Hash.new(&record) # хранит разделы записной книжки, каждый раздел хранит свои записи
		@transaction_counter = 0
		self.open
	end
	#-------------------------------------------------------------------------------------------
	# ИНТЕРФЕЙС
	def open
		begin
			if self.size == 0
				self.load_from_file()
			else
				raise "PhoneBook is already open!"
			end
		rescue RuntimeError => error
			puts error.message 
			puts error.backtrace
		end
	end

	def close
		self.dump()
		self.clear
	end

	def set(key,data) # добавить / обновить запись
		raise "\"key\" must be a String" unless key.kind_of? String
		raise "\"data\" must be a String" unless data.kind_of? String
		begin
			key = PhoneBook.get_normal_name(key)
			index = PhoneBook.index_by_name(key)
			if self.exist?(key, index) # udate
				@pages[index][key]= PhoneBook.get_normal_data(data)
			else
				if self.size < @@max_size # add
					@pages[index][key]= PhoneBook.get_normal_data(data)
					self.commit
				else
					raise "PhoneBook overflow!"
				end
			end
		rescue RuntimeError => error
			puts error.message 
			puts error.backtrace
		end
	end
	alias  []= set

	def get(key) # получить запись
		raise "\"key\" must be a String" unless key.kind_of? String
		key = PhoneBook.get_normal_name(key)
		index = PhoneBook.index_by_name(key)
		return self.exist?(key, index) ? @pages[index][key] : nil
	end
	alias  [] get

	def del(key) # удалить запись
		raise "\"key\" must be a String" unless key.kind_of? String
		key = PhoneBook.get_normal_name(key)
		index = PhoneBook.index_by_name(key)
		if self.exist?(key, index) 
			@pages[index].delete(key)
			self.commit
		end
	end

	def each(&block) #итератор
		@pages.each {|index, page| page.each(&block)}
	end

	def size
		size = 0
		@pages.each {|index, page| size += page.size}
		return size
	end

	def clear
		@pages.clear
	end

	def exist?(key, index = nil)
		raise "\"key\" must be a String" unless key.kind_of? String
		key = PhoneBook.get_normal_name(key)
		index = index != nil ? index : PhoneBook.index_by_name(key)
		if @pages.has_key?(index) 
			if @pages[index].has_key?(key) 
				return true
			end
		end
		return false
	end

	def dump(file_name = "data.txt")
		# формат: {хэш=>[name, data]}
		begin
			File.open(file_name, 'w:utf-8') do |data_file|
				self.each do |record| 
					data = "[\""+record[0]+"\",\""+record[1]+"\"]"
					data_hash = PhoneBook.hash_by_string(data) #!!!
					data_file.puts("{"+data_hash+"=>"+data+"}")
				end
			end
		rescue 
			puts error.message 
			puts error.backtrace
		end
	end

	#-------------------------------------------------------------------------------------------
	protected
	def load_from_file(file_name = "data.txt")
		begin
			self.clear
			if File.exist?(file_name)
				File.open(file_name, 'r:utf-8') do |data_file|
					while line = data_file.gets
	  					parse_data = line.scan(/^\{(?:(\d+)=>)([^\{]+)\}$/) # проверка данных на соответсвие формату dump() через RegExp
	  					if parse_data.size == 1
	  						if parse_data[0][0] == PhoneBook.hash_by_string(parse_data[0][1]) # хэши равны, значит записи не изменялись
	  							data = parse_data[0][1].scan(/"(.*?)"/)
	  							if data.size == 2
	  							self.set(data[0][0], data[1][0])
	  							end
	  						end
	  					end
					end
				end
			end
		rescue 
			puts error.message 
			puts error.backtrace
		end
	end

	def commit
		@transaction_counter += 1
		if @transaction_counter > @@buffer_size
			self.dump("tmp.txt")
			@transaction_counter = 0
			
		end
	end
	#-------------------------------------------------------------------------------------------
	private
	def self.get_normal_name(name) # проверить и нормализовать
		# ограничим длину строки 35 символами (@@key_length), обрежем лишние пробелы, первый символ заглавная буква
		raise "\"name\" must be a String" unless name.kind_of? String
		normal_name = PhoneBook.replace_special_characters(name) # уберём служебные символы
		normal_name = Unicode::capitalize(normal_name.chomp.strip)
		if normal_name.length > @@key_length
		 	normal_name = normal_name[0...@@key_length] 
		end 
		
		return normal_name
	end

	def self.get_normal_data(data) # проверить и нормализовать
		# ограничим длину строки 80 символами (@@data_length), обрежем лишние пробелы
		raise "\"data\" must be a String" unless data.kind_of? String
		normal_data = PhoneBook.replace_special_characters(data) # уберём служебные символы
		normal_data = normal_data.chomp.strip
		if normal_data.length > @@data_length
		 	normal_data = normal_name[0...@@data_length] 
		end 

		return normal_data
	end

	def self.replace_special_characters(str)
		raise "\"str\" must be a String" unless str.kind_of? String
		str.gsub(/[\"\{\[\}\]=>]+/, " ")
		
	end

	def self.index_by_name(name)
		raise "\"name\" must be a String" unless name.kind_of? String
		Unicode::upcase(name.lstrip[0])
	end

	def self.hash_by_string(str)
		raise "\"str\" must be a String" unless str.kind_of? String
		# хэш = сумма кодов символов
		result = 0
		arr = str.codepoints
		arr.each {|char_code| result += char_code}
		return result.to_s	
	end

end
