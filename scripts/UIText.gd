extends RichTextLabel

var myText = "nighttime: 5:00    herons: 0/5    fish: 1/20    bugs: 0/4    shrooms: 0/10"
var finale_timer = 500

func _ready():
	pass

func _process(delta):
	if global.startTimer and not global.is_in_cutscene:
		get_node("..").visible = true

		if global.nightfallTimer >= finale_timer:
			global.pauseGame = true
			global.pauseMoveInput = true
			global.is_in_cutscene = true
			if global.nightfallTimer == finale_timer:
				transition.interrupt()
			transition.long_fade_to("res://levels/nighttimefinale.tscn")
		else:
			if not global.pauseGame:
				global.nightfallTimer += delta
				
			myText = "nightfall: " + str(round_to_dec(finale_timer - global.nightfallTimer, 0))
			if global.numHerons > 0:
				myText = myText + "    herons: " + str(global.numHerons) + "/5"
			if global.numFish > 0:
				myText = myText + "    fish: " + str(global.numFish) + "/20"
			if global.numBugs > 0:
				myText = myText + "    bugs: " + str(global.numBugs) + "/4"
			if global.numMushrooms > 0:
				myText = myText + "    shrooms: " + str(global.numMushrooms) + "/8"
			set_bbcode(myText)
	else:
		get_node("..").visible = false

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)