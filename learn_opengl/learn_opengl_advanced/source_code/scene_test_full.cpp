// includes (general)
#include <iostream>
#include <vector>
#include <string>

#include <glad/glad.h>
#include <GLFW/glfw3.h>

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

// includes

#include <glm/glm.hpp> // model
#include <camera.h>
#include <tinyxml2.h>
#include <shader.h> // scene / model
#include <assimp/Importer.hpp> // model
#include <assimp/scene.h> // model
#include <assimp/postprocess.h> // model

// Callback functions
void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void processInput(GLFWwindow *window);
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);

// GLFW window
GLFWwindow* window;

// Viewport
short WIDTH = 800;
short HEIGHT = 600;

// deltaTime
float deltaTime = 0.0f;
float lastFrame = 0.0f;

// texture
struct Texture{
    unsigned int id;
    aiTextureType type;
    std::string path;
};

// vertex
struct Vertex{
    glm::vec3 position = glm::vec3(0.0f);
    glm::vec3 normal = glm::vec3(0.0f);
    glm::vec2 texCoord = glm::vec3(0.0f);
};

// mesh
struct Mesh{
    std::vector<Vertex>       vertices;
    std::vector<unsigned int> indices;
    int mNumberVertices;
    int mNumberFaces;
    unsigned int VAO, VBO, EBO;
};

// model
struct Model{
    std::string name = "";
    std::string uri = "";
    glm::mat4 transform;
    glm::vec3 translation = glm::vec3(0.0f);
    glm::vec3 rotation = glm::vec3(0.0f);
    glm::vec3 scale = glm::vec3(1.0f);
    Shader shader;
    std::vector<Mesh> meshes;
    std::vector<Texture> textures;
};

// scene
struct Scene{
    Camera camera = Camera(WIDTH, HEIGHT);
    std::vector<Model> models;     
};
Scene scene;

