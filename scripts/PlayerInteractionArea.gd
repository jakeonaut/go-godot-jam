extends Area

onready var player = get_node("..")
var next_text_timer = 0
var next_text_time_max = 3.5

func _ready():
    set_process(true)
    set_process_input(true)
            

func _process(delta):
    if not global.is_in_cutscene and global.pauseGame and not global.pauseMoveInput: return
    
    if global.is_in_cutscene and global.activeInteractor:
        next_text_timer += (delta)
        # print(next_text_timer)
        if next_text_timer > next_text_time_max and global.activeInteractor and is_instance_valid(global.activeInteractor):
            global.activeInteractor.InteractActivate()
            next_text_timer = 0
        return

    # print(global.activeInteractor)
    # can short circuit and just immediately interact with "activeInteractor" AKA TextBox if 
    # I am already looking at one (e.g. if global.activeInteractor exists   )
    if Input.is_action_just_pressed("ui_interact") and global.activeInteractor and is_instance_valid(global.activeInteractor):
        global.activeInteractor.InteractActivate()
        return

    var shortest_dist = 999 # zero escape saga
    var nearest_area = null
    var shortest_passive_dist = 999
    var nearest_passive_area = null

    # find the nearest active area and passive area
    var areas = get_overlapping_areas()
    for area in areas:
        if area.has_method("isActive") and area.isActive():
            var dist = area.global_transform.origin.distance_to(global_transform.origin)
            if area.has_method("PassiveInteractActivate"):
                if dist < shortest_passive_dist:
                    shortest_passive_dist = dist
                    nearest_passive_area = area
            
            if area.has_method("InteractActivate"):
                if dist < shortest_dist:
                    shortest_dist = dist
                    nearest_area = area

    # give priority to active area if user pressing interact action
    if Input.is_action_just_pressed("ui_interact"):
        if nearest_area:
            nearest_area.InteractActivate()
            player.walk_speed = 12
            player.startChargeSound.stop()
            player.sprint_timer = 0
        # Give secondary priority to held objects action.
        elif global.activeThrowableObject:
            player.is_interact_charging = true
            player.interact_charge_timer = 0
        # if no nearby active area, and no held object, use primary player action
        else:
            get_node("..").tryEmptyInteract()
    elif player.is_interact_charging and Input.is_action_pressed("ui_interact"):
        if global.activeThrowableObject and player.interact_charge_timer < player.interact_charge_time_max:
            var was_less_than_3 = player.interact_charge_timer < 3
            player.interact_charge_timer += (delta*22)
            if was_less_than_3 and player.interact_charge_timer >= 3:
                player.startChargeSound.play()
            
            if player.interact_charge_timer >= player.interact_charge_time_max:
                #player.fullChargeSound.play()
                pass
    elif player.is_interact_charging:
        player.is_interact_charging = 0
        if global.activeThrowableObject:
            player.startChargeSound.stop()
            if Input.is_action_pressed("ui_crouch"):
                global.activeThrowableObject.activate_crouch(player.interact_charge_timer)
            else: 
                global.activeThrowableObject.activate(player.interact_charge_timer)
    # otherwise, try to interact passive areas
    elif nearest_passive_area:
        nearest_passive_area.PassiveInteractActivate(delta)     

# cast a ray from camera at mouse position, and get the object colliding with the ray
# from: https://www.reddit.com/r/godot/comments/8ft84k/get_clicked_object_in_3d/
func getActiveInteractionAreaUnderMouse():
    var RAY_LENGTH = 150
    var player = get_node("..")
    var TheCamera = player.getTrueCamera()
    
    var mouse_pos = get_viewport().get_mouse_position()
    var ray_from = TheCamera.project_ray_origin(mouse_pos)
    var ray_to = ray_from + TheCamera.project_ray_normal(mouse_pos) * RAY_LENGTH
    var space_state = get_world().direct_space_state
    var hits = []
    # dummy fill
    var selection = true
    while selection:
        selection = space_state.intersect_ray(ray_from, ray_to, hits)
        if selection:
            # see if the selection collider is a child of me!! 
            var collider = selection.collider
            while collider and collider.has_node("..") and collider.get_node("..") != get_tree():
                if collider.has_method("InteractActivate"): 
                    var areas = get_overlapping_areas()
                    if collider in areas: return collider
                collider = collider.get_node("..")
            # only gets here if the selection collider was not my child
            hits.append(selection.rid)
    return null