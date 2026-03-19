using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Unity.VisualScripting;
using Unity.VisualScripting.Dependencies.Sqlite;

[CustomEditor(typeof(optic))]
public class OpticEditor : Editor
{
    int selected;
    public override void OnInspectorGUI()
    {
        optic targetOptic = (optic)target;

        string[] options = new string[]{
            "Reflective", "Refractive"
        };

        if (targetOptic.transform.tag == "Reflective") {selected = 0;} else {selected = 1;};
        
        selected = EditorGUILayout.Popup("Type of optic", selected, options, GUILayout.Width(300));

        switch (selected){
            case 0:
                targetOptic.reflective = true;
                targetOptic.refractive = false;
                targetOptic.transform.tag = "Reflective";
                break;
            case 1:
                targetOptic.reflective = false;
                targetOptic.refractive = true;
                targetOptic.transform.tag = "Refractive";
                break;
        }
        
        if (targetOptic.refractive ) {
            targetOptic.indexOfRefraction = EditorGUILayout.FloatField("Index of refraction:",targetOptic.indexOfRefraction, GUILayout.Width(400));
        }
        
    }

}
