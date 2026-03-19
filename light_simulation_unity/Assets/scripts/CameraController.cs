using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    // Initialize the camera transform
    Transform cameraTform;
    private readonly float xRotBoundTop = -45;
    private readonly float xRotBoundBot = 45;

    // Start is called before the first frame update
    void Start()
    {
        cameraTform = this.GetComponent<Transform>();
    }

    // Update is called once per frame
    void Update()
    {
        // Rotate the camera transform about the Z axis
        Vector3 cameraInput = new Vector3(-Input.GetAxisRaw("Mouse Y"), 0, 0);
        Vector3 rotationVector = cameraTform.rotation.eulerAngles + cameraInput;

        // Limit up/down camera movement
        float currentXAng = ((cameraTform.rotation.eulerAngles.x + 180) % 360) - 180;
        
        if (currentXAng <= xRotBoundTop) {
            rotationVector.x = xRotBoundTop+0.1f;
        }

        if (currentXAng >= xRotBoundBot) {
            rotationVector.x = xRotBoundBot-0.1f;
        }

        cameraTform.rotation = Quaternion.Euler(rotationVector);
    }
}
