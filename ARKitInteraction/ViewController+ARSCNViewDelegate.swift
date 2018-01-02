/*
See LICENSE folder for this sample’s licensing information.

Abstract:
ARSCNViewDelegate interactions for `ViewController`.
*/

import ARKit

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.virtualObjectInteraction.updateObjectToCurrentTrackingPosition()
            self.updateFocusSquare()
            
            /// Measure
            if(self.sceneView.isMeasureing){
                DispatchQueue.main.async { [weak self] in
                    self?.detectMeasureObjects()
                }
            }
            
        }
        
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        let baseIntensity: CGFloat = 40
        let lightingEnvironment = sceneView.scene.lightingEnvironment
        if let lightEstimate = session.currentFrame?.lightEstimate {
            lightingEnvironment.intensity = lightEstimate.ambientIntensity / baseIntensity
        } else {
            lightingEnvironment.intensity = baseIntensity
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.statusViewController.cancelScheduledMessage(for: .planeEstimation)
            self.statusViewController.showMessage("检测到平面")
            if self.virtualObjectLoader.loadedObjects.isEmpty {
                self.statusViewController.scheduleMessage("点击+号添加一个物品", inSeconds: 7.5, messageType: .contentPlacement)
            }
        }
        updateQueue.async {
            for object in self.virtualObjectLoader.loadedObjects {
                object.adjustOntoPlaneAnchor(planeAnchor, using: node)
            }
        }
        
        // add planes
        if (anchor is ARPlaneAnchor) {
            let plane = Plane(anchor: anchor as! ARPlaneAnchor, hidden: false, material: Plane.currentMaterial())
          self.planes[anchor.identifier] = plane
            node.addChildNode(plane)
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updateQueue.async {
            for object in self.virtualObjectLoader.loadedObjects {
                object.adjustOntoPlaneAnchor(planeAnchor, using: node)
            }
        }
        
        if (anchor is ARPlaneAnchor) {
            let plane = self.planes[anchor.identifier]
            plane?.update(anchor: anchor as! ARPlaneAnchor)        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `flatMap(_:)` to remove optional error messages.
        let errorMessage = messages.flatMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "会话启动失败", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // blurView.isHidden = false
        statusViewController.showMessage("""
        会话中断
        当中断结束后，会话会被重置.
        """, autoHide: false)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        //blurView.isHidden = true
        statusViewController.showMessage("重制会话")
        
        restartExperience()
    }
    
}


/***********************************************/
/*Measure*/
extension ViewController {
    //     func setupScene() {
    //        targetImageView.isHidden = true
    //        sceneView.delegate = self
    //        sceneView.session = session
    //        loadingView.startAnimating()
    //        meterImageView.isHidden = true
    //        resetButton.isHidden = true
    //        resetImageView.isHidden = true
    //        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
    //        resetValues()
    //    }
    
    
    func detectMeasureObjects() {
        guard let worldPosition = sceneView.realWorldVector(screenPosition: view.center) else { return }
        
        // loadingView.stopAnimating()
        if (sceneView.isMeasureing) {
            if sceneView.startMeasureValue == vectorZero {
                sceneView.startMeasureValue = worldPosition
               sceneView.currentMeasureLine = Line(sceneView: sceneView, startVector: sceneView.startMeasureValue, unit: unit)
            }
           sceneView.endMeasureValue = worldPosition
            sceneView.currentMeasureLine?.update(to: sceneView.endMeasureValue)
        }
    }
}
/*Measure*/
/***********************************************/

