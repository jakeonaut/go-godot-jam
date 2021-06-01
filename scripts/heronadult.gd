extends "GameMover.gd"

var ThrowableObject = preload('ThrowableObject.gd')

onready var player = get_tree().get_root().get_node("level").get_node("Player")
onready var herongod = get_tree().get_root().get_node("level").get_node("herongod")
onready var animationPlayer = get_node("AnimationPlayer")
onready var interactionArea = get_node("InteractionArea")

onready var spottedSound = get_node("Sounds/SpottedSound")
onready var peckSound = get_node("Sounds/PeckSound")
onready var growthSound = get_node("Sounds/GrowthSound")
onready var wingSound = get_node("Sounds/WingSound")
onready var pickupSound = get_node("Sounds/PickupSound")
onready var babyQuackSound = get_node("Sounds/BabyQuackSound")
onready var adultQuackSound = get_node("Sounds/AdultQuackSound")

onready var myFlightTarget = get_node("Target").global_transform.origin
var myHoverTarget = self.global_transform.origin
onready var NPC = get_tree().get_root().get_node("level").get_node("NPC")

var idle_timer = 0
var idle_time_max = 10
var jump_force = 20
var fly_away_timer = 0
var fly_away_time_max = 120

enum State {
	BABY_IDLE = 0,
	BABY_FOUND_A_FISH = 1,
	BABY_EATING_FISH = 2,
	BABY_GROW_UP = 3,
	ADULT_START_FLY = 4,
	ADULT_HOVER = 5,
	ADULT_FLY_AWAY_HOLD_PLAYER = 6,
	ADULT_FLY_AWAY = 7,
	BABY_JUST_STARTLED = 8,
	BABY_STARTLED = 9,
	ADULT_JUST_STARTLED = 10,
	ADULT_STARTLED = 11,
	SWOOP_DOWN = 12,
}

var state = State.ADULT_HOVER
var found_a_fish = false
var myfish = null
var eating_a_fish = false
var randomIdlePos = Vector3(0, 0, 0)

func _ready():
	set_process(true)
	set_physics_process(true)

	idle_time_max = 10 + randi() % 10
	randomIdlePos = Vector3(
						self.global_transform.origin.x + (randi() % 3) - 2, 
						self.global_transform.origin.y, 
						self.global_transform.origin.z + (randi() % 3) - 2)

func _process(delta):
	#._process(delta) # NOTE: This super method is called automatically
	# https://github.com/godotengine/godot/issues/6500
	pass

func _physics_process(delta):
	# ._physics_process(delta) # NOTE: This super method is called automatically
	# https://github.com/godotengine/godot/issues/6500

	.processPhysics(delta)

func isActive():
	return state == State.ADULT_HOVER or state == State.BABY_IDLE

func passiveActivate(delta):
	if state == State.BABY_IDLE and not global.activeThrowableObject:
		state = State.BABY_JUST_STARTLED
		animationPlayer.stop()
		animationPlayer.play("heronBabyStartle")
		wingSound.play()
		babyQuackSound.play()
	if state == State.SWOOP_DOWN and not player.is_being_carried:
		state = State.ADULT_FLY_AWAY_HOLD_PLAYER
		global.pauseMoveInput = true
		pickupSound.play()
		fly_away_timer = 0

func setNewFlightTarget(newFlightTarget):
	myFlightTarget = newFlightTarget

