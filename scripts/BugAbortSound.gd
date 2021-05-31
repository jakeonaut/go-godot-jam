extends AudioStreamPlayer

onready var bug = get_node("../../..")
onready var player = get_tree().get_root().get_node("level").get_node("Player")

func _ready():
    pass

func activateScript():
    if bug.mySprite.frame == 4: #hercules beetle fairy
        player.has_double_jump = true
    if bug.mySprite.frame == 5: #wisteria smiling dragonfly
        player.has_lunge_jump = true
    if bug.mySprite.frame == 7: # water sprinter
        player.has_water_sprint = true
    bug.visible = false
    bug.is_active = false

func isActive():
    # OVERRIDE ME... if you dare
    return true