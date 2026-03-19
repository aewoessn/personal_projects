using System.Collections;
using System.Collections.Generic;
using JetBrains.Annotations;
using UnityEngine;

[RequireComponent (typeof (MeshFilter))] 
[RequireComponent (typeof (MeshRenderer))]
[RequireComponent (typeof (MeshCollider))]
[RequireComponent (typeof (optic))]
public class lens : MonoBehaviour
{
    public float[] radiusOfCurvature;
    public Vector3 scale = Vector3.one;
    public float cylinderHeight = 1f;
    public float cylinderRadius = 1f;
    public string baseGeometry;
    public Vector3[] faceNormals;

    #region Cube lens
    public void createCubeLens(){

        // Instantiate a new mesh object
        Mesh mesh = new Mesh();

        // Link the new mesh to the mesh filter
        GetComponent<MeshFilter>().mesh = mesh;

        List<Vector3> verticesList = new List<Vector3>();
        List<Vector2> uvsList = new List<Vector2>();
        List<int> trianglesList = new List<int>();

        // Define cube face directions
        Vector3[] faceNormals = {
            Vector3.left,    // Left
            Vector3.right,   // Right 
            Vector3.down,    // Bottom
            Vector3.up,      // Top     
            Vector3.back,    // Back
            Vector3.forward, // Front
        };

        Vector3[] faceUps = {
            Vector3.up,      // Left
            Vector3.up,      // Right
            Vector3.back,    // Bottom
            Vector3.forward, // Top
            Vector3.up,      // Back
            Vector3.up,      // Front
        };

        int faceCount = 0;

        for (int i = 0; i < 6; i++)
        {
            AddFace(faceNormals[i], faceUps[i], ref verticesList, ref uvsList, ref trianglesList, faceCount, radiusOfCurvature[i], scale);
            faceCount++;
        }

        mesh.vertices = verticesList.ToArray();
        mesh.uv = uvsList.ToArray();
        mesh.triangles = trianglesList.ToArray();

        // Recalculate bounds and normals
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
        mesh.Optimize();
        GetComponent<MeshRenderer>().material = new Material(Shader.Find("Standard"));

        // Set the mesh collider
        GetComponent<MeshCollider>().sharedMesh = mesh;
    }

    void AddFace(Vector3 normal, Vector3 up, ref List<Vector3> vertices, ref List<Vector2> uvs, ref List<int> triangles, int faceIndex, float radiusOfCurvature, Vector3 scale)
    {
        int startIndex = vertices.Count;
        int subdivisions;
        if (radiusOfCurvature == 0) {
            subdivisions = 1;
        } else {
            subdivisions = 100;
        }

        int vertCountPerLine = subdivisions + 1;
        float step = 2f / subdivisions; // from -1 to 1 = 2 units
        Vector3 right = Vector3.Cross(up, normal);
        Vector3 scaledNormal = Vector3.Scale(normal, scale);

        for (int y = 0; y < vertCountPerLine; y++)
        {
            for (int x = 0; x < vertCountPerLine; x++)
            {
                float xPos = x * step - 1f;
                float yPos = y * step - 1f;
                
                Vector3 pointOnPlane = right * xPos + up * yPos;
                pointOnPlane = Vector3.Scale(pointOnPlane, scale);
                float curvatureOffset = radiusOfCurvature * Mathf.Cos(xPos * Mathf.PI / 2) * Mathf.Cos(yPos * Mathf.PI / 2);

                float faceOffset = scaledNormal.magnitude;
                pointOnPlane += -scaledNormal.normalized * (curvatureOffset + faceOffset);
                vertices.Add(pointOnPlane);
                uvs.Add(new Vector2(x / (float)subdivisions, y / (float)subdivisions));
            }
        }

        for (int y = 0; y < subdivisions; y++)
        {
            for (int x = 0; x < subdivisions; x++)
            {
                int topLeft = startIndex + x + y * vertCountPerLine;
                int topRight = topLeft + 1;
                int bottomLeft = topLeft + vertCountPerLine;
                int bottomRight = bottomLeft + 1;

                triangles.Add(topLeft);
                triangles.Add(bottomLeft);
                triangles.Add(topRight);

                triangles.Add(topRight);
                triangles.Add(bottomLeft);
                triangles.Add(bottomRight);
            }
        }
    }
    #endregion

