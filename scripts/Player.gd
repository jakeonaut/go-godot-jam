extends "PlayerGameMover.gd"

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0

var interact_charge_timer = 0
var interact_charge_time_max = 20

onready var itemGetSound = get_node("Sounds/ItemGetSound")
onready var startChargeSound = get_node("Sounds/StartChargeSound")
onready var startThrowChargeSound = get_node("Sounds/StartThrowChargeSound")
onready var fullChargeSound = get_node("Sounds/FullyChargedSound")
onready var fullyChargedThrowSound = get_node("Sounds/FullyChargedThrowSound")
onready var slowDownSound = get_node("Sounds/SlowDownSound")
onready var errorSound = get_node("Sounds/ErrorSound")
onready var splashSound = get_node("Sounds/SplashSound")
onready var growthSound = get_node("Sounds/GrowthSound")
onready var menuOpenSound = get_node("Sounds/MenuOpenSound")
onready var menuCloseSound = get_node("Sounds/MenuCloseSound")

onready var npc = get_tree().get_root().get_node("level").get_node("NPC")
onready var animationPlayer = get_node("AnimationPlayer")

onready var drownedTextbox = get_node("TextBoxes/DrownedTextContainer/TextBox")
onready var zoraDrownedTextbox = get_node("TextBoxes/ZoraDrownedTextContainer/TextBox")

onready var sunfish = get_tree().get_root().get_node("level").get_node("sunfish")

var has_bug_net = false
var has_sprint_boots = false
var playerWithBugNetTex = load("res://assets/sprites/player_sheet.png") 
var playerWithWingsTex = load("res://assets/sprites/player_sheet_with_wings.png") 
var bugCounter = 0
var should_i_sprint = true # used by textboxes to prevent player from trying to sprint mid conversation
var is_being_carried = false
var mushroomCounter = 0
var has_gotten_a_fish = false
var has_fed_a_heron = false

var seaFishTimer = 0
var seaFishTimeMax = 90
var seaFishTimeMax2 = 160
var seaFishTimeMax3 = 230

func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)

func getSeaFish():
    seaFishTimer = 1
    getCamera().rotateTo(180, false, true)
    getCamera().rotateXTo(360, false, true)
    global.is_in_cutscene = true
    
func _process(delta):
    # while global.numMushrooms > mushroomCounter:
    # 	getMushroom()

    # while global.bugCounter > bugCounter:
    # 	getBug()

    # ._process(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500

    #if Input.is_action_just_pressed("ui_interact"):
    #    cameraFlash.flash()
    
    if seaFishTimer > 0:
        if seaFishTimer < seaFishTimeMax:
            seaFishTimer += (delta*22)
            global_transform.origin.y += 0.4*(delta*60)
            sunfish.global_transform.origin.y -= 1.2
            if seaFishTimer >= seaFishTimeMax:
                # getCamera().rotateXTo(390, false, true)
                if global.activeInteractor != null:
                    global.activeInteractor.interact()
                global.pauseMoveInput = true
        elif seaFishTimer < seaFishTimeMax2:
            global_transform.origin.y += 1*(delta*60)
            seaFishTimer += (delta*22)
            # if seaFishTimer >= seaFishTimeMax2:
            #     getCamera().rotateXTo(0, false, true)
        elif seaFishTimer < seaFishTimeMax3:
            global_transform.origin.y += 0.6*(delta*60)
            seaFishTimer += (delta*22)
            if seaFishTimer >= seaFishTimeMax3:
                global.activeInteractor = sunfish.get_node("TextContainer/TextBox")
                sunfish.get_node("TextContainer/TextBox").interact()


    if Input.is_action_just_pressed("ui_accept") and not global.pauseMoveInput:
        if not global.pauseGame:
            global.pauseGame = true
            menuOpenSound.play()
        else:
            global.pauseGame = false
            menuCloseSound.play()

    # using enum state machines is so much easier than relying on states of timers and booleans..
    if has_sprint_boots:
        var sprint_speed = 22
        var fast_walk_speed = 14
        var cool_down_speed = 4
        if should_i_sprint and not global.activeInteractor and not global.activeThrowableObject:
            if should_i_sprint and (just_tried_to_sprint or ((Input.is_action_just_pressed("ui_interact") and sprint_timer == 0) or startChargeSound.playing or (sprint_timer > 0 and sprint_timer < sprint_time_max))):
                if Input.is_action_just_pressed("ui_interact") and not startChargeSound.playing:
                    startChargeSound.play()
                    sprint_timer = 0
                    just_tried_to_sprint = true

                if startChargeSound.playing:
                    walk_speed = cool_down_speed
                    if not Input.is_action_pressed("ui_interact"):
                        just_tried_to_sprint = false
                        walk_speed = fast_walk_speed
                        startChargeSound.stop()
                        fullChargeSound.stop()
                        sprint_timer = 0
                else:
                    if walk_speed == cool_down_speed:
                        fullChargeSound.play()
                        sprint_timer = 1
                        just_tried_to_sprint = false
                    walk_speed = sprint_speed
                    sprint_timer += (delta*22)

            elif sprint_timer >= sprint_time_max:
                just_tried_to_sprint = false
                if walk_speed == sprint_speed:
                    slowDownSound.play()
                if slowDownSound.playing:
                    walk_speed = cool_down_speed
                else:
                    walk_speed = fast_walk_speed
                    sprint_timer = 0
            elif not Input.is_action_pressed("ui_interact"):
                just_tried_to_sprint = false
                walk_speed = fast_walk_speed
                startChargeSound.stop()
                sprint_timer = 0
                should_i_sprint = true
        elif sprint_timer != 0:
            just_tried_to_sprint = false
            slowDownSound.play()
            walk_speed = fast_walk_speed
            startChargeSound.stop()
            fullChargeSound.stop()
            sprint_timer = 0
            should_i_sprint = true
        elif not Input.is_action_pressed("ui_interact"):
            should_i_sprint = true
            walk_speed = fast_walk_speed
            sprint_timer = 0
                

    # if Input.is_action_just_pressed("ui_action") and on_ground and not global.pauseMoveInput and not global.pauseGame:
    #     is_rolling = true
    #     rolling_timer = 0
    #     is_rotating = true


    if not global.is_in_cutscene:
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
    npc.textBox = npc.get_node("TextContainer2").get_node("TextBox")
    #getCamera().autoRotate = true

func getFirstFish():
    if has_gotten_a_fish:
        return
    has_gotten_a_fish = true
    npc.textBox = npc.get_node("TextContainer4").get_node("TextBox")
    if global.activeInteractor != null:
        global.activeInteractor.interact()
    global.activeInteractor = npc.textBox
    npc.textBox.interact()

func getZoraFlippers():
    has_zora_flippers = true
    itemGetSound.play()
    #getCamera().autoRotate = true

func getSprintBoots():
    has_sprint_boots = true
    itemGetSound.play()
    #getCamera().autoRotate = true

func getBug():
    bugCounter = bugCounter + 1
    itemGetSound.play()
    # print("got bug!: " + str(bugCounter))
    if bugCounter == 4:
        mySprite.texture = playerWithWingsTex
    #getCamera().autoRotate = true

func getMushroom():
    mySprite.pixel_size += 0.0022
    mushroomCounter = mushroomCounter + 1
    global.numMushrooms = mushroomCounter
    if mushroomCounter == global.maxMushrooms:
        animationPlayer.play("growth")
        growthSound.play()
        am_i_big = true

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
