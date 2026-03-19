#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

void main(){
    vec2 st = gl_FragCoord.xy / u_resolution; // Normalize between 0 and 1
    st *= vec2(3.0); // Repeat this number of times
    st = fract(st); // Create mini-grids

    vec3 color = vec3(st.x, st.y, 0.0);
    gl_FragColor = vec4(color,1.0);
}