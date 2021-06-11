extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    var npc = get_node("../../..")
    npc.try_to_forget = true
    npc.textBox = npc.get_node("TextContainerTeachJump/TextBox")

func isActive():
    # OVERRIDE ME... if you dare
    return true