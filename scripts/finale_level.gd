extends Spatial

onready var player = get_tree().get_root().get_node("level").get_node("Player")
onready var heron = get_tree().get_root().get_node("level").get_node("Heron")
onready var heron2 = get_tree().get_root().get_node("level").get_node("Heron/Heron2")
onready var heron3 = get_tree().get_root().get_node("level").get_node("Heron/Heron3")
onready var heron4 = get_tree().get_root().get_node("level").get_node("Heron/Heron4")
onready var heron5 = get_tree().get_root().get_node("level").get_node("Heron/Heron5")

onready var goodMusic = get_tree().get_root().get_node("level").get_node("goodMusic")
onready var badMusic = get_tree().get_root().get_node("level").get_node("badMusic")


func _ready():
	# global.numHerons = 5
	# global.numBugs = 4
	# global.numMushrooms = 9
	global.is_in_cutscene = true
	global.pauseMoveInput = true
	global.pauseGame = true
	global.did_i_win = true
	

	if global.numMushrooms >= 7:
		player.animationPlayer.play("growth")
		player.growthSound.play()
	if global.numBugs >= 4:
		player.mySprite.texture = player.playerWithWingsTex
	if global.numHerons < 5:
		global.did_i_win = false
		badMusic.play()
		heron.state = heron.State.ADULT_HOVER
		heron.adultQuackSound.play()
		heron5.queue_free()
	if global.numHerons < 4:
		heron4.queue_free()
	if global.numHerons < 3:
		heron3.queue_free()
	if global.numHerons < 2:
		heron2.queue_free()

	if global.did_i_win:
		goodMusic.play()