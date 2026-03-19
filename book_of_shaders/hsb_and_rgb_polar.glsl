#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

#define TWO_PI 6.28318530718

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution;
    vec3 color = vec3(0.0);

    // Set offset from center
    vec2 offset = vec2(0.5);

    // For each pixel, calculate the distance from the center
    vec2 toCenter = offset - st;
    float ang = (atan(toCenter.y, toCenter.x) / TWO_PI ) + 0.25; // get the angle
    float mag = length(toCenter)*2.0; // get the magnitude

    // Set hsb such that h = angle, s = 1.0, b = magnitude
    color = hsb2rgb(vec3(ang,mag,1.0));

    gl_FragColor = vec4(color,1.0);
}