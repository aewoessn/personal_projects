#ifndef OBJECT_H
#define OBJECT_H

// includes
#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

class Cube{

    public:

    // Vertex attributes
    float vertAttributes[256] = {
        // Position          // Normals           // Texture Coords
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 0.0f, 0.0f, 
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 0.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 1.0f, 1.0f,
         0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 1.0f, 0.0f,

        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f, 0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f, 0.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f, 1.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f, 1.0f, 0.0f,   
        
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f, 0.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f, 0.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f, 1.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f, 1.0f, 0.0f,

        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f, 0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f, 0.0f, 1.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f, 1.0f, 1.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f, 1.0f, 0.0f,

        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f, 0.0f, 0.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f, 0.0f, 1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f, 1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f, 1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f, 0.0f, 0.0f,
         0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f, 0.0f, 1.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f, 1.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f, 1.0f, 0.0f
    };

    // Face indices
    int faceIndices[36] = {
         0,  1,  2,
         0,  2,  3,
         4,  5,  6,
         4,  6,  7,
         8,  9, 10,
         8, 10, 11,
        12, 13, 14,
        12, 14, 15,
        16, 17, 18,
        16, 18, 19,
        20, 21, 22,
        20, 22, 23
    };

    // Model transform
    glm::mat4 model;

    // Rendering pipeline
    unsigned int VAO;
    unsigned int VBO;
    unsigned int EBO;

    // Constructor
    Cube( glm::mat4 modelTransform = glm::mat4(1.0f) ){

        // Set the model transform
        model = modelTransform;

        // Define the vertex array object (VAO)
        // This stores the attributes associated with a vertex array   
        //
        // Define the vertex buffer object (VBO)
        // This creates memory on GPU, tells OpenGL how to interpret the memory, and how to send the data to the GPU.
        // VBO -> GL_ARRAY_BUFFER
        
        glGenVertexArrays(1, &VAO);
        glBindVertexArray(VAO);

        glGenBuffers(1, &VBO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);

        // Specify the size of the buffer and fill in the buffer
        // GL_STREAM_DRAW -> Writes data once and is read a few times
        // GL_STATIC_DRAW -> Writes data once and is read many times
        // GL_DYNAMIC_DRAW -> Writes data many times and is read many times
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertAttributes), vertAttributes, GL_STATIC_DRAW);

        // Define the element buffer object (EBO)
        // This stores the indices used when drawing vertices
        glGenBuffers(1, &EBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(faceIndices), faceIndices, GL_STATIC_DRAW);

        // Specify how to interpret the vertex data and enable the "location" for the vertex shader
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)0);
        glEnableVertexAttribArray(0); // position

        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*) (3*sizeof(float)));
        glEnableVertexAttribArray(1); // normal

        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*) (6*sizeof(float)));
        glEnableVertexAttribArray(2); // texture
    };

    void renderObject() {
        glBindVertexArray(VAO);
        glDrawElements(GL_TRIANGLES, sizeof(faceIndices) / sizeof(faceIndices[0]) , GL_UNSIGNED_INT, 0);
    }
};

#endif