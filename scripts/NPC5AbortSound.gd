extends "AbortSound.gd"

onready var NPC5 = get_node("../../..")

func activateScript():
    NPC5.textBox = NPC5.get_node("TextContainer/TextBox")