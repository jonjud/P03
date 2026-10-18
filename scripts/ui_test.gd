extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var db : ItemDatabase = ItemDatabase.new()
	db.load_from_directory("res://data/")
	var inv : Inventory = Inventory.new()
	inv.add_to_existing_stacks(db, &"stone_00", 120)
	inv.add_to_existing_stacks(db, &"fiber_00", 5)
	$InventoryView.bind(inv)
	inv.remove_item(db,&"stone_00",30)
	$InventoryView.refresh()
	
