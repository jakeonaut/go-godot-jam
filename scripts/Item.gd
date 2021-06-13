extends StaticBody

onready var player = get_tree().get_root().get_node("level").get_node("Player")
onready var textBox = get_node("TextContainer").get_node("TextBox")
onready var getMushroomSound = get_node("GetMushroomSound")

enum State {
    BUG_NET = 0,
    ZORA_FLIPPERS = 1,
    SPRINT_BOOTS = 2,
    BUG = 3,
    MUSHROOM = 4,
    LEGENDARY_UNDERWATER_SEAFISH = 5,
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
    elif state == State.LEGENDARY_UNDERWATER_SEAFISH:
        player.getSeaFish()

    visible = false
    if state != State.MUSHROOM and global.activeInteractor == null:
        global.activeInteractor = textBox
        textBox.interact()
    elif state == State.MUSHROOM:
        getMushroomSound.play()
