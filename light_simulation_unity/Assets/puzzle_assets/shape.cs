using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (MeshFilter))] 
[RequireComponent (typeof (MeshRenderer))]
[RequireComponent (typeof (MeshCollider))]
[RequireComponent (typeof (optic))]
public class shape : MonoBehaviour
{
    public string typeOfGeometry;
    public float[] scale = {1f, 1f, 1f};
    public void createInitialGeometry(string typeOfGeometry) {

        // Set the type of geometry
        this.typeOfGeometry = typeOfGeometry;
        
        // Instantiate a new mesh object
        Mesh mesh = new Mesh();

        // Link the new mesh to the mesh filter
        GetComponent<MeshFilter>().mesh = mesh;

        switch (typeOfGeometry) {
            case ("tetrahedron"):

                // Define and assign vertices
                Vector3[] newVertices = {
                                        new Vector3( 0.0f, 0.0f, 0.0f),
                                        new Vector3( 1.0f, 1.0f, 0.0f), 
                                        new Vector3( 1.0f, 0.0f, 1.0f),
                                        new Vector3( 0.0f, 1.0f, 1.0f)
                                        };

                mesh.vertices = new Vector3[]{
                    newVertices[2], newVertices[1], newVertices[0],
                    newVertices[0], newVertices[1], newVertices[3],
                    newVertices[3], newVertices[2], newVertices[0],
                    newVertices[1], newVertices[2], newVertices[3]
                };

                // Assign triangles
                int[] newTriangles = {
                                    0, 1, 2,
                                    3, 4, 5,
                                    6, 7, 8,
                                    9, 10, 11
                                    };

                mesh.triangles = newTriangles;

                break;

            case ("prism"):

                // Define and assign vertices
                newVertices = new Vector3[]{
                                            new Vector3( 0.5f, -0.5f, 0.5f),
                                            new Vector3(-0.5f, -0.5f, 0.5f), 
                                            new Vector3( 0.0f,  0.5f, 0.5f),
                                            new Vector3( 0.5f, -0.5f, -0.5f),
                                            new Vector3(-0.5f, -0.5f, -0.5f), 
                                            new Vector3( 0.0f,  0.5f, -0.5f)
                                        };

                mesh.vertices = new Vector3[]{
                    newVertices[2], newVertices[1], newVertices[0],
                    newVertices[3], newVertices[4], newVertices[5],
                    newVertices[3], newVertices[2], newVertices[0],
                    newVertices[2], newVertices[3], newVertices[5],
                    newVertices[0], newVertices[1], newVertices[3],
                    newVertices[4], newVertices[3], newVertices[1],
                    newVertices[2], newVertices[4], newVertices[1],
                    newVertices[5], newVertices[4], newVertices[2]                            
                };

                // Assign triangles
                newTriangles = new int[]{
                                            0, 1, 2,
                                            3, 4, 5,
                                            6, 7, 8,
                                            9, 10, 11,
                                            12, 13, 14,
                                            15, 16, 17,
                                            18, 19, 20,
                                            21, 22, 23
                                        };
                mesh.triangles = newTriangles;

                break;

        }

        // Recalculate bounds and normals
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
        mesh.Optimize();
        GetComponent<MeshRenderer>().material = new Material(Shader.Find("Standard"));

        // Set the mesh collider
        GetComponent<MeshCollider>().sharedMesh = mesh;
    }
}