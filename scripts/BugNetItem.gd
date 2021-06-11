extends "Item.gd"

func _ready():
    state = State.BUG_NET

func activate():
    getItem()