extends "Item.gd"

onready var npc = get_tree().get_root().get_node("level").get_node("NPC")
onready var heronbaby = get_tree().get_root().get_node("level").get_node("heronbaby")
onready var heronbaby3 = get_tree().get_root().get_node("level").get_node("heronbaby3")

func _ready():
    state = State.ZORA_FLIPPERS

# @override
func passiveActivate(delta):
    .passiveActivate(delta)
    global.startTimer = true
    npc.textBox = npc.get_node("TextContainer6").get_node("TextBox")

    # if heronbaby.state == 5 or heronbaby.state == 6 or heronbaby.state == 7:
    #     heronbaby3.setNewFlightTarget(Vector3(-24, 32, -46))
    # else:
    #     heronbaby.setNewFlightTarget(Vector3(-24, 32, -46))