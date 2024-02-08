Shader "Holistic/Volumetric/RaymarchCloudVolume"
{
    Properties
    {
        _Scale ("Scale", Range(0.1, 10.0)) = 2
        _StepScale ("Step Scale", Range(0.1, 100.0)) = 1
        _Steps ("Steps", Range(1, 100)) = 50
        _MinHeight ("Min Height", Range(0.0, 5.0)) = 0.0
        _MaxHeight ("Max Height", Range(5.0, 10.0)) = 10
        _FadeDistance ("Fade Distance", Range(0.0, 10.0)) = 1
        _SunDirection ("Sun Direction", Vector) = (1, 0, 0, 0)
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest Always

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
                float4 pos : SV_POSITION;
                float3 view : TEXCOORD0;
                float4 projPos : TEXCOORD1;
                float wPos : TEXCOORD2;
            };

            float _Scale;
            float _StepScale;
            float _Steps;
            float _MinHeight;
            float _MaxHeight;
            float _FadeDistance;
            float3 _SunDirection;

            sampler2D _CameraDepthTexture;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.view = normalize(UnityWorldSpaceViewDir(o.wPos));
                o.projPos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(1,1,1,1);
            }
            ENDCG
        }
    }
}