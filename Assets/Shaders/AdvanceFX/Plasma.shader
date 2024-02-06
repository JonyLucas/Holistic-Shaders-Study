Shader "Holistic/Advanced/Plasma"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Speed ("Speed", Range(0, 100)) = 10
        _Scale1 ("Scale1", Range(0, 10)) = 2
        _Scale2 ("Scale2", Range(0, 10)) = 2
        _Scale3 ("Scale3", Range(0, 10)) = 2
        _Scale4 ("Scale4", Range(0, 10)) = 2
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        fixed4 _Color;
        float _Speed;
        float _Scale1;
        float _Scale2;
        float _Scale3;
        float _Scale4;

        void surf(Input IN, inout SurfaceOutput o)
        {
            const float PI = 3.14159265359;
            float speed = _Speed * _Time.x;

            // Vertical Movement
            float c = sin(IN.worldPos.x * _Scale1 + speed);

            // Horizontal Movement
            c += sin(IN.worldPos.y * _Scale2 + speed);

            // Diagonal Movement
            c += sin(_Scale3 * (IN.worldPos.x + sin(speed/2) + IN.worldPos.y + cos(speed/3)) + speed);

            //Circular Movement
            float c1 = pow(IN.worldPos.x + 0.5 * sin(speed/5), 2);
            float c2 = pow(IN.worldPos.y + 0.5 * sin(speed/3), 2);
            c += sin(sqrt((c1 + c2)* _Scale4 + 1 + speed));
            
            o.Albedo.r = sin(c/4.0 * PI);
            o.Albedo.g = sin(c/4.0 * PI + 2.0 * PI/3.0);
            o.Albedo.b = sin(c/4.0 * PI + 4.0 * PI/3.0);
            o.Albedo *= _Color;
        }
        ENDCG
    }
    FallBack "Diffuse"
}