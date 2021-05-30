extends "Item.gd"

onready var NPC = get_tree().get_root().get_node("level").get_node("NPC")

func _ready():
    state = State.BUG_NET

func activate():
    getItem()
    NPC.textBox = NPC.get_node("TextContainer2").get_node("TextBox")