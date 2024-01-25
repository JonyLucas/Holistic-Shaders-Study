Shader "Holistic/PropertiesChallenge4"
{
    Properties
    {
        _DiffuseTex ("Albedo (RGB)", 2D) = "white" {}
        _EmissionTex ("Emission", 2D) = "white" {}
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _DiffuseTex;
        sampler2D _EmissionTex;

        struct Input
        {
            float2 uv_DiffuseTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 color = tex2D (_DiffuseTex, IN.uv_DiffuseTex);
            o.Albedo = color.rgb;
            o.Emission = tex2D (_EmissionTex, IN.uv_DiffuseTex).rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
