extends RichTextLabel

var myText = ""
onready var player = get_tree().get_root().get_node("level").get_node("Player")

func _ready():
	pass

func _process(delta):
	if global.pauseGame and not global.pauseMoveInput and not global.is_in_cutscene:
		get_node("..").visible = true

		myText = "welcome to summer islands.\n take a break :)\n\npress enter to unpause\n"
		myText = myText + "move with WASD\njump with Spacebar\nmove camera with mouse or arrow keys\n"
		myText = myText + "talk to NPCs by clicking or pressing F\n"
		if player.has_bug_net:
			myText = myText + "pick up fish by clicking or pressin F\n aim with the mouse and click again to throw it to a heron!\n"
		if player.has_zora_flippers:
			myText = myText + "swim in the water by moving and jumping\n"
		if player.has_triple_jump:
			myText = myText + "keep jumping in the air to FLY some\n"
		elif player.has_double_jump:
			myText = myText + "jump again in the air to double jump\n"
		if player.has_sprint_boots:
			myText = myText + "hold down F or mouse button to charge up a sprint\n you can jump while sprinting!\n"
		if player.has_lunge_jump:
			myText = myText + "while in the air, hold down jump button to hover down\n"
		if player.am_i_big:
			myText = myText + "hurry and save the final heron!\n"

		if global.nightfallTimer > 200:
			myText = myText + "\n you're running out of time!"


		
		set_bbcode(myText)
	else:
		get_node("..").visible = false