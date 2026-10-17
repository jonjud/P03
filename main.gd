extends Node2D


func _ready() -> void:
	var db: ItemDatabase = ItemDatabase.new()
	db.load_from_directory("res://data/")
	var item_1 = db.get_item(&"stone_00")
	var item_2 = db.get_item(&"wood_00")
	var item_3 = db.get_item(&"wooden_sword_00")
	
	#Case 1 เคสปกติ
	var inv1_1 : Inventory = Inventory.new()
	var inv1_2 : Inventory = Inventory.new()
	add_test_slot(inv1_1,item_1,50)
	add_test_slot(inv1_2,item_1,20)
	print_slots("SRC1",inv1_1)
	print_slots("DST1",inv1_2)
	var result1 : Dictionary = inv1_1.transfer_to(inv1_2,db,&"stone_00",30)
	print_slots("SRC1",inv1_1)
	print_slots("DST1",inv1_2)
	print("====CASE 1====")
	print_result_transfer(inv1_1,result1)
	
	#Case 2 full dst slot
	var inv2_1 : Inventory = Inventory.new()
	var inv2_2 : Inventory = Inventory.new()
	add_test_slot(inv2_1,item_1,50)
	inv2_2.max_slots = 1
	add_test_slot(inv2_2,item_1,90)
	print_slots("SRC2",inv2_1)
	print_slots("DST2",inv2_2)
	var result2 : Dictionary = inv2_1.transfer_to(inv2_2,db,&"stone_00",20)
	print_slots("SRC2",inv2_1)
	print_slots("DST2",inv2_2)
	print("====CASE 2====")
	print_result_transfer(inv2_1,result2)
	
	#Case 3 not enough src quantity
	var inv3_1 : Inventory = Inventory.new()
	var inv3_2 : Inventory = Inventory.new()
	add_test_slot(inv3_1,item_1,10)
	add_test_slot(inv3_2,item_1,20)
	print_slots("SRC3",inv3_1)
	print_slots("DST3",inv3_2)
	var result3 : Dictionary = inv3_1.transfer_to(inv3_2,db,&"stone_00",20)
	print_slots("SRC3",inv3_1)
	print_slots("DST3",inv3_2)
	print("====CASE 3====")
	print_result_transfer(inv3_1,result3)
	
	#Case 4 transfer to own self
	var inv4_1 : Inventory = Inventory.new()
	add_test_slot(inv4_1,item_1,10)
	print_slots("SRC4",inv4_1)
	print_slots("DST4",inv4_1)
	var result4 : Dictionary = inv4_1.transfer_to(inv4_1,db,&"stone_00",20)
	print_slots("SRC4",inv4_1)
	print_slots("DST4",inv4_1)
	print("====CASE 4====")
	print_result_transfer(inv4_1,result4)
	
	#Case 5 มี 90 โอนเข้า 9 พอดี
	var inv5_1 : Inventory = Inventory.new()
	var inv5_2 : Inventory = Inventory.new()
	add_test_slot(inv5_1,item_1,50)
	inv5_2.max_slots = 1
	add_test_slot(inv5_2,item_1,90)
	print_slots("SRC5",inv5_1)
	print_slots("DST5",inv5_2)
	var result5 : Dictionary = inv5_1.transfer_to(inv5_2,db,&"stone_00",9)
	print_slots("SRC5",inv5_1)
	print_slots("DST5",inv5_2)
	print("====CASE 5====")
	print_result_transfer(inv5_1,result5)
	
	#Case 6 src = stone , dst = 2 max slot 1 is wood 2 is null
	var inv6_1 : Inventory = Inventory.new()
	var inv6_2 : Inventory = Inventory.new()
	add_test_slot(inv6_1,item_1,50)
	inv6_2.max_slots = 2
	add_test_slot(inv6_2,item_2,10)
	print_slots("SRC6",inv6_1)
	print_slots("DST6",inv6_2)
	var result6 : Dictionary = inv6_1.transfer_to(inv6_2,db,&"stone_00",50)
	print_slots("SRC6",inv6_1)
	print_slots("DST6",inv6_2)
	print("====CASE 6====")
	print_result_transfer(inv6_1,result6)
	
	#Case 7: other ==null , db == null
	var inv7_1 : Inventory = Inventory.new()
	var inv7_2 : Inventory = Inventory.new()
	add_test_slot(inv7_1,item_1,50)
	print_slots("SRC7",inv7_1)
	print_slots("DST7",inv7_2)
	var result7_1 : Dictionary = inv7_1.transfer_to(null,db,&"stone_00",10)
	var result7_2 : Dictionary = inv7_1.transfer_to(inv7_2,null,&"stone_00",10)
	print_slots("SRC7",inv7_1)
	print_slots("DST7",inv7_2)
	print("====CASE 7_1_OtherNull====")
	print_result_transfer(inv7_1,result7_1)
	print("====CASE 7_2_DBNull====")
	print_result_transfer(inv7_1,result7_2)
	
	#Case 8 : 2 slots in inv 8_1 ,1 is 90 stone , 2 is 50 and able to transfer 120 stone to dst
	var inv8_1 : Inventory = Inventory.new()
	var inv8_2 : Inventory = Inventory.new()
	add_test_slot(inv8_1,item_1,90)
	add_test_slot(inv8_1,item_1,50)
	print_slots("SRC8",inv8_1)
	print_slots("DST8",inv8_2)
	var result8 : Dictionary = inv8_1.transfer_to(inv8_2,db,&"stone_00",120)
	print_slots("SRC8",inv8_1)
	print_slots("DST8",inv8_2)
	print("====CASE 8====")
	print_result_transfer(inv8_1,result8)
	





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

func print_result_transfer(inv: Inventory,result: Dictionary) -> void:
	print("Transfer: ", result["transferred"])
	print("Remaining: ", result["remaining"])
	print("Reason: ", result["reason"])
	print("Slot count: ", inv.slots.size())
	for i in range(inv.slots.size()):
		var slot: InventorySlot = inv.slots[i]
		print("Slot ", i + 1," | item_data == null: ", slot.item_data == null," | quantity: ", slot.quantity)

func print_slots(label : String , inv : Inventory) -> void:
	print(label, " (", inv.slots.size(), " slots)")
	for i in range(inv.slots.size()):
		var slot : InventorySlot = inv.slots[i]
		print("  Slot ", i + 1, " | null: ", slot.item_data == null, " | qty: ", slot.quantity)
