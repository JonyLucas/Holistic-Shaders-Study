Shader "Holistic/BumpedEnvironment"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Cube ("Cubemap", Cube) = "" {}
        _BumpSlider ("Bumpiness", Range(0,10)) = 1
        _Brightness ("Brightness", Range(0,10)) = 1
    }
    SubShader
    {
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        sampler2D _MainTex;
        sampler2D _BumpMap;
        samplerCUBE _Cube;
        half _BumpSlider;
        half _Brightness;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 worldRefl; INTERNAL_DATA
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;

            o.Normal = UnpackNormal(tex2D (_BumpMap, IN.uv_BumpMap)) * _Brightness;
            o.Normal *= float3(_BumpSlider, _BumpSlider, 1);
            o.Emission = texCUBE (_Cube, WorldReflectionVector(IN, o.Normal)).rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
