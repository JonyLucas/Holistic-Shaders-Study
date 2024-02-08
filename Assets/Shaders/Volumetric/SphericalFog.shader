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

            struct fog_data
            {
                float3 center;
                float radius;
                float start;
                float density;
                float3 cameraPos;
                float3 viewDir;
                float maxDistance;
            };

            float CalculateFogDensity(fog_data data)
            {
                // Calculate ray-sphere intersection
                float3 p = data.cameraPos - data.center;
                float a = dot(data.viewDir, data.viewDir); // a = camera^2
                float b = 2 * dot(data.viewDir, p); // b = 2 * camera * view
                float c = dot(p, p) - data.radius * data.radius; // c = camera^2 - radius^2
                float d = b * b - 4 * a * c; // d = b^2 - 4ac

                if(d < 0)
                {
                    return 0;
                }

                float dsquare = sqrt(d);
                float dist1 = (-b + dsquare) / (2 * a);
                float dist2 = (-b - dsquare) / (2 * a);

                float farDist = min(data.maxDistance, dist2);
                float sample = dist1;
                float stepSize = (farDist - dist1) / 10;
                float stepContribution = data.density;

                float centerValue = 1/(1 - data.start);
                float clarity = 1;

                for(int i = 0; i < 10; i++)
                {
                    float3 samplePos = data.cameraPos + data.viewDir * sample;
                    float3 sampleDir = samplePos - data.center;
                    float sampleDist = length(sampleDir);
                    float sampleDensity = data.density * (1 - sampleDist / data.radius);
                    // float sampleValue = exp(-sampleDensity * stepSize * stepContribution); // float fog_amount = saturate(sampleDensity * stepContribution);
                    // clarity *= sampleValue; // clarity *= 1 - fog_amount;
                    float fog_amount = saturate(sampleDensity * stepContribution);
                    clarity *= 1 - fog_amount;
                    sample += stepSize;
                }

                return 1 - clarity;                
            }

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
                float4 texProj = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos));
                float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(texProj));
                float3 viewDir = normalize(i.view);

                fog_data data;
                data.center = _FogCenter;
                data.radius = 1;
                data.start = _FogStart;
                data.density = _FogDensity;
                data.cameraPos = _WorldSpaceCameraPos;
                data.viewDir = viewDir;
                data.maxDistance = 1000;

                float fog = CalculateFogDensity(data);
                color.rgb = _FogColor.rgb;
                color.a = fog;
                return color;
            }
            ENDCG
        }
    }
}