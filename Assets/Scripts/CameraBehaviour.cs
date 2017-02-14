using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraBehaviour : MonoBehaviour {

	public float rotationSpeed = 5f;
	public float minDistance = -2f, maxDistance = -10f;
	[Range(0,1)]public float zoomSensitivity = 0.2f;
	public bool shouldRotate = true;

	private Transform cam;
	private bool autoRotate = true;
	private float currentDistance = 1f;
	private int autoRotateDir = 1;

	void Start(){
		cam = Camera.main.transform;
	}

	// Update is called once per frame
	void Update () {
		float h = Input.GetAxis("Mouse X");

		if(Input.GetMouseButtonDown(1)){
			autoRotate = false;
		}

		if (Input.GetMouseButton(1)){
			transform.Rotate(0, rotationSpeed * h * 2, 0);
		}
		if (Input.GetMouseButtonUp(1)){
			autoRotateDir = h > 0 ? 1 : -1;
			autoRotate = true;
		}

		if(shouldRotate && autoRotate)
			transform.Rotate(0, autoRotateDir * rotationSpeed * Time.deltaTime, 0);
		
		float d = Input.GetAxis("Mouse ScrollWheel") * zoomSensitivity;
		if(d != 0){
			currentDistance = Mathf.Clamp01(currentDistance + d);
			float distance = Mathf.Lerp(maxDistance, minDistance, currentDistance);
			cam.localPosition = new Vector3(0,0,distance);
		}
	}
}
