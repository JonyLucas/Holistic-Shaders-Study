Shader "Holistic/LightingChallenge4"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf CustomBlinnLight

        half4 LightingCustomBlinnLight(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half3 halfWayVector = normalize(lightDir + viewDir);
            half diff = max(0, dot(s.Normal, lightDir));
            half spec = pow(max(0, dot(s.Normal, halfWayVector)), 128);

            half4 color;
            color.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten * _SinTime;
            color.a = s.Alpha;            
            return color;
        }

        float4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}