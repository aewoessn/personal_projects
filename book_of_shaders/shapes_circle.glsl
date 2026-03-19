#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
	vec2 st = gl_FragCoord.xy/u_resolution;
    float pct = 0.0;

    // a. The DISTANCE from the pixel to the center
    pct = 1.0 - distance(st,vec2(0.5))*2.0; // Need to multiply by 2 since the max distance is 0.5

    float circ = step(0.5,pct); // Now use step to create a logical circle

    // Transition between distance and stepped function

    // b. The LENGTH of the vector
    //    from the pixel to the center
    //vec2 toCenter = vec2(0.5)-st;
    //pct = length(toCenter);

    // c. The SQUARE ROOT of the vector
    //    from the pixel to the center
    // vec2 tC = vec2(0.5)-st;
    // pct = sqrt(tC.x*tC.x+tC.y*tC.y);

    // Transition between distance and stepped function
    vec3 color = mix(vec3(pct), vec3(circ), (sin(u_time) + 1.0) / 2.0 );

	gl_FragColor = vec4( color, 1.0 );
}