Shader "dengxuhui/DiffusePixelLevle"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXTCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                //转换模型空间到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);
                //将法向量转换到世界坐标中,归一化的法向量
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 world_light_dir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, world_light_dir));
                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }
            ENDCG
        }

    }
    FallBack "Diffuse"
}