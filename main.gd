
extends Node2D


func _ready() -> void:
	var db: ItemDatabase = ItemDatabase.new()
	db.load_from_directory("res://data/")
	var item = db.get_item(&"stone_00")
	
	if item == null:
		print("ERROR: stone_00 not found")
		return
		
	# CASE 1: มี 99 หัก 30 -> เหลือ 69
	var inv1: Inventory = Inventory.new()
	add_test_slot(inv1, item, 99)
	
	var result1: Dictionary = inv1.remove_item(db, &"stone_00", 30)
	
	print("\n===== CASE 1: REMOVE PARTIAL =====")
	print_result(inv1, result1)
	
	# CASE 2: มี 99 หัก 99 -> ช่องว่าง
	var inv2: Inventory = Inventory.new()
	add_test_slot(inv2, item, 99)
	
	var result2: Dictionary = inv2.remove_item(db, &"stone_00", 99)
	
	print("\n===== CASE 2: REMOVE ALL =====")
	print_result(inv2, result2)
	
	# CASE 3: มี 99 กับ 50 หัก 120
	# ช่องท้ายต้องว่าง ช่องแรกเหลือ 29
	var inv3: Inventory = Inventory.new()
	add_test_slot(inv3, item, 99)
	add_test_slot(inv3, item, 50)
	
	var result3: Dictionary = inv3.remove_item(db, &"stone_00", 120)
	
	print("\n===== CASE 3: REMOVE FROM LAST SLOT =====")
	print_result(inv3, result3)
	
	# CASE 4: มีรวม 149 หัก 150
	# ต้องล้มเหลว และจำนวนเดิมต้องไม่เปลี่ยน
	var inv4: Inventory = Inventory.new()
	add_test_slot(inv4, item, 99)
	add_test_slot(inv4, item, 50)
	
	var result4: Dictionary = inv4.remove_item(db, &"stone_00", 150)
	
	print("\n===== CASE 4: NOT ENOUGH =====")
	print_result(inv4, result4)
	
	# CASE 5: มีช่องว่างปนอยู่ 50 / ว่าง / 30 หัก 60
	# ช่องท้ายว่าง ช่องแรกเหลือ 20 ช่องกลางยังว่าง และต้องไม่ crash
	var inv5: Inventory = Inventory.new()
	add_test_slot(inv5, item, 50)
	add_test_slot(inv5, null, 0)
	add_test_slot(inv5, item, 30)
	
	var result5: Dictionary = inv5.remove_item(db, &"stone_00", 60)
	
	print("\n===== CASE 5: EMPTY SLOT IN THE MIDDLE =====")
	print_result(inv5, result5)


# สร้าง slot สำหรับ test
func add_test_slot(inv: Inventory,item,amount: int) -> void:
	var slot: InventorySlot = InventorySlot.new()
	slot.item_data = item
	slot.quantity = amount
	inv.slots.append(slot)

# แสดงผลลัพธ์และทุกช่อง
func print_result(inv: Inventory,result: Dictionary) -> void:
	print("Removed: ", result["removed"])
	print("Remaining: ", result["remaining"])
	print("Reason: ", result["reason"])
	print("Slot count: ", inv.slots.size())

	for i in range(inv.slots.size()):
		var slot: InventorySlot = inv.slots[i]
		print("Slot ", i + 1," | item_data == null: ", slot.item_data == null," | quantity: ", slot.quantity)
