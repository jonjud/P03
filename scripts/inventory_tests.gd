extends RefCounted
class_name InventoryTests

var db : ItemDatabase = ItemDatabase.new()
var passed : int = 0
var failed : int = 0

func run_all() -> void:
	db.load_from_directory("res://data/")
	test_add()
	test_remove()
	test_nonstackable()
	test_invalid_input()
	test_swap()
	test_move()
	test_transfer()
	print("Passed ", passed, " / Failed ", failed)

# ---------- helpers ----------
func check(label : String , condition : bool) -> void:
	if condition :
		passed += 1
	else :
		failed += 1
		print("FAIL: ", label)

func stone() -> ItemData:
	return db.get_item(&"stone_00")
func wood() -> ItemData:
	return db.get_item(&"wood_00")
func sword() -> ItemData:
	return db.get_item(&"wooden_sword_00")

func add_test_slot(inv : Inventory , item : ItemData , amount : int) -> void:
	var slot : InventorySlot = InventorySlot.new()
	slot.item_data = item
	slot.quantity = amount
	inv.slots.append(slot)

func qtys(inv : Inventory) -> Array:
	var out : Array = []
	for s in inv.slots :
		out.append(s.quantity)
	return out

func ids(inv : Inventory) -> Array:
	var out : Array = []
	for s in inv.slots :
		out.append(s.item_data.id if s.item_data != null else &"")
	return out

func total_of(inv : Inventory) -> int:
	var t : int = 0
	for s in inv.slots :
		if s.item_data != null and s.item_data.id == &"stone_00" :
			t += s.quantity
	return t

func check_add(label : String , inv : Inventory , r : Dictionary , added : int , remaining : int , reason : StringName , expected : Array) -> void:
	check(label + " added", r["added"] == added)
	check(label + " remaining", r["remaining"] == remaining)
	check(label + " reason", r["reason"] == reason)
	check(label + " slots", qtys(inv) == expected)

func check_remove(label : String , inv : Inventory , r : Dictionary , removed : int , remaining : int , reason : StringName , expected : Array) -> void:
	check(label + " removed", r["removed"] == removed)
	check(label + " remaining", r["remaining"] == remaining)
	check(label + " reason", r["reason"] == reason)
	check(label + " slots", qtys(inv) == expected)

func check_move(label : String , inv : Inventory , r : Dictionary , moved : bool , remaining : int , reason : StringName , expected : Array) -> void:
	check(label + " moved", r["moved"] == moved)
	check(label + " remaining", r["remaining"] == remaining)
	check(label + " reason", r["reason"] == reason)
	check(label + " slots", qtys(inv) == expected)

func check_swap(label : String , inv : Inventory , r : Dictionary , swapped : bool , reason : StringName , expected : Array) -> void:
	check(label + " swapped", r["swapped"] == swapped)
	check(label + " reason", r["reason"] == reason)
	check(label + " slots", qtys(inv) == expected)

# โอน 1 ครั้ง แล้วเช็ก ผล / เหตุผล / ทั้งสองฝั่ง / ผลรวม stone ไม่เปลี่ยน
func transfer_case(label : String , src : Inventory , dst : Inventory , qty : int , ok : bool , reason : StringName , src_exp : Array , dst_exp : Array) -> void:
	var before : int = total_of(src) + total_of(dst)
	var r : Dictionary = src.transfer_to(dst, db, &"stone_00", qty)
	check(label + " transferred", r["transferred"] == ok)
	check(label + " reason", r["reason"] == reason)
	check(label + " src", qtys(src) == src_exp)
	check(label + " dst", qtys(dst) == dst_exp)
	check(label + " total", total_of(src) + total_of(dst) == before)

# ---------- add ----------
func test_add() -> void:
	var a1 := Inventory.new()
	a1.max_slots = 2
	check_add("add1 partial_full", a1, a1.add_to_existing_stacks(db, &"stone_00", 250), 198, 52, &"partial_full", [99, 99])
	var a2 := Inventory.new()
	a2.max_slots = 2
	add_test_slot(a2, stone(), 99)
	add_test_slot(a2, stone(), 99)
	check_add("add2 full", a2, a2.add_to_existing_stacks(db, &"stone_00", 10), 0, 10, &"full", [99, 99])
	var a3 := Inventory.new()
	a3.max_slots = 2
	add_test_slot(a3, stone(), 90)
	check_add("add3 exact", a3, a3.add_to_existing_stacks(db, &"stone_00", 9), 9, 0, &"ok", [99])
	var a4 := Inventory.new()
	add_test_slot(a4, stone(), 90)
	add_test_slot(a4, stone(), 50)
	check_add("add4 first stack", a4, a4.add_to_existing_stacks(db, &"stone_00", 5), 5, 0, &"ok", [95, 50])
	var a5 := Inventory.new()
	add_test_slot(a5, stone(), 90)
	add_test_slot(a5, stone(), 50)
	check_add("add5 new slot", a5, a5.add_to_existing_stacks(db, &"stone_00", 90), 90, 0, &"ok", [99, 99, 32])
	check("fiber in db", db.has_item(&"fiber_00"))
	var f1 := Inventory.new()
	check_add("add fiber",f1,f1.add_to_existing_stacks(db,&"fiber_00",120),120,0,&"ok",[99,21])

