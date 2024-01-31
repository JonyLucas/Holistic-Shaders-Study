Shader "Holistic/Hologram"
{
    Properties
    {
        _RimColor ("Color", Color) = (0,0.5,0.5,0)
        _RimPower ("Power", Range(0.5, 8)) = 3
        _RimThreshold ("Threshold", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }
        
        pass
        {
            ZWrite On
            ColorMask 0
        }

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade

        float4 _RimColor;
        float _RimPower;
        float _RimThreshold;

        struct Input
        {
            float3 viewDir;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal)); // Saturate gives the values between 1 and 0
            rim = pow(rim, _RimPower);
            rim = rim > _RimThreshold ? rim : 0;
            o.Emission = _RimColor.rgb * rim;
            o.Alpha = rim;
        }
        ENDCG
    }
    FallBack "Diffuse"
}