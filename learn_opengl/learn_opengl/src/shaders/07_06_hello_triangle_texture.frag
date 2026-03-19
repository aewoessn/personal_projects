#version 330 core
out vec4 FragColor;

in vec3 vertexColor;
in vec2 texCoord;

uniform sampler2D inputTex;

void main(){
    FragColor = texture(inputTex, texCoord);
}