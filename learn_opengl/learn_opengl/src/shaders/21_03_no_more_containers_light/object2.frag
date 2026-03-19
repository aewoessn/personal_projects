#version 330 core
out vec4 FragColor;

in vec3 fragPos;
in vec3 normal;
in vec2 texCoord;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;

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

uniform PointLight pointLight;

vec3 calculatePointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir){

    // Diffuse lighting
    vec3 lightDir = normalize(light.position - fragPos);
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = (diff * vec3(texture2D(texture_diffuse1, texCoord))) * light.diffuseColor;   

    // Specular lighting
    vec3 reflectDir = reflect(-lightDir, normal);

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    vec3 specular = (vec3(texture2D(texture_specular1, texCoord)) * spec) * light.specularColor;

    // Ambient lighting
    vec3 ambient = vec3(texture2D(texture_diffuse1, texCoord)) * light.ambientColor;

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

    // point lighting
    outputColor += calculatePointLight(pointLight, norm, fragPos, viewDir);

    // final result
    FragColor = vec4(outputColor, 1.0);
}