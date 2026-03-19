using System.Collections;
using System.Collections.Generic;
using JetBrains.Annotations;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(shape))]
public class ShapeEditor : Editor
{
    [MenuItem ("GameObject/Extra/Tetraheron")]
    static void CreateTetrahedron() {
        GameObject gameObject = new GameObject("Tetrahedron");
        gameObject.AddComponent<shape>();
        
        gameObject.GetComponent<shape>().createInitialGeometry("tetrahedron");
    }

    [MenuItem ("GameObject/Extra/Prism")]
    static void CreatePrism() {
        GameObject gameObject = new GameObject("Prism");
        gameObject.AddComponent<shape>();
        
        gameObject.GetComponent<shape>().createInitialGeometry("prism");
    }

    [MenuItem ("GameObject/Extra/ngon")]
    static void CreateCube() {
        GameObject gameObject = new GameObject("Cube");
        gameObject.AddComponent<shape>();
        
        gameObject.GetComponent<shape>().createInitialGeometry("cube");
    }

    public override void OnInspectorGUI()
    {

    }
}
