Shader "Holistic/Advanced/Outline"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _OutlineColor ("Color", Color) = (1,1,1,1)
        _OutlineWidth ("Outline width", Range(0.0, 0.1)) = 0.01
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

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
        }
        ENDCG

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
            };

            float _OutlineWidth;
            float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); // Transform normal to view space
                const float2 offset = TransformViewToProjection(norm.xy); // Transform normal to screen space
                o.pos.xy += offset * _OutlineWidth; // Apply outline width
                o.color = _OutlineColor;
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