#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.14159265359

vec3 colorA = vec3(0.149,0.141,0.912);
vec3 colorB = vec3(1.000,0.833,0.224);

float plot(vec2 st, float pct){
    return step(pct-0.005, st.y) - step(pct+0.005, st.y);
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;

    // Each channel shaping
    vec3 y = vec3(smoothstep(0.0,1.0, st.x), sin(st.x*PI), pow(st.x,0.5));

    // For plotting
    vec3 pct = vec3(plot(st, y.r), plot(st, y.g), plot(st, y.b));

    // Mix color
    vec3 color = mix(colorA, colorB, y);

    // Plot shaping functions
    color = mix(color, vec3(1.0), pct);

    /* // All channel shaping
    // Gradient shaping function
    //float y = st.x; 
    //float y = sqrt(st.x);
    float y = pow(st.x,2.0);

    // For plotting
    float pct = plot(st, y);

    // Mix uses pct (a value from 0-1) to
    // mix the two colors
    vec3 color = mix(colorA, colorB, st.x);
    color = mix(color,vec3(1.0), pct);
    */

    gl_FragColor = vec4(color,1.0);
}