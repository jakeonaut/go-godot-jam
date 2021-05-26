extends "PlayerGameMover.gd"

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0

var interact_charge_timer = 0
var interact_charge_time_max = 20

onready var startChargeSound = get_node("Sounds/StartChargeSound")
onready var fullChargeSound = get_node("Sounds/FullyChargedSound")

func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)

    mySprite.setBugCatcherCostume()

func wearCostume(costume):
    if costume == "normal": 
        mySprite.setNormalClothes()
    elif costume == "moth": 
        mySprite.setMothCostume()
    elif costume == "bugcatcher": 
        mySprite.setBugCatcherCostume()
    elif costume == "cleric": 
        mySprite.setClericCostume()
        jumpSound = get_node("Sounds/JumpOverallsSound")
    elif costume == "luckycat": 
        mySprite.setLuckyCatCostume()
    elif costume == "nightgown": 
        mySprite.setNightgown()
    global.memory["player_costume"] = costume
    
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
