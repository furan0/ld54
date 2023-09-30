shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensity : hint_range(0.0,2.0) ;

const float borne_inf = 0.05;
const float borne_sup = 0.99;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec4 sampled = texture(TEXTURE,UV);
	float noise = random(UV);
	COLOR.rgb = sampled.rgb * color.rgb;
	float alpha_chan = sampled.a * color.a;
	float under_mask = step(borne_inf, alpha_chan);
	
	float upper_mask = step(borne_sup, alpha_chan);
	
	COLOR.a = step(intensity,noise + alpha_chan + upper_mask) * under_mask;
}