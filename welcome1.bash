#! /bin/bash/

function welcome1()
{
	 # Arrays of random messages
	RANDARRAYONE=(		"Don't hit the keys so hard! It hurts!"
				"Think honk if you're a telepath."
				"Of all the things I've ever lost, I miss my mind the most."
				"I am not the Lorax. I speak only for myself."
				"I will acknowledge rewards for they are my due; yet I will welcome obstacles for they are my challenge."
				"If you want me to fall for you, ${username:-Guest}, you better give me something worth tripping for.")

	RANDARRAYTWO=(		"Flitter flutter in the air, How I wonder why you're there? Chasing bats is not much fun - The worst is when you're killed by one."
				"See that funny little man, Try and catch him if you can. Quickly now! That's too slow - Where did all your money go?"
				"Think again before you try, to impale a floating eye. If you miss it with your sword, You may soon be very bored."
				"If a 'goblin (hob) waylays you, slice him up before he slays you. Nothing makes you look a slob, Like running from a hob'lin (gob)."
				"One big monster, he called troll. He don't rock and he don't roll, Drink no wine and smoke no stogies; He just love to eat them roguies.")

	RANDARRAYTHREE=(	"One man's constant is another man's variable."
				"Everything should be built top-down, except the first time."
				"If a listener nods his head when you're explaining your program, wake him up."
				"A language that doesn't affect the way you think about programming, is not worth knowing."
				"To understand a program you must become both the machine and the program."
				"Simplicity does not precede complexity, but follows it."
				"There are two ways to write error-free programs; only the third one works."
				"In software systems, it is often the early bird that MAKES the worm."
				"The best book on programming for the layman is Alice in Wonderland; but that's because it's the best book on anything for the layman."
				"Fools ignore complexity. Pragmatists suffer it. Some can avoid it. Geniuses remove it."
				"When we write programs that LEARN, it turns out that we do and they don't."
				"If your computer speaks English, it was probably made in Japan."
				"Don't have good ideas if you aren't willing to be responsible for them."
				"Dealing with failure is easy: Work hard to improve. Success is also easy to handle: You've solved the wrong problem. Work hard to improve.")

	WITTYARRAY=(		"Welcome, ${username:-Guest}! I'm the friendly terminal here to brighten your day."
				"Hi ${username:-Guest}, remember: the only thing worse than a bug is a feature that works too well."
				"Good to see you again, ${username:-Guest}! Let's make today less buggy and more productive."
				"Hello, ${username:-Guest}! Procrastination isn't bad if you start tomorrow."
				"Greetings, ${username:-Guest}! Did you know debugging is like being the detective in a crime movie where you are also the murderer?"
				"Welcome back, ${username:-Guest}! Don't worry, my circuits are as sharp as your coffee."
				"Hey there, ${username:-Guest}! Did you hear about the computer that crossed the road? It wanted to fetch the other side!"
				"Hi ${username:-Guest}! Remember, a little progress each day adds up to big results."
				"Hello, ${username:-Guest}! They say to 'think outside the box,' but I'm perfectly happy here in this terminal."
				"Hi ${username:-Guest}, let's make some magic happen—assuming you brought your wand.")

	# Dynamic selection from arrays
	randline1=${RANDARRAYONE[RANDOM % ${#RANDARRAYONE[@]}]}
	randline2=${RANDARRAYTWO[RANDOM % ${#RANDARRAYTWO[@]}]}
	randline3=${RANDARRAYTHREE[RANDOM % ${#RANDARRAYTHREE[@]}]}
	wittyline=${WITTYARRAY[RANDOM % ${#WITTYARRAY[@]}]}

	# Arrays for time-specific greetings
	EARLYARRAY=(		"Have you gotten a life yet, ${username:-Guest}?"
				"It's really VERY late!"
				"Got insomnia, ${username:-Guest}?"
				"Why are you waking me up, ${username:-Guest}?"
				"Getting an early start on the day?"
				"Do you realize what time it is, ${username:-Guest}?"
				"You probably shouldn't be drinking coffee at this time of day, ${username:-Guest}.")

	MORNARRAY=(		"Whatever food, news, or images you internalize in the morning, will define the energy and perspective of your day. Choose wisely, ${username:-Guest}."
				"Good morning, ${username:-Guest}!"
				"Have a great morning, ${username:-Guest}!"
				"This is the beginning of a fine day."
				"Have you had your coffee yet this morning?"
				"Have a great day!")

	LUNCHARRAY=(		"It's lunchtime!"
				"Are you going to eat something or just keep typing?"
				"I hope you remembered to bring a lunch today."
				"Go have a cup of coffee, ${username:-Guest}, and then get back to work refreshed.")

	AFTERARRAY=(		"Good afternoon, ${username:-Guest}!"
				"This looks like a great afternoon!"
				"Now that you've had a byte to eat, stop pounding on my keys so hard."
				"Welcome back, ${username:-Guest}."
				"Have you had your afternoon cup of coffee yet, ${username:-Guest}?")

	EVEARRAY=(		"Good evening, ${username:-Guest}!"
				"How did your day go today?"
				"I hope you are feeling well this evening."
				"Did you have a good day today, ${username:-Guest}?")

	RANDARRAY=(		"$randline1" "$randline2" "$randline3")

    # Determine the current hour
	hour=$(date +"%H")
	hour=$((10#$hour)) # Forces the interpretation of $hour as a decimal number

    # Select appropriate greeting
	if (( hour >= 0 && hour < 7 )); then
		welcomeline=${EARLYARRAY[RANDOM % ${#EARLYARRAY[@]}]}
	elif (( hour >= 7 && hour < 12 )); then
		welcomeline=${MORNARRAY[RANDOM % ${#MORNARRAY[@]}]}
	elif (( hour >= 12 && hour < 13 )); then
		welcomeline=${LUNCHARRAY[RANDOM % ${#LUNCHARRAY[@]}]}
	elif (( hour >= 13 && hour < 16 )); then
		welcomeline=${AFTERARRAY[RANDOM % ${#AFTERARRAY[@]}]}
	elif (( hour >= 16 && hour < 20 )); then
		welcomeline=${EVEARRAY[RANDOM % ${#EVEARRAY[@]}]}
	else
		welcomeline=${RANDARRAY[RANDOM % ${#RANDARRAY[@]}]}
	fi

	# Display the selected greeting
	if (( RANDOM % 2 == 0 )); then
		echo -e "$welcomeline"
	else
		echo -e "$wittyline"
	fi
}
