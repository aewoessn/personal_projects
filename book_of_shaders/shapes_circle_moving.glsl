#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
	vec2 st = gl_FragCoord.xy/u_resolution;
    vec3 color = vec3(0.0);

    // Translate the circle left-right
    float circ1 = step(0.95, 1.0 - distance(st,(vec2(sin(u_time),cos(u_time)) + 1.05) / 2.1)*2.0); // Need to multiply by 2 since the max distance is 0.5
    color = mix(color, vec3(1.0), circ1);
    
    float circ2 = step(0.95, 1.0 - distance(st,vec2(0.5))*2.0); // Need to multiply by 2 since the max distance is 0.5
    color = mix(color, vec3(1.0,0.0,0.0), circ2);

	gl_FragColor = vec4( color, 1.0 );
}