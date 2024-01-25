Shader "Holistic/WorldPosColoring"
{
    Properties
    {
        _YValue("Y Value", Float) = 1
        _UpperColor("Color", Color) = (1,1,1,1)
        _LowerColor ("Lower Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        float _YValue;
        float4 _UpperColor;
        float4 _LowerColor;

        struct Input
        {
            float3 worldPos;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = IN.worldPos.y > _YValue ? _UpperColor.rgb : _LowerColor.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}