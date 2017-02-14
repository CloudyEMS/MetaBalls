using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class MetaBalls : MonoBehaviour {

	public Material CurrentMaterial {
		get { 
			return mat;
		}
		set {
			if(value == mat)
				return;
			mat = pSystem.GetComponent<ParticleSystemRenderer>().sharedMaterial = value;
		}
	}

	private Material mat;
	private ParticleSystem pSystem;
	private ParticleSystem.Particle[] particles;
	private List<Vector4> particlesPos;
	private float speed = 0.0f;
	
	// Use this for initialization
	void Awake () {
		pSystem = GetComponent<ParticleSystem>();
		particles = new ParticleSystem.Particle[pSystem.main.maxParticles];
		particlesPos = new List<Vector4>(10);
		mat = pSystem.GetComponent<ParticleSystemRenderer>().sharedMaterial;
		speed = pSystem.main.startSpeedMultiplier;
	}
	
	// Update is called once per frame
	void Update () {
		// Clear the position of particles.
		particlesPos.Clear();

		// Get a list of the current alive particles in this frame.
		int aliveParticles = pSystem.GetParticles(particles);

		// Get the position of all alive particles in this frame.
		for(int i = 0; i < aliveParticles; i++){
			particlesPos.Add(particles[i].position);
		}

		// Update the position array in the shader.
		mat.SetVectorArray("_ParticlesPos", particlesPos);

	}

	public bool TogglePlay(){
		if(pSystem.isPlaying)
			pSystem.Pause();
		else
			pSystem.Play();
		
		return pSystem.isPlaying;
	}

	public void TogglePlay(bool b){
		if(b)
			pSystem.Play();
		else
			pSystem.Pause();
	}

	public bool ToggleNoise(){
		ParticleSystem.NoiseModule n = pSystem.noise;
		if(n.enabled)
			n.enabled = false;
		else
			n.enabled = true;
		return n.enabled;
	}

	public void ToggleNoise(bool b){
		ParticleSystem.NoiseModule n = pSystem.noise;
		n.enabled = b;
	}

	public void ChangeSpeed(float newSpeed){
		ParticleSystem.MainModule pmain = pSystem.main;
		pmain.startSpeedMultiplier = speed * newSpeed;
	}

}
