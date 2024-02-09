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

            float random(float3 value, float3 seed)
            {
                return frac(sin(dot(value, seed)) * 43758.5453);
            }

            float3 random3d(float3 value, float3 seed)
            {
                float3 result = float3(0, 0, 0);
                result.x = random(value, seed);
                result.y = random(value, result);
                result.z = random(value, result);
                return result;
            }

            float noise3d(float3 value)
            {
                value *= _Scale;
                float3 interp = frac(value);
                interp = smoothstep(0.0, 1.0, interp);

                float3 zValues[2];
                for (int z = 0; z < 2; z++)
                {
                    float3 yValues[2];
                    for (int y = 0; y < 2; y++)
                    {
                        float3 xValues[2];
                        for (int x = 0; x < 2; x++)
                        {
                            xValues[x] = random3d(value, float3(x, y, z));
                        }
                        yValues[y] = lerp(xValues[0], xValues[1], interp.x);
                    }
                    zValues[z] = lerp(yValues[0], yValues[1], interp.y);
                }

                float noise = -1.0 + 2.0 * lerp(zValues[0], zValues[1], interp.z);
                return noise;
            }

            #define MARCH(steps, noiseMap, rayDir, cameraPos, depth, color, sum, t) {\
                for(int i = 0; i < steps; i++) \
                { \
                    if(t > depth) \
                    { \
                        break; \
                    } \
                    float3 p = cameraPos + t * rayDir; \
                    if(p.y > _MaxHeight || p.y < _MinHeight || sum.a > 0.99) \
                    { \
                        t += max(0.1, 0.02 * t); \
                        continue; \
                    } \
                    float density = noiseMap(p); \
                    if(density > 0.01) \
                    { \
                        float diffuse = clamp((density - noiseMap(p + _SunDirection * 0.3)) / 0.6, 0, 1); \
                        sum = diffuse; \
                    } \
                    t += max(0.1, 0.02 * t); \
                } \
            }


            fixed4 raymarch(float3 cameraPos, float3 rayDir, fixed4 color, float depth)
            {
                fixed4 col = fixed4(0, 0, 0, 0);
                float ct = 0;
                MARCH(_Steps, noise3d, rayDir, cameraPos, depth, color, col, ct);
                return clamp(col, 0, 1);
            }

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
                float depth = 1;
                depth *= length(i.view);
                fixed4 color = fixed4(0, 0, 0, 0);
                fixed4 clouds = raymarch(_WorldSpaceCameraPos, normalize(i.view) * _Scale, color, depth);
                fixed3 mixedColors = color * (1 - clouds.a) + clouds.rgb;
                return fixed4(mixedColors, clouds.a);
            }
            ENDCG
        }
    }
}