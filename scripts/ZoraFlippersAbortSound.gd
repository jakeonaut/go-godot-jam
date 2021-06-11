extends AudioStreamPlayer

onready var npc = get_tree().get_root().get_node("level").get_node("NPC")

func _ready():
    pass

func activateScript():
    npc.textBox = npc.get_node("TextContainerPostHeronGrowth").get_node("TextBox")
    if global.activeInteractor != null:
        global.activeInteractor.interact()
    global.activeInteractor = npc.textBox
    npc.textBox.interact()

func isActive():
    # OVERRIDE ME... if you dare
    return true