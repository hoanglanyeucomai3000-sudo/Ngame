extends Label

@export var scroll_speed: float = 25.0 # Tốc độ chạy chữ

var parent_width: float = 0.0

func _ready() -> void:
	# Lấy chiều rộng của khung SignBoard chứa nó
	if get_parent() is Control:
		parent_width = (get_parent() as Control).size.x
	else:
		parent_width = 200.0 # Chiều rộng mặc định nếu không có khung cha
		
	# Cho chữ xuất hiện bắt đầu từ mép phải của khung
	position.x = parent_width

func _process(delta: float) -> void:
	# Cho chữ lướt dần sang bên trái
	position.x -= scroll_speed * delta
	
	# Khi toàn bộ chữ đã lọt hết qua mép trái của khung
	if position.x < -size.x:
		# Quay trở lại xuất phát từ mép phải của khung
		position.x = parent_width
