shader_type canvas_item;


const float borne_inf = 0.05;
const float borne_sup = 0.99;

const float intensity = 1.1;
const float opacity = 1.0;
float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec4 sampled = texture(TEXTURE,UV);
	float noise = random(UV);
	COLOR.rgb = sampled.rgb;
	float alpha_chan = COLOR.a * opacity;
	float under_mask = step(borne_inf, alpha_chan);
	
	float upper_mask = step(borne_sup, alpha_chan);
	
	COLOR.a = step(intensity,noise + alpha_chan + upper_mask) * under_mask;
}
