#ifndef SHADER_H
#define SHADER_H

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

class Shader{

    public:

        unsigned int shaderProgramID; // program ID

        Shader(){
            return;
        }

        Shader(const char* vertexShaderPath, const char* fragmentShaderPath) { // constructor
            // retrieve the vertex/fragment shader source code
            std::string vertexCode, fragmentCode;
            std::ifstream vertexShaderFile, fragmentShaderFile;

            // ensure ifstream objects can throw exceptions:
            vertexShaderFile.exceptions (std::ifstream::failbit | std::ifstream::badbit);
            fragmentShaderFile.exceptions (std::ifstream::failbit | std::ifstream::badbit);  
            
            // try to load the shader files
            try {
                // open files
                vertexShaderFile.open(vertexShaderPath);
                fragmentShaderFile.open(fragmentShaderPath);
                std::stringstream vertexShaderStream, fragmentShaderStream;

                // read file buffer into stream
                vertexShaderStream << vertexShaderFile.rdbuf();
                fragmentShaderStream << fragmentShaderFile.rdbuf();

                // close files
                vertexShaderFile.close();
                fragmentShaderFile.close();

                // convert stream to string
                vertexCode = vertexShaderStream.str();
                fragmentCode = fragmentShaderStream.str();
            } catch(std::ifstream::failure e) {
                std::cout << "ERROR::SHADER::FILE_NOT_SUCCESSFULLY_READ" << std::endl;
            }

            const char* vertexShaderSource = vertexCode.c_str();
            const char* fragmentShaderSource = fragmentCode.c_str();

            // shader compilation
            unsigned int vertexShader = 0;
            unsigned int fragmentShader = 0;
            int success;
            char infoLog[512];

            //--- Vertex shader ---//
            vertexShader = glCreateShader(GL_VERTEX_SHADER);

            // Attach the vertex shader source code to the vertex shader and compile it
            glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
            glCompileShader(vertexShader);

            // Error handling if vertex shader did not compile correctly
            glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);

            if (!success) {
                glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
                std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
            }

            //--- Fragment shader ---//
            fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);

            // Attach the fragment shader source code to the vertex shader and compile it
            glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
            glCompileShader(fragmentShader);

            // Error handling if fragment shader did not compile correctly
            glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);

            if (!success) {
                glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
                std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
            } 

            //--- Shader program ---//
            // Create a shader program to link the vertex and fragment shaders as a rendering pipeline
            shaderProgramID = glCreateProgram();
            glAttachShader(shaderProgramID, vertexShader);
            glAttachShader(shaderProgramID, fragmentShader);
            glLinkProgram(shaderProgramID);

            // Error handling
            glGetProgramiv(shaderProgramID, GL_LINK_STATUS, &success);

            if (!success) {
                glGetProgramInfoLog(shaderProgramID, 512, NULL, infoLog);
                std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
            }

            // Delete raw shaders since they are not needed once the program is linked
            glDeleteShader(vertexShader);
            glDeleteShader(fragmentShader);
        };
        
        void use() { // activate the shader program
            glUseProgram(shaderProgramID);
        };

        void setBool(const std::string &name, bool value) const{
            glUniform1i(glGetUniformLocation(shaderProgramID, name.c_str()), (int) value);
        };

        void setInt(const std::string &name, int value) const{
            glUniform1i(glGetUniformLocation(shaderProgramID, name.c_str()), value);
        };

        void setFloat(const std::string &name, float value) const{
            glUniform1f(glGetUniformLocation(shaderProgramID, name.c_str()), value);
        };

        void setMat4(const std::string &name, glm::mat4 value) const{
            glUniformMatrix4fv(glGetUniformLocation(shaderProgramID, name.c_str()), 1, GL_FALSE, glm::value_ptr(value));
        };

        void setVec3(const std::string &name, glm::vec3 value) const{
            glUniform3fv(glGetUniformLocation(shaderProgramID, name.c_str()), 1, glm::value_ptr(value));
        }
};


#endif