# ---------- remove (stackable) ----------
func test_remove() -> void:
	var r1 := Inventory.new()
	add_test_slot(r1, stone(), 99)
	check_remove("rm1 partial", r1, r1.remove_item(db, &"stone_00", 30), 30, 0, &"ok", [69])
	var r2 := Inventory.new()
	add_test_slot(r2, stone(), 99)
	check_remove("rm2 all", r2, r2.remove_item(db, &"stone_00", 99), 99, 0, &"ok", [0])
	check("rm2 slot empty", r2.slots[0].item_data == null)
	var r3 := Inventory.new()
	add_test_slot(r3, stone(), 99)
	add_test_slot(r3, stone(), 50)
	check_remove("rm3 from last", r3, r3.remove_item(db, &"stone_00", 120), 120, 0, &"ok", [29, 0])
	var r4 := Inventory.new()
	add_test_slot(r4, stone(), 99)
	add_test_slot(r4, stone(), 50)
	check_remove("rm4 not enough", r4, r4.remove_item(db, &"stone_00", 150), 0, 150, &"not_enough_quantity", [99, 50])
	var r5 := Inventory.new()
	add_test_slot(r5, stone(), 50)
	add_test_slot(r5, null, 0)
	add_test_slot(r5, stone(), 30)
	check_remove("rm5 empty middle", r5, r5.remove_item(db, &"stone_00", 60), 60, 0, &"ok", [20, 0, 0])

# ---------- remove (non-stackable) ----------
func test_nonstackable() -> void:
	var n1 := Inventory.new()
	check_remove("ns1 empty inv", n1, n1.remove_item(db, &"wooden_sword_00", 3), 0, 3, &"not_enough_quantity", [])
	var n2 := Inventory.new()
	add_test_slot(n2, sword(), 1)
	check_remove("ns2 one sword", n2, n2.remove_item(db, &"wooden_sword_00", 1), 1, 0, &"ok", [0])
	var n3 := Inventory.new()
	add_test_slot(n3, sword(), 1)
	add_test_slot(n3, sword(), 1)
	check_remove("ns3 not enough", n3, n3.remove_item(db, &"wooden_sword_00", 3), 0, 3, &"not_enough_quantity", [1, 1])
	var n4 := Inventory.new()
	add_test_slot(n4, sword(), 1)
	add_test_slot(n4, sword(), 1)
	add_test_slot(n4, sword(), 1)
	check_remove("ns4 last first", n4, n4.remove_item(db, &"wooden_sword_00", 1), 1, 0, &"ok", [1, 1, 0])
	var n5 := Inventory.new()
	add_test_slot(n5, sword(), 1)
	add_test_slot(n5, null, 0)
	add_test_slot(n5, sword(), 1)
	check_remove("ns5 empty between", n5, n5.remove_item(db, &"wooden_sword_00", 1), 1, 0, &"ok", [1, 0, 0])

# ---------- invalid input ----------
func test_invalid_input() -> void:
	var inv := Inventory.new()
	add_test_slot(inv, stone(), 50)
	check_remove("inv1 null db", inv, inv.remove_item(null, &"stone_00", 1), 0, 1, &"error_null_id", [50])
	check_remove("inv2 zero", inv, inv.remove_item(db, &"stone_00", 0), 0, 0, &"error_wrong_quantity", [50])
	check_remove("inv3 negative", inv, inv.remove_item(db, &"stone_00", -1), 0, -1, &"error_wrong_quantity", [50])
	check_remove("inv4 bad id", inv, inv.remove_item(db, &"not_existed_id", 1), 0, 1, &"error_null_id", [50])
	check_add("inv5 add null db", inv, inv.add_to_existing_stacks(null, &"stone_00", 1), 0, 1, &"error_null_id", [50])
	check_add("inv6 add zero", inv, inv.add_to_existing_stacks(db, &"stone_00", 0), 0, 0, &"error_wrong_quantity", [50])

# ---------- swap ----------
func test_swap() -> void:
	var s1 := Inventory.new()
	add_test_slot(s1, stone(), 50)
	add_test_slot(s1, wood(), 20)
	check_swap("sw1 two items", s1, s1.swap_slots(0, 1), true, &"ok", [20, 50])
	check("sw1 ids", ids(s1) == [&"wood_00", &"stone_00"])
	var s2 := Inventory.new()
	add_test_slot(s2, stone(), 10)
	add_test_slot(s2, null, 0)
	check_swap("sw2 with empty", s2, s2.swap_slots(0, 1), true, &"ok", [0, 10])
	var s3 := Inventory.new()
	add_test_slot(s3, stone(), 10)
	add_test_slot(s3, wood(), 20)
	check_swap("sw3 same index", s3, s3.swap_slots(0, 0), true, &"ok", [10, 20])
	var s4 := Inventory.new()
	add_test_slot(s4, stone(), 50)
	add_test_slot(s4, wood(), 30)
	check_swap("sw4 out of range", s4, s4.swap_slots(-1, 2), false, &"error_outside_inventory_index", [50, 30])
	var s5 := Inventory.new()
	add_test_slot(s5, stone(), 50)
	add_test_slot(s5, stone(), 30)
	check_swap("sw5 not merge", s5, s5.swap_slots(0, 1), true, &"ok", [30, 50])

