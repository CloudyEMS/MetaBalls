using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MenuManger : MonoBehaviour {

	public CameraBehaviour camRig;
	public GameObject fallingParticle, sphereParticle;
	public Material[] mats;

	private MetaBalls currentMetaBallScript;
	private bool isNoiseEnabled = false, isPlaying = true;
	private float currentSpeed = 1.0f;
	// Use this for initialization
	void Start () {
		if(fallingParticle == null || sphereParticle == null){
			Debug.LogError("Make sure there is a reference to the particle systems in the scene.");
			return;
		}
		// Only one should be active, spherical is by default.
		fallingParticle.SetActive(false);
		sphereParticle.SetActive(true);
		currentMetaBallScript = sphereParticle.GetComponent<MetaBalls>();
	}
	
	// Update is called once per frame
	void Update () {
		// Particle System.
		if(Input.GetKeyDown(KeyCode.Q)){
			fallingParticle.SetActive(false);
			sphereParticle.SetActive(true);
			InitParticleSystem(sphereParticle);
		}
		if(Input.GetKeyDown(KeyCode.W)){
			fallingParticle.SetActive(true);
			sphereParticle.SetActive(false);
			InitParticleSystem(fallingParticle);
		}


		// Material.
		if(Input.GetKeyDown(KeyCode.Alpha1)){
			currentMetaBallScript.CurrentMaterial = mats[0];
		}
		if(Input.GetKeyDown(KeyCode.Alpha2)){
			currentMetaBallScript.CurrentMaterial = mats[1];
		}
		if(Input.GetKeyDown(KeyCode.Alpha3)){
			currentMetaBallScript.CurrentMaterial = mats[2];
		}

		// Particle speed/movement.
		if(Input.GetKeyDown(KeyCode.A)){
			if(currentSpeed == 1.0f){
				currentSpeed = 2.0f;
			} else if (currentSpeed == 2.0f){
				currentSpeed = 0.5f;
			} else {
				currentSpeed = 1.0f;
			}
			currentMetaBallScript.ChangeSpeed(currentSpeed);
		}
		if(Input.GetKeyDown(KeyCode.S)){
			isPlaying = currentMetaBallScript.TogglePlay();
		}
		if(Input.GetKeyDown(KeyCode.D)){
			isNoiseEnabled = currentMetaBallScript.ToggleNoise();
		}

		// Camera background.
		if(Input.GetKeyDown(KeyCode.Z)){
			Camera.main.clearFlags = CameraClearFlags.Color;
			Camera.main.backgroundColor = Color.white;
		}
		if(Input.GetKeyDown(KeyCode.X)){
			Camera.main.clearFlags = CameraClearFlags.Color;
			Camera.main.backgroundColor = Color.black;
		}
		if(Input.GetKeyDown(KeyCode.C)){
			Camera.main.clearFlags = CameraClearFlags.Skybox;
		}
		if(Input.GetKeyDown(KeyCode.V)){
			camRig.shouldRotate = !camRig.shouldRotate;
//			Camera.main.clearFlags = CameraClearFlags.Skybox;
		}
	}

	private void InitParticleSystem(GameObject ps){
		Material m = currentMetaBallScript.CurrentMaterial;
		currentMetaBallScript = ps.GetComponent<MetaBalls>();
		currentMetaBallScript.CurrentMaterial = m;
		currentMetaBallScript.ChangeSpeed(currentSpeed);
		currentMetaBallScript.TogglePlay(isNoiseEnabled);
		currentMetaBallScript.TogglePlay(isPlaying);
	}
}
