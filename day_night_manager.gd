extends Node

# Tín hiệu phát ra khi chuyển sang ngày mới hoặc đổi mùa
signal day_changed(day_count: int)
signal season_changed(season_name: String)

# Khai báo 4 mùa
enum Season { SPRING, SUMMER, AUTUMN, WINTER }

# Thời gian hiện tại (Mặc định bắt đầu từ 5:00 AM)
var current_hour: float = 5.0
var current_day: int = 1
var current_season: int = Season.SPRING # Bắt đầu từ Mùa Xuân (0)

# CẤU HÌNH TỐC ĐỘ:
# 10 phút game = 7s thật -> 1 tiếng game = 42s thật
var time_speed: float = 1.0 / 42.0

func _process(delta: float) -> void:
	# Cộng dồn thời gian theo delta
	current_hour += delta * time_speed
	
	# Khi chạm 2:00 AM đêm (tương đương 26.0h trong hệ số thời gian)
	if current_hour >= 26.0:
		current_hour = 5.0 # Skip qua đêm, về lại 5:00 AM sáng hôm sau
		current_day += 1
		
		# Tính toán mùa mới dựa trên ngày (28 ngày / 1 mùa)
		var calculated_season: int = int((current_day - 1) / 28) % 4
		
		# Nếu sang mùa mới thì cập nhật biến và phát tín hiệu
		if calculated_season != current_season:
			current_season = calculated_season
			var season_names = ["SPRING", "SUMMER", "AUTUMN", "WINTER"]
			emit_signal("season_changed", season_names[current_season])
			
		emit_signal("day_changed", current_day)
