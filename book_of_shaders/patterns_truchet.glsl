#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.14159265359
vec2 createTiles( in vec2 _st, float zoom){
    _st *= zoom;
    _st = fract(_st)-0.5;
    return _st;    
}

mat3 rotate(float angle){
    return mat3(    cos(angle), -sin(angle), 0,
                    sin(angle), cos(angle), 0,
                    0,          0,          1);
}

void main(){
    vec2 st = (gl_FragCoord.xy / u_resolution); // Normalize between 0 and 1
    vec3 color = vec3(0.0);
    float zoom = 6.0;
    st *= zoom;
    vec3 _st = vec3(fract(st)-0.5,0.0);
    _st *= rotate(u_time); // Rotate all tiles
    //vec2 tile = createTiles(st, 6.0);

    // Rotate all of the tiles
    //vec3 tileRotated = vec3(tile,0.0) * rotate(0.0);

    // Pick out each odd **column**, and rotate 90 degrees
    float rot = -(2.0*PI/4.0);
    
    _st *= rotate(rot*(step(1.0,mod(st.x,2.0))*(1.0-step(1.0,mod(st.y,2.0)))));
    _st *= rotate(2.0*rot*(step(1.0,mod(st.x,2.0))*(step(1.0,mod(st.y,2.0)))));
    _st *= rotate(3.0*rot*(step(1.0,mod(st.y,2.0))*(1.0-step(1.0,mod(st.x,2.0)))));
    _st *= rotate(4.0*rot*(step(1.0,mod(st.y,2.0))*(step(1.0,mod(st.x,2.0)))));
    
    //gl_FragColor = vec4(vec3(step(1.0,mod(st.y,2.0)) * (1.0-step(1.0,mod(st.x,2.0)))),1.0);
    //gl_FragColor = vec4(vec3(_st.x,_st.y,_st.x),1.0);
    gl_FragColor = vec4(vec3(step(_st.x,_st.y)),1.0);
}