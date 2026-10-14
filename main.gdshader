shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    // Nếu màu pixel là màu xám/trắng của phông caro thì làm trong suốt
    if ((color.r > 0.7 && color.g > 0.7 && color.b > 0.7) || 
        (abs(color.r - color.g) < 0.05 && abs(color.g - color.b) < 0.05 && color.r > 0.5)) {
        // Giữ lại vùng da chân/mặt và chỉ xóa phông
        if (color.r > 0.85 && color.g > 0.65 && color.b > 0.5) {
            COLOR = color;
        } else {
            COLOR = vec4(0.0, 0.0, 0.0, 0.0);
        }
    } else {
        COLOR = color;
    }
}
