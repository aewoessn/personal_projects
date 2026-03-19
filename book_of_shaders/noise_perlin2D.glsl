#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float rand( vec2 _st) {
    return fract(sin(dot(_st,vec2(1e1,1e4)))*1e4);
}

void main(){
    vec2 st = gl_FragCoord.xy / u_resolution;
    st *= 10.0;
    vec2 fpos = fract(st);
    st = floor(st);

    // Lerp between current and next
    float noise =   mix(rand(st), rand(st+vec2(1.0,.0)), fpos.x) + 
                    mix(rand(st), rand(st+vec2(0.0,1.0)), fpos.y);
    noise = noise / 2.0;
    // Slerp between current and next
    //float noise2 = mix(rand(st.x), rand(st.x+1.0), smoothstep(0.0,1.0,fpos.x));
    gl_FragColor = vec4(vec3(noise),1.0);
}