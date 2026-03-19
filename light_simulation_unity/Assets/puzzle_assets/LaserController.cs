using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

[SerializeField]
public class LaserController : MonoBehaviour
{
    // The goal here is to cast a ray from a point in space, and see if it hits something
    float maxRayDistance = 50f;
    [SerializeField] public int maxNumberOfBounces = 10;
    
    RaycastHit hitInfo;
    LineRenderer lineRenderer;
    Vector3 reflectionVector;
    Vector3 refractionVector;

    // Start is called before the first frame update
    void Start()
    {
        // Assign the line renderer
        lineRenderer = GetComponent<LineRenderer>();

        // Set the initial points
        lineRenderer.positionCount = 1;
    }

    // Update is called once per frame
    void Update()
    {
        // From the front face of the light source, cast a ray
        Ray sourceRay = new Ray(this.transform.position, this.transform.right);
        Ray currentRay = sourceRay;
        lineRenderer.positionCount = 1;
        lineRenderer.SetPosition(0, this.transform.position);

        // Light bouncing simulation
        bool done = false;
        
        //Debug.Log("Ray reset");
        while (!done) {
            if (Physics.Raycast(currentRay, out hitInfo, maxRayDistance) && (lineRenderer.positionCount < maxNumberOfBounces)) {

                // Show that the ray hit something
                //Debug.DrawRay(currentRay.origin, currentRay.direction*hitInfo.distance, Color.red);
                //Debug.Log(lineRenderer.positionCount);
                //Debug.Log(hitInfo.point);

                // Solve the vector form of snells law
                Vector3 incomingVector = Vector3.Normalize(hitInfo.point - currentRay.origin);

                //Debug.Log(hitInfo.transform.tag);
                // Check to see that the tag of the target is
                switch (hitInfo.transform.tag) {
                    case "Reflective":
                        //Debug.Log("Reflect");

                        // Calculate the reflection vector
                        reflectionVector = calculateReflectionVector(incomingVector, hitInfo.normal);

                        // Overwrite the current ray using the reflection vector
                        currentRay = new Ray(hitInfo.point + (0.001f*reflectionVector), reflectionVector);
                        
                        // Update the line renderer
                        lineRenderer.positionCount += 1;
                        lineRenderer.SetPosition(lineRenderer.positionCount-1, currentRay.origin);

                        break;

                    case "Refractive":
                        //Debug.Log("Refract");
                        // Flag for internal reflection
                        bool totalReflection;
                        float objectIoR = hitInfo.transform.GetComponent<optic>().indexOfRefraction;

                        // Calculate the refraction vector
                        refractionVector = calculateRefractionVector(incomingVector, hitInfo.normal, 1.0f / objectIoR, out totalReflection);

                        // Overwrite the current ray
                        currentRay = new Ray(hitInfo.point + (0.001f*refractionVector), refractionVector);
                 
                        // Update the line renderer
                        lineRenderer.positionCount += 1;
                        lineRenderer.SetPosition(lineRenderer.positionCount-1, currentRay.origin);

                        // Handle refractions and total internal reflections
                        // Cast another ray to find where the refraction should end
                        Ray refractRay;
                        refractRay = new Ray(currentRay.origin + (maxRayDistance*refractionVector), -refractionVector);
                        RaycastHit[] refractHitInfo;
                        
                        refractHitInfo = Physics.RaycastAll(refractRay, maxRayDistance - 0.1f);
                        int correctInd;
                        correctInd = 0;
                        for (int i = 0; i < refractHitInfo.Length; i++) {
                            if (refractHitInfo[correctInd].distance < refractHitInfo[i].distance) {
                                correctInd = i;
                            }
                        }
                        //Debug.Log("Sorted raycast point: " + refractHitInfo[correctInd].point);

                        // Calculate a new refraction vector
                        refractionVector = calculateRefractionVector(refractionVector, -refractHitInfo[correctInd].normal, objectIoR / 1.0f, out totalReflection);

                        // Draw the ray between the two points
                        //Debug.DrawRay(currentRay.origin, currentRay.direction*Vector3.Distance(currentRay.origin, refractHitInfo[correctInd].point), Color.red);

                        // Overwrite the current ray
                        currentRay = new Ray(refractHitInfo[correctInd].point + (0.001f*refractionVector), refractionVector);

                        // Update the line renderer
                        lineRenderer.positionCount += 1;
                        lineRenderer.SetPosition(lineRenderer.positionCount-1, currentRay.origin);

                        while (totalReflection) {
                            // Cast another ray to find where the refraction should end
                            refractRay = new Ray(currentRay.origin + (maxRayDistance*refractionVector), -refractionVector);
                            refractHitInfo = Physics.RaycastAll(refractRay, maxRayDistance);
                            correctInd = 0;
                            for (int i = 0; i < refractHitInfo.Length; i++) {
                                if (refractHitInfo[correctInd].distance < refractHitInfo[i].distance) {
                                    correctInd = i;
                                }
                            }
                            //Debug.Log("Sorted raycast point: " + refractHitInfo[correctInd].point);
                            //Debug.Log("Final raycast point: " + refractHitInfo[0].point);

                            // Calculate a new refraction vector
                            refractionVector = calculateRefractionVector(refractionVector, -refractHitInfo[correctInd].normal, objectIoR / 1.0f, out totalReflection);

                            // Draw the ray between the two points
                            //Debug.DrawRay(currentRay.origin, currentRay.direction*Vector3.Distance(currentRay.origin, refractHitInfo[correctInd].point), Color.red);

                            // Overwrite the current ray
                            currentRay = new Ray(refractHitInfo[correctInd].point + (0.01f*refractionVector), refractionVector);

                            // Update the line renderer
                            lineRenderer.positionCount += 1;
                            lineRenderer.SetPosition(lineRenderer.positionCount-1, currentRay.origin);
                        }

                        // Update the line renderer
                        //lineRenderer.positionCount += 1;
                        //lineRenderer.SetPosition(lineRenderer.positionCount-1, hitInfo.point);
                        //done = true;
                        break;
                    case "Collector":
                        // Check for conditions

                        // Increment the internal timer for the puzzle
                        hitInfo.transform.GetComponent<CollectorController>().isBeingHit = true;
                        hitInfo.transform.GetComponent<CollectorController>().beamCounter++;
                        
                        // Laser stuff to avoid an infinite loop
                        done = true;

                        // Update the line renderer
                        lineRenderer.positionCount += 1;
                        lineRenderer.SetPosition(lineRenderer.positionCount-1, currentRay.origin + (currentRay.direction*hitInfo.distance));

                        // Check for puzzle completed flag
                        if (hitInfo.transform.GetComponent<CollectorController>().isPuzzleCompleted) {
                            // Turn off the laser
                            this.GetComponent<LaserController>().enabled = false;
                            lineRenderer.enabled = false;
                        }

                        break;
                    default:
                        //Debug.Log("Default");
                        // Error correction: If the ray hits something but it does not know what to do with it
                        done = true;

                        // Draw the final ray
                        //Debug.DrawRay(currentRay.origin, currentRay.direction*hitInfo.distance, Color.green);

                        // Update the line renderer
                        lineRenderer.positionCount += 1;
                        lineRenderer.SetPosition(lineRenderer.positionCount-1, currentRay.origin + (currentRay.direction*hitInfo.distance));
                        break;
                }
            } else {
                //Debug.Log("No hit");
                // If the ray does not hit anything
                // Break the while loop
                done = true;

                // Draw the final ray
                //Debug.DrawRay(currentRay.origin, currentRay.direction*maxRayDistance, Color.green);

                // Update the line renderer
                lineRenderer.positionCount += 1;
                lineRenderer.SetPosition(lineRenderer.positionCount-1, currentRay.origin + (currentRay.direction*maxRayDistance));
            }
        }                   
    }

