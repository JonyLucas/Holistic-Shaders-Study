Shader "Holistic/ToonRamp"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RampTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf ToonRamp

        fixed4 _Color;
        sampler2D _RampTex;
        
        float4 LightingToonRamp (SurfaceOutput s, float3 lightDir, float atten) {
            float diffuse = dot (s.Normal, lightDir);
            float h = diffuse * 0.5 + 0.5; // Defines a value, if the dot product is 0, the value would be 0.5
            float2 rh = h; // Defines the uv coordinate
            float3 ramp = tex2D (_RampTex, rh).rgb;

            float4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * ramp;
            c.a = s.Alpha;
            return c;
        }

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