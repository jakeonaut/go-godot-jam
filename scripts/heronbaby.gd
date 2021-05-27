extends "GameMover.gd"

var ThrowableObject = preload('ThrowableObject.gd')

onready var animationPlayer = get_node("AnimationPlayer")
onready var interactionArea = get_node("InteractionArea")

onready var spottedSound = get_node("Sounds/SpottedSound")
onready var peckSound = get_node("Sounds/PeckSound")
onready var growthSound = get_node("Sounds/GrowthSound")

var idle_timer = 0
var idle_time_max = 10
var jump_force = 10

enum State {
	IDLE = 0,
	FOUND_A_FISH = 1,
	EATING_FISH = 2,
	GROW_UP = 3,
}

var state = State.IDLE
var found_a_fish = false
var myfish = null
var eating_a_fish = false

func _ready():
	terminal_vel = 16
	set_process(true)
	set_physics_process(true)
	
func _physics_process(delta):
    # ._physics_process(delta) # NOTE: This super method is called automatically
    # https://github.com/godotengine/godot/issues/6500

    if global.pauseGame: return

    .processPhysics(delta)

func _process(delta):
	if state == State.IDLE and not animationPlayer.is_playing():
		idle_timer += (delta*22)
		if idle_timer >= idle_time_max:
			animationPlayer.play("heronBabyWingFlap")
			idle_timer = 0

	var areas = interactionArea.get_overlapping_areas()
	var still_near_my_fish = false
	for area in areas:
		if state == State.IDLE and area.get_node("..") is ThrowableObject:
			state = State.FOUND_A_FISH
			vv = jump_force
			spottedSound.play()
			myfish = area.get_node("..")
			still_near_my_fish = true
			break
			
		elif area.get_node("..") == myfish:
			still_near_my_fish = true
			if state == State.FOUND_A_FISH and not animationPlayer.is_playing() and on_ground:
				state = State.EATING_FISH
				animationPlayer.stop()
				animationPlayer.play("heronBabyPeck")
				peckSound.play()
				break
	if not still_near_my_fish:
		myfish = null
		if state != State.GROW_UP:
			state = State.IDLE
			
	if state == State.FOUND_A_FISH or state == State.EATING_FISH:
		var target = myfish.global_transform.origin
		var mypos = self.global_transform.origin
		
		var original_scale = self.transform.basis.get_scale()
		
		var previous_y_rotation = self.rotation.y

		look_at(Vector3(target.x, mypos.y, target.z), Vector3(0, 1, 0))
		self.rotate_object_local(Vector3(0,1,0), 3.14)
		
		self.rotation.y = lerp(previous_y_rotation, self.rotation.y, 0.1)
		
		var current_scale = self.transform.basis.get_scale()
		var fix_scale = original_scale / current_scale
		self.transform.basis = self.transform.basis.scaled(fix_scale)
			
	if state == State.EATING_FISH and not animationPlayer.is_playing():
		state = State.GROW_UP
		myfish.visible = false
		myfish.queue_free()
		growthSound.play()
		animationPlayer.play("heronBabyGrowUp")
		state = State.IDLE