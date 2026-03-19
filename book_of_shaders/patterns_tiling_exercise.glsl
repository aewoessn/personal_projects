#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.14159265359

float createBox( vec3 st, float width){
    float box = (step(-width,st.x) - step(width, st.x)) * 
            (step(-width,st.y) - step(width,st.y));
    return box;
}

mat3 rotate(float angle){
    return mat3(    cos(angle), -sin(angle), 0.,
                    sin(angle), cos(angle), 0.,
                    0., 0., 1.);
}

mat3 translate(vec2 amt) {
    return mat3(    1., 0., amt.x,
                    0., 1., amt.y,
                    0., 0., 1.);
}

mat3 scale(vec2 amt){
    return mat3(    1./amt.x, 0, 0,
                    0, 1./amt.y, 0,
                    0, 0, 1);

}

void main(){
    vec2 st = (gl_FragCoord.xy / u_resolution); // Normalize between 0 and 1
    st *= vec2(10.0); // Repeat this number of times
    st = fract(st); // Create mini-grids
    st -= 0.5;

    float box1 = createBox( vec3(st,1.0), 0.45);
    float box2 = createBox( vec3(st,1.0) * scale(vec2(0.5)) * rotate(45.0*(PI/180.)), 0.45);
    //vec2 st2 = (gl_FragCoord.xy / u_resolution); // Normalize between 0 and 1
    //st2 *= vec2(6.0); // Repeat this number of times
    //st2 = mod(st2,2.0); // Create mini-grids
    
    //float box2 = createBox( vec3(st2,1.0) * translate(vec2(-2.0,-2.0)) * rotate(45.0*(PI/180.0)), 0.24);
    
    vec3 color = vec3(box1 * box2);
    gl_FragColor = vec4(color,1.0);
}