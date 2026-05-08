shader_type spatial;

uniform sampler2D circular_gradient : filter_linear, repeat_disable, source_color;

uniform vec4 predicted_color : source_color = vec4(1.0, 0.0, 0.0, 0.25);
uniform vec4 charge_color : source_color = vec4(1.0, 0.0, 0.0, 0.5);

uniform float charge: hint_range(0.0, 1.0) = 0.5;

uniform float smoothing = 0.001;
float in_range(float val, float _min, float _max){
	float _min_result = smoothstep(_min - smoothing, _min + smoothing, val);
	float _max_result = smoothstep(_max - smoothing, _max + smoothing, val);
	return _min_result - _max_result;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float max_distance_range = in_range(texture(circular_gradient, UV).r, 0.01, 1.0);
	float current_distance_range = in_range(texture(circular_gradient, UV).r, 1.0 - charge, 1.0);
	
	vec4 final_color = mix(predicted_color, charge_color, current_distance_range) * max_distance_range;
	
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}

