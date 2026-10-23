extends Resource
class_name Inventory

@export var slots: Array[InventorySlot] = []
@export var max_slots: int = 20          # หรือใช้ weight-based ภายหลัง
@export var owner_id: String = ""        # character / player / world storage
const SCHEMA_VERSION : int = 1

signal inventory_changed

func add_to_existing_stacks(db : ItemDatabase , id : StringName , quantity : int) -> Dictionary :
	var remaining : int = quantity #ใส่แล้วเหลือเท่าไหร่
	
	if db == null:
		return {"added" : 0, "remaining" : remaining , "reason" : &"error_null_id"}
	var item : ItemData = db.get_item(id) #item ดึงมาจาก id โดยใช้ฟังก์ชั่นหา item จาก id ที่เขียนไว้
	if item == null:
		return {"added" : 0, "remaining" : remaining , "reason" : &"error_null_id"}
	if quantity <= 0 :
		return {"added" : 0, "remaining" : remaining , "reason" : &"error_wrong_quantity"}
	
	#ไล่หาอันที่มีอยู่แล้ว (Existed) ก่อนแล้วเอาไปใส่ พอ quantity ที่ใส่หมดก็ break , แต่ถ้าใส่ไม่หมดก็เอาไปลบอันที่ใส่ไปแล้ว แล้วย้ายไปลูปต่อไป
	for slot in slots :
		if remaining <= 0 :
			break
		if slot.item_data != null and slot.item_data.id == id :
			var space : int = maxi(0,item.max_stack - slot.quantity) #ช่องว่าง
			var to_add : int = mini(space, remaining) #ช่องที่เติมได้
			slot.quantity += to_add
			remaining -= to_add #
	
	#พอหลุดจากลูปที่แล้วคือเติมอันที่มีอยู่แล้ว อาจจะไม่มีหรือใส่จนหมดละ , แล้วก็เพิ่มอันแรกที่เจอว่า item_data == null เลย เติมให้หมด แต่ถ้าไม่หมดไป slot ต่อไป (ใช้ slot ที่สร้างไว้อยู่แล้ว)
	for slot in slots :
		if remaining <= 0 :
			break
		if slot.item_data == null :
			var to_add : int = mini(item.max_stack , remaining)
			slot.item_data = item
			slot.quantity = to_add #ใช้ = เลยเพราะเรามีพื้นฐานว่าถ้าเริ่มช่องใหม่จะมี 1 เสมอ
			remaining -= to_add
	#เหมือนลูปข้างบนแต่สร้าง slot ใหม่เลย
	while remaining > 0 and slots.size() < max_slots :
		var s : InventorySlot = InventorySlot.new()
		var to_add : int = mini(item.max_stack , remaining)
		s.item_data = item
		s.quantity = to_add #ใช้ = เลยเพราะเรามีพื้นฐานว่าถ้าเริ่มช่องใหม่จะมี 1 เสมอ
		slots.append(s)
		remaining -= to_add
	var added : int = quantity - remaining
	var reason : StringName = &"ok"
	
	if remaining > 0 :
		reason = &"partial_full" if added > 0 else &"full"
	if added > 0 :
		inventory_changed.emit()
	return {"added" : added, "remaining" : remaining, "reason" : reason}

func remove_item(db: ItemDatabase, id: StringName, quantity: int) -> Dictionary:
	var remaining: int = quantity
	# 1. Validate input
	if db == null or db.get_item(id) == null:
		return {"removed": 0, "remaining": remaining, "reason": &"error_null_id"}
	if quantity <= 0:
		return {"removed": 0, "remaining": remaining, "reason": &"error_wrong_quantity"}
	# 2. Count only matching items before modifying slots
	var total: int = 0
	for slot in slots:
		if slot != null and slot.item_data != null and slot.item_data.id == id and slot.quantity > 0:
			total += slot.quantity
	# Atomic failure: leave slots unchanged
	if total < quantity:
		return {"removed": 0, "remaining": quantity, "reason": &"not_enough_quantity"}
	# 3. Remove from the last slot to the first
	for i in range(slots.size() - 1, -1, -1):
		if remaining == 0:
			break
		var slot = slots[i]
		if slot == null:
			continue
		if slot.item_data != null and slot.item_data.id == id and slot.quantity > 0:
			var to_remove: int = mini(slot.quantity, remaining)
			slot.quantity -= to_remove
			remaining -= to_remove
			# 4. Keep the slot; clear its contents
			if slot.quantity == 0:
				slot.item_data = null
	# 5. Return consistent result
	inventory_changed.emit()
	return {"removed": quantity - remaining, "remaining": remaining, "reason": &"ok"}

