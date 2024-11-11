shader_type canvas_item;

uniform vec4 outline_colour : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0, 10) = 1.0;

void fragment() {
    vec4 sprite_color = texture(TEXTURE, UV);
    
    // Check surrounding pixels for transparency
    float alpha = 0.0;
    for(float x = -outline_width; x <= outline_width; x++) {
        for(float y = -outline_width; y <= outline_width; y++) {
            vec2 offset = vec2(x, y) * TEXTURE_PIXEL_SIZE;
            alpha += texture(TEXTURE, UV + offset).a;
        }
    }
    
    // Create outline effect
    vec4 final_color = sprite_color;
    if (sprite_color.a < 0.5 && alpha > 0.0) {
        final_color = outline_colour;
    }
    
    COLOR = final_color;
}