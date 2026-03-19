using System.Collections;
using System.Collections.Generic;
using JetBrains.Annotations;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(lens))]
public class LensEditor : Editor
{
    [MenuItem ("GameObject/Lens/Cube")]
    static void CreateCube() {
        GameObject gameObject = new GameObject("CubeLens");
        gameObject.AddComponent<lens>();
        
        gameObject.GetComponent<lens>().radiusOfCurvature = new float[] {0f, 0f, 0f, 0f, 0f, 0f};
        gameObject.GetComponent<lens>().baseGeometry = "cube";
        gameObject.GetComponent<lens>().faceNormals = new Vector3[]{
            Vector3.left,    // Left
            Vector3.right,   // Right 
            Vector3.down,    // Bottom
            Vector3.up,      // Top     
            Vector3.back,    // Back
            Vector3.forward, // Front
        };
        gameObject.GetComponent<lens>().createCubeLens();
    }

    [MenuItem ("GameObject/Lens/Cylinder")]
    static void CreateCurvedCylinder() {
        GameObject gameObject = new GameObject("CylinderLens");
        gameObject.GetComponent<Transform>().eulerAngles = new Vector3(0, 0, 0);
        gameObject.AddComponent<lens>();
        
        gameObject.GetComponent<lens>().radiusOfCurvature = new float[] {0f, 0f};
        gameObject.GetComponent<lens>().baseGeometry = "cylinder";
        
        gameObject.GetComponent<lens>().faceNormals = new Vector3[]{
            Vector3.right,    // Bottom
            Vector3.left      // Top     
        };
        
        gameObject.GetComponent<lens>().CreateCurvedCylinder();
    }

    public override void OnInspectorGUI()
    {
        lens targetLens = (lens)target;

        if (targetLens.baseGeometry == "cube"){
            GUILayout.Label("//---Scaling---//", GUILayout.Width(400));
            targetLens.scale[0] = EditorGUILayout.FloatField("x scaling", targetLens.scale[0], GUILayout.Width(400));
            targetLens.scale[1] = EditorGUILayout.FloatField("y scaling", targetLens.scale[1], GUILayout.Width(400));
            targetLens.scale[2] = EditorGUILayout.FloatField("z scaling", targetLens.scale[2], GUILayout.Width(400));
        }

        if (targetLens.baseGeometry == "cylinder") {
            GUILayout.Label("//---Cylinder parameters---//", GUILayout.Width(400));
            targetLens.cylinderHeight = EditorGUILayout.FloatField("Cylinder height", targetLens.cylinderHeight, GUILayout.Width(400));
            targetLens.cylinderRadius = EditorGUILayout.FloatField("Cylinder radius", targetLens.cylinderRadius, GUILayout.Width(400));
        }

        GUILayout.Label("//---Curvature---//", GUILayout.Width(400));
        for (int i = 0; i < targetLens.faceNormals.Length; i++){
            targetLens.radiusOfCurvature[i] = EditorGUILayout.FloatField((-targetLens.faceNormals[i]).ToString(), targetLens.radiusOfCurvature[i], GUILayout.Width(400));
        }

        if (GUILayout.Button("Update shape", GUILayout.Width(400))) {
            switch (targetLens.baseGeometry) {
                case "cube":
                    targetLens.GetComponent<lens>().createCubeLens();
                    break;
                case "cylinder":
                    targetLens.GetComponent<lens>().CreateCurvedCylinder();
                    break;
            }

        }
    }
}

