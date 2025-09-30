import SwiftUI
import SceneKit

struct OrientationCubeView: UIViewRepresentable {
    var qx: Double
    var qy: Double
    var qz: Double
    var qw: Double

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true

        // Cube
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.06)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemTeal
        material.locksAmbientWithDiffuse = true
        box.firstMaterial = material

        let cubeNode = SCNNode(geometry: box)
        scnView.scene?.rootNode.addChildNode(cubeNode)

        // Axes helpers (optional)
        scnView.scene?.rootNode.addChildNode(axis(length: 1.5, color: .systemRed,   x: 1,  y: 0,  z: 0)) // X
        scnView.scene?.rootNode.addChildNode(axis(length: 1.5, color: .systemGreen, x: 0,  y: 1,  z: 0)) // Y
        scnView.scene?.rootNode.addChildNode(axis(length: 1.5, color: .systemBlue,  x: 0,  y: 0,  z: 1)) // Z

        // Light
        let light = SCNLight()
        light.type = .omni
        light.intensity = 800
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(4, 6, 8)
        scnView.scene?.rootNode.addChildNode(lightNode)

        // Ambient light
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 250
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scnView.scene?.rootNode.addChildNode(ambientNode)

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4)
        scnView.scene?.rootNode.addChildNode(cameraNode)

        // Store reference to cube for later updates
        context.coordinator.cubeNode = cubeNode
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        // Update cube orientation from quaternion
        let q = simd_quatf(ix: Float(qx), iy: Float(qy), iz: Float(qz), r: Float(qw))
        context.coordinator.cubeNode?.simdOrientation = q
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var cubeNode: SCNNode?
    }

    // MARK: - Helpers

    private func axis(length: CGFloat, color: UIColor, x: Float, y: Float, z: Float) -> SCNNode {
        let cylinder = SCNCylinder(radius: 0.01, height: length)
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        cylinder.firstMaterial = mat

        let node = SCNNode(geometry: cylinder)
        node.position = SCNVector3(x * Float(length) / 2, y * Float(length) / 2, z * Float(length) / 2)

        // Rotate cylinder to align with the axis
        if x != 0 {
            node.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        } else if z != 0 {
            node.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        }
        return node
    }
}

struct OrientationCubeView_Previews: PreviewProvider {
    static var previews: some View {
        OrientationCubeView(qx: 0, qy: 0, qz: 0, qw: 1)
            .frame(height: 220)
    }
}
