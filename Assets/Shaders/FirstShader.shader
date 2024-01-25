Shader "Holistic/FirstShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _EmissionColor ("Emission Color", Color) = (0,0,0,0)
        _NormalColor ("Normal Color", Color) = (0.5,0.5,1,1)
    }
    SubShader
    {
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        struct Input
        {
            float2 uv_MainTex;
        };
        
        fixed4 _Color;
        fixed4 _EmissionColor;
        fixed4 _NormalColor;

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
            o.Emission = _EmissionColor.rgb;
            o.Normal = _NormalColor.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
