Shader "Holistic/LightingChallenge2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MetallicTex ("Metallic (R)", 2D) = "white" {}
        _SpecColor ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf StandardSpecular

        float4 _Color;
        sampler2D _MetallicTex;
        

        struct Input
        {
            float2 uv_MetallicTex;
        };

        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            o.Albedo = _Color.rgb;
            o.Smoothness = 1 - tex2D(_MetallicTex, IN.uv_MetallicTex).r;
            o.Specular = _SpecColor;
        }
        ENDCG
    }
    FallBack "Diffuse"
}