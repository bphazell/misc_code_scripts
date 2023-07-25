# CF game requirements

class Game

	def initialize(first_room)
		@first_room = first_room
	end

	def prompt()
		print "> "
	end

	def play()
    	next_room = @first_room
    	puts next_room.upcase

		while true
			puts "\n----------------"
			room = Object.const_get(next_room.to_s)
			next_room = room.new
		end
	end
end