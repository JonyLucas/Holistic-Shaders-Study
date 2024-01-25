Shader "Holistic/DotProduct"
{
    Properties
    {
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float3 viewDir;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half dotp = dot(IN.viewDir, o.Normal);
            o.Albedo = float3(dotp, dotp, dotp);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
