using UnityEngine;

[ExecuteInEditMode]
public class StyledClouds : MonoBehaviour
{
    public Shader cloudShader;
    public float minHeight = 0.0f;
    public float maxHeight = 5.0f;
    public float fadeDist = 2;
    public float scale = 5;
    public float steps = 50;
    public Texture noiseTex;
    public Transform directionalLight;

    private Camera _camera;
    private Material _material;
    
    public Material Material
    {
        get
        {
            if (_material) return _material;
            _material = new Material(cloudShader);
            _material.hideFlags = HideFlags.HideAndDontSave;
            return _material;
        }
    }
    
    private void Awake()
    {
        if (_material)
        {
            DestroyImmediate(_material);
        }
        
        _camera = GetComponent<Camera>();
    }

    private Matrix4x4 GetFrustumCorners()
    {
        var frustumCorners = Matrix4x4.identity;
        var fCorners = new Vector3[4];
        
        _camera.CalculateFrustumCorners(new Rect(0, 0, 1, 1), _camera.farClipPlane, _camera.stereoActiveEye, fCorners);
        
        for (var i = 0; i < fCorners.Length; i++)
        {
            var vector = fCorners[i];
            vector.z *= -1;
            fCorners[i] = vector;
        }
        
        frustumCorners.SetRow(0, fCorners[1]);
        frustumCorners.SetRow(1, fCorners[2]);
        frustumCorners.SetRow(2, fCorners[3]);
        frustumCorners.SetRow(3, fCorners[0]);
        
        return frustumCorners;
    }
    
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!cloudShader || !Material)
        {
            Graphics.Blit(src, dest); // Don't do anything if we don't have a shader or material
            return;
        }
        
        Material.SetTexture("_NoiseTex", noiseTex);
        Material.SetFloat("_MinHeight", minHeight);
        Material.SetFloat("_MaxHeight", maxHeight);
        Material.SetFloat("_FadeDist", fadeDist);
        Material.SetFloat("_Scale", scale);
        Material.SetFloat("_Steps", steps);
        Material.SetVector("_LightDir", directionalLight ? -directionalLight.forward : Vector3.up);
        
        Material.SetMatrix("_CameraToWorldMatrix", _camera.cameraToWorldMatrix);
        Material.SetMatrix("_FrustumCornersWS", GetFrustumCorners());
        Material.SetVector("_CloudParams", new Vector4(minHeight, maxHeight, fadeDist, scale));
        
        CustomGraphicsBlit(src, dest, Material, 0);
    }

    static void CustomGraphicsBlit(RenderTexture src, RenderTexture dest, Material material, int pass)
    {
        RenderTexture.active = dest;
        
        material.SetTexture("_MainTex", src);
        
        GL.PushMatrix();
        GL.LoadOrtho();
        
        material.SetPass(pass);
        
        GL.Begin(GL.QUADS);
        
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);
        
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);
        
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);
        
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);
        
        GL.End();
        GL.PopMatrix();
    }
    
    private void OnDisable()
    {
        if (_material)
        {
            DestroyImmediate(_material);
        }
    }

    
}
