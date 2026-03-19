precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

float createCross( vec2 st, vec2 width, vec2 size) {
    float box = (step(-size.x,st.x) - step(size.x, st.x)) * 
                (step(-size.y,st.y) - step(size.y,st.y));

    float cross = (step(-width.x, st.x) - step(width.x, st.x)) + 
                (step(-width.y, st.y) - step(width.y, st.y));
 
    return box * cross;
}

void main() {
    vec3 color = vec3(0.0);
    vec2 st = (gl_FragCoord.xy / u_resolution) - vec2(0.5);
    vec3 tmpSt = vec3(st,1.0);
    mat3 trans = mat3(  1, 0, cos(u_time)/2.25, 
                        0, 1, sin(u_time)/2.25, 
                        0, 0, 1);
    tmpSt = tmpSt * trans;
    float cross = createCross(vec2(tmpSt.x, tmpSt.y), 
                                vec2(0.01), 
                                vec2(0.05));   
    //st = trans * st;
    //float cross = createCross(vec2(st.x + cos(u_time)/2.25, st.y + sin(u_time)/2.25), 
    //                            vec2(0.01), 
    //                            vec2(0.05));


    color = color + cross;
    gl_FragColor = vec4(color,1.0);
}