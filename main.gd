extends Node2D


func _ready() -> void:
	var db: ItemDatabase = ItemDatabase.new()
	db.load_from_directory("res://data/")
	var item_1 = db.get_item(&"stone_00")
	var item_2 = db.get_item(&"wood_00")
	var item_3 = db.get_item(&"wooden_sword_00")
	
	var inv1 : Inventory = Inventory.new()
	add_test_slot(inv1,item_1,99)
	add_test_slot(inv1,null,0)
	var result1 : Dictionary = inv1.move_slots(0,1)
	print("====CASE 1====")
	print_result_moved(inv1,result1)
	
	var inv2 : Inventory = Inventory.new()
	add_test_slot(inv2,item_1,30)
	add_test_slot(inv2,item_1,20)
	var result2 : Dictionary = inv2.move_slots(0,1)
	print("====CASE 2====")
	print_result_moved(inv2,result2)
	
	var inv3 : Inventory = Inventory.new()
	add_test_slot(inv3,item_2,99)
	add_test_slot(inv3,item_2,50)
	var result3 : Dictionary = inv3.move_slots(0,1)
	print("====CASE 3====")
	print_result_moved(inv3,result3)
	
	var inv4 : Inventory = Inventory.new()
	add_test_slot(inv4,item_1,66)
	add_test_slot(inv4,item_2,55)
	var result4 : Dictionary = inv4.move_slots(0,1)
	print("====CASE 4====")
	print_result_moved(inv4,result4)
	
	var inv5 : Inventory = Inventory.new()
	add_test_slot(inv5,item_3,1)
	add_test_slot(inv5,item_3,1)
	var result5 : Dictionary = inv5.move_slots(0,1)
	print("====CASE 5====")
	print_result_moved(inv5,result5)
	
	var inv6 : Inventory = Inventory.new()
	add_test_slot(inv6,null,0)
	add_test_slot(inv6,item_2,55)
	var result6 : Dictionary = inv6.move_slots(0,1)
	print("====CASE 6====")
	print_result_moved(inv6,result6)
	
	var inv7 : Inventory = Inventory.new()
	add_test_slot(inv7,item_2,66)
	add_test_slot(inv7,item_2,55)
	var result7 : Dictionary = inv7.move_slots(-1,2)
	print("====CASE 7====")
	print_result_moved(inv7,result7)
	
	var inv8 : Inventory = Inventory.new()
	add_test_slot(inv8,item_1,66)
	add_test_slot(inv8,item_2,55)
	var result8 : Dictionary = inv8.move_slots(5,5)
	print("====CASE 8====")
	print_result_moved(inv8,result8)
	
	var inv9 : Inventory = Inventory.new()
	add_test_slot(inv9,item_1,66)
	add_test_slot(inv9,item_2,55)
	var result9 : Dictionary = inv9.move_slots(0,0)
	print("====CASE 9====")
	print_result_moved(inv9,result9)
	
	





# สร้าง slot สำหรับ test
func add_test_slot(inv: Inventory,item : ItemData ,amount: int) -> void:
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
	for i in range(inv.slots.size()):
		var slot: InventorySlot = inv.slots[i]
		print("Slot ", i + 1," | item_data == null: ", slot.item_data == null," | quantity: ", slot.quantity)

func print_result_swapped(inv: Inventory,result: Dictionary) -> void:
	print("Swapped: ", result["swapped"])
	print("Reason: ", result["reason"])
	print("Slot count: ", inv.slots.size())
	for i in range(inv.slots.size()):
		var slot: InventorySlot = inv.slots[i]
		print("Slot ", i + 1," | item_data == null: ", slot.item_data == null," | quantity: ", slot.quantity)

func print_result_removed(inv: Inventory,result: Dictionary) -> void:
	print("Removed: ", result["removed"])
	print("Remaining: ", result["remaining"])
	print("Reason: ", result["reason"])
	print("Slot count: ", inv.slots.size())
	for i in range(inv.slots.size()):
		var slot: InventorySlot = inv.slots[i]
		print("Slot ", i + 1," | item_data == null: ", slot.item_data == null," | quantity: ", slot.quantity)

func print_result_moved(inv: Inventory,result: Dictionary) -> void:
	print("Moved: ", result["moved"])
	print("Remaining: ", result["remaining"])
	print("Reason: ", result["reason"])
	print("Slot count: ", inv.slots.size())
	for i in range(inv.slots.size()):
		var slot: InventorySlot = inv.slots[i]
		print("Slot ", i + 1," | item_data == null: ", slot.item_data == null," | quantity: ", slot.quantity)
