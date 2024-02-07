Shader "Holistic/Volumetric/PrimitiveSphere"
{
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2_f
            {
                float3 w_pos : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 light_diff : COLOR0; 
            };

            v2_f vert(const appdata v)
            {
                v2_f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                const half3 world_normal = UnityObjectToWorldNormal(v.normal);
                const half normal_light = max(0, dot(world_normal, _WorldSpaceLightPos0.xyz));
                o.light_diff = normal_light * _LightColor0;
                return o;
            }

            #define STEPS 64 // Number of steps to take along the Ray
            #define STEP_LENGHT 0.01 // Step size to travel along the Ray

            bool sphere_hit(const float3 position, const float3 center, const float radius)
            {
                return length(position - center) < radius;
            }

            float3 ray_march_hit(float3 position, const float3 direction)
            {
                for (int i = 0; i < STEPS; i++)
                {
                    position += direction * STEP_LENGHT;
                    if (sphere_hit(position, float3(0, 0, 0), 0.5))
                    {
                        return position;
                    }
                }

                return 0;
            }

            fixed4 frag(const v2_f i) : SV_Target
            {
                const float3 view_direction = normalize(i.w_pos - _WorldSpaceCameraPos);
                const float3 hit_position = ray_march_hit(i.w_pos, view_direction);
                // const float distance = saturate(length(hit_position - i.w_pos));
                const float distance = saturate(length(hit_position));
                if (distance != 0)
                {
                    // return fixed4(distance, 0, 0, 1);
                    fixed4 light_color = i.light_diff;
                    light_color.a = 1;
                    return  fixed4(hit_position.r, hit_position.g, hit_position.b, distance) * light_color;
                }

                return fixed4(0, 0, 0, 0);
            }
            ENDCG
        }
    }
}