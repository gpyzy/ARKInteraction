import Foundation
import SceneKit
import ARKit

class VirtualCube: SCNNode {
    
    var modelName: String {
        return "Cube"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override init(){
         super.init()
        
        let cube = SCNBox(width: 0.5, height: 0.8, length: 0.5, chamferRadius: 0)
        cube.materials = [self.createMaterial()]
        self.geometry=cube
        
       
    }
    
    func createMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = UIImage(named: "/Resources/Models.Scnassets/Cube/cube-material.png")
        mat.diffuse.wrapS = .repeat
        mat.diffuse.wrapT = .repeat
        mat.roughness.wrapS = .repeat
        mat.roughness.wrapT = .repeat
        mat.metalness.wrapS = .repeat
        mat.metalness.wrapT = .repeat
        mat.normal.wrapS = .repeat
        mat.normal.wrapT = .repeat
        
        return mat
    }
    
}