# ---------- move ----------
func test_move() -> void:
	var m1 := Inventory.new()
	add_test_slot(m1, stone(), 99)
	add_test_slot(m1, null, 0)
	check_move("mv1 to empty", m1, m1.move_slots(0, 1), true, 0, &"ok", [0, 99])
	var m2 := Inventory.new()
	add_test_slot(m2, stone(), 30)
	add_test_slot(m2, stone(), 20)
	check_move("mv2 merge all", m2, m2.move_slots(0, 1), true, 0, &"ok", [0, 50])
	var m3 := Inventory.new()
	add_test_slot(m3, wood(), 99)
	add_test_slot(m3, wood(), 50)
	check_move("mv3 merge partial", m3, m3.move_slots(0, 1), true, 50, &"ok", [50, 99])
	var m4 := Inventory.new()
	add_test_slot(m4, stone(), 66)
	add_test_slot(m4, wood(), 55)
	check_move("mv4 different", m4, m4.move_slots(0, 1), true, 0, &"ok", [55, 66])
	var m5 := Inventory.new()
	add_test_slot(m5, sword(), 1)
	add_test_slot(m5, sword(), 1)
	check_move("mv5 swords", m5, m5.move_slots(0, 1), true, 0, &"ok", [1, 1])
	var m6 := Inventory.new()
	add_test_slot(m6, null, 0)
	add_test_slot(m6, wood(), 55)
	check_move("mv6 empty src", m6, m6.move_slots(0, 1), false, 0, &"error_moving_null", [0, 55])
	var m7 := Inventory.new()
	add_test_slot(m7, wood(), 66)
	add_test_slot(m7, wood(), 55)
	check_move("mv7 out of range", m7, m7.move_slots(-1, 2), false, 0, &"error_outside_inventory_index", [66, 55])
	var m8 := Inventory.new()
	add_test_slot(m8, stone(), 66)
	add_test_slot(m8, wood(), 55)
	check_move("mv8 bad same index", m8, m8.move_slots(5, 5), false, 0, &"error_outside_inventory_index", [66, 55])
	var m9 := Inventory.new()
	add_test_slot(m9, stone(), 66)
	add_test_slot(m9, wood(), 55)
	check_move("mv9 same index", m9, m9.move_slots(0, 0), false, 0, &"error_same_index", [66, 55])

# ---------- transfer ----------
func test_transfer() -> void:
	var s1 := Inventory.new()
	var d1 := Inventory.new()
	add_test_slot(s1, stone(), 50)
	add_test_slot(d1, stone(), 20)
	transfer_case("tr1 normal", s1, d1, 30, true, &"ok", [20], [50])
	var s2 := Inventory.new()
	var d2 := Inventory.new()
	add_test_slot(s2, stone(), 50)
	d2.max_slots = 1
	add_test_slot(d2, stone(), 90)
	transfer_case("tr2 dst full", s2, d2, 20, false, &"error_destination_full", [50], [90])
	var s3 := Inventory.new()
	var d3 := Inventory.new()
	add_test_slot(s3, stone(), 10)
	add_test_slot(d3, stone(), 20)
	transfer_case("tr3 not enough", s3, d3, 20, false, &"error_not_enough_quantity", [10], [20])
	var s4 := Inventory.new()
	add_test_slot(s4, stone(), 10)
	transfer_case("tr4 to self", s4, s4, 20, false, &"error_same_inventory", [10], [10])
	var s5 := Inventory.new()
	var d5 := Inventory.new()
	add_test_slot(s5, stone(), 50)
	d5.max_slots = 1
	add_test_slot(d5, stone(), 90)
	transfer_case("tr5 exact fit", s5, d5, 9, true, &"ok", [41], [99])
	var s6 := Inventory.new()
	var d6 := Inventory.new()
	add_test_slot(s6, stone(), 50)
	d6.max_slots = 2
	add_test_slot(d6, wood(), 10)
	transfer_case("tr6 new slot", s6, d6, 50, true, &"ok", [0], [10, 50])
	check("tr6 ids", ids(d6) == [&"wood_00", &"stone_00"])
	var s7 := Inventory.new()
	var d7 := Inventory.new()
	add_test_slot(s7, stone(), 50)
	check("tr7a null other", s7.transfer_to(null, db, &"stone_00", 10)["reason"] == &"error_null_inventory")
	check("tr7b null db", s7.transfer_to(d7, null, &"stone_00", 10)["reason"] == &"error_null_id")
	check("tr7 unchanged", qtys(s7) == [50] and qtys(d7) == [])
	var s8 := Inventory.new()
	var d8 := Inventory.new()
	add_test_slot(s8, stone(), 90)
	add_test_slot(s8, stone(), 50)
	transfer_case("tr8 two src slots", s8, d8, 120, true, &"ok", [20, 0], [99, 21])
