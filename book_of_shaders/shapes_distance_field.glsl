#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
	vec2 st = gl_FragCoord.xy/u_resolution;
    float pct = 0.0;

    //pct = (distance(st,vec2(0.4))/2.0) + (distance(st,vec2(0.6))/2.0);
    //pct = distance(st,vec2(0.4)) * distance(st,vec2(0.6));
    //pct = min(distance(st,vec2(0.4)),distance(st,vec2(0.6)));
    //pct = max(distance(st,vec2(0.4)),distance(st,vec2(0.6)));
    pct = pow(distance(st,vec2(0.4)),distance(st,vec2(0.6)));

    vec3 color = vec3(pct);

	gl_FragColor = vec4( color, 1.0 );
}