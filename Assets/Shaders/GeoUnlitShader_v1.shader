Shader "Unlit/GeoUnlitShader_v1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _PositionFactor("Position Factor", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom //ジオメトリシェーダーの関数がどれかGPUに教える
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

             //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                //float2 uv : TEXCOORD0;
            };

            
            struct g2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            fixed4 _Color;
            float _PositionFactor;

            appdata vert (appdata v)
            {
                return v;
            }

            //ジオメトリシェーダー
            //引数のinputは文字通り頂点シェーダーからの入力
            //streamは参照渡しで次の処理に値を受け渡ししている　TriangleStream<>で三角面を出力する
            [maxvertexcount(3)] //出力する頂点の最大数　正直よくわからない
            void geom(triangle appdata input[3], inout TriangleStream<g2f> stream)
            {
                // 法線を計算 
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                //1枚のポリゴンの中心 
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                
		        //ランダムな値 
                float r = rand(center.xy);
                float g = rand(center.xz);
                float b = rand(center.yz);

                [unroll] //繰り返す処理を畳み込んで最適化してる？
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    //法線ベクトルに沿って頂点を移動 
                    v.vertex.xyz += normal * (sin(_Time.w) + 0.5)*_PositionFactor;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.color = fixed4(r,g,b,1);
                    stream.Append(o);
                }
                stream.RestartStrip();
            }

            fixed4 frag(g2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
