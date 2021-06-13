extends TextureRect

onready var text = get_node("Text")
onready var dialogSound = get_node("DialogSound")
onready var abortSound = get_node("AbortSound")
export(NodePath) var nextTextBoxPath = NodePath("")
onready var player = get_tree().get_root().get_node("level").get_node("Player")

var doubleClickTimer = 0
var doubleClickTimeMax = 6

var type = "textBox"

func _ready():
    self.hide()
    set_process_input(true)

func _input_event(camera, event, click_position, click_normal, shape_idx):
    if event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
        self.interact()

    if shape_idx:
        pass
    if camera:
        pass
    if click_position:
        pass
    if click_normal:
        pass

func _process(delta):
    if doubleClickTimer < doubleClickTimeMax:
        doubleClickTimer += delta*22

        
func InteractActivate():
    interact()
        
func interact():
    # dialogSound.isActive can be overridden
    if !visible and dialogSound.isActive():
        text.get_v_scroll().value = 0
        self.show()
        doubleClickTimer = 0
        dialogSound.play()
        dialogSound.activateScript()
        if has_node("Event"):
            get_node("Event").activate()
        global.pauseGame = true
        global.pauseMoveInput = true
        if player.glitch_form != player.GlitchForm.FLOOR: player.on_ground = true
        player.vv = 0
        player.is_lunging = 0
        player.should_i_sprint = false
        player.sprint_timer = 0
        player.walk_speed = 12
        player.just_tried_to_sprint = false
    elif doubleClickTimer >= doubleClickTimeMax:
        self.hide()
        global.pauseGame = false
        global.pauseMoveInput = false
        if !nextTextBoxPath.is_empty() and get_node(nextTextBoxPath):
            var nextTextBox = get_node(nextTextBoxPath)
            if nextTextBox and nextTextBox.type == "textBox":
                nextTextBox.interact()
            elif nextTextBox and nextTextBox.type == "textBoxContainer":
                nextTextBox = nextTextBox.get_node("TextBox")
                nextTextBox.interact()
            global.activeInteractor = nextTextBox
        else:
            abortSound.play()
            global.activeInteractor = null
            abortSound.activateScript()
            
func abort():
    hide()
    abortSound.play()
    global.activeInteractor = null
    global.pauseGame = false
    global.pauseMoveInput = false