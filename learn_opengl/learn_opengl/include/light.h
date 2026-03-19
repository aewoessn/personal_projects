#ifndef LIGHT_H
#define LIGHT_H

// includes
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

// directional light
class DirectionalLight{
    public:
        glm::vec3 lightDirection;

        glm::vec3 ambientColor;
        glm::vec3 diffuseColor;
        glm::vec3 specularColor;
};

// point light
class PointLight{
    public:
        glm::vec3 lightPosition;

        glm::vec3 ambientColor;
        glm::vec3 diffuseColor;
        glm::vec3 specularColor;

        float constant;
        float linear;
        float quadratic;
};

// spot light
class SpotLight{
    public:
        glm::vec3 lightDirection;
        glm::vec3 lightPosition;

        glm::vec3 ambientColor;
        glm::vec3 diffuseColor;
        glm::vec3 specularColor;

        float constant;
        float linear;
        float quadratic;

        float cutOff;
        float outerCutOff;
};

#endif