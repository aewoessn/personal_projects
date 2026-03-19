#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// Plot a line on Y using a value between 0.0-1.0
// For some percentage, in this case Y, generate a notch (plot line) using the step function
float plot(vec2 st, float pct){
    return step(pct-0.005, st.y) - step(pct+0.005, st.y);
}

void main() {
	vec2 st = gl_FragCoord.xy/u_resolution; // Get and normalize the resolution

    //--- Shaping functions ---//
    //float y = st.x; // Function: y = x
    //float y = pow(st.x,5.0); // Function: y = x^5
    //float y = exp(st.x); // Function: e^x
    //float y = sqrt(st.x); // Function: x^0.5
    //float y = step(0.5,st.x); // Function: Threshold = x
    //float y = smoothstep(0.05, 0.95, st.x); // Function smoothstep
    //float y = step(0.1,st.x) * (1.0 - step(st.x, 0.9) * (1.0 - ((st.x - 0.1) / (0.9 - 0.1))));
    float y = (clamp(st.x, 0.1, 0.9) - 0.1) / (0.9 - 0.1);
    
    vec3 color = vec3(y); // Generate a gradient in the x-direction

    // Plot a line
    float pct = plot(st, y); // 1 for everything within the thickness of the plot line, 0 everywhere else
    color = ((1.0-pct)*color) + (pct*vec3(0.0,1.0,0.0)); // Set the gradient to be greyscale, and the plot line to be green

	gl_FragColor = vec4(color,1.0);
}