#version 330 core
out vec4 FragColor;

in vec3 fragPos;
in vec3 normal;
in vec2 texCoord;

struct Material{
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct Light{
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

uniform Material material;
uniform Light light;
uniform vec3 viewPosition;

void main(){

    // Diffuse lighting
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(light.position - fragPos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = (diff * vec3(texture2D(material.diffuse, texCoord))) * light.diffuse;   

    // Specular lighting
    vec3 viewDir = normalize(viewPosition - fragPos);
    vec3 reflectDir = reflect(-lightDir, norm);

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = (vec3(texture2D(material.specular, texCoord)) * spec) * light.specular;

    // Ambient lighting
    vec3 ambient = vec3(texture2D(material.diffuse, texCoord)) * light.ambient;

    // Final result
    vec3 result = ambient + diffuse + specular;
    FragColor = vec4(result, 1.0);
}