Shader "Holistic/PropertiesChallenge3"
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
            fixed4 green = fixed4(0, 1, 0, 1);
            fixed4 color = tex2D (_MainTex, IN.uv_MainTex) * green;
            o.Albedo = color.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
