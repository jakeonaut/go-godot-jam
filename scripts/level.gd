extends Spatial

onready var npc = get_node("NPC")

func _ready():
    npc.activate()
