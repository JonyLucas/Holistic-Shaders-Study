Shader "Holistic/WorldPosStripes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleMultiplier ("Scale Multiplier", Float) = 1
        _OddColor ("Odd Color", Color) = (1,1,1,1)
        _EvenColor ("Even Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        float _ScaleMultiplier;
        float4 _OddColor;
        float4 _EvenColor;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float3 worldPos;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            float rim = 1 - saturate(dot(IN.viewDir, o.Normal));
            // o.Albedo = lerp(_OddColor, _EvenColor, frac(IN.worldPos.x * _ScaleMultiplier)); // frac returns the fractional part of a float
            o.Emission = frac(IN.worldPos.x * _ScaleMultiplier * 0.5) > 0.4 ? _EvenColor * rim : _OddColor * rim; // frac returns the fractional part of a float
        }
        ENDCG
    }
    FallBack "Diffuse"
}