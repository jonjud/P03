extends Node2D

func _ready() -> void:
	var db = ItemDatabase.new()
	var ok = db.load_from_directory("res://data/")
	print("load ok: ", ok)                                  # ควรได้ true
	print("has wood_00: ", db.has_item(&"wood_00"))         # ควรได้ true
	print("has stone_00: ",db.has_item(&"stone_00"))
	print("get ไม่มีอันนี้: ", db.get_item(&"ไม่มีอันนี้"))   # ควรได้ <null>