func swap_slots(a: int, b: int) -> Dictionary:
	if a < 0 or a >= max_slots or b < 0 or b >= max_slots :
		return {"swapped" : false ,"remaining" : 0 , "reason" : &"error_outside_inventory_index"}
	_ensure_size(maxi(a, b) + 1)
	var temp : InventorySlot = slots[a]
	slots[a] = slots[b]
	slots[b] = temp
	inventory_changed.emit()
	return {"swapped" : true,"remaining" : 0 ,"reason" : &"ok"}

func move_slots(from_index : int , to_index : int) -> Dictionary:
	# 1. เช็กขอบเขต (กับ max_slots) ก่อนแตะ slots
	if from_index < 0 or from_index >= max_slots or to_index < 0 or to_index >= max_slots :
		return {"moved" : false , "remaining" : 0 , "reason" : &"error_outside_inventory_index"}
	if from_index == to_index :
		return {"moved" : false , "remaining" : 0 , "reason" : &"error_same_index"}
	# 2. ต้นทางว่าง (รวมกรณีเกินขนาด array) ต้องล้มก่อนต่อช่อง
	if from_index >= slots.size() or slots[from_index] == null or slots[from_index].item_data == null :
		return {"moved" : false , "remaining" : 0 , "reason" : &"error_moving_null"}
	# 3. ผ่านการตรวจครบแล้วค่อยต่อช่อง
	_ensure_size(to_index + 1)
	var src : InventorySlot = slots[from_index]
	var dst : InventorySlot = slots[to_index]
	# 4. ปลายทางว่าง = ย้ายไปทั้งช่อง
	if dst.item_data == null :
		swap_slots(from_index , to_index)
		return {"moved" : true , "remaining" : 0 , "reason" : &"ok"}
	# 5. ชนิดเดียวกัน และปลายทางยังมีที่ว่าง = รวม stack
	if dst.item_data.id == src.item_data.id :
		var space : int = maxi(0 , dst.item_data.max_stack - dst.quantity)
		if space > 0 :
			var moved : int = mini(space , src.quantity)
			dst.quantity += moved
			src.quantity -= moved
			if src.quantity <= 0 :
				src.item_data = null
				src.quantity = 0
			inventory_changed.emit()
			return {"moved" : true , "remaining" : src.quantity , "reason" : &"ok"}

	# 6. นอกนั้น = สลับ
	swap_slots(from_index , to_index)
	return {"moved" : true , "remaining" : 0 , "reason" : &"ok"}

func transfer_to(other : Inventory , db : ItemDatabase, id : StringName,quantity : int) -> Dictionary:
	if db == null:
		return {"transferred": false, "remaining": 0, "reason": &"error_null_id"}
	if other == null:
		return {"transferred": false, "remaining": 0, "reason": &"error_null_inventory"}
	if other == self:
		return {"transferred": false, "remaining": 0, "reason": &"error_same_inventory"}
	
	var item : ItemData = db.get_item(id)
	if item == null:
		return {"transferred": false, "remaining": 0, "reason": &"error_null_id"}
	if quantity <= 0:
		return {"transferred": false, "remaining": 0, "reason": &"error_wrong_quantity"}
	var total: int = 0
	for slot in slots:
		if slot != null and slot.item_data != null and slot.item_data.id == id and slot.quantity > 0:
			total += slot.quantity
	if total < quantity:
		return {"transferred": false, "remaining": 0, "reason": &"error_not_enough_quantity"}
	var space : int = 0
	for dst_slot in other.slots :
		if dst_slot == null:
			continue
		if dst_slot.item_data == null:
			space += item.max_stack
		elif dst_slot.item_data.id == id:
			space += maxi(0,item.max_stack- dst_slot.quantity)
	space += maxi(0,other.max_slots - other.slots.size()) * item.max_stack
	
	if space < quantity :
		return {"transferred": false, "remaining": 0, "reason": &"error_destination_full"}
	var removed_result : Dictionary = remove_item(db, id, quantity)
	var added_result : Dictionary = other.add_to_existing_stacks(db, id, quantity)
	if removed_result["reason"] != &"ok" or added_result["reason"] != &"ok" :
		push_error("นับขั้น 3 ผิด")
		return {"transferred": false, "remaining": 0, "reason": &"error_internal"}
	return {"transferred": true, "remaining": 0, "reason": &"ok"}

