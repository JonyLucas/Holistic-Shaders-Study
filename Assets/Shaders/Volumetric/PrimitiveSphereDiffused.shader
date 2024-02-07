Shader "Holistic/Volumetric/PrimitiveSphereDiffused"
{
    Properties
    {
        sphere_center ("Sphere Center", Vector) = (0, 0, 0)
    }
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
            };

            struct v2_f
            {
                float3 w_pos : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2_f vert(const appdata v)
            {
                v2_f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            #define STEPS 64 // Number of steps to take along the Ray
            #define STEP_LENGHT 0.01 // Step size to travel along the Ray
            float3 sphere_center;

            bool sphere_hit(const float3 position, const float3 center, const float radius)
            {
                return length(position - center) < radius;
            }

            float3 ray_march_hit(float3 position, const float3 direction, const float3 center)
            {
                for (int i = 0; i < STEPS; i++)
                {
                    position += direction * STEP_LENGHT;
                    if (sphere_hit(position, center, 0.5))
                    {
                        return position;
                    }
                }

                return 0;
            }

            fixed4 frag(const v2_f i) : SV_Target
            {
                const float3 view_direction = normalize(i.w_pos - _WorldSpaceCameraPos);
                const float3 hit_position = ray_march_hit(i.w_pos, view_direction, sphere_center);
                // const float distance = saturate(length(hit_position - i.w_pos));
                const float distance = saturate(length(hit_position));
                if (distance != 0)
                {
                    const half3 normal = normalize(hit_position - sphere_center);//normalize(hit_position - float3(_SphereCenter.x, _SphereCenter.y, _SphereCenter.z));
                    const half light_normal = saturate(max(0, dot(normal, _WorldSpaceLightPos0.xyz)));
                    half4 light_color = _LightColor0 * light_normal * 2;
                    light_color.a = 1;
                    
                    half4 color = half4(normal.r, normal.g, normal.b, distance);
                    color *= light_color;
                    return  color;
                }

                return fixed4(0, 0, 0, 0);
            }
            ENDCG
        }
    }
}