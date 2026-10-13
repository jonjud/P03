extends Resource
class_name Inventory

@export var slots: Array[InventorySlot] = []
@export var max_slots: int = 20          # หรือใช้ weight-based ภายหลัง
@export var owner_id: String = ""        # character / player / world storage

func add_to_existing_stacks(db : ItemDatabase , id : StringName , quantity : int) -> Dictionary :
	var remaining : int = quantity	
	var item : ItemData = db.get_item(id)
	if item == null :
		return {"added" : 0, "remaining" : remaining , "reason" : "there's no item attached to the id"}
	if quantity <= 0 :
		return {"added" : 0, "remaining" : remaining , "reason" : "Why you wanna add 0 or lesser than that ? "}
	for slot in slots :
		if remaining <= 0 :
			break
		if slot.item_data != null and slot.item_data.id == id :
			var space : int = maxi(0,item.max_stack - slot.quantity) #ช่องว่าง
			var to_add : int = mini(space, remaining) #ช่องที่เติมได้
			slot.quantity += to_add
			remaining -= to_add
	for slot in slots :
		if remaining <= 0 :
			break
		if slot.item_data == null :
			var to_add : int = mini(item.max_stack , remaining)
			slot.item_data = item
			slot.quantity = to_add #ใช้ = เลยเพราะเรามีพื้นฐานว่าถ้าเริ่มช่องใหม่จะมี 1 เสมอ
			remaining -= to_add
			
	while remaining > 0 and slots.size() < max_slots :
		var s : InventorySlot = InventorySlot.new()
		var to_add : int = mini(item.max_stack , remaining)
		s.item_data = item
		s.quantity = to_add #ใช้ = เลยเพราะเรามีพื้นฐานว่าถ้าเริ่มช่องใหม่จะมี 1 เสมอ
		slots.append(s)
		remaining -= to_add
	return {"added" : quantity - remaining, "remaining" : remaining, "reason" : "ok"}
