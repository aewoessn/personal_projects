#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(14.9898,78.233)))*
        43758.55);
}

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st *= 10.0;

    vec2 ipos = floor(st);
    vec2 fpos = fract(st);
    vec3 color = vec3(random( ipos ));
    
    gl_FragColor = vec4(color,1.0);
}