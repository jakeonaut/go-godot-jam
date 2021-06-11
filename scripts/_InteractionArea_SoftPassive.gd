extends Area

var touchingPlayer = false
var wasTouchingPlayer = false
onready var parent = get_parent()

func _ready():
    set_process(true)

func isActive():
    return parent.has_method("isActive") and \
           parent.isActive()

func _process(delta):
    touchingPlayer = false
    var areas = get_overlapping_areas()
    for area in areas:
        if area.is_in_group("player"):
            touchingPlayer = true

    if touchingPlayer and not wasTouchingPlayer:
        if parent.has_method("softPassiveActivate"):
            parent.softPassiveActivate(delta)

    if not touchingPlayer and not wasTouchingPlayer:
        if parent.has_method("stopSoftPassiveActivate"):
            parent.stopSoftPassiveActivate()
        
    wasTouchingPlayer = touchingPlayer