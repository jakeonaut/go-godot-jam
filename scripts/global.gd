extends Node

var hasLoadedGame = false
var memory = {}

var numHearts = 3

var activeInteractor = null
var activeThrowableObject = null
var activeThrowableObjectPath = null
var activeSavePoint = null

var isRespawning = false
var cameraRotation = 0

var pauseMoveInput = false # don't allow player physics or camera input??
var pauseGame = false   
var is_in_cutscene = false

var can_broom = false

var startTimer = false
var nightfallTimer = 0
var numHerons = 0
var numFish = 0
var numBugs = 0
var numMushrooms = 0

func _ready():
    randomize()

    # somehow this gets rid of errors LOL
    if hasLoadedGame: pass
    if memory: pass
    if numHearts: pass
    if activeInteractor: pass
    if activeThrowableObject: pass
    if activeThrowableObjectPath: pass
    if activeSavePoint: pass
    if isRespawning: pass
    if cameraRotation: pass
    if pauseMoveInput: pass
    if pauseGame: pass
    if can_broom: pass
    if startTimer: pass
    if numHerons: pass
    if numBugs: pass
    if numMushrooms: pass
    if nightfallTimer: pass
    if is_in_cutscene: pass


var save_game_file = "user://savegame.save"
func saveGame():
    var save_game = File.new()
    save_game.open(save_game_file, File.WRITE)
    save_game.store_line(to_json(global.memory))
    save_game.close()

func loadGame():
    var save_game = File.new()
    if not save_game.file_exists("user://savegame.save"):
        return # Error! We don't have a save to load.
    
    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    save_game.open(save_game_file, File.READ)
    
    global.memory = parse_json(save_game.get_line())
    while not save_game.eof_reached():
        # ... ??? Is this because global.memory is stored on a single line? enigmatic..
        var current_line = parse_json(save_game.get_line())
        
    save_game.close()