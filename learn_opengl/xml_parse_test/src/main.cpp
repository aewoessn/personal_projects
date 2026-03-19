#include <iostream>
#include <filesystem>
#include <string>
#include <vector>
#include <tinyxml2.h>
#include <glm/glm.hpp>

// Directory
std::filesystem::path currentDir = std::filesystem::current_path();

//std::vector<Model> modelList;

using namespace tinyxml2;

struct Object{
    const char* name;
    glm::vec3 position;
    glm::vec3 rotation;
    glm::vec3 scale;
};

std::vector<Object> sceneObjects;

int main(){

    // Load the XML document
    XMLDocument xDoc;

    std::string filename = (currentDir.string() + "\\..\\data\\test.xml");
    XMLError result = xDoc.LoadFile(filename.data());
    if (result != XML_SUCCESS) {
        std::cerr << "Error loading XML file: " << result << std::endl;
        return -1;
    }

    // pull out the scene
    XMLElement* scene = xDoc.FirstChildElement("scene");
    if (!scene) {
        std::cerr << "No <scene> element found." << std::endl;
        return -1;
    }

    // Iterate over each <object>
    for (XMLElement* object = scene->FirstChildElement("object");
         object != nullptr;
         object = object->NextSiblingElement("object")) 
    {
        // Find <name>
        XMLElement* nameElem = object->FirstChildElement("name");
        if (nameElem) {
            Object newObject;
            newObject.name = nameElem->Attribute("value");
            newObject.position = glm::vec3(object->FirstChildElement("position")->FloatAttribute("x"),
                                           object->FirstChildElement("position")->FloatAttribute("y"),
                                           object->FirstChildElement("position")->FloatAttribute("z"));

            newObject.rotation = glm::vec3(object->FirstChildElement("rotation")->FloatAttribute("x"),
                                           object->FirstChildElement("rotation")->FloatAttribute("y"),
                                           object->FirstChildElement("rotation")->FloatAttribute("z"));

            newObject.scale =    glm::vec3(object->FirstChildElement("scale")->FloatAttribute("x"),
                                           object->FirstChildElement("scale")->FloatAttribute("y"),
                                           object->FirstChildElement("scale")->FloatAttribute("z"));

            sceneObjects.push_back(newObject);
        }
    }

    std::cout << sceneObjects.size() << std::endl;
    return 0;
}