shader_type spatial;

uniform sampler2D circular_gradient_1 : filter_linear, repeat_disable, source_color;
uniform sampler2D circular_gradient_2 : filter_linear, repeat_disable, source_color;

uniform vec4 predicted_color : source_color = vec4(1.0, 0.0, 0.0, 0.25);
uniform vec4 charge_color : source_color = vec4(1.0, 0.0, 0.0, 0.5);

uniform float angle_range: hint_range(0.0, 360.0) = 90.0;
uniform float charge: hint_range(0.0, 0.99) = 0.5;

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
	float new_angle_range = (180.0 - (angle_range/2.0));
	float min_angle_range = (0.0 + new_angle_range)/360.0;
	float max_angle_range = (360.0 - new_angle_range)/360.0;
	
	float final_angle_range = in_range(texture(circular_gradient_1, UV).r, min_angle_range, max_angle_range);
	
	float max_distance_range = in_range(texture(circular_gradient_2, UV).r, 0.01, 1.0);
	float current_distance_range = in_range(texture(circular_gradient_2, UV).r, 1.0 - charge, 1.0);
	
	vec4 final_color = mix(predicted_color, charge_color, current_distance_range) * max_distance_range * final_angle_range;
	
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}

