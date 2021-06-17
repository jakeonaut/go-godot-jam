extends Spatial

onready var player = get_node("Player")

func _ready():
    global.pauseGame = false
    global.pauseMoveInput = false
    global.is_in_cutscene = false
    player.getCamera().rotate_down()
