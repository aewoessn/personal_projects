#version 330 core
out vec4 FragColor;

in vec2 texCoord;

uniform sampler2D inputTexture1;
uniform sampler2D inputTexture2;

void main(){
    FragColor = mix(texture2D(inputTexture1, texCoord), texture2D(inputTexture2, texCoord), 0.2);
}