#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.14159265359

float createBox( vec2 st, float width){
    float box = (step(-width,st.x) - step(width, st.x)) * 
            (step(-width,st.y) - step(width,st.y));
    return box;
}

void main(){
    vec2 st = (gl_FragCoord.xy / u_resolution); // Normalize between 0 and 1
    st *= 20.0; // Create mini-grid
    //st.x += step(1.0,mod(st.y,2.0)) * 0.5; // Add 0.5 to every other y strip
    if  (mod(u_time,2.0)>1.0){
        st.y -= (step(1.0,mod(st.x,2.0)) * u_time); // Add 0.5 to every other y strip
        st.y += ((1.0-step(1.0,mod(st.x,2.0))) * u_time); // Add 0.5 to every other y strip
    } else {
        st.x -= (step(1.0,mod(st.y,2.0)) * u_time); // Add 0.5 to every other y strip
        st.x += ((1.0-step(1.0,mod(st.y,2.0))) * u_time); // Add 0.5 to every other y strip
    }
    
    st = fract(st); // Finish up grid
    st -= 0.5;
    vec3 color = vec3(0.0);
    
    float box = 1.0 - createBox(st, 0.25);
    color += box;
    gl_FragColor = vec4(color,1.0);
}