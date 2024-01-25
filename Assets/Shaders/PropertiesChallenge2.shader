Shader "Holistic/PropertiesChallenge2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 color = tex2D (_MainTex, IN.uv_MainTex);
            color.g = 1;
            o.Albedo = color.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
