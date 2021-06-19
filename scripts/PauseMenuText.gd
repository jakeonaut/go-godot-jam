extends RichTextLabel

var myText = ""
onready var player = get_tree().get_root().get_node("level").get_node("Player")

func _ready():
    pass

func _process(delta):
    if global.pauseGame and not global.pauseMoveInput and not global.is_in_cutscene:
        get_node("..").visible = true

        myText = "welcome to summer islands.  take a break :)\n\npress enter to unpause    hold ESC to quit\n\n"
        if player.has_zora_flippers:
            myText = myText + "swim in the water by moving and jumping\n"


        
        set_bbcode(myText)
    else:
        get_node("..").visible = false