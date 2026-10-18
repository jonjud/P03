extends Control

var inv : Inventory 
@onready var grid_con : GridContainer = $GridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func bind(inventory : Inventory) -> void:
	inv = inventory
	refresh()

func refresh() -> void:
	if inv == null:
		return
	for child in grid_con.get_children() :
		child.queue_free()
	for i in range(inv.max_slots) :
		var cell : Label = Label.new()
		cell.custom_minimum_size = Vector2(80,50)
		if i < inv.slots.size() and inv.slots[i].item_data != null:
			cell.text = "%s\nx%d" % [inv.slots[i].item_data.display_name,inv.slots[i].quantity]
		else :
			cell.text = "-"
		grid_con.add_child(cell)
