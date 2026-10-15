extends Node2D


func _ready() -> void:
	var db: ItemDatabase = ItemDatabase.new()
	db.load_from_directory("res://data/")
	var item = db.get_item(&"stone_00")
	
	var inv1 : Inventory = Inventory.new()
	var slot1 : InventorySlot = InventorySlot.new()
	slot1.item_data = item
	slot1.quantity = 50
	inv1.slots.append(slot1)
	
	#Case 1 : 
	var result1_1 : Dictionary = inv1.add_to_existing_stacks(null,&"stone_00",1)
	print_result(inv1,result1_1)
	var result1_2 : Dictionary = inv1.remove_item(null,&"stone_00",1)
	print_result_removed(inv1,result1_2)
	#Case 2 :
	var result2_1 : Dictionary = inv1.add_to_existing_stacks(db,&"stone_00",0)
	print_result(inv1,result2_1)
	var result2_2 : Dictionary = inv1.remove_item(db,&"stone_00",0)
	print_result_removed(inv1,result2_2)
	#Case 3 :
	var result3_1 : Dictionary = inv1.add_to_existing_stacks(db,&"stone_00",-1)
	print_result(inv1,result3_1)
	var result3_2 : Dictionary = inv1.remove_item(db,&"stone_00",-1)
	print_result_removed(inv1,result3_2)
	#Case 4 :
	var result4_1 : Dictionary = inv1.add_to_existing_stacks(db,&"not_existed_id",1)
	print_result(inv1,result4_1)
	var result4_2 : Dictionary = inv1.remove_item(db,&"not_existed_id",1)
	print_result_removed(inv1,result4_2)
	
	
	
	
	





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