int main(){
    
    // Initialize GLFW
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    // Create a window object
    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "Loading scene...", NULL, NULL);

    if (window == NULL) {
        std::cout << "Did not create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window); // forces window to be main context on current thread
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED); // captures cursor for input
    glfwSetCursorPosCallback(window, mouse_callback); // set mouse input callback
    glfwSetScrollCallback(window, scroll_callback); // set mouse scroll callback

    // Check to see if GLAD can be loaded correctly
    if (!gladLoadGLLoader( (GLADloadproc) glfwGetProcAddress)) {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }

    // Set the dimensions of the current viewport and set callback in case the window is resized
    glViewport(0, 0, WIDTH, HEIGHT);
    glEnable(GL_DEPTH_TEST);

    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    //--- include stuff here ---//
    std::string sceneURI = "./scenes/scene_test.xml";

    // Load XML file
    using namespace tinyxml2;
    XMLDocument xDoc;
    XMLError result = xDoc.LoadFile(sceneURI.data());

    // Parse the XML file
    // <scene>
    XMLElement* sceneElement = xDoc.FirstChildElement("scene");

    // <object>
    for (XMLElement* object = sceneElement->FirstChildElement("object");
         object != nullptr;
         object = object->NextSiblingElement("object")) {
            
            Model model;

            // parse <object> information
            // <object/name>
            model.name = (std::string) object->Attribute("name");

            // <object/uri>
            XMLElement* uriElement = object->FirstChildElement("uri");
            model.uri = (std::string) uriElement->Attribute("value");

            // <object/position>
            XMLElement* translationElement = object->FirstChildElement("translation");
            if (translationElement){
                model.translation = glm::vec3(translationElement->FloatAttribute("x"),
                                              translationElement->FloatAttribute("y"),
                                              translationElement->FloatAttribute("z"));
            }

            // <object/rotation>
            XMLElement* rotationElement = object->FirstChildElement("rotation");
            if (rotationElement){
                model.rotation = glm::vec3(rotationElement->FloatAttribute("x"),
                                           rotationElement->FloatAttribute("y"),
                                           rotationElement->FloatAttribute("z"));
            }
            
            // <object/scale>
            XMLElement* scaleElement = object->FirstChildElement("scale");
            if (scaleElement){
                model.scale = glm::vec3(scaleElement->FloatAttribute("x"),
                                        scaleElement->FloatAttribute("y"),
                                        scaleElement->FloatAttribute("z"));
            }

            // <object/vertexShader> & <object/fragmentShader>
            XMLElement* vertexShaderElement = object->FirstChildElement("vertexShader");
            XMLElement* fragmentShaderElement = object->FirstChildElement("fragmentShader");

            model.shader = Shader(vertexShaderElement->Attribute("value"),
                                  fragmentShaderElement->Attribute("value"));

            // load model file
            using namespace Assimp;
            Importer importer;

            const aiScene* _aiScene = importer.ReadFile(model.uri, aiProcess_Triangulate | aiProcess_GenSmoothNormals | aiProcess_FlipUVs | aiProcess_CalcTangentSpace);

            // load all textures for model
            std::vector<Texture> textures_loaded;

            // loop through each material
            for(int i = 0; i < _aiScene->mNumMaterials; i++){
                aiMaterial* mat = _aiScene->mMaterials[i];
                aiString texturePath;
                Texture _texture;

                // find all the diffuse maps in the material file and load them
                for(int j = 0; j < mat->GetTextureCount(aiTextureType_DIFFUSE); j++){
                    mat->GetTexture(aiTextureType_DIFFUSE, j, &texturePath);
                    
                    _texture.type = aiTextureType_DIFFUSE;
                    _texture.path = texturePath.data;

                    // load the texture
                    unsigned int textureID;
                    glGenTextures(1, &textureID);

                    int width, height, nrComponents;
                    stbi_set_flip_vertically_on_load(true);
                    unsigned char *data = stbi_load((model.uri + "/../" + _texture.path).c_str(), &width, &height, &nrComponents, 0);

                    if (data) { 
                        GLenum format;
                        if (nrComponents == 1)
                            format = GL_RED;
                        else if (nrComponents == 3)
                            format = GL_RGB;
                        else if (nrComponents == 4)
                            format = GL_RGBA;

                        glBindTexture(GL_TEXTURE_2D, textureID);
                        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
                        glGenerateMipmap(GL_TEXTURE_2D);

                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                    }
                    stbi_image_free(data);

                    _texture.id = textureID;

                    // push texture to list of loaded textures
                    textures_loaded.push_back(_texture);
                }

                // find all the diffuse maps in the material file and load them
                for(int j = 0; j < mat->GetTextureCount(aiTextureType_SPECULAR); j++){
                    mat->GetTexture(aiTextureType_SPECULAR, j, &texturePath);
                    
                    _texture.type = aiTextureType_SPECULAR;
                    _texture.path = texturePath.data;

                    // load the texture
                    unsigned int textureID;
                    glGenTextures(1, &textureID);

                    int width, height, nrComponents;
                    stbi_set_flip_vertically_on_load(true);
                    unsigned char *data = stbi_load((model.uri + "/../" + _texture.path).c_str(), &width, &height, &nrComponents, 0);

                    if (data) { 
                        GLenum format;
                        if (nrComponents == 1)
                            format = GL_RED;
                        else if (nrComponents == 3)
                            format = GL_RGB;
                        else if (nrComponents == 4)
                            format = GL_RGBA;

                        glBindTexture(GL_TEXTURE_2D, textureID);
                        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
                        glGenerateMipmap(GL_TEXTURE_2D);

                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                    }
                    stbi_image_free(data);

                    _texture.id = textureID;

                    textures_loaded.push_back(_texture);
                }
            }
            model.textures = textures_loaded;

            // link all textures to the object -- this only works if a singular texture map is used
            if (textures_loaded.size() > 0){
                model.shader.use();
                for(int i = 0; i < textures_loaded.size(); i++){
                        glActiveTexture(GL_TEXTURE0 + i);
                        if (textures_loaded[i].type == aiTextureType_DIFFUSE){
                            model.shader.setInt("diffuse_texture", i);
                        } else if (textures_loaded[i].type == aiTextureType_SPECULAR){
                            model.shader.setInt("specular_texture",i);
                        }
                        glBindTexture(GL_TEXTURE_2D, textures_loaded[i].id);
                }
            }   
            // loop through all meshes in the obj file
            for(int i = 0; i < _aiScene->mRootNode->mNumChildren; i++){
                // get the current child node
                aiNode* _aiNode = _aiScene->mRootNode->mChildren[i];

                // get the number of meshes in the current child node
                // go through each child node mesh
                // get the scene mesh index

                // loop through each sub-mesh
                for(int j = 0; j < _aiNode->mNumMeshes; j++){
                    aiMesh* _aiMesh = _aiScene->mMeshes[_aiNode->mMeshes[j]];
                    Vertex vertex;
                    Mesh mesh;

                    mesh.mNumberVertices = _aiMesh->mNumVertices;
                    mesh.mNumberFaces = _aiMesh->mNumFaces;
                    
                    // loop through each vertex
                    for(int ii = 0; ii < _aiMesh->mNumVertices; ii++){
                        // position
                        if (_aiMesh->HasPositions()){
                            vertex.position = glm::vec3(_aiMesh->mVertices[ii].x, 
                                                        _aiMesh->mVertices[ii].y, 
                                                        _aiMesh->mVertices[ii].z);
                        }

                        // normal
                        if (_aiMesh->HasNormals()){
                            vertex.normal = glm::vec3(_aiMesh->mNormals[ii].x, 
                                                    _aiMesh->mNormals[ii].y, 
                                                    _aiMesh->mNormals[ii].z);
                        }

                        // texture coordinates
                        if (_aiMesh->HasTextureCoords(0)){
                            vertex.texCoord = glm::vec2(_aiMesh->mTextureCoords[0][ii].x,
                                                        _aiMesh->mTextureCoords[0][ii].y);
                        }

                        // push vertex to vector of vertices in current mesh
                        mesh.vertices.push_back(vertex);
                    }

                    // loop through each face index
                    for(int ii = 0; ii < _aiMesh->mNumFaces; ii++){

                        for(int jj = 0; jj < _aiMesh->mFaces->mNumIndices; jj++){
                            // push index to vector
                            mesh.indices.push_back(_aiMesh->mFaces[ii].mIndices[jj]);
                        }
                    }
                
                    // set up VAO, VBO, EBO for sub mesh
                    // create buffers/arrays
                    glGenVertexArrays(1, &mesh.VAO);
                    glGenBuffers(1, &mesh.VBO);
                    glGenBuffers(1, &mesh.EBO);

                    glBindVertexArray(mesh.VAO);
                    // load data into vertex buffers
                    glBindBuffer(GL_ARRAY_BUFFER, mesh.VBO);
                    // A great thing about structs is that their memory layout is sequential for all its items.
                    // The effect is that we can simply pass a pointer to the struct and it translates perfectly to a glm::vec3/2 array which
                    // again translates to 3/2 floats which translates to a byte array.
                    glBufferData(GL_ARRAY_BUFFER, mesh.vertices.size() * sizeof(Vertex), &mesh.vertices[0], GL_STATIC_DRAW);  

                    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.EBO);
                    glBufferData(GL_ELEMENT_ARRAY_BUFFER, mesh.indices.size() * sizeof(unsigned int), &mesh.indices[0], GL_STATIC_DRAW);

                    glEnableVertexAttribArray(0);	
                    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)0);
                    // vertex normals
                    glEnableVertexAttribArray(1);	
                    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)offsetof(Vertex, normal));
                     // texture coordinates
                    glEnableVertexAttribArray(2);	
                    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)offsetof(Vertex, texCoord));
                    glBindVertexArray(0);

                    // push sub-mesh to list of meshes
                    model.meshes.push_back(mesh);
                }
            }
            // push model to  list of models in scene
            scene.models.push_back(model);
        }
    
    //std::cout << "Scene parsing complete!" << std::endl;
    
    //--- end ---//

    // FPS counter initialization
    char fpsBuffer[sizeof(int)+5];
    int frameCounter = 0;
    float totalTime = 0.0f;
    float sampleTime = 1.0f;

    // Rendering loop
    while (!glfwWindowShouldClose(window)) {

        // deltaTime calculation
        float currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        
        // FPS Counter
        if (totalTime < sampleTime) {
            frameCounter++;
            totalTime += deltaTime;
        } else {
            sprintf(fpsBuffer, "FPS: %i", frameCounter);
            glfwSetWindowTitle(window, fpsBuffer); 
            frameCounter = 0;
            totalTime = 0;         
        }
        
        // Input for window
        processInput(window);

        // Clear the color buffer
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Draw each model in the scene
        for(int i = 0; i < scene.models.size(); i++){
            // Apply translation, rotation, and scaling
            scene.models[i].transform = glm::mat4(1.0f);
            scene.models[i].transform = glm::translate(scene.models[i].transform, scene.models[i].translation);

            scene.models[i].transform = glm::rotate(scene.models[i].transform, scene.models[i].rotation.x, glm::vec3(1.0f, 0.0f, 0.0f));
            scene.models[i].transform = glm::rotate(scene.models[i].transform, scene.models[i].rotation.y, glm::vec3(0.0f, 1.0f, 0.0f));
            scene.models[i].transform = glm::rotate(scene.models[i].transform, scene.models[i].rotation.z, glm::vec3(0.0f, 0.0f, 1.0f));

            scene.models[i].transform = glm::scale(scene.models[i].transform, scene.models[i].scale);

            // Set active shader program
            scene.models[i].shader.use();

            // Set shader uniforms
            scene.models[i].shader.setMat4("model", scene.models[i].transform);
            scene.models[i].shader.setMat4("view", scene.camera.cameraView);
            scene.models[i].shader.setMat4("projection", scene.camera.cameraProjection);

            // Draw triangles
            for(int j = 0; j < scene.models[i].meshes.size(); j++){
                glBindVertexArray(scene.models[i].meshes[j].VAO);
                glDrawElements(GL_TRIANGLES, static_cast<unsigned int>(scene.models[i].meshes[j].indices.size()), GL_UNSIGNED_INT, 0);
                glBindVertexArray(0);
            }
        }

        // Events and frame buffer swap
        glfwSwapBuffers(window); // swap between frame buffers
        glfwPollEvents(); // check to see if any event are triggered
    }

    glfwTerminate();
    
    return 0;
}


