extends "Item.gd"

onready var NPC = get_tree().get_root().get_node("level").get_node("NPC")

func _ready():
    pass

# @override
func passiveActivate(delta):
    .passiveActivate(delta)
    NPC.textBox = NPC.get_node("TextContainer2").get_node("TextBox")