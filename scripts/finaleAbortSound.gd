extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
	global.game_over = true
	# transition.long_fade_to("res://levels/empty_level.tscn")
	get_tree().quit()

func isActive():
    # OVERRIDE ME... if you dare
    return true