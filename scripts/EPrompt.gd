extends RichTextLabel

func _process(delta):
    var input_events = InputMap.get_action_list("ui_interact")
    for event in input_events:
        if event is InputEventKey:
            bbcode_text = "Press " + OS.get_scancode_string(event.scancode)