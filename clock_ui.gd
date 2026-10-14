extends CanvasLayer

@onready var time_label: Label = get_node_or_null("ClockUI/ClockPanel/Timelabel")
@onready var day_label: Label = get_node_or_null("ClockUI/ClockPanel/DayLabel")
@onready var hour_hand: Control = get_node_or_null("ClockUI/ClockPanel/Hourhand")

# Thêm tham chiếu đến ô hiển thị Mùa (Node TextureRect trên UI của anh)
@onready var season_icon: TextureRect = get_node_or_null("ClockUI/ClockPanel/SeasonIcon")

# Khai báo đường dẫn 4 logo mùa đặt tại gốc res://
const SEASON_TEXTURES: Dictionary = {
	0: preload("res://spring.png"), # Mùa xuân (hoa)
	1: preload("res://summer.png"), # Mùa hạ (thuyền)
	2: preload("res://autumn.png"), # Mùa thu (lá phong)
	3: preload("res://winter.png")  # Mùa đông (quả thông)
}

# Mảng 7 ngày trong tuần
const DAYS_OF_WEEK: Array[String] = ["Mon.", "Tue.", "Wed.", "Thu.", "Fri.", "Sat.", "Sun."]

func _ready() -> void:
	if time_label == null:
		time_label = get_node_or_null("ClockPanel/Timelabel")
	if day_label == null:
		day_label = get_node_or_null("ClockPanel/DayLabel")
	if hour_hand == null:
		hour_hand = get_node_or_null("ClockPanel/Hourhand")
	if season_icon == null:
		season_icon = get_node_or_null("ClockPanel/SeasonIcon")

func _process(_delta: float) -> void:
	if not DayNightManager:
		return
		
	var hour: float = float(DayNightManager.current_hour)
	
	# Xử lý hiển thị giờ khi vượt qua 24h (12h đêm)
	var display_raw_hour: float = hour
	if display_raw_hour >= 24.0:
		display_raw_hour -= 24.0
		
	var int_hour: int = int(display_raw_hour)
	var raw_minute: int = int((display_raw_hour - int_hour) * 60)
	
	# NHẢY PHÚT MỖI 10 PHÚT (00, 10, 20, 30, 40, 50)
	var minute: int = (raw_minute / 10) * 10
	
	# Định dạng AM / PM
	var period: String = "AM" if int_hour < 12 else "PM"
	var display_hour: int = int_hour % 12
	if display_hour == 0:
		display_hour = 12
		
	if time_label != null:
		time_label.text = "%02d:%02d %s" % [display_hour, minute, period]

	# HIỂN THỊ THỨ VÀ NGÀY (VD: Mon. 1, Tue. 2, ..., Sun. 7, Mon. 8, ...)
	if day_label != null:
		var total_days: int = DayNightManager.current_day
		
		# Tính thứ dựa trên total_days (Ngày 1 -> Mon. index 0)
		var day_index: int = (total_days - 1) % 7
		var day_name: String = DAYS_OF_WEEK[day_index]
		
		# Tính ngày trong tháng từ 1 đến 28 (1 tháng = 4 tuần = 28 ngày)
		var day_in_month: int = ((total_days - 1) % 28) + 1
		
		day_label.text = "%s %d" % [day_name, day_in_month]

	# ĐỔI LOGO MÙA TỰ ĐỘNG THEO DAYNIGHTMANAGER
	if season_icon != null:
		var current_season_id: int = DayNightManager.current_season
		if SEASON_TEXTURES.has(current_season_id):
			season_icon.texture = SEASON_TEXTURES[current_season_id]

	# XOAY KIM THEO VÒM BÁN NGUYỆT ĐỨNG (5:00 AM -> 2:00 AM đêm)
	if hour_hand != null:
		var start_hour: float = 5.0    # 5:00 AM
		var end_hour: float = 26.0     # 2:00 AM đêm
		var total_hours: float = end_hour - start_hour # 21 tiếng
		
		var progress: float = clampf((hour - start_hour) / total_hours, 0.0, 1.0)
		
		# Giữ nguyên góc xoay 190 -> 350 độ chuẩn của anh
		var start_angle: float = 190.0
		var end_angle: float = 350.0
		
		hour_hand.rotation_degrees = lerp(start_angle, end_angle, progress)
