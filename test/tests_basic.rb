require 'test/unit'
require '../PhoneBook'

class Test_PhoneBook < Test::Unit::TestCase
	def setup
		@pb = PhoneBook.new
	end
	#-------------------------------------ОСНОВНАЯ ФУНКЦИОНАЛЬНОСТЬ------------------------------------{1}
	def test_01_init
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		assert_equal( 0, @pb.size, "Количество записей 0")
	end

	def test_02_add_data
		assert_not_nil( @pb, "Ссылка на объект не пустая")
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
		assert_equal( 2, n, "Счётчик итератора равен числу записей")
	end

	def test_07_exist?
		assert_not_nil( @pb, "Ссылка на объект не пустая")
		@pb.set("ТехПомощь1", "(911) 927-14-44")
		assert_equal(true, @pb.exist?("ТехПомощь1"), "Запись \"ТехПомощь\" существует")
	end
	#--------------------------------------------------------------------------------------------------{1}
	
end