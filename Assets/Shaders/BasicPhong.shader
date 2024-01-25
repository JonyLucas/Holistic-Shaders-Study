Shader "Holistic/BasicPhong"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
        _Shininess ("Shininess", Range(0.01, 1)) = 0.5
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
    }
    SubShader
    {
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf BlinnPhong

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;
        half _Shininess;
        half _Glossiness;

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
            o.Specular = _Shininess;
            o.Gloss = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
