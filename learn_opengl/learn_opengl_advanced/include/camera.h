#ifndef CAMERA_H
#define CAMERA_H

// includes
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

class Camera {
    public:

        // Viewport parameters
        int viewWidth;
        int viewHeight;

        // Camera transform
        glm::vec3 cameraPos;
        glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
        glm::vec3 cameraUp = glm::vec3(0.0f, 1.0f, 0.0);

        // View and Projection transforms
        glm::mat4 cameraView;
        glm::mat4 cameraProjection;

        // Mouse input
        bool firstMouse = true;
        float lastX;
        float lastY;
        float yaw = -90.0f;
        float pitch = 0.0f;
        float fov = 45.0f;

        // Constructor
        Camera(int WIDTH, int HEIGHT, glm::vec3 position = glm::vec3(0.0f, 0.0f, 3.0f),
                                      glm::vec3 frontVector = glm::vec3(0.0f, 0.0f, -1.0f),
                                      glm::vec3 upVector = glm::vec3(0.0f, 1.0f, 0.0)) {
            viewWidth = WIDTH;
            viewHeight = HEIGHT;

            lastX = viewWidth / 2;
            lastY = viewHeight / 2;

            // View and Projection transforms
            cameraPos = position;
            cameraFront = frontVector;
            cameraUp = upVector;
            updateCamera();
        };

        void updateCamera() {
            // View and Projection transforms
            cameraView = glm::lookAt(cameraPos, cameraPos + cameraFront, cameraUp);
            cameraProjection = glm::perspective(glm::radians(fov), (float) viewWidth / (float) viewHeight, 0.1f, 100.0f);
        };

        // Process mouse input
        void processMouseInput(double xpos, double ypos) {
            // Error handling for first mouse input
            if (firstMouse) {
                lastX = xpos;
                lastY = ypos;
                firstMouse = false;
            }

            float xoffset = xpos - lastX;
            float yoffset = lastY - ypos;
            lastX = xpos;
            lastY = ypos;

            const float sensitivity = 0.1f;
            xoffset *= sensitivity;
            yoffset *= sensitivity;

            yaw += xoffset;
            pitch += yoffset;

            if (pitch > 89.0f) pitch = 89.0f;
            if (pitch < -89.0f) pitch = -89.0f;

            glm::vec3 direction;
            direction.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
            direction.y = sin(glm::radians(pitch));
            direction.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
            cameraFront = glm::normalize(direction);

            updateCamera();
        };

        // Process mouse scroll
        void processMouseScroll(double xoffset, double yoffset) {
            fov -= (float) yoffset;
            if (fov < 1.0f) fov = 1.0f;
            if (fov > 45.0f) fov = 45.0f;

            updateCamera();
        };
};

#endif