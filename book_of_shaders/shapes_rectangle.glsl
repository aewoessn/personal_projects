#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

#define PI 3.14159265359

float prod( vec4 a ) {
    return a.x * a.y * a.z * a.w;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;

    // Set-up array of squares
    vec4 rect[13];

    // Make the first inner-most square
    rect[0] = vec4( step(0.4, st.x), 
                    step(0.4, st.y), 
                    1.0-step(0.6,st.x), 
                    1.0-step(0.6,st.y));
    vec3 color = vec3(prod(rect[0]),0.0,0.0);

    // Loop through the rest of the squares
    float minVal = 0.35;
    float maxVal = 0.65;

    float prevProd = prod(rect[0]);
    float currProd;

    for (int i = 1; i < 13; i++) {
        rect[i] = vec4( step(minVal, st.x), 
                        step(minVal, st.y), 
                        1.0-step(maxVal, st.x), 
                        1.0-step(maxVal,st.y));

        if ( mod(float(i),2.0) > 0.0) {
            currProd = prod(rect[i]);
                            color = mix(color,
                            vec3(1.0, 1.0, 1.0),
                            currProd - prevProd);
        } else {
             currProd = prod(rect[i]);
                            color = mix(color,
                            vec3(1.0, 0.0, 0.0),
                            currProd - prevProd);           
        }

        prevProd = currProd;
        minVal -= 0.05;
        maxVal += 0.05;
    }

    // Add a moving rectangle
    vec4 rectM = vec4(  step(((cos(u_time*0.5*PI) / 2.1) + 0.5) - 0.025, st.x), 
                        step(((sin(u_time*0.5*PI) / 2.1) + 0.5) - 0.025, st.y), 
                        1.0-step(((cos(u_time*0.5*PI) / 2.1) + 0.5) + 0.025,st.x), 
                        1.0-step(((sin(u_time*0.5*PI) / 2.1) + 0.5) + 0.025,st.y));

    color = mix(color,
                vec3(0.0, 0.0, 1.0),
                rectM.x * rectM.y * rectM.z * rectM.w);

     // Add another moving rectangle
    vec4 rectM2 = vec4(  step(((sin(u_time*PI) / 4.1) + 0.5) - 0.025, st.x), 
                        step(((cos(u_time*PI) / 4.1) + 0.5) - 0.025, st.y), 
                        1.0-step(((sin(u_time*PI) / 4.1) + 0.5) + 0.025,st.x), 
                        1.0-step(((cos(u_time*PI) / 4.1) + 0.5) + 0.025,st.y));

    color = mix(color,
                vec3(0.0, 1.0, 0.0),
                rectM2.x * rectM2.y * rectM2.z * rectM2.w);   
    //--- Method 1 ---//
    // left
    //color = vec3(step(0.05,st.x) * (1.0 - step(0.1,st.x)));

    // bottom
    //color *= step(0.1, st.y);

    // top
    //color *= (1.0-step(0.9,st.y));

    // right
    //color *= (1.0-step(0.9,st.x));

    gl_FragColor = vec4(color,1.0);
}