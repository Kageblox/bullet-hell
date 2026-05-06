shader_type spatial;
render_mode unshaded;

uniform vec4 color_override : source_color = vec4(0,0,0,0);
uniform sampler2D albedo_texture : filter_linear;

void fragment() {
	vec4 albedo =  texture(albedo_texture, UV);
	ALBEDO = mix(albedo.rgb, color_override.rgb, color_override.a);
	ALPHA = albedo.a;
}
