//
//  Coordinator.swift
//  HelloTamnaAR
//
//  Created by Hyeonsoo Kim on 2022/06/28.
//

import SwiftUI
import ARKit
import RealityKit

//will be NSObject
class Coordinator: NSObject, ARSessionDelegate {
    
    //참조를 보유하고 싶지않기에 약한 속성으로 취급 (약한 참조) -> class안에서 참조한 class이기에 weak로?
    weak var view: ARView? //TODO: ?
    
    //AR세션에서 일어나는 Event들을 처리하기위해 Delegate를 준수, 채택.
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) { //why objc? -> 이 함수를 받을 때, #selector형태로 받기 때문.
        //Tap하고 있는 View에 대한 접근 권한 얻기.
        guard let view = self.view else { return }
        
        let tapLocation = recognizer.location(in: view) //기본적으로 화면을 탭하면 탭의 위치가 표시됨.
        
        //tap된 위치가 entity(Entity타입)위치와 일치한다면, ModelEntity로 다운캐스팅하고 옵셔널 바인딩하며 할당.
        //빨간상자 modelEntity를 tap하면 그 상자가 entity에 반환됨.  
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
            let material = SimpleMaterial(color: UIColor.random(), isMetallic: true)
            entity.model?.materials = [material]
        }
    }
    
}

class Coordinator2: NSObject, ARSessionDelegate {
    
    weak var view: ARView?
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let view = self.view else { return }
        
        let tapLocation = recognizer.location(in: view)
        
        
        //참고 url: https://shoveller.tistory.com/entry/ARKitRay-Casting
        //estimatePlane -> 추정 평면: 추정되는 평면 위치에서만 생성가능.
        //existingPlaneGeometry -> 평면: 좀더 자유분방스.
        //existingPlaneInfinite -> 무한 평면: 한번 수평면으로 인식된 위치면 해당 높이로 무제한 가상의 평면이 있다고 가정된다. 그 높이면 무한정 박을 수 있음. 공중일지라도.
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        //raycast를 사용하면 카메라 화면 중앙에서 ray를 캐스팅할 수 있습니다. ray가 뭐누.. 광선...?
        //ray: 실제 World의 표면에서 3D 위치를 찾는데 사용하는 수학적 광선.
        //ARRaycastResult: 화면의 한 지점을 검사하여 발견한 실제 지표면에 대한 정보.
        //우리는 그것이 어디에서 교차할지 말해야합니다.
        
        if let result = results.first { //광선 빔 싸악. 누른 곳에서 가장 가까운 위치 result?
            
            //Create new anchor
            //기존 AR 앵커가 없어도..? 추가가 가능하네? 가능하다.
            //ARAnchor class 자체가 makeUIView에서 생성? 사용이 불가능하네요. ARsessionDelegate를 여기 coordinator에서 받아서 그런듯.
            //AnchorEntity-RealityKit꺼. scene에 저장됨., ARAnchor-ARKit산유물. session에 저장됨.
            let anchor = ARAnchor(name: "Plane Anchor", transform: result.worldTransform) //세계변환한 값을 기준으로 새로운 anchor를 생성. 이는 모든 변형 정보, 방향, 축척, 크기, 회전 등등을 포함한다는 것을 의미한다.
            view.session.add(anchor: anchor) //plane을 감지하여 생성된 anchor가 session에 추가됨. 이렇게 add안하면 생성안됨.
            
            let modelEntity = ModelEntity(mesh: MeshResource.generateBox(size: 0.3))
            modelEntity.model?.materials = [SimpleMaterial(color: .blue, isMetallic: true)]
            
            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(modelEntity)
            
            view.scene.addAnchor(anchorEntity)
            //1. raycast를 통해 얻은 결과를 실제세계에 맞게 변형하고, ARAnchor 인스턴스를 생성.
            //2. arView.session에 ARAnchor를 add.
            //3. scene에서 쓰일 AnchorEntity의 anchor로 ARAnchor를 넣음.
            //4. model넣기.
            //5. scene에 만들어진 AnchorEntity를 추가.
            //요약 : ARAnchor -> Add to Session -> AnchorEntity로 만듦 -> ModelEntity넣기 -> Add to Scene
            
            print(view.scene.anchors.count) //tap -> count += 1
        }
    }
}

/*
 사용자가 현실 세계의 물리적 구조와 관련하여 가상 객체를 배치하도록 하려면 레이캐스트를 수행해야 합니다. 손가락 탭 위치에서 인지된 AR 세계로 광선을 "촬영"합니다. 그런 다음 레이캐스트는 이 광선이 비행기나 포인트 클라우드와 같은 추적 가능과 교차하는지 알려줍니다.
 */

//복잡했지 ARAnchor? 짧게해보자. ARAnchor 쓸 필요없나봐.

class Coordinator3: NSObject {
    
    //ARAnchor는 RealityKit에서 사용할 수 있지만, 간단히 무시하고 대신 AnchorEntity를 사용하십시오.
    
    weak var view: ARView?
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        
        guard let view = view else { return }
        
        let tapLocation = recognizer.location(in: view)
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            
            //ARAnchor - ARKit Framework
            //AnchorEntity - RealityKit Framework ... so we'd better use AnchorEntity... 
            
            let anchorEntity = AnchorEntity(raycastResult: result) //이렇게 접근하면 더이상 ARSessionDelegate도 필요없음. 지우자.
            
            let modelEntity = ModelEntity(mesh: MeshResource.generateBox(size: 0.1))
            modelEntity.model?.materials = [SimpleMaterial(color: UIColor.random(), isMetallic: true)]
            anchorEntity.addChild(modelEntity)
            
            view.scene.anchors.append(anchorEntity)
        }
    }
}

//ARKit과 RealityKit의 혼합을 설명하기 위해 Coordinator2처럼 해본 것.
//RealityKit은 Entity, AnchorEntity, ModelEntity, this Entity, that Entity... Entity로 시작하고 Entity로 끝난다.
//RealityKit은 결국 Anchor로 AnchorEntity만 잘 있으면 된다.
