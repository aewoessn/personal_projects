#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

public class MeshSaver : MonoBehaviour
{
    public MeshFilter meshFilter;

#if UNITY_EDITOR
    [ContextMenu("Save Mesh As Asset")]
    void SaveMesh()
    {
        if (meshFilter == null || meshFilter.sharedMesh == null)
        {
            Debug.LogError("MeshFilter or its Mesh is missing.");
            return;
        }

        string path = "Assets/SavedMeshes/";
        string meshName = meshFilter.sharedMesh.name;
        string assetPath = path + meshName + "test.asset";

        // Create directory if it doesn't exist
        if (!AssetDatabase.IsValidFolder(path.TrimEnd('/')))
        {
            System.IO.Directory.CreateDirectory(path);
        }

        // Duplicate the mesh to avoid editing the original in memory
        Mesh meshCopy = Instantiate(meshFilter.sharedMesh);

        // Save the mesh asset
        AssetDatabase.CreateAsset(meshCopy, assetPath);
        AssetDatabase.SaveAssets();

        Debug.Log("Mesh saved to: " + assetPath);
    }
#endif
}