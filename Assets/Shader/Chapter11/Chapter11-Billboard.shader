Shader "Unity Shaders Book/Chapter 11/Billboard" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}  // 广告牌显示的透明纹理
    	_Color ("Color Tint", Color) = (1, 1, 1, 1) // 控制显示整体颜色
    	_VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1 // 调整是固定发现还是固定指向上的方向 即约束垂直方向的程度
    }
    
    SubShader {
	    Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector" = "True" "DisableBatching" = "True"}
		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float _VerticalBillboarding;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			
			

			v2f vert(a2v v)
			{
				v2f o;

				float3 center = float3(0, 0, 0);
				float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
				float3 normalDir = viewer - center;

				normalDir.y = normalDir.y * _VerticalBillboarding;

				normalDir = normalize(normalDir);
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));

				upDir = normalize(cross(normalDir, rightDir));
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

				o.pos = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				return c;
				
			}

			
			
			ENDCG
			
		}
    }
	Fallback "Transparent/VertexLit"
  
}
