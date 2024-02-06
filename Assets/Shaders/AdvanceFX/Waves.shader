Shader "Holistic/Advanced/Waves"
{
    Properties
    {
        _MainTex ("Diffuse", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _Frequency ("Frequency", Range(0.1, 10)) = 1
        _Amplitude ("Amplitude", Range(0.1, 10)) = 1
        _Speed ("Speed", Range(0.1, 100)) = 10
        _ScrollSpeed ("Scrool Speed", Range(0.1, 10)) = 1
        _ScrollX ("Scrool X", Range(0.1, 1)) = 1
        _ScrollY ("Scrool Y", Range(0.1, 1)) = 1
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        struct Input
        {
            float2 uv_MainTex;
            float3 vertColor;
        };

        float4 _TintColor;
        float _Frequency;
        float _Amplitude;
        float _Speed;
        float _ScrollSpeed;
        float _ScrollX;
        float _ScrollY;
        sampler2D _MainTex;

        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
            float4 texcoord1 : TEXCOORD1;
            float4 texcoord2 : TEXCOORD2;
        };

        void vert(inout appdata v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            const half waveHeight = _Amplitude * sin(_Time.y * _Speed + v.vertex.x * _Frequency);
            const half waveHeight2 = _Amplitude * sin((2*_Time).y * _Speed + v.vertex.z * (2*_Frequency));
            v.vertex.y += waveHeight + waveHeight2;
            v.normal = normalize(float3(v.normal.x + waveHeight, v.normal.y, v.normal.z + waveHeight));
            o.vertColor = waveHeight + 2;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            float2 uv = IN.uv_MainTex + float2(_ScrollX,_ScrollY) * _Time.y * _ScrollSpeed;
            float4 c = tex2D(_MainTex, uv) * _TintColor;
            o.Albedo = c.rgb * IN.vertColor.rgb;
        }
        ENDCG
    }
    Fallback "Deffuse"
}