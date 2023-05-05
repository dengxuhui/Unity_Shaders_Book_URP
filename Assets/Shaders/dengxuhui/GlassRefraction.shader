Shader "dengxuhui/GlassRefraction"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map",2D)="bump" {}
        _CubeMap("Environment Cubemap",Cube)="_Skybox" {}
        //模拟折射时图像的扭曲程度，值越大，扭曲越明显
        _Distortion("Distortion",Range(0,200))=0.5
        //0.0表示不折射（只有反射），1.0表示完全折射
        _RefractAmount("Refract Amount",Range(0.0,1.0))=0.5
    }
    SubShader
    {
        //Queue需要使用Transparent
        Tags
        {
            "Queue"="Transparent" "RenderType"="Opaque"
        }

        GrabPass
        {
            "_RefractionTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _CubeMap;
            float _Distortion;
            float _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                //最终颜色=反射颜色 + 折射颜色
                //反射颜色=对Cubemap采样，通过求取reflDir
                //reflDir=法线纹理采样结果对反射值
                //折射颜色=对GrabPass抓取RT采样，通过屏幕坐标采样

                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
                //折射
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;
                //将法线纹理采样从切线空间转换到世界空间下
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                fixed3 reflDir = reflect(-worldViewDir, bump);
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                //反射
                fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb;

                fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;

                return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}