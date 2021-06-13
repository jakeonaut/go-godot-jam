extends "AbortSound.gd"

onready var elderCatNpc = get_node("../../..")

func activateScript():
    elderCatNpc.textBox = elderCatNpc.get_node("TextContainer6/TextBox")