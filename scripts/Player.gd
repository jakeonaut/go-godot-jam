extends "PlayerGameMover.gd"

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0

var interact_charge_timer = 0
var interact_charge_time_max = 20

onready var itemGetSound = get_node("Sounds/ItemGetSound")
onready var startChargeSound = get_node("Sounds/StartChargeSound")
onready var fullChargeSound = get_node("Sounds/FullyChargedSound")
onready var slowDownSound = get_node("Sounds/SlowDownSound")
onready var errorSound = get_node("Sounds/ErrorSound")
onready var splashSound = get_node("Sounds/SplashSound")
onready var growthSound = get_node("Sounds/GrowthSound")

onready var animationPlayer = get_node("AnimationPlayer")

onready var drownedTextbox = get_node("TextBoxes/DrownedTextContainer/TextBox")
onready var zoraDrownedTextbox = get_node("TextBoxes/ZoraDrownedTextContainer/TextBox")

var has_bug_net = false
var has_sprint_boots = false
var playerWithBugNetTex = load("res://assets/sprites/player_sheet.png") 
var bugCounter = 0

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

    if has_sprint_boots:
        var sprint_speed = 26
        if ((Input.is_action_pressed("ui_interact") and sprint_timer == 0) or (sprint_timer != 0 and sprint_timer < sprint_time_max)) and not global.activeThrowableObject:
            if Input.is_action_just_pressed("ui_interact") and not startChargeSound.playing:
                startChargeSound.play()
                sprint_timer = 0

            if startChargeSound.playing:
                walk_speed = 4
            else:
                if walk_speed == 4:
                    fullChargeSound.play()
                    sprint_timer = 0
                walk_speed = sprint_speed
                sprint_timer += (delta*22)
        elif sprint_timer >= sprint_time_max:
            if walk_speed == sprint_speed:
                slowDownSound.play()
            if slowDownSound.playing:
                walk_speed = 4
            else:
                walk_speed = 12
                sprint_timer = 0
        elif not Input.is_action_pressed("ui_interact"):
            walk_speed = 12
            startChargeSound.stop()
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

func getBugNet():
    has_bug_net = true
    itemGetSound.play()
    mySprite.texture = playerWithBugNetTex

func getZoraFlippers():
    has_zora_flippers = true
    itemGetSound.play()

func getSprintBoots():
    has_sprint_boots = true
    itemGetSound.play()

func getBug():
    bugCounter = bugCounter + 1
    print("got bug!: " + str(bugCounter))
    if bugCounter == 4:
        animationPlayer.play("growth")
        growthSound.play()

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

    # if Input.is_action_just_pressed("ui_focus_next"):
    #     getCamera().toggleNext()
    # if Input.is_action_just_pressed("ui_focus_forward"):
    #     getCamera().focusForward(facing)

func faceDown():
    mySprite.faceDown()

func tryEmptyInteract():
    pass    

func IJustDrowned():
    transitioning = false
    if has_zora_flippers:
        zoraDrownedTextbox.interact()
        global.activeInteractor = zoraDrownedTextbox
    else:
        drownedTextbox.interact()
        global.activeInteractor = drownedTextbox
