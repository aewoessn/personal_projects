#version 330 core
out vec4 FragColor;

in vec3 fragPos;
in vec3 normal;
in vec2 texCoord;

uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPosition;

void main(){

    // Diffuse lighting
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPosition - fragPos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;   
    
    // Ambient lighting
    float ambientStrength = 0.1f;
    vec3 ambient = ambientStrength * lightColor;

    vec3 result = ambient * objectColor;
    FragColor = vec4(result, 1.0);
}