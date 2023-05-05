Shader "dengxuhui/NormalMapTangentSpace"
{
    Properties
    {
        //颜色调节
        _Color("Color", Color) = (1,1,1,1)
        //纹理贴图
        _MainTex("MainTex", 2D) = "white" {}
        //法线贴图
        _BumpMap("BumpMap", 2D) = "bump" {}
        //法线强度
        _BumpScale("BumpScale", Float) = 1.0
        //高光
        _SpecularColor("SpecColor", Color) = (1,1,1,1)
        //高光强度
        _Gloss("Gloss", Range(8,255)) = 8
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
            #include  "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _SpecularColor;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                //世界空间到切线空间到变换矩阵
                float3x3 worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);
                o.lightDir = mul(worldToTangent, WorldSpaceLightDir(v.vertex));
                o.viewDir = mul(worldToTangent, WorldSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                //纹理采样
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                // fixed3 tangentNormal = packedNormal.xyz * 2 - 1;
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                //自发光
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(
                    saturate(dot(tangentNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }

    FallBack "Specular"
}