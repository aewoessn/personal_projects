#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(14.9898,78.233)))*43758.55);
}

float random (float x) {
    return fract(sin(x*78.233)*43758.55);
}

void main(){
    vec2 st = (gl_FragCoord.xy / u_resolution); // Normalize between 0 and 1
    float rNum = random(floor(u_time));
    float rNum2 = random(ceil(u_time));
    float n_grid = rNum * 200.0;

    // Create a 2 x 50 grid
    st *= vec2(n_grid,2.0);
    st.x += step(1.0,mod(st.y,2.0)) * u_time * rNum * sign(rNum-0.5) * 20.0;
    st.x += (1.0-step(1.0,mod(st.y,2.0))) * u_time * rNum2 * sign(rNum2-0.5)* 40.0;
    float rand = step(random(floor(u_time)),random(floor(st)));

    gl_FragColor = vec4(vec3(rand),1.0);

}