    Vector3 calculateReflectionVector(Vector3 normalizedLightVector, Vector3 normalVector) {
            float cos_theta_1 = Vector3.Dot(-normalVector, normalizedLightVector);
            //Debug.Log("Reflection vector: " + (normalizedLightVector + (2 * cos_theta_1 * normalVector)));
            return normalizedLightVector + (2 * cos_theta_1 * normalVector);
    }

    Vector3 calculateRefractionVector(Vector3 normalizedLightVector, Vector3 normalVector, float indexRatio, out bool isReflection) {
            float cos_theta_1 = Vector3.Dot(-normalVector, normalizedLightVector);
            float radicand_1 = roundToNearest(1 - Mathf.Pow(cos_theta_1,2), 0.0001f);
            float sin_theta_2 = indexRatio*Mathf.Sqrt(radicand_1);
            float radicand_2 = roundToNearest(1 - Mathf.Pow(sin_theta_2,2), 0.0001f);

            if (radicand_2 < 0) {
                //Debug.Log("Reflection vector: " + (normalizedLightVector + (2 * cos_theta_1 * normalVector)));
                isReflection = true;
                return normalizedLightVector + (2 * cos_theta_1 * normalVector);
            } else {
                float cos_theta_2 = Mathf.Sqrt(radicand_2);

                //Debug.Log("Refraction vector: " + ((indexRatio*normalizedLightVector) + (((indexRatio*cos_theta_1) - cos_theta_2)*normalVector)));
                isReflection = false;
                return (indexRatio*normalizedLightVector) + (((indexRatio*cos_theta_1) - cos_theta_2)*normalVector);
            }
    }

    float roundToNearest(float inputNumber, float acc) {
        return Mathf.Round(inputNumber/acc)*acc;
    }
}   
