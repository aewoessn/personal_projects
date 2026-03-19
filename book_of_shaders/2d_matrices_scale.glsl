precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.14159265359
float createCross( vec2 st, vec2 width, vec2 size) {
    float box = (step(-size.x,st.x) - step(size.x, st.x)) * 
                (step(-size.y,st.y) - step(size.y,st.y));

    float cross = (step(-width.x, st.x) - step(width.x, st.x)) + 
                (step(-width.y, st.y) - step(width.y, st.y));
 
    return box * cross;
}

mat3 translate(vec2 amt) {
    return mat3(    1, 0, amt.x,
                    0, 1, amt.y,
                    0, 0, 1);

}

mat3 rotate(float angle){
    return mat3(    cos(angle), -sin(angle), 0,
                    sin(angle), cos(angle), 0,
                    0,          0,          1);
}

mat3 scale(vec2 amt){
    return mat3(    amt.x, 0, 0,
                    0, amt.y, 0,
                    0, 0, 1);

}

void main() {
    vec3 color = vec3(0.0);
    vec2 st = (gl_FragCoord.xy / u_resolution) - vec2(0.5);
    vec3 tmpSt = vec3(st,1.0);

    mat3 trans = translate(vec2(cos(u_time),sin(u_time))/2.0);

    mat3 rot = rotate(sin(u_time)*PI);

    mat3 scale = scale(vec2(sin(u_time)/PI));

    tmpSt = tmpSt * trans * scale * rot;
    float cross = createCross(vec2(tmpSt.x, tmpSt.y), 
                                vec2(0.01), 
                                vec2(0.05));   

    color = color + cross;
    gl_FragColor = vec4(color,1.0);
}