extends Node2D
#PickUpTest.gd

const MESSAGES : Dictionary = {
	&"ok": "",
	&"full": "กระเป๋าเต็ม",
	&"partial_full": "เก็บได้ไม่ครบ กระเป๋าเต็ม",
	&"error_null_id": "ไอเท็มนี้เก็บไม่ได้",
}

func _ready() -> void:
	$Player.pickup_done.connect(_on_pickup_done)
	$InventoryView.bind($Player.inv)

func _on_pickup_done(result: Dictionary) -> void:
	$MessageLabel.text = MESSAGES.get(result["reason"], "ไม่สามารถเก็บได้")
