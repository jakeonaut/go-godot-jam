extends "Item.gd"

onready var NPC = get_tree().get_root().get_node("level").get_node("NPC")
onready var heronbaby = get_tree().get_root().get_node("level").get_node("heronbaby")
onready var heronbaby3 = get_tree().get_root().get_node("level").get_node("heronbaby3")

func _ready():
    state = State.ZORA_FLIPPERS

# @override
func passiveActivate(delta):
    .passiveActivate(delta)
    NPC.textBox = NPC.get_node("TextContainerZora").get_node("TextBox")

    if heronbaby.state == 0:
        heronbaby.setNewFlightTarget(Vector3(-24, 32, -46))
    elif heronbaby3.state == 0:
        heronbaby3.setNewFlightTarget(Vector3(-24, 32, -46))