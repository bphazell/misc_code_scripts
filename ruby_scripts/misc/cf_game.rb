# Working at CrowdFlower game
# to play, type "ruby cf_game.rb" into your Terminal

require_relative 'cf_game_reqs'

class Mission_St
	def initialize
		puts "It's 9:29am. You've just arrived at 2111 Mission St., home of"
	    puts "Thrift Town, Fabric Outlet, and most importantly, CrowdFlower,"
	    puts "which is where you work. You're almost late for a call with a"
	    puts "very important client, Thomson Reuters. They're so important that"
	    puts "your company pays them $20,000 a week to do their work for them."
	    puts "Although you're almost late you have to enter the secret code"
	    puts "to unlock the front door. The code is 4 digits. The first number"
	    puts "is 2, but the landlord changes the code so often you can't quite"
	    puts "remember the rest..."
	    code = "2%s%s%s" % [rand(9)+1, rand(9)+1, rand(9)+1]
	    cheat = "2222"
	    print "[keypad]> "
	    guess = gets.chomp()
	    guesses = 1

	    while guess != code and guess != cheat and guesses < 5
	      puts "BZZZZEDDD! Try again.... Hint, try #{cheat}."
	      puts "Or not, if you want to see what happens..."
	      guesses += 1
	      print "[keypad]> "
	      guess = gets.chomp()
	    end

	    if guess == code or guess == cheat
	      puts "The door beeps and unlocks, allowing you to push past the drunk flies"
	      puts "in the entryway and go up to the 3rd floor, CrowdFlower HQ."
	      puts "------------------------"
		  return ::Reception.new
	    else
	      puts "After 5 guesses, the landlord lumbers to the door and"
	      puts "calls the police. When the police arrive, they pick you up"
	      puts "and take you to a cell with a bunch of crack heads."
	      puts "------------------------"
	      return ::Jail.new
	    end
	end
end

class Jail
	def initialize
		puts "Because Thomson Reuters is such an important client, you"
	    puts "still call in to the meeting, 30 minutes late. However, a crack"
		puts "head grabs your phone and farts into it. TR is so insulted"
		puts "that they take their business elsewhere. You enjoy the rest of"
		puts "the day and night in jail, finally at peace. Eventually, your CEO"
		puts "comes by to bail you out using the money you saved the"
		puts "company by getting rid of TR. He immediately promotes you and"
		puts "gives you a raise for thinking outside the box while in the box."
		puts "Congratulations! You won!"
		Process.exit(0)
	end
end

class Reception
	def initialize
		puts "The meeting is in Oak, so you walk through to the main office and"
		puts "veer to the right. As you're reaching for the door knob, you can hear"
		puts "your colleague listening to the hold music and singing along. All of"
		puts "a sudden the receptionist calls out to you, 'Hello? Do you know how to remove"
		puts "staples from paper?' What do you say?"

		$new_game.prompt()
		action = gets.chomp()

		if action == "nothing"
			puts "You pretend to not hear, and enter the room."
			puts "------------------------"
			return ::Oak.new
		elsif action == "google it"
			puts "You tell her to Google it before ducking into the room,"
			puts "hoping she doesn't follow."
			puts "------------------------"
			return ::Oak.new
		elsif action == "staple remover"
			puts "After telling her to use a staple remover, the receptionist"
			puts "asks how, so you go help her find it and demonstrate"
			puts "its use. However, as soon as you show her how to do that, she"
			puts "asks you to show her how to Safari. You sigh, and grab a chair."
			puts "------------------------"
			return ::Reception.new
		else
			puts "------------------------"
			puts "CHOOSE FROM 1) 'nothing', 2) 'google it', and 3) 'staple remover'."
			puts "------------------------"
			return ::Reception.new
		end
	end
end

class Oak
	def initialize
		puts "The room is dark, faintly musty and smelling of stale Bi-Rite. You"
		puts "stand for a moment allowing your eyes to adjust as your colleague"
		puts "clears their throat, as if they weren't just belting out a tune."
		puts "When your eyes have adjusted somewhat you realize it isn't your colleague"
		puts "sitting there, but your CEO. You immediately say 'Oh. Sorry!'"
		puts "and get out of there as quick as you can. He can be a weird guy, you know."
		puts "------------------------"
		return ::Sycamore.new
	end
end


class Sycamore
	def initialize
		puts "Running past Reception you look wildly around for the room the call"
		puts "is now in. An out-of-control beard attached to the gnarliest set of"
		puts "white-person dreads you've ever seen catches your attention. Ah, there's"
		puts "Jeff, the only good thing about this TR madness. You enter Sycamore,"
		puts "and hunker down for the call. Our Polish counterpart is on the line"
		puts "and discussing plans on completely re-doing all of CrowdFlower technology"
		puts "to fit the needs of TR. Our contact in Denver aggrees and asks whether"
		puts "it can be done by EOD. Jeff is nodding and singing 'One Love'. How should"
		puts "you respond?"

		$new_game.prompt()
		action = gets.chomp()

		if action == "stupid"
			puts "You say, 'That's the stupidest idea I ever heard.' You can hear the"
			puts "Scottish contact turning purple and direct-dialing CrowdFlower's"
			puts "VP of RevOps. You get an email in your inbox within seconds:"
			puts "YOU'RE FIRED!"
			Process.exit()
		elsif action == "yes"
			puts "You say, 'Yes, definitely, end of day, no problem'. You proceed"
			puts "to file a million Jira tickets all with priority 'blocker'. 5 minutes"
			puts "later, the Enterprise Engineers enter the room, hang up the phone, and"
			puts "proceed to throw you out the window onto 17th street. A crack head finds"
			puts "your twitching body and starts to eat your brain."
			Process.exit()
		elsif action == "help"
			puts "You say, 'We are just a small company, however, if TR were to acquire us"
			puts "I'm sure we could get it done ASAP.' The Denver guy pauses for a moment"
			puts "and then says, 'Deal! We are wiring over 10 billion dollars now'. You log"
			puts "onto your checking account and see 9 zeros after your balance. You calmly"
			puts "shut the lid to your laptop, walk out the door, and buy one way tickets to"
			puts "Kauai where you spend the rest of your days. You win!"
			Process.exit()
		else
			puts "------------------------"
			puts "CHOOSE FROM 1) 'stupid', 2) 'yes', and 3) 'help'."
			puts "------------------------"
			return ::Sycamore.new
		end
	end
end

$new_game = Game.new(:Mission_St)
$new_game.play()