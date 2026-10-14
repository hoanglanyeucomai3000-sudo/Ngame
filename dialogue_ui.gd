extends CanvasLayer

@onready var dialogue_panel: Control = $DialoguePanel
@onready var text_label: Label = $DialoguePanel/TextLabel
@onready var portrait: TextureRect = $DialoguePanel/Portrait # Viền rỗng của anh

# THAM CHIẾU MỚI: Chỉ vào nút Avatar nằm trong Portrait
@onready var avatar: TextureRect = $DialoguePanel/Portrait/Avatar 

@onready var name_label: Label = $DialoguePanel/NameLabel

var is_active: bool = false
var dialogue_lines: Array = []
var current_line_index: int = 0
var current_npc_code_name: String = "" # Mã NPC (ví dụ: khanh_toan)

# Thư mục gốc chứa toàn bộ avatar biểu cảm
const PORTRAIT_BASE_PATH: String = "res://camxucnhanvat"

func _ready() -> void:
	dialogue_panel.visible = false

# Bắt đầu hội thoại
func start_dialogue(display_name: String, npc_code_name: String, lines: Array) -> void:
	if lines.size() == 0:
		return
		
	current_npc_code_name = npc_code_name
	dialogue_lines = lines
	current_line_index = 0
	
	name_label.text = display_name
	dialogue_panel.visible = true
	is_active = true
	
	show_current_line()

# Hiển thị câu thoại & tách chuỗi lấy tên biểu cảm
func show_current_line() -> void:
	var line_data = dialogue_lines[current_line_index]
	var emotion: String = "normal"
	var text_content: String = ""

	if line_data is String:
		if ":" in line_data:
			var parts = line_data.split(":", true, 1)
			emotion = parts[0].strip_edges()
			text_content = parts[1].strip_edges()
		else:
			text_content = line_data

	text_label.text = text_content
	load_portrait(emotion)

# Tải ảnh avatar từ thư mục res://camxucnhanvat/<npc_code_name>/<emotion>_<npc_code_name>.png
func load_portrait(emotion: String) -> void:
	var file_path = "%s/%s/%s_%s.png" % [PORTRAIT_BASE_PATH, current_npc_code_name, emotion, current_npc_code_name]
	
	# Chỉ load ảnh vào nút `avatar` bên trong, giữ nguyên viền `portrait`
	if avatar != null:
		if ResourceLoader.exists(file_path):
			avatar.texture = load(file_path)
		else:
			# Nếu không tìm thấy biểu cảm cụ thể, thử load hình normal
			var fallback_path = "%s/%s/normal_%s.png" % [PORTRAIT_BASE_PATH, current_npc_code_name, current_npc_code_name]
			if ResourceLoader.exists(fallback_path):
				avatar.texture = load(fallback_path)
			else:
				print("Không tìm thấy ảnh avatar tại: ", file_path)
				avatar.texture = null # Xóa ảnh cũ nếu hoàn toàn không tìm thấy

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
		
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		get_viewport().set_input_as_handled()
		advance_dialogue()

func advance_dialogue() -> void:
	current_line_index += 1
	if current_line_index < dialogue_lines.size():
		show_current_line()
	else:
		close_dialogue()

func close_dialogue() -> void:
	dialogue_panel.visible = false
	is_active = false
	dialogue_lines.clear()
	current_line_index = 0
