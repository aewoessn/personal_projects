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

/*
struct Light{
    vec3 position;
    vec3 direction;
    float cutOff;
    float outerCutOff;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};
*/
uniform Material material;
uniform DirLight dirLight;
uniform vec3 viewPosition;

vec3 calculateDirectionalLight( DirLight dirLight, vec3 normal, vec3 viewPosition){

    // Diffuse lighting
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(-dirLight.direction);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = (diff * vec3(texture2D(material.diffuse, texCoord))) * dirLight.diffuseColor;   

    // Specular lighting
    vec3 viewDir = normalize(viewPosition - fragPos);
    vec3 reflectDir = reflect(-lightDir, norm);

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = (vec3(texture2D(material.specular, texCoord)) * spec) * dirLight.specularColor;

    // Ambient lighting
    vec3 ambient = vec3(texture2D(material.diffuse, texCoord)) * dirLight.ambientColor;

    // Final result
    return (ambient + diffuse + specular);
}

void main(){

    // initialize final output color
    vec3 outputColor = vec3(0.0f);

    // directional lighting
    outputColor += calculateDirectionalLight(dirLight, normal, viewPosition);

    // point lighting

    // spot light

    // final result
    FragColor = vec4(outputColor, 1.0);

    
}