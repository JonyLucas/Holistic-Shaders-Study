Shader "Holistic/Advanced/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _ScaleUV ("Scale UV", Range(0, 20)) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent" // You should use transparent so it would be drawn after the other objects
        }
        
        GrabPass{}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 uvgrab : TEXCOORD1;
                float2 uvbump : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize; // Texel Size means 1 pixel size in UV space
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _ScaleUV;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvgrab.xy = (float2(o.vertex.x, -o.vertex.y) + o.vertex.w) * 0.5; // Make sure the UV is in the range of 0-1
                o.uvgrab.zw = o.vertex.zw; //o.uvgrab.xy + _GrabTexture_TexelSize.xy;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvbump = TRANSFORM_TEX(v.uv, _BumpMap);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half2 bump = UnpackNormal(tex2D(_BumpMap, i.uvbump)).rg;
                float2 offset = bump * _ScaleUV + _GrabTexture_TexelSize.xy;
                i.uvgrab.xy += offset * i.uvgrab.z;
                fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
                fixed4 tint = tex2D(_MainTex, i.uv);
                col *= tint;
                return col;
            }
            ENDCG
        }
    }
}