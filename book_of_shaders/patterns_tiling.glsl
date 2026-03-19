#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.14159265359
float createCrossSmooth( vec2 st, vec2 width, vec2 size, float mag) {
    float box = (smoothstep(-size.x-(mag/2.),-size.x+(mag/2.),st.x) - smoothstep(size.x-(mag/2.), size.x+(mag/2.),st.x)) * 
                (smoothstep(-size.y-(mag/2.),-size.y+(mag/2.),st.y) - smoothstep(size.y-(mag/2.),size.y+(mag/2.),st.y));

    float cross = (smoothstep(-width.x-(mag/2.), -width.x+(mag/2.), st.x) - smoothstep(width.x-(mag/2.), width.x+(mag/2.),st.x)) + 
                (smoothstep(-width.y-(mag/2.), -width.y+(mag/2.),st.y) - smoothstep(width.y-(mag/2.), width.y+(mag/2.), st.y));
 
    return box * cross;
}

float createCross( vec2 st, vec2 width, vec2 size) {
    float box = (step(-size.x,st.x) - step(size.x, st.x)) * 
                (step(-size.y,st.y) - step(size.y,st.y));

    float cross = (step(-width.x, st.x) - step(width.x, st.x)) + 
                (step(-width.y, st.y) - step(width.y, st.y));
 
    return box * cross;
}

mat2 rotate(float angle){
    return mat2(    cos(angle), -sin(angle),
                    sin(angle), cos(angle));
}

void main(){
    vec2 st = (gl_FragCoord.xy / u_resolution); // Normalize between 0 and 1
    st *= vec2(3.0); // Repeat this number of times
    st = fract(st); // Create mini-grids
    st = st - 0.5;

    mat2 rotate = rotate(30.0*(PI/180.0));
    float cross = createCrossSmooth( st * rotate, vec2(0.01), vec2(0.45), 0.005);
    
    vec3 color = vec3(cross);
    gl_FragColor = vec4(color,1.0);
}