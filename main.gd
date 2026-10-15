
extends Node2D


func _ready() -> void:
	var db: ItemDatabase = ItemDatabase.new()
	db.load_from_directory("res://data/")
	var item = db.get_item(&"wooden_sword_00")
	
	if item == null:
		print("ERROR: wooden_sword_00 not found")
		return
		
	var inv1 : Inventory = Inventory.new()
	var inv2 : Inventory = Inventory.new()
	var inv3 : Inventory = Inventory.new()
	var inv4 : Inventory = Inventory.new()
	var inv5 : Inventory = Inventory.new()
	
	#Case 1
	print("====CASE 1====")
	var result1 : Dictionary = inv1.add_to_existing_stacks(db,&"wooden_sword_00",3)
	print_result(inv1,result1)
	
	#Case 2
	print("\n====CASE 2====")
	var slot2_1 : InventorySlot = InventorySlot.new()
	slot2_1.item_data = db.get_item(&"wooden_sword_00")
	slot2_1.quantity = 1
	inv2.slots.append(slot2_1)
	var result2 : Dictionary = inv2.add_to_existing_stacks(db,&"wooden_sword_00",1)
	print_result(inv2,result2)
	
	#Case3
	inv3.max_slots = 2
	var result3 : Dictionary = inv3.add_to_existing_stacks(db,&"wooden_sword_00",3)
	
	print("\n====CASE 3====")
	print_result(inv3,result3)
	
	#Case 4
	var slot4_1 : InventorySlot = InventorySlot.new()
	var slot4_2 : InventorySlot = InventorySlot.new()
	var slot4_3: InventorySlot = InventorySlot.new()
	
	slot4_1.item_data = db.get_item(&"wooden_sword_00")
	slot4_2 .item_data = db.get_item(&"wooden_sword_00")
	slot4_3 .item_data = db.get_item(&"wooden_sword_00")

	inv4.slots.append(slot4_1)
	inv4.slots.append(slot4_2)
	inv4.slots.append(slot4_3)

	var result4 : Dictionary = inv4.remove_item(db,&"wooden_sword_00",1)

	print("\n====CASE 4====")
	print_result_removed(inv4,result4)

	#Case 5
	var slot5_1 : InventorySlot = InventorySlot.new()
	var slot5_2 : InventorySlot = InventorySlot.new()
	var slot5_3: InventorySlot = InventorySlot.new()

	slot5_1.item_data = db.get_item(&"wooden_sword_00")
	slot5_2.quantity = 0
	slot5_3 .item_data = db.get_item(&"wooden_sword_00")

	inv5.slots.append(slot5_1)
	inv5.slots.append(slot5_2)
	inv5.slots.append(slot5_3)

	var result5 : Dictionary = inv5.remove_item(db,&"wooden_sword_00",1)

	print("\n====CASE 5====")
	print_result_removed(inv5,result5)





# สร้าง slot สำหรับ test
func add_test_slot(inv: Inventory,item,amount: int) -> void:
	var slot: InventorySlot = InventorySlot.new()
	slot.item_data = item
	slot.quantity = amount
	inv.slots.append(slot)

# แสดงผลลัพธ์และทุกช่อง
func print_result(inv: Inventory,result: Dictionary) -> void:
	print("Added: ", result["added"])
	print("Remaining: ", result["remaining"])
	print("Reason: ", result["reason"])
	print("Slot count: ", inv.slots.size())

func print_result_removed(inv: Inventory,result: Dictionary) -> void:
	print("Removed: ", result["removed"])
	print("Remaining: ", result["remaining"])
	print("Reason: ", result["reason"])
	print("Slot count: ", inv.slots.size())

	for i in range(inv.slots.size()):
		var slot: InventorySlot = inv.slots[i]
		print("Slot ", i + 1," | item_data == null: ", slot.item_data == null," | quantity: ", slot.quantity)
