extends KinematicBody

onready var mySprite = get_node("Sprite3D") if has_node("Sprite3D") else null
onready var landSound = get_node("Sounds/LandSound") if has_node("Sounds/LandSound") else null
onready var bumpSound = get_node("Sounds/BumpSound") if has_node("Sounds/BumpSound") else null

var true_terminal_vel = 32
var water_terminal_vel = 5
var hit_water_terminal_vel = 1
var terminal_vel = true_terminal_vel
var is_floating = false
var float_timer = 0
var float_time_limit = 2
var big_float_time_limit = 5
var is_touching_water = false
var was_touching_water = false
var on_ground = true
var was_on_ground = true
var was_just_on_ground_timer = 0
var was_just_on_ground_time_limit = 5
var just_landed = false
var fallCounter = 0
var fallCountMin = 0.5
var fallCountMax = 30
var take_fall_damage = false
var spawn_origin
var last_grounded_pos = 0
var falling_y_offset = 16

var linear_velocity = Vector3()
var lv = linear_velocity

export var grav = 80
var g = Vector3(0, -grav, 0)

var dir = Vector3(0, 0, 0)
var prev_dir = dir
var up = -g.normalized() # (up is against gravity)
var vv = up.dot(lv) # vertical velocity
var hv = lv - up * vv # horizontal velocity

var walk_speed = 12

var is_rotating = false
var rotateTimer = 0
var rotateTimeLimit = 1
var num_rotations = 0
var max_rotations = 1

func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)
    float_timer = float_time_limit
    spawn_origin = self.global_transform.origin
    last_grounded_pos = spawn_origin

    if walk_speed:
        pass
    if falling_y_offset:
        pass
    if fallCountMin:
        pass

func _process(delta):
    if delta:
        pass

func _physics_process(delta):
    tryToRespawn()

func tryToRespawn():
    if not on_ground and translation.y < -40: # translation.y < (last_grounded_pos.y - falling_y_offset):
        respawn()

func respawn():
    self.hv = Vector3(0, 0, 0)
    self.linear_velocity = Vector3(0, 0, 0)

    self.global_transform.origin = spawn_origin
    self.global_transform.origin.y += 2
    last_grounded_pos = self.global_transform.origin

func processPhysics(delta):
    lv = linear_velocity
    g = Vector3(0, -grav, 0)
    
    if not is_touching_water:
        is_floating = false
    applyGravity(delta)
    
    up = -g.normalized() # (up is against gravity)
    vv = up.dot(lv) # vertical velocity
    hv = lv - up * vv # horizontal velocity
    
    applyTerminalVelocity(delta)
    
    processInputs(delta)
    if is_touching_water:
        hv -= (hv.normalized()*delta*22)
        if abs(hv.length()) < delta*22:
            hv = Vector3()
            dir = Vector3(0.0, 0.0, 0.0)
        
    lv = hv + (up * vv)
    
    # move_and_slide automatically includes "delta"
    linear_velocity = move_and_slide(lv, -g.normalized(), true)

    postProcessInputs(delta)
    prev_dir = dir

    if is_rotating:
        mySprite.setRotating(true)
        rotateTimer += delta*22
        if rotateTimer >= rotateTimeLimit:
            rotateTimer = 0
            if mySprite:
                if mySprite.isFacingDown(): mySprite.faceLeft()
                elif mySprite.isFacingLeft(): mySprite.faceUp()
                elif mySprite.isFacingUp(): mySprite.faceRight()
                elif mySprite.isFacingRight(): 
                    mySprite.faceDown()
                    num_rotations += 1
                    if num_rotations >= max_rotations:
                        is_rotating = false
                        mySprite.setRotating(false)
                        mySprite.fixSpriteFacing()

    noFloorBelow()
    
    just_landed = false
    if not was_on_ground and on_ground: # I just landed!!
        landed()
        # Falling fast and far
        if fallCounter >= fallCountMax: 
            landedFast()
        elif take_fall_damage == false:
            landedNormally()
        else:
            landedFromBounce()
        just_landed = true


    if not is_touching_water and was_touching_water:
        float_timer = 0
    if was_on_ground and not on_ground: # I just fell off platform!
        was_just_on_ground_timer = 0
    was_on_ground = on_ground
    was_touching_water = is_touching_water

    if was_just_on_ground_timer <= was_just_on_ground_time_limit:
        was_just_on_ground_timer += (delta*22)
    
func applyGravity(delta):
    if is_floating and not abs(translation.y - spawn_origin.y) > 2:
        g = Vector3(0, grav/10, 0)
        if float_timer >= big_float_time_limit:
            g = Vector3(0, grav/2, 0)
        on_ground = false
    elif is_touching_water:
        g = Vector3(0, -grav/2, 0)
    else:
        g = Vector3(0, -grav, 0)

    lv += g * delta

func applyTerminalVelocity(delta):
    if is_touching_water:
        terminal_vel = hit_water_terminal_vel
        if float_timer >= big_float_time_limit:
            terminal_vel = water_terminal_vel
    else:
        terminal_vel = true_terminal_vel

    if vv < -terminal_vel:
        vv = -terminal_vel
        fallCounter += (delta*22)
        if is_touching_water:
            float_timer += (delta*22)
            if float_timer >= float_time_limit:
                is_floating = true
    if vv > terminal_vel and is_floating:
        vv = terminal_vel

func startRotateSprite(max2):
    num_rotations = 0
    max_rotations = max2
    is_rotating = true
    rotateTimer = 0
    if mySprite: mySprite.faceDown()

func processInputs(delta):
    if delta:
        pass

func postProcessInputs(delta):
    if delta:
        pass
    
func landed():
    last_grounded_pos = self.global_transform.origin

func landedFast():
    take_fall_damage = true
    if bumpSound: bumpSound.play()

func landedNormally():
    if landSound and not is_touching_water:
        landSound.play()

func landedFromBounce():
    take_fall_damage = false

func noFloorBelow():
    if is_on_floor():
        fallCounter = 0
        on_ground = true
        if is_touching_water:
            is_floating = true
    else:
        on_ground = false