// Frame buffer resizing call back
void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
    WIDTH = width;
    HEIGHT = height;
    glViewport(0, 0, width, height);
}

// Mouse input callback
void mouse_callback(GLFWwindow* window, double xpos, double ypos) {
    scene.camera.processMouseInput(xpos, ypos);
}

// Mouse scroll callback
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset) {
    scene.camera.processMouseScroll(xoffset, yoffset);
}


// Input handler
void processInput(GLFWwindow* window) {

    // Close program
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, true);
    }

    // Move camera
    const float cameraSpeed = 2.5f * deltaTime;
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {scene.camera.cameraPos += cameraSpeed * scene.camera.cameraFront; scene.camera.updateCamera();}
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) {scene.camera.cameraPos -= cameraSpeed * scene.camera.cameraFront; scene.camera.updateCamera();}
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) {scene.camera.cameraPos -= glm::normalize(glm::cross(scene.camera.cameraFront, scene.camera.cameraUp)) * cameraSpeed; scene.camera.updateCamera();}
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) {scene.camera.cameraPos += glm::normalize(glm::cross(scene.camera.cameraFront, scene.camera.cameraUp)) * cameraSpeed; scene.camera.updateCamera();}

    // Toggle scene rendering
    if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS) {
        GLint polygonMode[2];
        glGetIntegerv(GL_POLYGON_MODE, polygonMode);
        
        float duration = 0.2;
        float startTime = glfwGetTime();

        if (polygonMode[0] == GL_FILL) {
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
                } else if (polygonMode[0] == GL_LINE) {
            glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
        } else if (polygonMode[0] == GL_POINT) {
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }

        // Delay whole program to reject frame-to-frame inputs
        while ((glfwGetTime() - startTime) < duration) { }
    }

    // Save image (WIP)
    if (glfwGetKey(window, GLFW_KEY_F1) == GLFW_PRESS) {
        // Try to save image
        int* buffer = new int[ 800 * 600 * 3 ];
        glReadPixels( 0, 0, 800, 600, GL_RGB, GL_UNSIGNED_BYTE, buffer );

        FILE   *out = fopen("out.tga", "w");
        short  TGAhead[] = {0, 2, 0, 0, 0, 0, WIDTH, HEIGHT, 24};
        fwrite(&TGAhead, sizeof(TGAhead), 1, out);
        fwrite(buffer, 3 * WIDTH * HEIGHT, 1, out);
        fclose(out);

    }
}