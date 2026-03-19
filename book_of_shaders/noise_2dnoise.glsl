#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    vec3 color = vec3(0.0);

    float rnd = fract(sin(dot(st.xy,vec2(10.9898,58.233)))* 43758.545313);
    
    gl_FragColor = vec4(vec3(rnd),1.0);
}