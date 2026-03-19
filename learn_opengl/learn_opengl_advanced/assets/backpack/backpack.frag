#version 330 core
out vec4 FragColor;

in vec3 pos;
in vec3 normal;
in vec2 texCoord;

uniform sampler2D diffuse_texture;
uniform sampler2D specular_texture;

void main(){
    FragColor = texture2D(diffuse_texture, texCoord);
    //FragColor = vec4(0.5f, 0.5f, 0.5f, 1.0f);
}