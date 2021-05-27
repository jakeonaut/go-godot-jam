extends "PlayerGameMover.gd"

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0

var interact_charge_timer = 0
var interact_charge_time_max = 20

onready var startChargeSound = get_node("Sounds/StartChargeSound")
onready var fullChargeSound = get_node("Sounds/FullyChargedSound")
onready var slowDownSound = get_node("Sounds/SlowDownSound")
var sprint_timer = 0
var sprint_time_max = 40

func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)
    
func _process(delta):
    # ._process(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500

    #if Input.is_action_just_pressed("ui_interact"):
    #    cameraFlash.flash()

    if Input.is_action_just_pressed("ui_accept") and not global.pauseMoveInput:
        if not global.pauseGame:
            global.pauseGame = true
        else:
            global.pauseGame = false

    if Input.is_action_pressed("ui_interact") and not global.activeThrowableObject and sprint_timer < sprint_time_max:
        if Input.is_action_just_pressed("ui_interact") and not startChargeSound.playing:
            startChargeSound.play()

        if startChargeSound.playing:
            walk_speed = 1
        else:
            if walk_speed == 1:
                fullChargeSound.play()
                sprint_timer = 0
            walk_speed = 21
            sprint_timer += (delta*22)
    else:
        if walk_speed == 21:
            slowDownSound.play()
        if slowDownSound.playing:
            walk_speed = 2
        else:
            walk_speed = 12
        if not Input.is_action_pressed("ui_interact") or global.activeThrowableObject:
            sprint_timer = 0

    # if Input.is_action_just_pressed("ui_action") and on_ground and not global.pauseMoveInput and not global.pauseGame:
    #     is_rolling = true
    #     rolling_timer = 0
    #     is_rotating = true


    tryRotateCamera(delta)

    if global.pauseGame: return

    # if not is_walking:
    #     sprite_reset_timer += delta
    #     if sprite_reset_timer >= sprite_reset_limit and not mySprite.isFacingDown():
    #         mySprite.faceDown()
    # else:
    #     sprite_reset_timer = 0

func _physics_process(delta):
    # ._process_physics(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500
    pass

func tryRotateCamera(delta):
    # if not Input.is_action_pressed("ui_ctrl"):
    if Input.is_action_pressed("ui_rotate_left"):
        cameraRotationCounter += delta
        getCamera().rotate_left((delta*66)+(cameraRotationCounter*36))
    elif Input.is_action_pressed("ui_rotate_right"):
        cameraRotationCounter += delta
        getCamera().rotate_right((delta*66)+(cameraRotationCounter*36))
    else: cameraRotationCounter = 0
    # elif Input.is_action_pressed("ui_ctrl"):
    #     if Input.is_action_just_pressed("ui_rotate_left"):
    #         getCamera().rotate_left_90deg()
    #     elif Input.is_action_just_pressed("ui_rotate_right"):
    #         getCamera().rotate_right_90deg()
        
    if cameraRotationCounter > 1: cameraRotationCounter = 1
    
    if Input.is_action_pressed("ui_rotate_up"):
        getCamera().rotate_up(3*(delta*66))
    if Input.is_action_pressed("ui_rotate_down"):
        getCamera().rotate_down(3*(delta*66))

    if Input.is_action_just_pressed("ui_focus_next"):
        getCamera().toggleNext()
    if Input.is_action_just_pressed("ui_focus_forward"):
        getCamera().focusForward(facing)

func faceDown():
    mySprite.faceDown()

func tryEmptyInteract():
    pass    
