using UnityEngine;

public class CameraSpinner : MonoBehaviour
{
    [SerializeField]
    [Range(0, 1)]
    private float _rotationSpeed = 1.0f;
    private Transform _transform;

	void Start ()
    {
        _transform = transform;	
	}
	
	void Update ()
    {
        _transform.Rotate(
            new Vector3(
                Mathf.Sin(Time.time * 0.5f) * 0.5f,
                Mathf.Sin(Time.time * 0.1f),
                0.0f
            ) * _rotationSpeed
        );
	}
}
