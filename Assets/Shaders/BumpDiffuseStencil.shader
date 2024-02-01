Shader "Holistic/BumpDiffuseStencil"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {} // Use bump to indicate that it's a bump map
        _NormalSlider ("Normal Strength", Range(0, 10)) = 1
        _ScaleSlider ("Scale", Range(0.5, 10)) = 1

        _SRef ("Stencil Ref", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _SComp ("Stencil Comp", Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)] _SOp ("Stencil Op", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
        }

        Stencil
        {
            Ref [_SRef]
            Comp [_SComp]
            Pass [_SOp]
        }

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _NormalSlider;
        float _ScaleSlider;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex * _ScaleSlider);
            o.Albedo = c.rgb;
            // o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap), _ScaleSlider);
            o.Normal *= float3(_NormalSlider, _NormalSlider, 1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}