Shader "Holistic/Volumetric/SphericalFog"
{
    Properties
    {
        _FogCenter("Fog Center", Vector) = (0, 0, 0, 0.5)
        _FogColor("Fog Color", Color) = (0.5, 0.5, 0.5, 1)
        _FogStart("Fog Start", Range(0, 1)) = 0.5
        _FogDensity("Fog Density", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
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

            struct v2f
            {
                float3 view : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 projPos : TEXCOORD1;
            };

            float4 _FogCenter;
            fixed4 _FogColor;
            float _FogStart;
            float _FogDensity;
            sampler2D _CameraDepthTexture;

            v2f vert(appdata_base v)
            {
                v2f o;
                float4 wPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.projPos = ComputeScreenPos(o.pos);
                o.view = wPos.xyz - _WorldSpaceCameraPos;

                float inFrontOf = (o.pos.z/o.pos.w) > 0;
                o.pos.z *= inFrontOf;
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half4 color = half4(1,1,1,1);
                return color;
            }
            ENDCG
        }
    }
}