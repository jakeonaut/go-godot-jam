extends "Item.gd"

var animation_counter = 0
export var frame_delay = 0.4
# If true, this will override frame_delay after first frame change.
export var should_randomize_frame_delay = false

var is_active = true

onready var mySprite = get_node("Sprite3D")

func _ready():
    state = State.BUG
    set_process(true)

# @override
func isActive():
    return is_active and player.has_bug_net

# @override
func passiveActivate(delta):
    print(is_active)
    is_active = false
    getItem()

# @override
func getItem():
    global.numBugs += 1
    player.getBug()

    if global.activeInteractor == null:
        global.activeInteractor = textBox
        textBox.interact()

func preProcess():
    pass

func _process(delta):
    preProcess()
    animate(delta)

func animate(delta):
    animation_counter += delta
    if animation_counter >= frame_delay:
        animation_counter = 0
        var frame = mySprite.get_frame()

        mySprite.flip_h = not mySprite.flip_h
        
        if should_randomize_frame_delay:
            randomizeFrameDelay()

func randomizeFrameDelay():
    frame_delay = rand_range(0.1, 1.0)