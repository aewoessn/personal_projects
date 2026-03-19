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

struct DirLight{
    vec3 direction;
     
    vec3 ambientColor;
    vec3 diffuseColor;
    vec3 specularColor;
}; 

struct PointLight{
    vec3 position;

    vec3 ambientColor;
    vec3 diffuseColor;
    vec3 specularColor;

    float constant;
    float linear;
    float quadratic;
};

uniform vec3 viewPosition;
uniform Material material;
uniform DirLight dirLight;

#define NR_POINT_LIGHTS 4
uniform PointLight pointLights[NR_POINT_LIGHTS];

vec3 calculateDirectionalLight(DirLight light, vec3 normal, vec3 viewDir){

    // Diffuse lighting
    vec3 lightDir = normalize(-light.direction);

    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = (diff * vec3(texture2D(material.diffuse, texCoord))) * light.diffuseColor;   

    // Specular lighting
    vec3 reflectDir = reflect(-lightDir, normal);

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = (vec3(texture2D(material.specular, texCoord)) * spec) * light.specularColor;

    // Ambient lighting
    vec3 ambient = vec3(texture2D(material.diffuse, texCoord)) * light.ambientColor;

    // Final result
    return (ambient + diffuse + specular);
}

vec3 calculatePointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir){

    // Diffuse lighting
    vec3 lightDir = normalize(light.position - fragPos);
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = (diff * vec3(texture2D(material.diffuse, texCoord))) * light.diffuseColor;   

    // Specular lighting
    vec3 reflectDir = reflect(-lightDir, normal);

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = (vec3(texture2D(material.specular, texCoord)) * spec) * light.specularColor;

    // Ambient lighting
    vec3 ambient = vec3(texture2D(material.diffuse, texCoord)) * light.ambientColor;

    // Point source attenuation
    float distance = length(light.position - fragPos);
    float attenuation = 1.0f / (light.constant + (light.linear * distance) + (light.quadratic * distance * distance));
    
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;

    // Final result
    return (ambient + diffuse + specular);
}

void main(){

    // initialize final output color
    vec3 outputColor = vec3(0.0f);

    // constant calculations
    vec3 viewDir = normalize(viewPosition - fragPos);
    vec3 norm = normalize(normal);

    // directional lighting
    outputColor += calculateDirectionalLight(dirLight, norm, viewDir);

    // point lighting
    for (int i = 0; i < NR_POINT_LIGHTS; i++){
        outputColor += calculatePointLight(pointLights[i], norm, fragPos, viewDir);
    }
    
    // spot light

    // final result
    FragColor = vec4(outputColor, 1.0);

    
}