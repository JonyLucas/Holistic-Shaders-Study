Shader "Holistic/StencilWall"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _SRef ("Stencil Reference", Float) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _SComp ("Stencil Comparison", Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)] _SOp ("Stencil Operation", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry-1"
        }

        ZWrite Off
        ColorMask 0

        Stencil
        {
            Ref [_SRef]
            Comp [_SComp]
            Pass [_SOp]
        }

        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}