    #region cylindrical lens
    public void CreateCurvedCylinder()
    {
        Mesh mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;

        // Hardcode certain parameters
        int radialSubdivisions = 100;
        int heightSubdivisions = 1;

        List<Vector3> verticesList = new List<Vector3>();
        List<Vector2> uvsList = new List<Vector2>();
        List<int> trianglesList = new List<int>();

        // Add cylindrical body
        AddCylinderBody(cylinderHeight, cylinderRadius, radialSubdivisions, heightSubdivisions, ref verticesList, ref uvsList, ref trianglesList);

        // Add curved caps
        AddCurvedCap(true, cylinderHeight, cylinderRadius, radialSubdivisions, radiusOfCurvature[0], ref verticesList, ref uvsList, ref trianglesList);  // Top
        AddCurvedCap(false, cylinderHeight, cylinderRadius, radialSubdivisions, radiusOfCurvature[1], ref verticesList, ref uvsList, ref trianglesList); // Bottom

        mesh.vertices = verticesList.ToArray();
        mesh.uv = uvsList.ToArray();
        mesh.triangles = trianglesList.ToArray();

        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
        mesh.Optimize();

        GetComponent<MeshRenderer>().material = new Material(Shader.Find("Standard"));
        GetComponent<MeshCollider>().sharedMesh = mesh;
    }

    void AddCylinderBody(float height, float radius, int radialSubdivisions, int heightSubdivisions, ref List<Vector3> vertices, ref List<Vector2> uvs, ref List<int> triangles)
    {
        int startIndex = vertices.Count;
        float halfHeight = height / 2f;

        for (int y = 0; y <= heightSubdivisions; y++)
        {
            float v = y / (float)heightSubdivisions;
            float yPos = Mathf.Lerp(-halfHeight, halfHeight, v);

            for (int i = 0; i <= radialSubdivisions; i++)
            {
                float u = i / (float)radialSubdivisions;
                float angle = u * Mathf.PI * 2;
                float x = Mathf.Cos(angle) * radius;
                float z = Mathf.Sin(angle) * radius;
                vertices.Add(new Vector3(x, z, -yPos));
                uvs.Add(new Vector2(u, v));
            }
        }

        int vertsPerRow = radialSubdivisions + 1;
        for (int y = 0; y < heightSubdivisions; y++)
        {
            for (int i = 0; i < radialSubdivisions; i++)
            {
                int a = startIndex + i + y * vertsPerRow;
                int b = a + vertsPerRow;
                int c = b + 1;
                int d = a + 1;

                triangles.Add(a);
                triangles.Add(b);
                triangles.Add(d);

                triangles.Add(d);
                triangles.Add(b);
                triangles.Add(c);
            }
        }
    }

    void AddCurvedCap(bool isTop, float height, float radius, int radialSubdivisions, float curvatureRadius, ref List<Vector3> vertices, ref List<Vector2> uvs, ref List<int> triangles)
    {
        int startIndex = vertices.Count;
        int capResolution = 30;
        float centerY = isTop ? height / 2f : -height / 2f;
        Vector3 center = new Vector3(0, 0, centerY);
        Vector3 normal = isTop ? Vector3.back : Vector3.forward;

        for (int y = 0; y <= capResolution; y++)
        {
            float tY = y / (float)capResolution;

            // NEW: Even spacing using a quarter-sphere angle
            float angle = tY * Mathf.PI / 2f;
            float r = Mathf.Sin(angle) * radius;

            for (int i = 0; i <= radialSubdivisions; i++)
            {
                float u = i / (float)radialSubdivisions;
                float azimuth = (isTop ? u : 1 - u) * Mathf.PI * 2;

                float x = Mathf.Cos(azimuth) * r;
                float z = Mathf.Sin(azimuth) * r;

                Vector3 point = new Vector3(x, z, 0f);

                // Curved offset (same as before)
                if (curvatureRadius != 0f)
                {
                    float curvedOffset = Mathf.Cos(angle) * curvatureRadius;
                    point += normal * curvedOffset;
                }

                point.z -= centerY;
                vertices.Add(point);
                uvs.Add(new Vector2(u, tY));
            }
        }


        int rowVerts = radialSubdivisions + 1;
        for (int y = 0; y < capResolution; y++)
        {
            for (int i = 0; i < radialSubdivisions; i++)
            {
                int a = startIndex + i + y * rowVerts;
                int b = a + rowVerts;
                int c = b + 1;
                int d = a + 1;

                triangles.Add(a);
                triangles.Add(d);
                triangles.Add(b);

                triangles.Add(d);
                triangles.Add(c);
                triangles.Add(b);

            }
        }
    }

    #endregion
}
