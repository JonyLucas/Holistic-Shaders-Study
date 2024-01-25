Shader "Holistic/UsePropertiesShader"
{
    Properties
    {
        _MyColor ("Example Color", Color) = (1,1,1,1)
        _MyRange("Example Range", Range(0,5)) = 1
        _MyTex ("Example Texture", 2D) = "white" {}
        _MyCube ("Example Cube", Cube) = "" {}
        _MyFloat ("Example Float", Float) = 1.0
        _MyVector ("Example Vector", Vector) = (1,1,1,1)
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        fixed4 _MyColor;
        float _MyRange;
        sampler2D _MyTex;
        samplerCUBE _MyCube;
        float _MyFloat;
        float4 _MyVector;
        
        struct Input
        {
            float2 uv_MyTex;
            float3 worldRefl; // reflection vector
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MyTex, IN.uv_MyTex) * _MyRange; // Converts sampler2D to a vector representation, using uv_MyTex as the coordinates
            o.Albedo = c.rgb + _MyColor.rgb; // Adds the color property to the texture
            o.Emission = texCUBE(_MyCube, IN.worldRefl).rgb; // Converts samplerCUBE to a vector representation, using worldRefl as the coordinates
        }
        ENDCG
    }
    FallBack "Diffuse"
}
