#version 330 core
out vec4 FragColor;

in vec3 fragPos;
in vec3 normal;
in vec2 texCoord;

uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPosition;
uniform vec3 viewPosition;

void main(){

    // Diffuse lighting
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPosition - fragPos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;   

    // Specular lighting
    float specularStrength = 0.5f;
    vec3 viewDir = normalize(viewPosition - fragPos);
    vec3 reflectDir = reflect(-lightDir, norm);

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 256);
    vec3 specular = specularStrength * spec * lightColor;

    // Ambient lighting
    float ambientStrength = 0.1f;
    vec3 ambient = ambientStrength * lightColor;

    // Final result
    vec3 result = (ambient + diffuse + specular) * objectColor;
    FragColor = vec4(result, 1.0);
}