extends Node2D


func _ready() -> void:
	var db: ItemDatabase = ItemDatabase.new()
	db.load_from_directory("res://data/")
	
	# CASE 1: เติม 250 stone โดยมี 2 ช่อง
	var inv1: Inventory = Inventory.new()
	inv1.max_slots = 2
	
	var result1: Dictionary = inv1.add_to_existing_stacks(
		db, &"stone_00", 250
	)
	
	print("\n===== CASE 1: PARTIAL FULL =====")
	print_result(inv1, result1)
	
	# CASE 2: ทุกช่องเต็ม 99 แล้วเติมอีก 10
	var inv2: Inventory = Inventory.new()
	inv2.max_slots = 2
	
	for i in range(2):
		var slot: InventorySlot = InventorySlot.new()
		slot.item_data = db.get_item(&"stone_00")
		slot.quantity = 99
		inv2.slots.append(slot)
		
	var result2: Dictionary = inv2.add_to_existing_stacks(db, &"stone_00", 10)
	
	print("\n===== CASE 2: FULL =====")
	print_result(inv2, result2)
	
	# CASE 3: เติมพอดีกับพื้นที่ว่าง
	var inv3: Inventory = Inventory.new()
	inv3.max_slots = 2
	
	var slot3: InventorySlot = InventorySlot.new()
	slot3.item_data = db.get_item(&"stone_00")
	slot3.quantity = 90
	inv3.slots.append(slot3)
	
	var result3: Dictionary = inv3.add_to_existing_stacks(db, &"stone_00", 9)
	
	print("\n===== CASE 3: OK =====")
	print_result(inv3, result3)
	
	#CASE 4: (อันเก่า) สร้าง 2 slots แล้วเติม 5 ใน slot แรก
	var inv4: Inventory = Inventory.new()
	var slot4_1: InventorySlot = InventorySlot.new()
	var slot4_2: InventorySlot = InventorySlot.new()
	
	slot4_1.item_data = db.get_item(&"stone_00")
	slot4_1.quantity = 90
	slot4_2.item_data = db.get_item(&"stone_00")
	slot4_2.quantity = 50
	
	inv4.slots.append(slot4_1)
	inv4.slots.append(slot4_2)
	
	var result4: Dictionary = inv4.add_to_existing_stacks(db,&"stone_00",5)
	print("\n===== CASE 4: OK=====")
	print_result(inv4, result4)
	
	#Case 5: slot 1 = 90, slot 2 = 50 เติม 90 → ต้องได้ 99 / 99 / ช่องใหม่ 37
	var inv5: Inventory = Inventory.new()
	var slot5_1: InventorySlot = InventorySlot.new()
	var slot5_2: InventorySlot = InventorySlot.new()
	
	slot5_1.item_data = db.get_item(&"stone_00")
	slot5_1.quantity = 90
	slot5_2.item_data = db.get_item(&"stone_00")
	slot5_2.quantity = 50
	
	inv5.slots.append(slot5_1)
	inv5.slots.append(slot5_2)
	
	var result5: Dictionary = inv5.add_to_existing_stacks(db,&"stone_00",90)
	print("\n===== CASE 5: PARTIAL FULL=====")
	print_result(inv5,result5)


func print_result(inv: Inventory, result: Dictionary) -> void:
	print("Added: ", result["added"])
	print("Remaining: ", result["remaining"])
	print("Reason: ", result["reason"])
	print("Slot count: ", inv.slots.size())
	for i in range(inv.slots.size()):
		print("Slot ", i + 1, ": ", inv.slots[i].quantity)
