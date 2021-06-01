extends KinematicBody

var ThrowableObject = preload('ThrowableObject.gd')

onready var player = get_tree().get_root().get_node("level").get_node("Player")
onready var npc = get_tree().get_root().get_node("level").get_node("NPC")
onready var npc2 = get_tree().get_root().get_node("level").get_node("NPC2")
onready var map = get_tree().get_root().get_node("level").get_node("Map")
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

onready var heron1 = get_tree().get_root().get_node("level").get_node("Heron")

var idle_timer = 0
var idle_time_max = 10
var jump_force = 100
var fly_away_timer = 0
var fly_away_time_max = 120

enum State {
	ADULT_START_FLY = 4,
	ADULT_GOD_RISE = 12,
	ADULT_HOVER = 5,
	ADULT_FLY_AWAY_HOLD_PLAYER = 6,
	ADULT_FLY_AWAY = 7,
	ADULT_JUST_STARTLED = 10,
	ADULT_STARTLED = 11,
	ADULT_GROW_HOVER = 13,
}

var rise_timer = 0
var rise_time_max = 10

var state = State.ADULT_START_FLY
var found_a_fish = false
var myfish = null
var eating_a_fish = false
var randomIdlePos = Vector3(0, 0, 0)

func _ready():
	state = State.ADULT_START_FLY
	set_process(true)
	set_physics_process(true)

	adultQuackSound.play()

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

	self.processInputs(delta)

func isActive():
	return state == State.ADULT_HOVER

func passiveActivate(delta):
	if state == State.ADULT_HOVER and not player.is_being_carried:
		if not player.am_i_big:
			state = State.ADULT_FLY_AWAY_HOLD_PLAYER
			global.pauseMoveInput = true
			pickupSound.play()
			fly_away_timer = 0
		else:
			state = State.ADULT_JUST_STARTLED
			animationPlayer.stop()
			animationPlayer.play("heronAdultFlapAway")
			wingSound.play()
			babyQuackSound.play()

func setNewFlightTarget(newFlightTarget):
	myFlightTarget = newFlightTarget

# @override
func processInputs(delta):
	if state == State.ADULT_START_FLY:
		if not animationPlayer.is_playing():
			state = State.ADULT_GOD_RISE
			animationPlayer.play("heronAdultFlapAway")
			wingSound.play()
			adultQuackSound.play()

	if state == State.ADULT_GOD_RISE:
		global_transform.origin.y += delta*10
		PlayerTurnToMe()
		if not animationPlayer.is_playing():
			animationPlayer.play("heronAdultFlapAway", -1, 0.5)
			wingSound.play()
		rise_timer += (delta)
		if rise_timer >= rise_time_max:
			state = State.ADULT_FLY_AWAY

	if state == State.ADULT_GROW_HOVER:
		# myHoverTarget = self.global_transform.origin
		# myHoverTarget.y -= 8
		global_transform.origin.y -= delta*30
		TurnToPlayer()
		if not animationPlayer.is_playing():
			peckSound.play()
			state = State.ADULT_HOVER
			animationPlayer.play("heronAdultFlapAway", -1, 0.5)
			wingSound.play()
	if state == State.ADULT_HOVER:
		# myHoverTarget = self.global_transform.origin
		# myHoverTarget.y -= 8
		if global.did_i_win:
			global_transform.origin.y += delta*16
			if not babyQuackSound.playing and not global.activeInteractor and not global.game_over:
				npc2.activate()
		else:
			global_transform.origin.y -= delta*14
			map.global_transform.origin.y -= delta * 1.5
			if not growthSound.playing:
				rotation.y += delta*5
			if not peckSound.playing:
				peckSound.play()
				if not global.activeInteractor and not global.game_over:
					npc.activate()
		if not animationPlayer.is_playing():
			if global.did_i_win:
				animationPlayer.play("heronAdultFlapAway", -1, 0.5)
				wingSound.play()

	if state == State.ADULT_FLY_AWAY_HOLD_PLAYER:
		global.pauseMoveInput = true
		player.translation = self.translation
		player.is_lunging = 0
		player.is_being_carried = true
		if not animationPlayer.is_playing():
			animationPlayer.play("heronAdultFlapAway", -1, 0.5)
			wingSound.play()
		
		var closeX = abs(self.global_transform.origin.x - myFlightTarget.x)
		var closeY = abs(self.global_transform.origin.y - myFlightTarget.y)
		var closeZ = abs(self.global_transform.origin.z - myFlightTarget.z)
		# print(str(closeX) + ", " + str(closeY) + ", " + str(closeZ))
		if closeX < 1.5 and closeY < 12 and closeZ < 1.5:
			state = State.ADULT_FLY_AWAY
			player.is_being_carried = false
			global.pauseMoveInput = false
			adultQuackSound.play()
		else:
			TurnTo(myFlightTarget)
			self.global_transform.origin = lerp(self.global_transform.origin, myFlightTarget, 2*delta/3)
			

		# fly_away_timer += (delta*22)
		# if fly_away_timer >= fly_away_time_max:
		# 	state = State.ADULT_FLY_AWAY
		# 	adultQuackSound.play()

	if state == State.ADULT_FLY_AWAY:
		global_transform.origin.y += delta*10
		PlayerTurnToMeKinda()
		if not animationPlayer.is_playing():
			animationPlayer.play("heronAdultFlapAway", -1, 0.5)
			wingSound.play()
		
		var closeX = abs(self.global_transform.origin.x - myFlightTarget.x)
		var closeY = abs(self.global_transform.origin.y - myFlightTarget.y)
		var closeZ = abs(self.global_transform.origin.z - myFlightTarget.z)
		# print(str(closeX) + ", " + str(closeY) + ", " + str(closeZ))
		if closeX < 15 and closeY < 20 and closeZ < 15:
			state = State.ADULT_HOVER
			if global.did_i_win:
				heron1.state = heron1.State.ADULT_FLY_AWAY_HOLD_PLAYER
				babyQuackSound.play()
			else:
				animationPlayer.play("heronBabyGrowUp")
				growthSound.play()
				peckSound.play()
		else:
			TurnTo(myFlightTarget)
			self.global_transform.origin = lerp(self.global_transform.origin, myFlightTarget, 2*delta/3)

func TurnToPos(pos):
	TurnTo(pos)

func TurnToFish():
	if myfish:
		TurnTo(myfish.global_transform.origin)

func TurnToPlayer():
	TurnTo(player.global_transform.origin)

func PlayerTurnToMe():
	var target = player.global_transform.origin
	var mypos = self.global_transform.origin
	
	var original_scale = player.transform.basis.get_scale()
	

	player.look_at(Vector3(mypos.x, mypos.y+150, mypos.z), Vector3(0, 1, 0))
	
	var current_scale = player.transform.basis.get_scale()
	var fix_scale = original_scale / current_scale
	player.transform.basis = player.transform.basis.scaled(fix_scale)

func PlayerTurnToMeKinda():
	var target = player.global_transform.origin
	var mypos = self.global_transform.origin
	
	var original_scale = player.transform.basis.get_scale()
	
	var previous_rotation = player.rotation
	player.look_at(Vector3(mypos.x, mypos.y+50, mypos.z), Vector3(0, 1, 0))
	player.rotation = lerp(previous_rotation, player.rotation, 0.1)
	
	var current_scale = player.transform.basis.get_scale()
	var fix_scale = original_scale / current_scale
	player.transform.basis = player.transform.basis.scaled(fix_scale)

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