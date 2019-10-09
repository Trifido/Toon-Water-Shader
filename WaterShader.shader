Shader "Unlit/WaterShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (1,1,1,1)
		_EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
		_DepthFactor("Depth Factor", float) = 1.0
		_DepthRampTex("Depth Ramp", 2D) = "white" {}
		_Alpha("Transparent", float) = 0.5
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_WaveSpeed("Wave Speed", float) = 1.0
		_WaveAmp("Wave Amp", float) = 0.2

	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
			LOD 100
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag 

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
					float4 screenPos : TEXCOORD1;
				};

				sampler2D _MainTex;
				sampler2D _CameraDepthTexture;
				sampler2D _DepthRampTex;
				float4 _MainTex_ST;
				float4 _BaseColor;
				float4 _EdgeColor;
				float _DepthFactor;
				float _Alpha;

				float _WaveSpeed;
				float _WaveAmp;
				sampler2D _NoiseTex;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);

					//Wave Animation
					float noiseSample = tex2Dlod(_NoiseTex, float4(o.uv, 0, 0));
					o.vertex.y += sin(_Time * _WaveSpeed * noiseSample) * _WaveAmp;
					o.vertex.x += cos(_Time * _WaveSpeed * noiseSample) * _WaveAmp;
					
					o.screenPos = ComputeScreenPos(o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.screenPos);
					float depth = LinearEyeDepth(depthSample).r;

					float foamLine = 1 - saturate(_DepthFactor * (depth - i.screenPos.w));
					float4 foamRamp = float4(tex2D(_DepthRampTex, float2(foamLine, 0.5)).rgb, _Alpha);

					float4 col = _BaseColor * foamRamp;// *_EdgeColor;

					return col;

					//fixed4 col = tex2D(_MainTex, i.uv) * _BaseColor;
					//return col;
				}
			ENDCG
        }
    }
}
