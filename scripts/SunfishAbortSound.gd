extends AudioStreamPlayer

onready var player = get_tree().get_root().get_node("level").get_node("Player")

func _ready():
    pass

func activateScript():
	print("uh huh...")
	player.getCamera().rotateXTo(-30, false, false)
	player.getCamera().rotateTo(0, false, false)
	global.is_in_cutscene = false

func isActive():
    # OVERRIDE ME... if you dare
    return true