extends "GameMover.gd"

onready var pickupSound = get_node("Sounds/PickupSound")
onready var throwSound = get_node("Sounds/ThrowSound")
onready var splashSound = get_node("Sounds/SplashSound")
onready var player = get_tree().get_root().get_node("level").get_node("Player")
onready var npc = get_tree().get_root().get_node("level").get_node("NPC")
onready var interactionArea = get_node("InteractionArea")

var is_held = false
var was_just_thrown = false
# so it doesn't hatch/crash on initial load
var has_initially_landed = false
var thrown_down = false
var was_planted = false
var was_rolled = false

var pickupCounter = 0
var pickupCounterMax = 3

var throw_force = 1
var throw_speed = 14
var jump_force = 10
var am_i_big = false

var is_being_eaten = false
var im_the_first = false

func _ready():
    set_process(true)
    set_physics_process(true)

    var randNum = (randi() % 9)
    mySprite.start_frame = randNum*2

func _process(delta):
    #._process(delta) # NOTE: This super method is called automatically
    # https://github.com/godotengine/godot/issues/6500

    if global.pauseGame: return

    if (global.activeThrowableObject == self or is_held) and pickupCounter < pickupCounterMax:
        pickupCounter += (delta*22)

func _physics_process(delta):
    # ._physics_process(delta) # NOTE: This super method is called automatically
    # https://github.com/godotengine/godot/issues/6500

    if global.pauseGame: return

    if self.repositionSelf(): return

    if not was_touching_water and interactionArea.is_touching_water:
        splashSound.play()
    is_touching_water = interactionArea.is_touching_water
    .processPhysics(delta)
    if not has_initially_landed and on_ground:
        has_initially_landed = true

func repositionSelf():
    if is_held:
        self.translation = player.translation
        self.translation.y += 2 # nodelta
        if player.am_i_big:
            self.translation.y += 4
        set_collision_mask_bit(1, false)
        return true
    return false

# @override
func processInputs(delta):
    if take_fall_damage:
        vv = jump_force
        on_ground = false

    if was_just_thrown:
        was_just_thrown = false
        hv = player.facing.normalized() * (throw_speed - 1)
        vv = jump_force + (5 * throw_force / 5)
        if thrown_down:
            hv = player.facing.normalized() * 0
            vv = -jump_force*2
            player.should_magic_jump = true
        if was_rolled:
            vv = 0
    elif on_ground: 
        if was_rolled:
            rollStep(delta)
        else:
            hv = Vector3()
    thrown_down = false

func rollStep(delta):
    hv -= (hv.normalized()*delta*15)
    if abs(hv.length()) < delta*22:
        hv = Vector3()
        was_rolled = false

# @override
func respawn():
    .respawn()

    self.is_held = false
    self.was_just_thrown = false
    self.thrown_down = false
    self.has_initially_landed = false

# @override
func landed():
    .landed() #super
    if not was_rolled:
        set_collision_mask_bit(1, true)
    if not has_initially_landed:
        has_initially_landed = true
    if im_the_first and not is_being_eaten:
        im_the_first = false
        npc.textBox = npc.get_node("TextContainerPostFish").get_node("TextBox")
        if global.activeInteractor != null:
            global.activeInteractor.interact()
        global.activeInteractor = npc.textBox
        npc.textBox.interact()

func isActive():
    # since "isActive" is used for determining when the object is "interacted" with
    # by the player, don't count as "active" when player is holding this object.
    # BECAUSE player will already know about it through the global var.
    return visible and not global.activeThrowableObject and not is_being_eaten

func activate(interact_charge_timer = 1):
    if not player.has_bug_net:
        player.errorSound.play()
        player.get_node("TextBoxes/NeedNetTextContainer/TextBox").interact()
        global.activeInteractor = player.get_node("TextBoxes/NeedNetTextContainer/TextBox")
    else:
        if not player.has_gotten_a_fish:
            player.getFirstFish()
            im_the_first = true
        # Should be able to talk while holding an object.
        if not is_held and global.activeThrowableObject == null:
            pickup()
        elif pickupCounter >= pickupCounterMax and (global.activeThrowableObject == self or is_held):
            throw(interact_charge_timer)
		
func getEaten():
	is_being_eaten = true

func pickup():
    is_floating = false
    was_rolled = false
    # Pick up
    pickupSound.play()
    is_held = true
    global.activeThrowableObject = self
    pickupCounter = 0
    self.repositionSelf()
    player.is_lunging = 0
    player.should_i_sprint = false
    player.sprint_timer = 0
    player.walk_speed = 12
    player.just_tried_to_sprint = false

func throw(interact_charge_timer = 1):
    spawn_origin = self.global_transform.origin
    is_floating = false
    float_timer = float_time_limit
    # Throw! Roll
    throwSound.play()
    is_held = false
    was_just_thrown = true
    throw_force = interact_charge_timer
    was_planted = true
    # if Input.is_action_pressed("ui_jump") and not player.is_pressing_horizontal_input:
    #     thrown_down = true

    global.activeThrowableObject = null
    
func activate_crouch():
    if not is_held and global.activeThrowableObject == null:
        pickup()
    elif pickupCounter >= pickupCounterMax and (global.activeThrowableObject == self or is_held):
        throw()
        if player.on_ground:
            was_rolled = true
            self.translation = player.translation            
        else:
            thrown_down = true