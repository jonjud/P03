extends Node

var db : ItemDatabase = ItemDatabase.new()
var inv : Inventory = Inventory.new()
var invB : Inventory = Inventory.new()

# ช่องที่เลือกไว้: อยู่กระเป๋าไหน (null = ยังไม่ได้เลือก) และช่องที่เท่าไหร่
var selected_inv : Inventory = null
var selected_index : int = -1

func _ready() -> void:
	db.load_from_directory("res://data/")
	invB.max_slots = 5
	inv.add_to_existing_stacks(db, &"stone_00", 120)
	inv.add_to_existing_stacks(db, &"fiber_00", 5)
	$InventoryView.bind(inv)
	$InventoryViewB.bind(invB)
	# สัญญาณส่ง index มาก่อน แล้ว bind ต่อท้ายว่า "คลิกมาจากกระเป๋าไหน"
	$InventoryView.slot_clicked.connect(_on_view_clicked.bind(inv))
	$InventoryViewB.slot_clicked.connect(_on_view_clicked.bind(invB))

func _on_view_clicked(i : int , clicked_inv : Inventory) -> void:
	# คลิกแรก: เลือกช่องต้นทาง (ต้องมีของ)
	if selected_inv == null :
		if i < clicked_inv.slots.size() and clicked_inv.slots[i].item_data != null :
			selected_inv = clicked_inv
			selected_index = i
			print("Selected slot ", i)
		return
	# คลิกที่สอง
	var result : Dictionary
	if selected_inv == clicked_inv : #ใช้ selected และ clicked_inv เพื่อแยกระหว่างกระเป๋าเดียวกันและคนละกระเป๋า
		result = clicked_inv.move_slots(selected_index, i)
		print("Move result: ", result["reason"])
	else :
		var slot : InventorySlot = selected_inv.slots[selected_index]
		result = selected_inv.transfer_to(clicked_inv, db, slot.item_data.id, slot.quantity)
		print("Transfer result: ", result["reason"])
	selected_inv = null
	selected_index = -1
	$InventoryView.refresh()
	$InventoryViewB.refresh()
