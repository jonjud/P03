extends Node2D

func _ready() -> void:
	var inventory : Inventory = Inventory.new()
	
	var db : ItemDatabase = ItemDatabase.new()
	db.load_from_directory("res://data/")
	
	var slot_1 = InventorySlot.new()
	var slot_2 = InventorySlot.new()
	slot_1.item_data = db.get_item(&"stone_00")
	slot_1.quantity = 90
	slot_2.item_data = db.get_item(&"stone_00")
	slot_2.quantity = 50
	
	inventory.slots.append(slot_1)
	inventory.slots.append(slot_2)
	
	print(inventory.add_to_existing_stacks(db,&"stone_00",5))
	print("Slot 1 : ", slot_1.quantity)
	print("Slot 2 :", slot_2.quantity)
	print(inventory.add_to_existing_stacks(db,&"stone_00",20))
	print("Slot 1 : ", slot_1.quantity)
	print("Slot 2 :", slot_2.quantity)
	print(inventory.add_to_existing_stacks(db,&"ไม่มีอันนี้",20))
	print("Slot 1 : ", slot_1.quantity)
	print("Slot 2 :", slot_2.quantity)
