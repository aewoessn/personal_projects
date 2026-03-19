#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265359

// Plot a line on Y using a value between 0.0-1.0
// For some percentage, in this case Y, generate a notch (plot line) using the step function
float plot(vec2 st, float pct){
    return step(pct-0.005, st.y) - step(pct+0.005, st.y);
}

// Compute a quadratic bezier curve
float quadBezier( float x, float a, float b ) {
    float om2a = 1.0 - (2.0*a);

    float t = (sqrt((a*a) + (om2a*x)) - a) / om2a;
    float y = ((1.0 - (2.0*b))*t*t) + (2.0*b*t);
    return y;
    
}

void main() {
	vec2 st = gl_FragCoord.xy/u_resolution; // Get and normalize the resolution

    //--- Advanced Shaping Functions ---//
    //float y = mod(st.x, 0.5); // Modulo function
    //float y = fract(st.x); // Fraction
    //float y = ceil(st.x);  // nearest integer that is greater than or equal to x
    //float y = floor(st.x); // nearest integer less than or equal to x
    //float y = sign(st.x);  // extract the sign of x
    //float y = abs(st.x);   // return the absolute value of x
    //float y = clamp(st.x,0.1,0.9); // constrain x to lie between 0.0 and 1.0
    //float y = min(0.0,st.x);   // return the lesser of x and 0.0
    //float y = max(0.0,st.x);   // return the greater of x and 0.0
    float y = quadBezier(st.x, u_mouse.x / u_resolution.x, u_mouse.y / u_resolution.y);

    vec3 color = vec3(y); // Generate a gradient in the x-direction

    // Plot a line
    float pct = plot(st, y); // 1 for everything within the thickness of the plot line, 0 everywhere else
    color = ((1.0-pct)*color) + (pct*vec3(0.0,1.0,0.0)) ; // Set the gradient to be greyscale, and the plot line to be green

	gl_FragColor = vec4(color,1.0);
}