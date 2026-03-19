using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class CollectorController : MonoBehaviour
{
    public int requiredNumberOfBeams = 1;
    public float requiredNumberOfSeconds = 5f;
    public bool isPuzzleCompleted = false;
    public bool isBeingHit = false;
    private float timer = 0f;
    public int beamCounter = 0;
    public GameObject puzzleSlave;
    public GameObject indicatorBar;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (isBeingHit && !isPuzzleCompleted && beamCounter == requiredNumberOfBeams){
            if (timer == 0f) {
                indicatorBar.transform.GetComponent<MeshRenderer>().enabled = true;
            }
            timer += Time.deltaTime;
            
            indicatorBar.transform.localScale += new Vector3(0, Time.deltaTime * (indicatorBar.transform.localScale.z/requiredNumberOfSeconds), 0);

            if (timer >= requiredNumberOfSeconds) {
                isPuzzleCompleted = true;
                puzzleSlave.GetComponent<DoorController>().ToggleDoor();
            }

        } else if ((!isBeingHit || beamCounter != requiredNumberOfBeams) && !isPuzzleCompleted) {
            if (timer>0f) {
                indicatorBar.transform.localScale -= new Vector3(0, Time.deltaTime * (indicatorBar.transform.localScale.z/requiredNumberOfSeconds), 0);
                timer -= Time.deltaTime;
            } else if (timer < 0f) {
                indicatorBar.transform.localScale = new Vector3(indicatorBar.transform.localScale.x, 0f, indicatorBar.transform.localScale.z);
                indicatorBar.transform.GetComponent<MeshRenderer>().enabled = false;
                timer = 0f;
            }

        }

        // Reset hit status each frame
        isBeingHit = false;
        beamCounter = 0;
    }
}
