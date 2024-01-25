Shader "Holistic/BumpedEnvironmentChallenge"
{
    Properties
    {
        _NormalMap ("Normal Map", 2D) = "white" {}
        _CubeMap ("Cube Map", Cube) = "" {}
    }
    SubShader
    {
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        sampler2D _NormalMap;
        samplerCUBE _CubeMap;

        struct Input
        {
            float2 uv_NormalMap;
            float3 worldRefl; INTERNAL_DATA
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Normal = UnpackNormal(tex2D (_NormalMap, IN.uv_NormalMap));
            o.Albedo = texCUBE(_CubeMap, WorldReflectionVector(IN, o.Normal)).rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
