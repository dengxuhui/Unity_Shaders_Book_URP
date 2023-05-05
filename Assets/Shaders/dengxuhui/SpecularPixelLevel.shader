Shader "dengxuhui/SpecularPixelLevel"
{
    Properties
    {
        //漫反射系数
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        //高光系数
        _Specular("Specular",Color) = (1,1,1,1)
        //高光强度
        _Gloss("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
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
                float3 worldNormal: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //高光
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                fixed3 specular = _LightColor0.rgb * _SpecColor.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
                //漫反射

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                return fixed4(diffuse + specular + ambient, 1.0);
            }
            ENDCG
        }

    }

    FallBack
    "Specular"
}