#ifndef MESH_H
#define MESH_H

// includes
#include <glad/glad.h>
#include <string>
#include <vector>
#include <shader.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

// vertex struct
struct Vertex{
    glm::vec3 Position;
    glm::vec3 Normal;
    glm::vec2 TexCoords;
};

// texture struct
struct Texture{
    unsigned int id;
    std::string type;
    std::string path;
};

// mesh class
class Mesh{
    public:
        std::vector<Vertex> vertices;
        std::vector<unsigned int> indices;
        std::vector<Texture> textures;
        unsigned int VAO;

        Mesh(std::vector<Vertex> vertices, std::vector<unsigned int> indices, std::vector<Texture> textures){
            this -> vertices = vertices;
            this -> indices = indices;
            this -> textures = textures;

            setupMesh();
        };


        void Draw(Shader &shader) {
            // Bind textures
            unsigned int diffuseNr = 1;
            unsigned int specularNr = 1;

            for (unsigned int i = 0; i < textures.size(); i++) {
                glActiveTexture(GL_TEXTURE0 + i);

                std::string number;
                std::string name = textures[i].type;
                if (name == "texture_diffuse") {
                    number = std::to_string(diffuseNr++);
                } else if (name == "texture_specular") {
                    number = std::to_string(specularNr++);
                }

                shader.setInt((name + number).c_str(), i);
                glBindTexture(GL_TEXTURE_2D, textures[i].id);
            }

            // --- Safety check: skip empty meshes ---
            if (indices.empty() || vertices.empty()) {
                std::cerr << "[Mesh::Draw] Skipping draw: empty mesh (V="
                        << vertices.size() << " I=" << indices.size() << ")\n";
                glActiveTexture(GL_TEXTURE0);
                return;
            }

            // Render
            glBindVertexArray(VAO);

            // Optional debug consistency check
            #ifndef NDEBUG
            GLint boundEBO = 0;
            glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &boundEBO);
            if ((GLuint)boundEBO != EBO) {
                std::cerr << "[Mesh::Draw] Warning: bound EBO != mesh EBO\n";
            }
            #endif

            glDrawElements(GL_TRIANGLES,
                        static_cast<GLsizei>(indices.size()),
                        GL_UNSIGNED_INT,
                        0);

            glBindVertexArray(0);

            // Reset texture unit
            glActiveTexture(GL_TEXTURE0);
        }

        
    private:
        unsigned int VBO = 0, EBO = 0;

        void setupMesh() {
            // Generate arrays/buffers
            glGenVertexArrays(1, &VAO);
            glGenBuffers(1, &VBO);
            glGenBuffers(1, &EBO);

            glBindVertexArray(VAO);

            // --- Vertex buffer (VBO) ---
            glBindBuffer(GL_ARRAY_BUFFER, VBO);
            if (!vertices.empty()) {
                glBufferData(GL_ARRAY_BUFFER,
                            vertices.size() * sizeof(Vertex),
                            vertices.data(),
                            GL_STATIC_DRAW);
            } else {
                // Allocate a tiny buffer to keep state valid
                glBufferData(GL_ARRAY_BUFFER, 0, nullptr, GL_STATIC_DRAW);
                std::cerr << "[Mesh::setupMesh] Warning: mesh created with 0 vertices\n";
            }

            // --- Element buffer (EBO) ---
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
            if (!indices.empty()) {
                glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                            indices.size() * sizeof(unsigned int),
                            indices.data(),
                            GL_STATIC_DRAW);
            } else {
                // Still bind a valid empty buffer
                glBufferData(GL_ELEMENT_ARRAY_BUFFER, 0, nullptr, GL_STATIC_DRAW);
                std::cerr << "[Mesh::setupMesh] Warning: mesh created with 0 indices\n";
            }

            // --- Vertex attributes ---
            // Position
            glEnableVertexAttribArray(0);
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)0);

            // Normal
            glEnableVertexAttribArray(1);
            glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex),
                                (void*)offsetof(Vertex, Normal));

            // Texture coordinates
            glEnableVertexAttribArray(2);
            glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex),
                                (void*)offsetof(Vertex, TexCoords));

            glBindVertexArray(0);
        }

};

#endif