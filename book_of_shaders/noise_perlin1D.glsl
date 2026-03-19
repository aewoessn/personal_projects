#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float rand( float x) {
    return fract(sin(x)*1e4);
}

void main(){
    vec2 st = gl_FragCoord.xy / u_resolution;
    st.x *= 10.0;
    vec2 fpos = fract(st);
    st.x = floor(st.x);

    // Lerp between current and next
    float noise = mix(rand(st.x), rand(st.x+1.0), fpos.x);

    // Slerp between current and next
    float noise2 = mix(rand(st.x), rand(st.x+1.0), smoothstep(0.0,1.0,fpos.x));
    gl_FragColor = vec4(vec3(noise2),1.0);
}