extends AudioStreamPlayer

func _ready():
    pass

func activateScript():
    global.startTimer = true

func isActive():
    # OVERRIDE ME... if you dare
    return true