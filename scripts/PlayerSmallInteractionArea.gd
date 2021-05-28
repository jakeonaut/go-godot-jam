extends Area

onready var parent = get_parent()

var is_touching_a_ladder = false
var is_touching_enemy = false
var is_touching_water = false
var was_touching_water = false
var water_y = 0

func _ready():
    set_process(true)

func _process(delta):
    was_touching_water = is_touching_water

    is_touching_a_ladder = false
    is_touching_enemy = false
    is_touching_water = false
    var areas = get_overlapping_areas()
    for area in areas:
        if area.is_in_group("ladders"):
            is_touching_a_ladder = true
        if area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
            is_touching_enemy = true
        if area.is_in_group("water"):
            var collision_shape = area.get_node("CollisionShape")
            is_touching_water = true
            water_y = collision_shape.global_transform.origin.y + (collision_shape.get_shape().get_extents().y) + 1

    if is_touching_water and not was_touching_water and not parent.splashSound.playing:
        parent.splashSound.play()
