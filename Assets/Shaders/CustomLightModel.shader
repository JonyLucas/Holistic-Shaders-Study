Shader "Holistic/CustomLightModel"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf CustomLight

        half4 LightingCustomLight (SurfaceOutput s, half3 lightDir, half atten)
        {
            half3 normal = normalize(s.Normal);
            half NdotL = dot(normal, lightDir);
            half4 color;
            color.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
            color.a = s.Alpha;
            return color;
        }
        

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
        }
        ENDCG
    }
    FallBack "Diffuse"
}