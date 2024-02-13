// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'

// Upgrade NOTE: commented out 'float4x4 _CameraToWorld', a built-in variable

// Upgrade NOTE: commented out 'float4x4 _CameraToWorld', a built-in variable

// Upgrade NOTE: commented out 'float4x4 _CameraToWorld', a built-in variable

Shader "Holistic/RaymarchCloudsCamera"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off
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
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 view : TEXCOORD1;
            };

            float _MinHeight;
            float _MaxHeight;
            float _FadeDist;
            float _Scale;
            float _StepScale;
            float _Steps;
            float4 _LightDir;
            float3 _MoveDirection;
            
            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _NoiseTex;

            float4x4 _FrustumCornersWS;
            float4x4 _CameraToWorldMatrix;
            float4 _CloudParams;

            fixed4 integrate(fixed4 sum, float diffuse, float density, fixed4 bgcol, float t)
            {
                fixed3 lighting = fixed3(0.65, 0.68, 0.7) * 1.3 + 0.5 * fixed3(0.7, 0.5, 0.3) * diffuse;
                fixed3 colrgb = lerp(fixed3(1.0, 0.95, 0.8), fixed3(0.65, 0.65, 0.65), density);
                fixed4 col = fixed4(colrgb.r, colrgb.g, colrgb.b, density);
                col.rgb *= lighting;
                col.rgb = lerp(col.rgb, bgcol, 1.0 - exp(-0.003 * t * t));
                col.a *= 0.5;
                col.rgb *= col.a;
                return sum + col * (1.0 - sum.a);
            }

            #define MARCH(steps, noiseMap, cameraPos, viewDir, bgcol, sum, depth, t) { \
                for (int i = 0; i < steps  + 1; i++) \
                { \
                    if(t > depth) \
                        break; \
                    float3 pos = cameraPos + t * viewDir; \
                    if (pos.y < _MinHeight || pos.y > _MaxHeight || sum.a > 0.99) \
                    {\
                        t += max(0.1, 0.02*t); \
                        continue; \
                    }\
                    \
                    float density = noiseMap(pos); \
                    if (density > 0.01) \
                    { \
                        float diffuse = clamp((density - noiseMap(pos + 0.3 * _LightDir)) / 0.6, 0.0, 1.0);\
                        sum = integrate(sum, diffuse, density, bgcol, t); \
                    } \
                    t += max(0.1, 0.02 * t); \
                } \
            }


            #define NOISEPROC(N, P) 1.75 * N * saturate((_MaxHeight - P.y)/_FadeDist)

            float noise3d(float3 x)
            {
                x *= _Scale;
                float3 p = floor(x);
                float3 f = frac(x);
                f = smoothstep(0,1,f);

                float2 uv = (p.xy + float2(37.0, -17.0) * p.z) + f.xy;
                float2 rg = tex2Dlod(_NoiseTex, float4(uv/256.0, 0.0, 0.0)).rg;
                return -1.0 + 2.0 * lerp(rg.g, rg.r, f.z);
            }

            float map1(float3 q)
            {
                float3 p = q;
                float f;
                f = 0.5 * noise3d(q);
                q *= 2.0;
                f += 0.25 * noise3d(q);
                q *= 3.5;
                f += 0.125 * noise3d(q);
                return NOISEPROC(f, p);
            }

            float map2(float3 q)
            {
                float3 p = q;
                float f;
                f = 0.8 * noise3d(q);
                q *= 1.5;
                f += 0.4 * noise3d(q);
                q *= 3.5;
                f += 0.2 * noise3d(q);
                return NOISEPROC(f, p);
            }

            float map3(float3 q)
            {
                float3 p = q;
                float f;
                f = 1.2 * noise3d(q);
                q *= 2;
                f += 0.65 * noise3d(q);
                q *= 4;
                f += 0.15 * noise3d(q);
                return NOISEPROC(f, p);
            }

            fixed4 raymarch(float3 cameraPos, float3 viewDir, fixed4 bgcol, float depth)
            {
                fixed4 col = fixed4(0, 0, 0, 0);
                float ct = 0;

                MARCH(_Steps, map1, cameraPos, viewDir, bgcol, col, depth, ct);
                MARCH(_Steps, map2, cameraPos, viewDir, bgcol, col, depth * 2, ct);
                MARCH(_Steps, map3, cameraPos, viewDir, bgcol, col, depth * 3, ct);

                return clamp(col, 0.0, 1.0);
            }

            v2f vert(appdata_img v)
            {
                v2f o;
                half index = v.vertex.z;
                v.vertex.z = 0.1;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                    o.uv.y = 1 - o.uv.y;

                #endif

                o.view = _FrustumCornersWS[(int) index];
                o.view /= abs(o.view.z);
                o.view = mul(_CameraToWorldMatrix, o.view);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 start = _WorldSpaceCameraPos;
                float2 uv = i.uv;

                #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                    uv.y = 1 - uv.y;
                #endif

                float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, uv).r);
                depth *= length(normalize(i.view));

                fixed4 color = tex2D(_MainTex, i.uv);
                fixed4 sum = raymarch(start, normalize(i.view), color, depth);
                return fixed4(color * (1.0 - sum.a) + sum.rgb, 1.0);                
            }
            ENDCG
        }
    }
}