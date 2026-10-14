shader_type canvas_item;

// Màu nước sông/hồ mặc định
uniform vec4 water_color : source_color = vec4(0.15, 0.45, 0.70, 1.0);

// CẤU HÌNH GỢN SÓNG BÉ
uniform float wave_speed : hint_range(0.1, 10.0) = 1.2;        // Tốc độ nước chảy
uniform float wave_frequency : hint_range(1.0, 100.0) = 25.0;  // Tần số CAO (25.0) để tạo gợn sóng BÉ, li ti
uniform float wave_strength : hint_range(0.001, 0.1) = 0.008;  // Lực sóng BÉ (0.008) tạo độ uốn nhẹ nhàng

// CẤU HÌNH LẤP LÁNH NƯỚC
uniform float sparkle_speed : hint_range(0.1, 8.0) = 1.5;     // Tốc độ nhấp nháy
uniform float sparkle_density : hint_range(0.8, 0.999) = 0.95; // Hạt lấp lánh vừa phải

// Hàm tạo hiệu ứng hạt sáng ngẫu nhiên
float pseudo_noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    
    // 1. TẠO GỢN SÓNG BÉ TĂN TĂN
    // Sóng dọc li ti
    float wave_small = sin(uv.y * wave_frequency + TIME * wave_speed) * wave_strength;
    uv.x += wave_small;
    
    // Sóng ngang đang xen nhẹ để gợn nước tự nhiên
    float wave_sub = cos(uv.x * (wave_frequency * 0.8) - TIME * wave_speed * 0.8) * (wave_strength * 0.6);
    uv.y += wave_sub;

    // Lấy màu từ Texture ảnh (nếu không có Texture sẽ tự lấy water_color)
    vec4 tex_color = texture(TEXTURE, uv);
    if (tex_color.a < 0.01) {
        tex_color = water_color;
    }
    
    // 2. HIỆU ỨNG ÁNH SÁNG LẤP LÁNH TRÊN GỢN SÓNG BÉ
    if (tex_color.a > 0.1) {
        // Lưới hạt nhỏ tỉ lệ thuận với gợn sóng bé
        vec2 grid = floor(uv * 400.0);
        grid.y -= floor(TIME * wave_speed * 0.8);
        grid.x += floor(wave_small * 100.0);
        
        float noise = pseudo_noise(grid + floor(TIME * sparkle_speed));
        
        if (noise > sparkle_density) {
            float flash = sin(TIME * sparkle_speed * 0.8 + noise * 10.0) * 0.5 + 0.5;
            vec4 sparkle_tint = vec4(0.9, 0.98, 1.0, 0.9);
            tex_color = mix(tex_color, sparkle_tint, flash * 0.35);
        }
    }
    
    COLOR = tex_color;
}