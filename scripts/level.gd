extends Spatial

onready var npc = get_node("NPC")

func _ready():
	global.pauseGame = false
	global.pauseMoveInput = false
	global.is_in_cutscene = false
	global.nightfallTimer = 0
	npc.activate()
