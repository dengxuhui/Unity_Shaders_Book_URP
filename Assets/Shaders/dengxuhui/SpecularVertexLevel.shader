Shader "dengxuhui/SpecularVertexLevel"
{
    Properties
    {
        //  漫反射
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        //高光
        _Specular("Specular", Color) = (1,1,1,1)
        //高光区域大小
        _Gloss("Gloss",Range(8.0, 256)) = 20
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
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert(a2v v)
            {
                //逐顶点计算漫反射以及高光
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //世界坐标系下的法线
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                //光照方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                //高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                o.color = ambient + diffuse + specular;

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}