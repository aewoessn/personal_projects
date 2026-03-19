using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    // Set the player speed 
    public float maxSpeed = 5;

    // Initialize the players rigid body
    Rigidbody playerRb;
    Transform playerTform;

    // Start is called before the first frame update
    void Start()
    {
        // Get the transform and rigid body associated with this GameObject
        playerTform = this.GetComponent<Transform>();
        playerRb = this.GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        // Rotate the player transform about the Y axis
        Vector3 rotationVector = playerTform.rotation.eulerAngles + new Vector3(0, Input.GetAxisRaw("Mouse X"), 0);
        playerTform.rotation = Quaternion.Euler(rotationVector);

        // Get WASD inputs and move the player
        playerRb.AddForce((playerTform.right * Input.GetAxis("Horizontal")) + (playerTform.forward * Input.GetAxis("Vertical")), ForceMode.Impulse);
        playerRb.velocity = Vector3.ClampMagnitude(playerRb.velocity, maxSpeed);
    }   
}