func to_dict() -> Dictionary:
	var slt : Array = []
	for slot in slots:
		var dct : Dictionary = {}
		if slot == null or slot.item_data == null:
			dct["id"] = ""
			dct["quantity"] = 0
		else:
			dct["id"] = str(slot.item_data.id)
			dct["quantity"] = slot.quantity
		slt.append(dct)
	return {"schema_version": SCHEMA_VERSION, "owner_id": owner_id, "max_slots": max_slots, "slots": slt}

static func from_dict(data: Dictionary, db : ItemDatabase) -> Dictionary:
	if db == null:
		return {"ok": false, "inventory": null, "reason": &"error_db_null"}
	if not data.has("schema_version") or not data.has("owner_id") or not data.has("max_slots") or not data.has("slots"):
		return {"ok": false, "inventory": null, "reason": &"error_incomplete_data"}
	if data["schema_version"] != SCHEMA_VERSION:
		return {"ok": false, "inventory": null, "reason": &"error_incorrect_schema"}
	if typeof(data["owner_id"]) != TYPE_STRING:
		return {"ok": false, "inventory": null, "reason": &"error_incorrect_owner_id"}
	if typeof(data["max_slots"]) != TYPE_INT:
		return {"ok": false, "inventory": null, "reason": &"error_incorrect_max_slots"}
	if typeof(data["slots"]) != TYPE_ARRAY:
		return {"ok": false, "inventory": null, "reason": &"error_incorrect_slots_type"}
	if data["slots"].size() > data["max_slots"]:
		return {"ok": false, "inventory": null, "reason": &"error_slots_count_exceed"}
	# รอบที่ 1: ตรวจทุกช่องก่อน ยังไม่สร้างอะไร
	for s in data["slots"]:
		if typeof(s) != TYPE_DICTIONARY or not s.has("id") or not s.has("quantity"):
			return {"ok": false, "inventory": null, "reason": &"error_incomplete_slot"}
		if typeof(s["id"]) != TYPE_STRING or typeof(s["quantity"]) != TYPE_INT:
			return {"ok": false, "inventory": null, "reason": &"error_incorrect_slot"}
		if s["id"] == "":
			if s["quantity"] != 0:
				return {"ok": false, "inventory": null, "reason": &"error_incorrect_slot"}
			continue   # ช่องว่างถูกต้อง ตรวจรอบนี้เท่านั้น ไม่ได้ข้ามการสร้าง
		var item : ItemData = db.get_item(StringName(s["id"]))
		if item == null:
			return {"ok": false, "inventory": null, "reason": &"error_no_item_attached_to_id"}
		if s["quantity"] <= 0 or s["quantity"] > item.max_stack:
			return {"ok": false, "inventory": null, "reason": &"error_wrong_quantity"}
	# รอบที่ 2: ผ่านหมดแล้วค่อยสร้าง ทุกช่องต้องถูก append (รวมช่องว่าง)
	var inv : Inventory = Inventory.new()
	inv.owner_id = data["owner_id"]
	inv.max_slots = data["max_slots"]
	for s in data["slots"]:
		var slot : InventorySlot = InventorySlot.new()
		if s["id"] != "":
			slot.item_data = db.get_item(StringName(s["id"]))
			slot.quantity = s["quantity"]
		else:
			slot.quantity = 0
		inv.slots.append(slot)
	return {"ok": true, "inventory": inv, "reason": &"ok"}

func _ensure_size(n : int) -> void:
	while slots.size() < n :
		var s : InventorySlot = InventorySlot.new()
		s.quantity = 0      # default ของ InventorySlot เป็น 1 ต้องตั้ง 0 เอง
		slots.append(s)
