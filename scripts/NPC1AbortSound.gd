extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    var NPC = get_node("../../..")
    NPC.textBox = NPC.get_node("TextContainerTeachJump/TextBox")

func isActive():
    # OVERRIDE ME... if you dare
    return true