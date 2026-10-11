คำถามหลักคือ inventory data model ใช้ซ้ำได้และเตรียม replicate ได้หรือไม่
คำตอบ : (รอพิสูจน์)
OQ-03-01 : Inventory capacity model: slot-based, weight-based, หรือ hybrid? 
คำตอบจาก Bible : Slot-based (grid) ไม่มี weight; stack ต่อ slot ตาม `max_stack`; weight/tab เป็น Later | EXPERIMENTAL | P-03 

OQ-03-06 : Interaction range และ priority rules ละเอียดแค่ไหน?
คำตอบจาก Bible : ระยะ interact คงที่ใกล้เคียงระยะ pickup ของ P-02; เลือกเป้าที่ใกล้สุดในทิศที่ผู้เล่นหัน; ถ้าเท่ากันเรียงลำดับ Pickup > Interact > Build; แสดง prompt ทีละอย่าง | EXPERIMENTAL | P-03 

OQ-11-06 : มี automated test ระดับไหนที่คุ้มค่าในช่วง prototype?
คำตอบจาก Bible : ทดสอบอัตโนมัติเฉพาะ logic ที่ไม่ผูก UI: inventory ops, recipe, salvage validation, serialization | DIRECTION | P-03 

OQ-11-02 : Character data เก็บฝั่งไหนใน multiplayer เป็นหลัก? 


เกณฑ์ผ่าน (5):
-ops ทุกตัวรัน/เทสต์ได้โดยไม่โหลด scene/UI/Node
-test อัตโนมัติผ่านครบ
-serialize > deserialize ได้ state เท่าเดิม
-เพิ่ม item ใหม่ด้วย .tres อย่างเดียวไม่แก้โค้ด
-เล่นจริง: เก็บ→กระเป๋า→ลากเข้า Inventory ที่สอง→ลากกลับ ไม่มีของหายหรือเพิ่มเอง
-เกณฑ์ล้ม (4):
-ต้องมี Node/UI ถึงเทสต์ logic ได้
-serialize พึ่ง reference ของ Node หรือ Texture
-ของหายหรือซ้ำในกรณี fail/transfer
-hardcode item id ใน UI