# @override
func processInputs(delta):
	if state == State.BABY_IDLE:
		TurnToPos(randomIdlePos)
		if not animationPlayer.is_playing():
			idle_timer += (delta*22)
			if idle_timer >= idle_time_max:
				if randi() % 3 == 0:
					peckSound.play()
					animationPlayer.play("heronBabyPeck")
					randomIdlePos = Vector3(
						self.global_transform.origin.x + (randi() % 3) - 2, 
						self.global_transform.origin.y, 
						self.global_transform.origin.z + (randi() % 3) - 2)
				else:
					wingSound.play()
					animationPlayer.play("heronBabyWingFlap")
				idle_timer = 0
				idle_time_max = 10 + randi() % 10

	if state == State.BABY_JUST_STARTLED:
		true_terminal_vel = 16
		if on_ground:
			vv = jump_force*1.5
			on_ground = false
			wingSound.play()
			state = State.BABY_STARTLED
	elif state == State.BABY_STARTLED:
		if not animationPlayer.is_playing():
			animationPlayer.play("heronBabyStartle")
			wingSound.play()
		if on_ground:
			state = State.BABY_IDLE
	elif state == State.ADULT_JUST_STARTLED:
		true_terminal_vel = 16
		if on_ground:
			vv = jump_force*1.5
			on_ground = false
			wingSound.play()
			state = State.ADULT_STARTLED
	elif state == State.ADULT_STARTLED:
		if not animationPlayer.is_playing():
			animationPlayer.play("heronAdultFlapAway")
			wingSound.play()
		if on_ground:
			state = State.ADULT_START_FLY
	else:
		true_terminal_vel = 32

	if state == State.BABY_IDLE or state == State.BABY_FOUND_A_FISH or state == State.BABY_EATING_FISH:
		BabyTryToFindFish()
			
	if state == State.BABY_FOUND_A_FISH or state == State.BABY_EATING_FISH:
		TurnToFish()
			
	if state == State.BABY_EATING_FISH and not animationPlayer.is_playing():
		FinishEatingFish()

	if state == State.BABY_GROW_UP and not animationPlayer.is_playing():
		global.numHerons += 1
		state = State.ADULT_START_FLY
		animationPlayer.play("heronAdultFlapAwayStart")
		adultQuackSound.play()
		wingSound.play()

	if state == State.ADULT_START_FLY:
		vv = jump_force/4
		if not animationPlayer.is_playing():
			state = State.ADULT_HOVER
			animationPlayer.play("heronAdultFlapAway")
			wingSound.play()
			adultQuackSound.play()

	if state == State.ADULT_HOVER:
		if not global.did_i_win:
			self.global_transform.origin.y += (delta/4)
		TurnTo(herongod.global_transform.origin)
		vv = jump_force/32
		if not global.did_i_win:
			vv = jump_force/12
		if not animationPlayer.is_playing():
			animationPlayer.play("heronAdultFlapAway")
			wingSound.play()

	if state == State.SWOOP_DOWN:
		if not animationPlayer.is_playing():
			animationPlayer.play("heronAdultFlapAway")
			wingSound.play()

	if state == State.ADULT_FLY_AWAY_HOLD_PLAYER:
		vv = jump_force/4
		global_transform.origin.x += delta*10
		global_transform.origin.z += delta*10
			

		# fly_away_timer += (delta*22)
		# if fly_away_timer >= fly_away_time_max:
		# 	state = State.ADULT_FLY_AWAY
		# 	adultQuackSound.play()

	if state == State.ADULT_FLY_AWAY:
		# vv = jump_force/4
		if not animationPlayer.is_playing():
			animationPlayer.play("heronAdultFlapAway")
			wingSound.play()
		
		var closeX = abs(self.global_transform.origin.x - myHoverTarget.x)
		var closeY = abs(self.global_transform.origin.y - myHoverTarget.y)
		var closeZ = abs(self.global_transform.origin.z - myHoverTarget.z)
		if closeX < 2 and closeY < 10 and closeZ < 2:
			state = State.ADULT_HOVER
			adultQuackSound.play()
		else:
			TurnTo(myHoverTarget)
			self.global_transform.origin = lerp(self.global_transform.origin, myHoverTarget, 2*delta/3)

func BabyTryToFindFish():
	var areas = interactionArea.get_overlapping_areas()
	var still_near_my_fish = false
	for area in areas:
		if state == State.BABY_IDLE and area.get_node("..") is ThrowableObject:
			state = State.BABY_FOUND_A_FISH
			vv = jump_force
			spottedSound.play()
			myfish = area.get_node("..")
			still_near_my_fish = true
			animationPlayer.stop()
			animationPlayer.play("heronBabyStartle")
			break
			
		elif area.get_node("..") == myfish:
			still_near_my_fish = true
			if state == State.BABY_FOUND_A_FISH and not animationPlayer.is_playing() and on_ground:
				state = State.BABY_EATING_FISH
				animationPlayer.stop()
				animationPlayer.play("heronBabyPeck")
				peckSound.play()
				break
	if not still_near_my_fish:
		myfish = null
		if state == State.BABY_FOUND_A_FISH or state == State.BABY_EATING_FISH:
			state = State.BABY_IDLE

func TurnToPos(pos):
	TurnTo(pos)

func TurnToFish():
	if myfish:
		TurnTo(myfish.global_transform.origin)

func TurnToPlayer():
	TurnTo(player.global_transform.origin)

func TurnTo(target):
	var mypos = self.global_transform.origin
	
	var original_scale = self.transform.basis.get_scale()
	
	var previous_y_rotation = self.rotation.y

	look_at(Vector3(target.x, mypos.y, target.z), Vector3(0, 1, 0))
	self.rotate_object_local(Vector3(0,1,0), 3.14)
	
	self.rotation.y = lerp(previous_y_rotation, self.rotation.y, 0.1)
	
	var current_scale = self.transform.basis.get_scale()
	var fix_scale = original_scale / current_scale
	self.transform.basis = self.transform.basis.scaled(fix_scale)

func FinishEatingFish():
	state = State.BABY_GROW_UP
	myfish.visible = false
	if global.activeThrowableObject == myfish:
		global.activeThrowableObject = null
	myfish.queue_free()
	growthSound.play()
	animationPlayer.play("heronBabyGrowUp")
	NPC.textBox = NPC.get_node("TextContainerPostHeronBaby").get_node("TextBox")