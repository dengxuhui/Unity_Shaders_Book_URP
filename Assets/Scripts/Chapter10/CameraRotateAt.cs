using System;
using UnityEngine;

namespace Chapter10
{
    public class CameraRotateAt : MonoBehaviour
    {
        public Transform rotateTarget;
        public bool rotate = false;

        private void Update()
        {
            if (rotate && rotateTarget != null)
            {
                transform.RotateAround(rotateTarget.position, Vector3.up, 20 * Time.deltaTime);
            }
        }
    }
}