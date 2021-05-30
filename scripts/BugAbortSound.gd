extends AudioStreamPlayer

onready var bug = get_node("../../..")

func _ready():
    pass

func activateScript():
    bug.visible = false
    bug.is_active = false

func isActive():
    # OVERRIDE ME... if you dare
    return true