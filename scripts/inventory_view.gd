extends Control

var inv : Inventory

# [ขั้น 1] สถานะการเลือกช่องบนหน้าจอ
# -1 หมายถึงยังไม่ได้เลือกช่องไหน
# เป็น UI state ไม่ใช่ข้อมูลที่เก็บใน Inventory
var selected : int = -1

@onready var grid_con : GridContainer = $GridContainer


func _ready() -> void:
	pass


func bind(inventory : Inventory) -> void:
	inv = inventory
	selected = -1
	refresh()


func refresh() -> void:
	if inv == null:
		return

	for child in grid_con.get_children():
		grid_con.remove_child(child)
		child.queue_free()

	for i in range(inv.max_slots):
		var cell : Button = Button.new()
		cell.pressed.connect(_on_cell_pressed.bind(i))
		cell.custom_minimum_size = Vector2(80, 50)

		if i < inv.slots.size() and inv.slots[i].item_data != null:
			cell.text = "%s\nx%d" % [
				inv.slots[i].item_data.display_name,
				inv.slots[i].quantity
			]
		else:
			cell.text = "-"

		grid_con.add_child(cell)


func _on_cell_pressed(i : int) -> void:
	# [ขั้น 2] กรณีที่ 1: ยังไม่ได้เลือกช่องต้นทาง
	if selected == -1:
		# ตรวจสอบว่าช่องอยู่ใน Array จริง และมีไอเทม
		if i < inv.slots.size() and inv.slots[i].item_data != null:
			selected = i
			print("Selected slot:", selected)
		# ถ้าเป็นช่องว่าง จะไม่ทำอะไร
		return
		
	# กรณีที่ 2: เลือกช่องต้นทางไว้แล้ว
	var result = inv.move_slots(selected, i)
	# ยกเลิกการเลือกช่องต้นทางหลังจากลองย้าย
	selected = -1
	# [ขั้น 3] แสดงเหตุผลของผลลัพธ์ก่อน
	print("Move result reason:", result["reason"])
	# [ขั้น 4] อัปเดตหน้าจอให้ตรงกับ Inventory
	refresh()
