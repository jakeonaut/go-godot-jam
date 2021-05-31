extends StaticBody

onready var player = get_tree().get_root().get_node("level").get_node("Player")
onready var textBoxContainer = get_node("TextContainer")
onready var textBox = get_node("TextContainer").get_node("TextBox")

enum State {
    BUG_NET = 0,
    ZORA_FLIPPERS = 1,
    SPRINT_BOOTS = 2,
    BUG = 3,
    MUSHROOM = 4,
}

export var state = State.BUG_NET

func _ready():
    pass

func isActive():
    return visible

func passiveActivate(delta):
    getItem()

func getItem():
    if state == State.BUG_NET:
        player.getBugNet()
    elif state == State.ZORA_FLIPPERS:
        player.getZoraFlippers()
    elif state == State.SPRINT_BOOTS:
        player.getSprintBoots()
    elif state == State.MUSHROOM:
        player.getMushroom()

    visible = false
    if global.activeInteractor == null:
        global.activeInteractor = textBox
        textBox.interact()