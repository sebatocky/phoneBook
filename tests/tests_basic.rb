require 'test/unit'
require '../src/PhoneBook'

class Test_PhoneBook < Test::Unit::TestCase
	def setup
		@pb = PhoneBook.new
	end
	#-------------------------------------ОСНОВНАЯ ФУНКЦИОНАЛЬНОСТЬ------------------------------------{1}
	def test_01_init
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		assert_equal( true, @pb.is_available, "Открыта - доступна")
		assert_equal( 0, @pb.size, "Количество записей 0")
	end

	def test_02_add_data
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		assert_raise(ArgumentError) {@pb.set("", "")}
		@pb.set("ТехПомощь", "(911) 927-14-44")
		assert_equal( 1, @pb.size, "Количество записей 1")
		assert_equal( "(911) 927-14-44", @pb.get("ТехПомощь"), "Данные записи с именем \"ТехПомощь\"")
	end

	def test_03_delete_data
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		@pb.set("ТехПомощь", "(911) 927-14-44")
		assert_equal( 1, @pb.size, "Количество записей 1")
		@pb.del("ТехПомощь")
		assert_equal( 0, @pb.size, "Количество записей 0")
		@pb.set("НоваяЗапись", "927-14-44")
		@pb.del("НеСуществующаяЗапись")
		assert_equal( 1, @pb.size, "Количество записей 1")
	end

	def test_04_update_data
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		@pb.set("ТехПомощь", "(911) 927-14-44")
		@pb.set("ТехПомощь", "(911) 927-44-15")
		assert_equal( "(911) 927-44-15", @pb.get("ТехПомощь"), "Обновлённые данные записи с именем \"ТехПомощь\"")
	end

	def test_05_clear_data
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		@pb.set("ТехПомощь1", "(911) 927-14-44")
		@pb.set("ТехПомощь2", "(911) 927-44-15")
		assert_equal( 2, @pb.size, "Количество записей 2")
		@pb.clear
		assert_equal( 0, @pb.size, "Количество записей 0")
	end

	def test_06_iterator_each
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		@pb.set("ТехПомощь1", "(911) 927-14-44")
		@pb.set("ТехПомощь2", "(911) 927-44-15")
		n = 0
		@pb.each {n +=1 }
		assert_equal( @pb.size, n, "Счётчик итератора равен числу записей")
	end

	def test_07_exist?
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		@pb.set("ТехПомощь1", "(911) 927-14-44")
		assert_equal(true, @pb.exist?("ТехПомощь1"), "Запись \"ТехПомощь\" существует")
	end
	
	def test_08_data_normal
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		@pb.set("  вася  ", "   (921) 927-08-08   ")
		assert_equal(true, @pb.exist?("Вася"), "Запись \"Вася\" существует")
		assert_equal( "(921) 927-08-08", @pb.get("вася"), "Данные нормализуются")
		assert_equal( "(921) 927-08-08", @pb.get(" Вася"), "Данные нормализуются")

		test_string = ""
		('a'..'z').each {|ch| test_string += ch}
		('0'..'9').each {|ch| test_string += ch.to_s}
		('A'..'Z').each {|ch| test_string += ch}
		test_string += "()- ?!#$@+"
		test_string += test_string * 3

		@pb.set(test_string, test_string)
		assert_equal( test_string[0...80], @pb.get(test_string[0...35]), "Данные нормализуются")
	end

	def test_09_save_file
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		@pb.set("А_Запись1", "1"*10)
		@pb.set("В_Запись2", "2"*10)
		@pb.set("Б_Запись3", "3"*10)
		@pb.set("В_Запись4", "4"*10)
		@pb.set("Г_Запись5", "5"*10)
		@pb.set("Д_Запись6", "6"*10)
		@pb.set("E_Запись7", "7"*10)
		@pb.set("А_Запись8", "8"*10)
		@pb.set("1_Запись9", "9"*10)
		@pb.dump("test.txt")
		@pb.close
		line_count = 0
		File.open("test.txt", 'r:utf-8') do |data_file|
			while line = data_file.gets
	  			line_count += 1
	  		end
		end
		@pb.open()
		assert_equal(line_count, @pb.size, "Количество записей равно количеству строк в файле")
		
		if File.exist?("test.txt")
			File.delete("test.txt")
		end
		
		if File.exist?("data.txt")
			File.delete("data.txt")
		end
	end
	#--------------------------------------------------------------------------------------------------{1}

end