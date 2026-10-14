extends Resource
class_name Inventory

@export var slots: Array[InventorySlot] = []
@export var max_slots: int = 20          # หรือใช้ weight-based ภายหลัง
@export var owner_id: String = ""        # character / player / world storage


func add_to_existing_stacks(db : ItemDatabase , id : StringName , quantity : int) -> Dictionary :
	var remaining : int = quantity #ใส่แล้วเหลือเท่าไหร่
	var item : ItemData = db.get_item(id) #item ดึงมาจาก id โดยใช้ฟังก์ชั่นหา item จาก id ที่เขียนไว้
	
	if item == null :
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
	return {"removed": quantity - remaining, "remaining": remaining, "reason": &"ok"}

	
	
	
