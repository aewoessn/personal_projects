// includes (general)
#include <iostream>
#include <vector>
#include <string>

#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include "scene.h"

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
    // scene
    std::string sceneURI = "./scenes/22_01_depth_test_function.xml";
    scene = Scene(sceneURI);

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
        scene.DrawAll();

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