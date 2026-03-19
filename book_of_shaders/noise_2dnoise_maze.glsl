#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(14.9898,78.233)))*43758.55);
}

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st *= 10.0;

    vec2 ipos = floor(st);
    vec2 fpos = fract(st);
    float rnd = random( ipos );
    
    float index = floor(rnd * 4.0);
    
    vec2 fposR = fpos;
    if (index == 1.0) {
        fposR = vec2(1.0) - fposR;
    } else if (index == 2.0) {
        fposR = vec2(1.0-fposR.x,fposR.y);
    } else if (index == 3.0) {
        fposR = 1.0 - vec2(1.0-fposR.x,fposR.y);
    }

    //float maze =    step(fposR.y,fposR.x+0.1)-
    //                step(fposR.y,fposR.x-0.1)+
    //                step(fposR.y,fposR.x-0.9)+
    //                step(fposR.x,fposR.y-0.9);

    float maze =    smoothstep(fposR.x-0.2,fposR.x,fposR.y) -
                    smoothstep(fposR.x,fposR.x+0.2,fposR.y) +
                    smoothstep(fposR.x-0.2,fposR.x,fposR.y-1.0) +
                    smoothstep(fposR.x+0.2,fposR.x,fposR.y+1.0);

    //gl_FragColor = vec4(color,1.0);
    gl_FragColor = vec4(vec3(maze),1.0);
}