extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    var npc = get_node("../../..")
    npc.textBox = npc.get_node("TextContainerTeachJump/TextBox")

func isActive():
    # OVERRIDE ME... if you dare
    return true