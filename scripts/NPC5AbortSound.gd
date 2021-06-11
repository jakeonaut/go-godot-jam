extends "AbortSound.gd"

onready var npc5 = get_node("../../..")

func activateScript():
    npc5.textBox = npc5.get_node("TextContainer/TextBox")