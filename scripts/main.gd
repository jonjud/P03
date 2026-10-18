extends Node2D


func _ready() -> void:
	InventoryTests.new().run_all()
