extends TextureRect

var read_input = false
var read_mouse_sensitivity_input = false
var input_action_to_read = ""
var inputNodeToChange = null

var escHoldTimer = 0
var escHoldTimerMax = 40

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func _process(delta):
    if not global.pauseGame or read_input or read_mouse_sensitivity_input or global.activeInteractor != null:
        return

    if Input.is_action_pressed("ui_cancel"):
        escHoldTimer += (delta*22)
        if escHoldTimer >= escHoldTimerMax:
            get_tree().quit()
    else:
        escHoldTimer = 0

func erase_action_events(action_name):
    var input_events = InputMap.get_action_list(action_name)
    for event in input_events:
        InputMap.action_erase_event(action_name, event)

func startInputRead(action_name, nodeName, display_name):
    get_node("PressAKey").visible = true
    get_node("PressAKey/Text").bbcode_text = \
"              press any key \n            \n    (except enter or escape)\n   \n           to set the key for \n\n            " + display_name
    read_input = true
    input_action_to_read = action_name
    inputNodeToChange = get_node("InputControl/"+nodeName+"/Text")

func _input(ev):
    if not global.pauseGame or global.activeInteractor != null:
        read_input = false
        read_mouse_sensitivity_input = false
        return

    if read_mouse_sensitivity_input:
        if not ev.is_pressed():
            return

        var keyText = OS.get_scancode_string(ev.scancode)
        if keyText == "Escape" or keyText == "Enter" or keyText == "1" or keyText == "2" \
            or keyText == "3" or keyText == "4" or keyText == "5" or keyText == "6" \
            or keyText == "7" or keyText == "8" or keyText == "9" or keyText == "0":

            if keyText != "Escape" and keyText != "Enter":
                global.mouseSensitivity = int(keyText)
                get_node("InputControl/MouseSensitivityRect/Text").bbcode_text = keyText
            get_node("PressNumber").visible = false
            read_mouse_sensitivity_input = false
    elif read_input:
        if not ev.is_pressed():
            return

        var keyText = OS.get_scancode_string(ev.scancode)

        if keyText != "Escape" and keyText != "Enter":
            erase_action_events(input_action_to_read)
            var new_event = InputEventKey.new()
            new_event.set_scancode(ev.scancode)
            InputMap.action_add_event(input_action_to_read, new_event)
            inputNodeToChange.bbcode_text = keyText

        get_node("PressAKey").visible = false
        read_input = false
        input_action_to_read = ""
        inputNodeToChange = null
    else:
        if ev is InputEventMouseButton and ev.is_pressed(): # and ev.button_index == BUTTON_RIGHT:
            if ev.position.x > 141 and ev.position.x < 186 \
                and ev.position.y > 236 and ev.position.y < 278:
                startInputRead("ui_up", "MoveUpKeyRect", "MOVE FORWARD")
            if ev.position.x > 198 and ev.position.x < 235 \
                and ev.position.y > 237 and ev.position.y < 279:
                startInputRead("ui_left", "MoveLeftKeyRect", "MOVE LEFT")
            if ev.position.x > 248 and ev.position.x < 284 \
                and ev.position.y > 239 and ev.position.y < 279:
                startInputRead("ui_down", "MoveDownKeyRect", "MOVE DOWN")
            if ev.position.x > 301 and ev.position.x < 337 \
                and ev.position.y > 239 and ev.position.y < 279:
                startInputRead("ui_right", "MoveRightKeyRect", "MOVE RIGHT")
            if ev.position.x > 495 and ev.position.x < 610 \
                and ev.position.y > 239 and ev.position.y < 279:
                startInputRead("ui_jump", "JumpKeyRect", "JUMP")
            if ev.position.x > 142 and ev.position.x < 219 \
                and ev.position.y > 306 and ev.position.y < 343:
                startInputRead("ui_rotate_left", "MoveCameraLeftKeyRect", "ROTATE CAMERA LEFT")
            if ev.position.x > 237 and ev.position.x < 321 \
                and ev.position.y > 306 and ev.position.y < 343:
                startInputRead("ui_rotate_right", "MoveCameraRightKeyRect", "ROTATE CAMERA RIGHT")
            if ev.position.x > 336 and ev.position.x < 420 \
                and ev.position.y > 306 and ev.position.y < 343:
                startInputRead("ui_rotate_up", "MoveCameraUpKeyRect", "ROTATE CAMERA UP")
            if ev.position.x > 442 and ev.position.x < 531 \
                and ev.position.y > 306 and ev.position.y < 343:
                startInputRead("ui_rotate_down", "MoveCameraDownKeyRect", "ROTATE CAMERA DOWN")
            if ev.position.x > 495 and ev.position.x < 610 \
                and ev.position.y > 322 and ev.position.y < 412:
                startInputRead("ui_interact", "InteractKeyRect", "INTERACT/TALK")

            if ev.position.x > 287 and ev.position.x < 375 \
                and ev.position.y > 322 and ev.position.y < 412:
                get_node("PressNumber").visible = true
                read_mouse_sensitivity_input = true

        
# mouse sensitivity: (287, 375) - (322, 412)