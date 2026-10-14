extends CanvasModulate

# Gradient màu chuyển đổi theo các khung giờ trong ngày
# Sáng sớm (Cam nhạt) -> Bắt đầu trưa (Trắng) -> Chiều tà (Cam đỏ) -> Tối/Đêm (Xanh thẫm)
@export var night_color: Color = Color("1e2245")    # 0h - 5h sáng (Đêm tối)
@export var dawn_color: Color = Color("f3a261")     # 6h - 7h sáng (Hừng đông)
@export var day_color: Color = Color("ffffff")      # 8h - 16h chiều (Nắng ban ngày)
@export var dusk_color: Color = Color("e76f51")     # 17h - 19h tối (Hoàng hôn)
@export var late_night_color: Color = Color("2b2d42") # 20h - 23h đêm (Tối muộn)

func _process(_delta: float) -> void:
	if not DayNightManager:
		return
		
	var hour: float = float(DayNightManager.current_hour)
	color = calculate_day_night_color(hour)

func calculate_day_night_color(hour: float) -> Color:
	# 0h - 5h: Đêm sâu
	if hour < 5.0:
		return night_color
	# 5h - 6h: Bình minh
	elif hour < 6.0:
		var t = (hour - 5.0) / 2.0
		return night_color.lerp(dawn_color, t)
	# 6h - 9h: Nắng lên ban ngày
	elif hour < 9.0:
		var t = (hour - 6.0) / 2.0
		return dawn_color.lerp(day_color, t)
	# 9h - 16h: Ban ngày rực rỡ
	elif hour < 16.0:
		return day_color
	# 16h - 18h: Hoàng hôn chiều tà
	elif hour < 18.0:
		var t = (hour - 16.0) / 2.0
		return day_color.lerp(dusk_color, t)
	# 18h - 20h: Tối hẳn
	elif hour < 20.0:
		var t = (hour - 18.0) / 2.0
		return dusk_color.lerp(late_night_color, t)
	# 20h - 24h: Đêm muộn chuyển về midnight
	else:
		var t = (hour - 20.0) / 4.0
		return late_night_color.lerp(night_color, t)
