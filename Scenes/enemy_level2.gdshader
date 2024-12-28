shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 input_color=texture(TEXTURE, UV);
	COLOR=vec4(input_color.g,input_color.r,input_color.b,input_color.a) ;	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
