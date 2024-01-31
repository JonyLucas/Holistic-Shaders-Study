Shader "Holistic/LightingChallenge1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MetallicTex ("Metallic (R)", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _EmissionThreshold ("Emission Threshold", Range(0,10)) = 0.0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Standard

        float4 _Color;
        half _Metallic;
        fixed _EmissionThreshold;
        sampler2D _MetallicTex;
        

        struct Input
        {
            float2 uv_MetallicTex;
        };

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _Color.rgb;
            o.Smoothness = tex2D(_MetallicTex, IN.uv_MetallicTex).r;
            o.Metallic = _Metallic;
            o.Emission = o.Smoothness.r * _EmissionThreshold;
        }
        ENDCG
    }
    FallBack "Diffuse"
}