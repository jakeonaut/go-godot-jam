extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    transition.long_fade_to("res://levels/empty_level.tscn")

func isActive():
    # OVERRIDE ME... if you dare
    return true