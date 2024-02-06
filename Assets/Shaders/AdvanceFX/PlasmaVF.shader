Shader "Holistic/Advanced/PlasmaVF"
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
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float4 worldPos : TEXCOORD0;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            float _Speed;
            float _Scale1;
            float _Scale2;
            float _Scale3;
            float _Scale4;

            v2f vert(appdata v)
            {
                const float PI = 3.14159265359;
                float speed = _Speed * _Time.x;

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                // Vertical Movement
                float c = sin(o.worldPos.x * _Scale1 + speed);

                // Horizontal Movement
                c += sin(o.worldPos.y * _Scale2 + speed);

                // Diagonal Movement
                c += sin(_Scale3 * (o.worldPos.x + sin(speed / 2) + o.worldPos.y + cos(speed / 3)) + speed);

                //Circular Movement
                float c1 = pow(o.worldPos.x + 0.5 * sin(speed / 5), 2);
                float c2 = pow(o.worldPos.y + 0.5 * sin(speed / 3), 2);
                c += sin(sqrt((c1 + c2) * _Scale4 + 1 + speed));

                o.color.r = sin(c / 4.0 * PI);
                o.color.g = sin(c / 4.0 * PI + 2.0 * PI / 3.0);
                o.color.b = sin(c / 4.0 * PI + 4.0 * PI / 3.0);
                // o.color = v.color;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}