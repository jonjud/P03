extends Node

var db : ItemDatabase = ItemDatabase.new()
var inv : Inventory = Inventory.new()
var invB : Inventory = Inventory.new()
const MESSAGES : Dictionary = {
	&"ok": "",
	&"error_destination_full": "ช่องเก็บของปลายทางเต็ม",
	&"error_same_index": "เลือกช่องเดิมซ้ำ",
	&"error_moving_null": "ช่องนี้ไม่มีของให้ย้าย",
	&"error_not_enough_quantity": "ของไม่พอ",
	&"error_outside_inventory_index": "ช่องนี้อยู่นอกกระเป๋า",
	}

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

func _show(reason : StringName) -> void:
	$MessageLabel.text = MESSAGES.get(reason, "ไม่สามารถทำได้")

func _on_view_clicked(i : int , clicked_inv : Inventory) -> void:
	# คลิกแรก: เลือกช่องต้นทาง (ต้องมีของ)
	if selected_inv == null :
		if i < clicked_inv.slots.size() and clicked_inv.slots[i].item_data != null :
			selected_inv = clicked_inv
			selected_index = i
			$MessageLabel.text = "เลือกช่อง " + str(i + 1) + " แล้ว เลือกปลายทาง"
		else :
			_show(&"error_moving_null")
		return
	# คลิกที่สอง
	var result : Dictionary
	if selected_inv == clicked_inv :
		result = clicked_inv.move_slots(selected_index, i)
	else :
		var slot : InventorySlot = selected_inv.slots[selected_index]
		result = selected_inv.transfer_to(clicked_inv, db, slot.item_data.id, slot.quantity)
	_show(result["reason"])
	selected_inv = null
	selected_index = -1
