Shader "dengxuhui/DiffuseHalfLambertLevel"
{
    Properties
    {
        //材质表面漫反射系数
        _Diffuse("Diffuse", Color) = (1,1,1,1)
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
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //归一化的法线
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed halfLambert = dot(i.worldNormal, worldLightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb * halfLambert;

                fixed3 color = ambient + diffuse;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}