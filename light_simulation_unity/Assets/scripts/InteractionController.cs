using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractionController : MonoBehaviour
{

    private bool interactionState = false;
    private RaycastHit hitInfo;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (!interactionState) {
            Ray interactionRay = new Ray(transform.position, transform.forward);

            Debug.DrawRay(interactionRay.origin, interactionRay.direction*2f, Color.green);
            if (Physics.Raycast(interactionRay, out hitInfo, 2f)) {
                PuzzleComponent hitComponent;
                if (hitInfo.transform.TryGetComponent<PuzzleComponent>(out hitComponent)) {
                    Debug.Log("Press E to interact");
                    if (Input.GetKeyDown(KeyCode.E)) {
                        interactionState = true;

                        GetComponent<PlayerController>().enabled = false;
                        GetComponent<Rigidbody>().isKinematic = true;
                        GetComponent<CapsuleCollider>().enabled = false;
                        Vector3 attachmentPosition = hitInfo.transform.GetChild(0).transform.position;
                        Quaternion attachmentQuat = hitInfo.transform.GetChild(0).transform.rotation;
                        this.transform.SetPositionAndRotation(attachmentPosition, attachmentQuat);
                    }
                }
            }
        } else {
            if (Input.GetKeyDown(KeyCode.E)) {
                        interactionState = false;
                        GetComponent<PlayerController>().enabled = true;
                        GetComponent<Rigidbody>().isKinematic = false;
                        GetComponent<CapsuleCollider>().enabled = true;

            }
            
            hitInfo.transform.RotateAround(hitInfo.transform.position, Vector3.up, Input.GetAxis("Horizontal") * 0.1f);
            transform.RotateAround(transform.position, Vector3.up, Input.GetAxis("Horizontal") * 0.1f);
        }


    }
}
