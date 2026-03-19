#version 330 core
out vec4 FragColor;

in vec3 pos;

void main(){
    FragColor = vec4(-pos + 0.5f, 1.0f);
}