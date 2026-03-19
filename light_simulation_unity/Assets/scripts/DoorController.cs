using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class DoorController : MonoBehaviour
{
    public GameObject pivotPoint; // World space pivot (e.g., hinge position)
    public float rotationAngle = 90f; // Total rotation in degrees
    public float duration = 1f; // Time in seconds for the door to open
    private bool isRotating = false;
    private bool isOpen = false;

    public void ToggleDoor()
    {
        if (!isRotating)
        {
            StartCoroutine(RotateDoor(isOpen ? -rotationAngle : rotationAngle));
            isOpen = !isOpen;
        }
    }

    private IEnumerator RotateDoor(float angle)
    {
        isRotating = true;

        float elapsed = 0f;
        float previousStep = 0f;
        float startAngle = 0f;
        float endAngle = angle;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / duration);
            float smoothT = Mathf.SmoothStep(0f, 1f, t);

            // Calculate how much to rotate this frame
            float currentAngle = Mathf.Lerp(startAngle, endAngle, smoothT);
            float deltaAngle = currentAngle - previousStep;
            previousStep = currentAngle;

            transform.RotateAround(pivotPoint.transform.position, Vector3.up, deltaAngle);

            yield return null;
        }

        isRotating = false;
    }
}
