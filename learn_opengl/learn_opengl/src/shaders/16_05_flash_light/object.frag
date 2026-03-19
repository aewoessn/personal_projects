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
    vec3 direction;
    float cutOff;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};

uniform Material material;
uniform Light light;
uniform vec3 viewPosition;

void main(){

    // Spot light angle calculation
    vec3 lightDir = normalize(light.position - fragPos);
    float theta = dot(lightDir, normalize(-light.direction));

    if (theta > light.cutOff) {
        // Diffuse lighting
        vec3 norm = normalize(normal);    

        float diff = max(dot(norm, lightDir), 0.0);
        vec3 diffuse = (diff * vec3(texture2D(material.diffuse, texCoord))) * light.diffuse;   

        // Specular lighting
        vec3 viewDir = normalize(viewPosition - fragPos);
        vec3 reflectDir = reflect(-lightDir, norm);

        float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
        vec3 specular = (vec3(texture2D(material.specular, texCoord)) * spec) * light.specular;

        // Ambient lighting
        vec3 ambient = vec3(texture2D(material.diffuse, texCoord)) * light.ambient;

        // Point source attenuation
        float distance = length(light.position - fragPos);
        float attenuation = 1.0f / (light.constant + (light.linear * distance) + (light.quadratic * distance * distance));
        
        ambient *= attenuation;
        diffuse *= attenuation;
        specular *= attenuation;
        
        // Final result (phong lighting)
        vec3 result = ambient + diffuse + specular;
        FragColor = vec4(result, 1.0);

    } else {
        FragColor = vec4(light.ambient * vec3(texture2D(material.diffuse, texCoord)), 1.0f);
    }

    
}