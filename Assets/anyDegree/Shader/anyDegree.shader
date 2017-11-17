Shader "Headjack/anyDegree" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "black" {}
		_H("Horizontal Degrees",float)=360
		_V("Vertical Degrees",float)=180
	}
	SubShader { 
		//Background queue and zwrite(off) combined will always render this in the background
		Tags {"Queue"="Background" }
		cull off
		ZWrite off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 pos : TEXCOORD0;
				float2 uvScale : TEXCOORD1;
			};

			//The horizontal and vertical degrees will be stored in these uints
			uint _H,_V;

			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(vertex);

				 //The pixel shader needs to know the local vertex positions
				 //These are saved in o.pos
				o.pos=  vertex.xyz;

				//Divide the full panorama angles (360x180) by the custom angles
				o.uvScale=float2(360.0/_H,180.0/_V);
				return o;
			}
			//This function transforms a XYZ position/direction to an equirectangular coordinate
			float2 PositionToUV(float3 p)
			{
				return float2(atan2(p.x,p.z)*0.15915495087 ,asin(p.y)*0.3183099524);
			}

			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target{
				//Calculate the uv coordinate on the texture for this pixel
				float2 uv=i.uvScale*(PositionToUV(normalize(i.pos)))+.5;

				//Check if the coordinates are between 0 and 1, multiply the result
				return tex2D(_MainTex,uv)*all(ceil(uv)==1);
			}
			ENDCG
		}
	}
}