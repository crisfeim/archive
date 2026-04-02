import Foundation

/*
Task paper scoping:
    - empty document returns no scopes
    - document with no headers returns no scopes
    - switch case is not a scope
    - function call with labeled arg is not a scope
    - header with dot is not a scope
    - nested scopes have correct depths
    - empty scope has zero length body
    - header with space in name is a scope
    
Symbol scoping:
    Necesitamos un:
        - Parser que devuelva un rango (en donde empieza el símbolo y en donde acaba)
        - Una manera de detectar si el cursor está en ese rango
        - Una manera de mostrar sólo ese rango cuando el usuario entra
        - Trazar el stack
        
    Api:
        struct Symbol {
            let name: Sting
            let start: Int
            let end: Int
        }
        
        parse(code: String)     -> Symbol
        getScope(position: Int) -> Symbol
        focus(start: Int, end: Int)
*/

// Test Framework:
    func test(_ description: String, body: () -> Void) {
        body()
    }

    func assertEqual(_ a: (String, Int), _ b: (String, Int)) {
        if a.0 != b.0 || a.1 != b.1 {
            print("❌ Expected \(a) & \(b) to be equal")
        }
    }

// Vim:
    // Implementation:
        enum Vi {
            static func apply(_ m: String, to s: (String, Int)) -> (String, Int) {
                switch m {
                    case "l": 
                        guard s.1 < s.0.count else { return s }
                        return (s.0, s.1 + 1)
                    case "h": 
                        guard s.1 > 1 else { return s }
                        return (s.0, s.1 - 1)
                    default : return s
                }
            }
        }

    // Tests:
        test("l moves cursor right one place") {
            let s = ("hello", 3)
            let r = Vi.apply("l", to: s)
            let e = ("hello", 4)
            
            assertEqual(r, e)
        }

        test("l doesn't moves the cursor if it is already at the end of the line") {
            let s = ("hello", 5)
            let r = Vi.apply("l", to: s)
            let e = s
            
            assertEqual(r, e)
        }

        test("h moves cursor to the left one place") {
            let s = ("hello", 3)
            let r = Vi.apply("h", to: s)
            let e = ("hello", 2)
            
            assertEqual(r, e)
        }

        test("h doesn't moves the cursor if it is at the beginning of a line") {
            let s = ("hello", 1)
            let r = Vi.apply("h", to: s)
            let e = s
            
            assertEqual(r, e)
        }

// fmodels:
    /*
    build.sh
        swiftc main.swift -o bin.o
        sudo cp bin.o /usr/local/bin/fmodels
    */
    import Foundation
    import FoundationModels
    
    let model = SystemLanguageModel.default
    
    guard case .available = model.availability else {
        fputs("Error: Apple Intelligence not available.\n", stderr)
        exit(1)
    }

    let session = LanguageModelSession()
    
    let cyan = "\u{001B}[96m"
    let reset = "\u{001B}[0m"
    
    print("Chat started. Type 'exit' to quit.\n")
    
    while true {
        print(">>> ", terminator: "")
        fflush(stdout)
        guard let input = readLine(), !input.isEmpty else { continue }
        if input == "exit" { break }
        do {
        print("\u{001B}[38;2;99;102;241m> \u{001B}[0m", terminator: "")
            var previous = ""
            for try await snapshot in session.streamResponse(to: input) {
                let new = String(snapshot.content.dropFirst(previous.count))
                print(cyan + new + reset, terminator: "")
                fflush(stdout)
                previous = snapshot.content
            }
            print("\n")
        } catch {
            fputs("Error: \(error.localizedDescription)\n", stderr)
        }
    }


// Codility:
	import Foundation

	final class CatImageCell: UICollectionViewCell {
		
		private var imageView: UIImageView!
		private var currentPlaceholder: UIImage?
		
		convenience init(imageView: UIImageView) {
			self.init()
			self.imageView = imageView
		}
		
		override func prepareForReuse() {
			super.prepareForReuse()
			cleanImage()
			cleanIdentity()
		}
		
		func set(model: CatImageCellModel) {
			_set(model: ModelDecorator(model))
		}
		
		private func _set(model: CatImageCellModel) {
			captureModelIdentity(model.placeholderImage)
			setImage(model.placeholderImage)
			model.fetchCatImage { [weak self] result in
				self?.updateImage(from: result, ifMatches: model.placeholderImage)
			}
		}
		
		private func captureModelIdentity(_ placeholder: UIImage) {
			currentPlaceholder = placeholder
		}
		
		private func setImage(_ image: UIImage?) {
			dispatchOnMainThreadIfNeeded { [weak self] in
				self?.imageView.image = image
			}
		}
		
		private func updateImage(from result: CatImageResult, ifMatches model: UIImage) {
			guard matchesModelIdentity(model), case .success(let image) = result else { return }
			setImage(image)
		}
		
		private func matchesModelIdentity(_ placeholder: UIImage) -> Bool {
			currentPlaceholder == placeholder
		}
		
		private func cleanImage() {
			setImage(nil)
		}
		
		private func cleanIdentity() {
			currentPlaceholder = nil
		}
	}

	private typealias CatImageResult  = Result<UIImage, ImageFetchingError>
	private typealias CatImageFetcher = (@escaping (CatImageResult) -> Void) -> Void

	private struct ModelDecorator: CatImageCellModel {
		private let decoratee: CatImageCellModel
		
		init(_ decoratee: CatImageCellModel) {
			self.decoratee = decoratee
		}
		
		var placeholderImage: UIImage {
			decoratee.placeholderImage
		}
		
		func fetchCatImage(completion: @escaping (CatImageResult) -> Void) {
			withRetry(2, completion: completion)
		}

		private func withRetry(_ retries: UInt, completion: @escaping (CatImageResult) -> Void) { 
			decoratee.fetchCatImage { result in
				switch result {
					case .failure(let error) 
					where error == .timeout && retries > 0 : withRetry(retries - 1, completion: completion)
					default: completion(result)
				}
			}
		}
	}

	private func dispatchOnMainThreadIfNeeded(block: @escaping () -> Void) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { block() }
		}
		block()
	}





	import Foundation




	class UICollectionViewCell {
		func prepareForReuse() {}
	}

	class UIImageView {
		var image: UIImage?
	}


	enum ImageFetchingError: Error {
		case timeout
		case unknown
	}

	struct UIImage: Equatable {}
	protocol CatImageCellModel {
		var placeholderImage: UIImage { get }
		func fetchCatImage(completion: @escaping (Result<UIImage, ImageFetchingError>) -> Void)
	}

// EnvironmentBindings:
    import SwiftUI
    
    private struct CartCountKey: EnvironmentKey {
        static let defaultValue: Binding<Int> = .constant(0)
    }
    
    extension EnvironmentValues {
        var cartCount: Binding<Int> {
            get { self[CartCountKey.self] }
            set { self[CartCountKey.self] = newValue }
        }
    }
    
    struct Home: View {
        @State var cartCount = 0
        
        var body: some View {
            VStack {
                CartList().environment(\.cartCount, $cartCount)
                Button("Add item to cart") { cartCount += 1 }
            }
        }
    }
    
    struct CartList: View {
        @EnvironmentBinding(\.cartCount) private var count
        var body: some View {
            Text(count.description)
        }
    }
    
    @propertyWrapper
    struct EnvironmentBinding<Value>: DynamicProperty {
        @Environment private var binding: Binding<Value>
        init(_ keyPath: KeyPath<EnvironmentValues, Binding<Value>>) {
            self._binding = Environment(keyPath)
        }
        var wrappedValue: Value {
            get { binding.wrappedValue }
            nonmutating set { binding.wrappedValue = newValue }
        }
        var projectedValue: Binding<Value> {
            binding
        }
    }
// CrossCuttingConcerns:
    import Foundation
    
    public typealias Guid = String
    
    
    public protocol IBookingService {
        func BookFlight(passengerId: Guid, flightId: Guid)
    }
    
    public protocol ICheckInService {
        func PerformCheckIn(ticketId: Guid)
    }
    
    public protocol IMaintenanceService {
        func ScheduleRepair(planeId: Guid)
    }
    
    public protocol IStatusRegistry {
        func IsSystemLocked() -> Bool
    }
    
    
    struct BookingService: IBookingService {
        func BookFlight(passengerId: Guid, flightId: Guid) {}
    }
    
    struct CheckingInService: ICheckInService {
        func PerformCheckIn(ticketId: Guid) {} 
    }
    
    struct MaintenanceService: IMaintenanceService {
        func ScheduleRepair(planeId: Guid) {}
    }
    
    struct StatusRegistry: IStatusRegistry {
        func IsSystemLocked() -> Bool {true}
    }
    
    func isLockedDecorator<each Param>(_ decoratee: @escaping (repeat each Param) -> Void, _ isLocked: () -> Bool) -> (repeat each Param) throws -> Void {
        if isLocked() { return decoratee }
        return { (params: repeat each Param) in throw NSError(domain: "testng", code: 0) }
    }
    
    struct System {
        let bookFlight: (Guid, Guid) throws -> Void
        let performCheckIn: (Guid) throws -> Void
        let scheduleRepair: (Guid) throws -> Void
    }
    
    func composer() -> System {
        let status         = StatusRegistry()
        let bookFlight     = BookingService().BookFlight(passengerId:flightId:)
        let performCheckIn = CheckingInService().PerformCheckIn(ticketId:)
        let scheduleRepair = MaintenanceService().ScheduleRepair(planeId:)
        
        return System(
            bookFlight    : isLockedDecorator(bookFlight    , status.IsSystemLocked),
            performCheckIn: isLockedDecorator(performCheckIn, status.IsSystemLocked),
            scheduleRepair: isLockedDecorator(scheduleRepair, status.IsSystemLocked)
        )
    }

// aviator:
    // aviator-realitykit.swift
    
    // AirplaneRealityKitEntity.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 25/11/25.
    
    
    import RealityKit
    import UIKit
    
    final class AirplaneRealityKitEntity: Entity {
        var propeller: Entity!
        let scaleFactor: Float = 0.25
        
        required init() {
            super.init()
            self.name = "AirPlane"
            self.scale = SIMD3<Float>(repeating: scaleFactor)
            
            createCockpit()
            createEngine()
            createTailPlane()
            createSideWing()
            createPropellerAssembly()
        }
        
        private func createMaterial(color: UIColor) -> RealityKit.Material {
            let material = SimpleMaterial(color: color, isMetallic: false)
            return material
        }
        
        private func createCockpit() {
            let mesh = MeshResource.generateBox(width: 60, height: 50, depth: 50)
            let mat = createMaterial(color: AviatorApp.Colors.red)
            let cockpit = ModelEntity(mesh: mesh, materials: [mat])
            self.addChild(cockpit)
        }
        
        private func createEngine() {
            let mesh = MeshResource.generateBox(width: 20, height: 50, depth: 50)
            let mat = createMaterial(color: AviatorApp.Colors.white)
            let engine = ModelEntity(mesh: mesh, materials: [mat])
            engine.position = [40, 0, 0]
            self.addChild(engine)
        }
        
        private func createTailPlane() {
            let mesh = MeshResource.generateBox(width: 15, height: 20, depth: 5)
            let mat = createMaterial(color: AviatorApp.Colors.red)
            let tailPlane = ModelEntity(mesh: mesh, materials: [mat])
            tailPlane.position = [-35, 25, 0]
            self.addChild(tailPlane)
        }
        
        private func createSideWing() {
            let mesh = MeshResource.generateBox(width: 40, height: 8, depth: 150)
            let mat = createMaterial(color: AviatorApp.Colors.red)
            let sideWing = ModelEntity(mesh: mesh, materials: [mat])
            self.addChild(sideWing)
        }
        
        private func createPropellerAssembly() {
            let propMesh = MeshResource.generateBox(width: 20, height: 10, depth: 10)
            let propMat = createMaterial(color: AviatorApp.Colors.brown)
            propeller = ModelEntity(mesh: propMesh, materials: [propMat])
            propeller.position = [50, 0, 0]
            
            let bladeMesh = MeshResource.generateBox(width: 1, height: 100, depth: 20)
            let bladeMat = createMaterial(color: AviatorApp.Colors.brownDark)
            let blade = ModelEntity(mesh: bladeMesh, materials: [bladeMat])
            blade.position = [0, 0, 0]
            
            propeller.addChild(blade)
            self.addChild(propeller)
        }
    }

    
    // AviatorApp_RealityKit.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 25/11/25.
    
    
    import RealityKit
    import SwiftUI
    
    struct AviatorApp_RealityKit: View {
        @State var x: Float = 0.0
        @State var y: Float = 100.0
        @State var z: Float = 200.0
        @State var fieldOfView: Float = 60.0
        let scene = AviatorRealityKitScene()
        
        var body: some View {
            RealityView { content in
                content.add(scene.rootAnchor)
            }
            .ignoresSafeArea()
            .onChange(of: x, updateCamera)
            .onChange(of: y, updateCamera)
            .onChange(of: z, updateCamera)
            .onChange(of: fieldOfView, updateFieldOfView)
            .overlay(slides)
        }
        
        var slides: some View {
            VStack {
                Slider(value: $x, in: 0...500) {
                    Text("x")
                }
                Slider(value: $y, in: 0...500) {
                    Text("y")
                }
                Slider(value: $z, in: 0...500) {
                    Text("z")
                }
                
                Slider(value: $fieldOfView, in: 0...500) {
                    Text("Field of view")
                }
            }
        }
        
        func updateCamera() {
            scene.cameraEntity.position = [x, y, z]
        }
        
        func updateFieldOfView() {
            scene.cameraEntity.camera.fieldOfViewInDegrees = fieldOfView
        }
    }

    
    #Preview {
        AviatorApp_RealityKit()
    }

    
    // AviatorRealityScene.swift
    import RealityKit
    import UIKit
    import simd
    
    final class AviatorRealityKitScene {
        
        let rootAnchor = AnchorEntity()
        var airPlane = AirplaneRealityKitEntity()
        var sea = Entity()
        var sky = Entity()
        
        var cameraEntity: PerspectiveCamera!
        
        
        init() {
            rootAnchor.name = "RootScene"
            setupScene()
        }
        
        private func setupScene() {
            
            cameraEntity = PerspectiveCamera()
            cameraEntity.camera.fieldOfViewInDegrees = 60
            cameraEntity.position = [0, 100, 200]
            cameraEntity.look(
                at: [0, 0, 0],
                from: cameraEntity.position,
                relativeTo: rootAnchor
            )
            rootAnchor.addChild(cameraEntity)
            
            createLights()
            createSea()
            createSky()
            createPlane()
        }
        
        private func createLights() {
            let shadowLight = DirectionalLight()
            shadowLight.light.intensity = 1500
            shadowLight.light.color = .white
            shadowLight.look(at: [0, 0, 0], from: [150, 350, 350], relativeTo: rootAnchor)
            rootAnchor.addChild(shadowLight)
            
            let ambientLight = PointLight()
            ambientLight.light.intensity = 800
            ambientLight.light.color = AviatorApp.Colors.ambientSky
            ambientLight.position = [0, 200, 0]
            rootAnchor.addChild(ambientLight)
        }
        
        private func createSea() {
            let mesh = MeshResource.generateCylinder(height: 800, radius: 600)
            let material = SimpleMaterial(color: AviatorApp.Colors.blue, isMetallic: false)
            sea = ModelEntity(mesh: mesh, materials: [material])
            sea.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
            sea.position = [0, -600, 0]
            rootAnchor.addChild(sea)
        }
        
        private func createSky() {
            sky = Entity()
            sky.position = [0, -600, 0]
            rootAnchor.addChild(sky)
        }
        
        private func createPlane() {
            airPlane.position = [0, 100, 0]
            rootAnchor.addChild(airPlane)
        }
    }

    
    import SwiftUI
    #Preview {
        AviatorApp_RealityKit()
    }

    
    
    // aviator-scenekit.swift
    
    // AirPlane.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 25/11/25.
    
    import SceneKit
    
    class AirPlane: SCNNode {
        
        var propeller: SCNNode!
        let scaleFactor: Float = 0.25
        
        override init() {
            super.init()
            self.name = "AirPlane"
            self.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
            
            createCockpit()
            createEngine()
            createTailPlane()
            createSideWing()
            createPropellerAssembly()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func createMaterial(color: UIColor) -> SCNMaterial {
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.lightingModel = .phong // Usar Phong para un look low-poly con sombreado plano (flat shading)
            return material
        }
        
        // El tutorial original modifica los vértices, aquí usaremos una forma simple de caja
        private func createCockpit() {
            let geom = SCNBox(width: 60, height: 50, length: 50, chamferRadius: 0)
            geom.materials = [createMaterial(color: AviatorApp.Colors.red)]
            let cockpit = SCNNode(geometry: geom)
            cockpit.castsShadow = true
            self.addChildNode(cockpit)
        }
        
        private func createEngine() {
            let geom = SCNBox(width: 20, height: 50, length: 50, chamferRadius: 0)
            geom.materials = [createMaterial(color: AviatorApp.Colors.white)]
            let engine = SCNNode(geometry: geom)
            engine.position = SCNVector3(40, 0, 0)
            engine.castsShadow = true
            self.addChildNode(engine)
        }
        
        private func createTailPlane() {
            let geom = SCNBox(width: 15, height: 20, length: 5, chamferRadius: 0)
            geom.materials = [createMaterial(color: AviatorApp.Colors.red)]
            let tailPlane = SCNNode(geometry: geom)
            tailPlane.position = SCNVector3(-35, 25, 0)
            tailPlane.castsShadow = true
            self.addChildNode(tailPlane)
        }
        
        private func createSideWing() {
            let geom = SCNBox(width: 40, height: 8, length: 150, chamferRadius: 0)
            geom.materials = [createMaterial(color: AviatorApp.Colors.red)]
            let sideWing = SCNNode(geometry: geom)
            sideWing.castsShadow = true
            self.addChildNode(sideWing)
        }
        
        private func createPropellerAssembly() {
            let propGeom = SCNBox(width: 20, height: 10, length: 10, chamferRadius: 0)
            propGeom.materials = [createMaterial(color: AviatorApp.Colors.brown)]
            propeller = SCNNode(geometry: propGeom)
            propeller.castsShadow = true
            propeller.position = SCNVector3(50, 0, 0)
            
            // Aspa de la hélice
            let bladeGeom = SCNBox(width: 1, height: 100, length: 20, chamferRadius: 0)
            bladeGeom.materials = [createMaterial(color: AviatorApp.Colors.brownDark)]
            let blade = SCNNode(geometry: bladeGeom)
            blade.castsShadow = true
            // El tutorial original lo posiciona en 8,0,0, aquí lo centralizamos
            blade.position = SCNVector3(0, 0, 0)
            
            propeller.addChildNode(blade)
            self.addChildNode(propeller)
        }
        
        func updatePropeller() {
            propeller.rotation = SCNVector4(1, 0, 0, propeller.rotation.w + 0.3)
        }
    }

    
    // AviatorApp.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 22/11/25.
    
    import SceneKit
    import SwiftUI
    
    // https://medium.com/@medkalech/getting-started-with-scenekit-in-swiftui-ad4082a27446
    // https://developer.apple.com/documentation/realitykit/model3d/
    // https://developer.apple.com/documentation/RealityKit/RealityView
    struct AviatorApp: View {
        private let scene = AviatorScene()
        private var airPlane: AirPlane { scene.airPlane }
        private var sea: SCNNode { scene.sea }
        private var sky: SCNNode { scene.sky }
        
        @State private var normalizedMousePos = CGPoint.zero
        @State private var viewSize: CGSize = .zero
        
        var body: some View {
            GeometryReader { geometry in
                SceneView(
                    scene: scene,
                    options: [.autoenablesDefaultLighting]
                )
                .onAppear { viewSize = geometry.size }
                .gesture(dragGesture)
                .onReceive(Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()) { _ in
                    update(time: Date().timeIntervalSince1970)
                }
            }
            .ignoresSafeArea()
        }
        
        var dragGesture: some Gesture {
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    
                    guard self.viewSize != .zero else { return }
                    
                    let screenWidth = self.viewSize.width
                    let screenHeight = self.viewSize.height
                    
                    let tx = -1 + (value.location.x / screenWidth) * 2
                    let ty = 1 - (value.location.y / screenHeight) * 2
                    
                    normalizedMousePos = CGPoint(x: tx, y: ty)
                }
        }
    }

    extension AviatorApp {
        private func normalize(_ v: CGFloat, vmin: CGFloat, vmax: CGFloat, tmin: CGFloat, tmax: CGFloat) -> CGFloat {
            let nv = max(min(v, vmax), vmin)
            let dv = vmax - vmin
            let pc = (nv - vmin) / dv
            let dt = tmax - tmin
            let tv = tmin + (pc * dt)
            return tv
        }
        
        private func update(time: TimeInterval) {
            
            airPlane.updatePropeller()
            sea.rotation = SCNVector4(0, 1, 0, sea.rotation.w + Float(0.005))
            sky.rotation = SCNVector4(0, 1, 0, sky.rotation.w + Float(0.01))
            
            updatePlaneMovement()
        }
        
        private func updatePlaneMovement() {
            let targetX = normalize(normalizedMousePos.x, vmin: -1, vmax: 1, tmin: -100, tmax: 100)
            let targetY = normalize(normalizedMousePos.y, vmin: -1, vmax: 1, tmin: 25, tmax: 175)
            
            let currentX = CGFloat(airPlane.position.x)
            let currentY = CGFloat(airPlane.position.y)
            
            let newX = currentX + (targetX - currentX) * 0.1
            let newY = currentY + (targetY - currentY) * 0.1
            
            let diffY = targetY - currentY
            
            // Rotación suavizada (z e x)
            airPlane.rotation = SCNVector4(0, 0, 1, Float(diffY) * 0.0128)
            
            airPlane.position.x = Float(newX)
            airPlane.position.y = Float(newY)
        }
    }

    #Preview {
        AviatorApp()
    }

    
    // AviatorScene.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 25/11/25.
    
    
    import SceneKit
    import SwiftUI
    
    class AviatorScene: SCNScene {
        
        var airPlane = AirPlane()
        var sea = SCNNode()
        var sky = SCNNode()
        
        override init() {
            super.init()
            setupScene()
        }
        
        private func setupScene() {
            background.contents = AviatorApp.Colors.fogColor
            
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.fieldOfView = 60
            cameraNode.camera?.zNear = 1
            cameraNode.camera?.zFar = 10000
            cameraNode.position = SCNVector3(0, 100, 200)
            rootNode.addChildNode(cameraNode)
            
            createLights()
            
            createSea()
            createSky()
            createPlane()
        }
        
        private func createLights() {
            // 1. Luz Hemisférica (HemisphereLight)
            // En SceneKit, se usa una luz ambiente con un color para simular el skyColor
            let hemiLight = SCNLight()
            hemiLight.type = .ambient // Tipo ambiente para luz general
            // CORRECCIÓN: Usar 'color' directamente. Se simula el skyColor (0xaaaaaa)
            hemiLight.color = AviatorApp.Colors.ambientSky
            hemiLight.intensity = 900 // Intensidad base del tutorial (0.9) ajustada a SceneKit
            let hemiNode = SCNNode()
            hemiNode.light = hemiLight
            rootNode.addChildNode(hemiNode)
            
            // 2. Luz Direccional (DirectionalLight)
            let shadowLight = SCNLight()
            shadowLight.type = .directional
            shadowLight.color = UIColor.white
            shadowLight.intensity = 1500
            shadowLight.castsShadow = true
            
            let shadowNode = SCNNode()
            shadowNode.light = shadowLight
            shadowNode.position = SCNVector3(150, 350, 350)
            // CORRECCIÓN: Usar SCNVector3(0, 0, 0) o SCNVector3Zero
            shadowNode.look(at: SCNVector3(0, 0, 0))
            rootNode.addChildNode(shadowNode)
            
            // 3. Luz Ambiental Adicional (AmbientLight)
            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.color = UIColor(white: 0.5, alpha: 1.0)
            ambientLight.intensity = 500
            let ambientNode = SCNNode()
            ambientNode.light = ambientLight
            rootNode.addChildNode(ambientNode)
        }
        
        private func createSea() {
            let geom = SCNCylinder(radius: 600, height: 800)
            let mat = SCNMaterial()
            mat.diffuse.contents = AviatorApp.Colors.blue
            mat.transparency = 0.8
            mat.lightingModel = .phong
            geom.materials = [mat]
            
            sea = SCNNode(geometry: geom)
            sea.rotation = SCNVector4(1, 0, 0, -Float.pi / 2)
            sea.position = SCNVector3(0, -600, 0)
            rootNode.addChildNode(sea)
        }
        
        private func createSky() {
            sky.position = SCNVector3(0, -600, 0)
            rootNode.addChildNode(sky)
        }
        
        private func createPlane() {
            airPlane.position = SCNVector3(0, 100, 0)
            rootNode.addChildNode(airPlane)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    #Preview {
        SceneView(scene: AviatorScene()).ignoresSafeArea()
    }

    
    // Colors.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 25/11/25.
    
    
    import UIKit
    import SceneKit
    import SwiftUI
    
    extension AviatorApp {
        struct Colors {
            static let red = UIColor(red: 0xF2/255.0, green: 0x53/255.0, blue: 0x46/255.0, alpha: 1.0)
            static let white = UIColor(red: 0xD8/255.0, green: 0xD0/255.0, blue: 0xD1/255.0, alpha: 1.0)
            static let brown = UIColor(red: 0x59/255.0, green: 0x33/255.0, blue: 0x2E/255.0, alpha: 1.0)
            static let pink = UIColor(red: 0xF5/255.0, green: 0x98/255.0, blue: 0x6E/255.0, alpha: 1.0)
            static let brownDark = UIColor(red: 0x23/255.0, green: 0x19/255.0, blue: 0x0F/255.0, alpha: 1.0)
            static let blue = UIColor(red: 0x68/255.0, green: 0xC3/255.0, blue: 0xC0/255.0, alpha: 1.0)
            static let ambientSky = UIColor(red: 0xAA/255.0, green: 0xAA/255.0, blue: 0xAA/255.0, alpha: 1.0) // 0xaaaaaa
            static let ambientGround = UIColor(red: 0x00/255.0, green: 0x00/255.0, blue: 0x00/255.0, alpha: 1.0) // 0x000000
            static let fogColor = UIColor(red: 0xF7/255.0, green: 0xD9/255.0, blue: 0xAA/255.0, alpha: 1.0) // 0xf7d9aa
        }
    }


// command palette:
    import Foundation
    
    
    // MARK: - Domain
    
    enum Action {
            case createFile(path: String)
            case createFolder(path: String)
            case deleteFile(path: String)
            case renameFile(from: String, to: String)
            case runCommand(command: String)
            case unknown(input: String)
    }

    // MARK: - 1. Regex (NSRegularExpression, sin bare slash)
    
    func parseWithRegex(_ input: String) -> [Action] {
            let s = input.trimmingCharacters(in: .whitespaces)
            var results: [Action] = []
        
            let patterns: [(String, (NSTextCheckingResult, String) -> Action?)] = [
                    // rename foo to bar
                    (#"(?i)rename\s+(\S+)\s+to\s+(\S+)"#, { match, str in
                            guard match.numberOfRanges == 3,
                                        let r1 = Range(match.range(at: 1), in: str),
                                        let r2 = Range(match.range(at: 2), in: str) else { return nil }
                            return .renameFile(from: String(str[r1]), to: String(str[r2]))
                    }),
                    // create file / touch
                    (#"(?i)(?:create file|touch)\s+(\S+)"#, { match, str in
                            guard match.numberOfRanges == 2,
                                        let r = Range(match.range(at: 1), in: str) else { return nil }
                            return .createFile(path: String(str[r]))
                    }),
                    // create folder / mkdir
                    (#"(?i)(?:create folder|mkdir)\s+(\S+)"#, { match, str in
                            guard match.numberOfRanges == 2,
                                        let r = Range(match.range(at: 1), in: str) else { return nil }
                            return .createFolder(path: String(str[r]))
                    }),
                    // delete / rm
                    (#"(?i)(?:delete|rm)\s+(\S+)"#, { match, str in
                            guard match.numberOfRanges == 2,
                                        let r = Range(match.range(at: 1), in: str) else { return nil }
                            return .deleteFile(path: String(str[r]))
                    }),
                    // run / $
                    (#"(?i)(?:run|\$)\s+(.+)"#, { match, str in
                            guard match.numberOfRanges == 2,
                                        let r = Range(match.range(at: 1), in: str) else { return nil }
                            return .runCommand(command: String(str[r]))
                    }),
            ]
        
            // Split on "then" o "and then" para múltiples acciones
            let thenPattern = try! NSRegularExpression(pattern: #"\s+(?:and\s+)?then\s+"#, options: .caseInsensitive)
            let nsString = s as NSString
            let fullRange = NSRange(location: 0, length: nsString.length)
            var parts: [String] = []
            var lastEnd = 0
            for match in thenPattern.matches(in: s, range: fullRange) {
                    let partRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                    parts.append(nsString.substring(with: partRange))
                    lastEnd = match.range.location + match.range.length
            }
            parts.append(nsString.substring(from: lastEnd))
        
            for part in parts {
                    var matched = false
                    for (pattern, builder) in patterns {
                            guard let re = try? NSRegularExpression(pattern: pattern) else { continue }
                            let range = NSRange(part.startIndex..., in: part)
                            if let match = re.firstMatch(in: part, range: range),
                                    let action = builder(match, part) {
                                    results.append(action)
                                    matched = true
                                    break
                            }
                    }
                    if !matched {
                            results.append(.unknown(input: part))
                    }
            }
        
            return results
    }

    // MARK: - 2. NaturalLanguage + Regex para argumentos
    
    import FoundationModels
    
    @Generable
    enum ActionKind: String {
        case createFile
        case createFolder
        case deleteFile
        case renameFile
        case runCommand
        case unknown
    }

    @Generable
    struct ParsedAction {
        let kind: ActionKind
        let argument: String
        let secondArgument: String  // para rename: el destino
    }

    @Generable
    struct ActionPlan {
        let actions: [ParsedAction]
    }

    func parseWithFoundationModels(_ input: String) async throws -> [Action] {
        let session = LanguageModelSession()
        
        let plan = try await session.respond(
            to: """
            Parse this command into a list of file system actions.
            The argument field contains the file/folder path or shell command.
            For rename actions, argument is the source and secondArgument is the destination.
            If the intent is unclear, use unknown.
            
            Command: "\(input)"
            """,
            generating: ActionPlan.self
        )
        
        return plan.content.actions.map { parsed in
            switch parsed.kind {
                case .createFile:   return .createFile(path: parsed.argument)
                case .createFolder: return .createFolder(path: parsed.argument)
                case .deleteFile:   return .deleteFile(path: parsed.argument)
                case .renameFile:   return .renameFile(from: parsed.argument, to: parsed.secondArgument)
                case .runCommand:   return .runCommand(command: parsed.argument)
                case .unknown:      return .unknown(input: parsed.argument)
            }
        }
    }

    // MARK: - Demo
    
    func printActions(_ actions: [Action], label: String) {
            print("\n[\(label)]")
            for a in actions {
                    switch a {
                    case .createFile(let p):       print("  createFile(\(p))")
                    case .createFolder(let p):     print("  createFolder(\(p))")
                    case .deleteFile(let p):       print("  deleteFile(\(p))")
                    case .renameFile(let f, let t):print("  renameFile(\(f) -> \(t))")
                    case .runCommand(let c):       print("  runCommand(\(c))")
                    case .unknown(let i):          print("  unknown(\(i))")
                    }
            }
    }

    let tests = [
            "create file main.swift",
            "mkdir src then touch src/index.html",
            "delete build",
            "rename old.swift to new.swift",
            "run swift main.swift",
            "create folder myproject then create file myproject/main.swift then run swift myproject/main.swift",
    ]

    for test in tests {
            print("\nInput: \"\(test)\"")
        printActions(parseWithRegex(test),           label: "Regex")
    //try await printActions(parseWithFoundationModels(test), label: "NaturalLanguage")
    }

// Funkos:
    // CoreLogic/FunkoCard.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 18/7/25.
    
    import Foundation
    
    public struct FunkoCard: Identifiable, Equatable {
        public let id = UUID().uuidString
        public let image: String
        public let tag: Int
        public var showBack: Bool = true
        
        public init(image: String, tag: Int) {
            self.image = image
            self.tag = tag
        }
        
        ///  Provides an array of all the cards available.
        ///  NOTE: default ordering places matches as horizontal neighbors (handled on vm with .shuffle)
        public static let allCards: [FunkoCard] = {
            (1...8).reduce(into: [FunkoCard](), {
                $0.append(FunkoCard(image: $1.description, tag: $1))
                $0.append(FunkoCard(image: $1.description, tag: $1))
            })
        }()
    }

    
    // CoreLogic/Game.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 18/7/25.
    
    import Foundation
    
    public class Game {
        public var cards: [FunkoCard]
        public var lastToggledCardIndex: Int?
        
        public init(cards: [FunkoCard]) {
            self.cards = cards
        }
        
        private var countOfFaceUpCards: Int {
            return cards.filter { !$0.showBack }.count
        }
        
        public var score: Int {
            countOfFaceUpCards / 2
        }
        
        public var isGameOver: Bool {
            score == cards.count / 2
        }
        
        public var userStartedNewPairMatch: Bool {
            let facedUpCards = cards.filter { !$0.showBack }
            let countOfFaceUpCardsIsEven = facedUpCards.count % 2 == 0
            return !countOfFaceUpCardsIsEven
        }
        
        public func toggleCardAndResetIfNeeded(index: Int) {
            
            let previousCardIndex = lastToggledCardIndex
            // 1. Toggle the card
            toggleCard(index: index)
            // 2. If first move -> do nothing:
            if userStartedNewPairMatch { return }
            // 2. If second move we verify if it matches previous card
            // If same tag -> do nothing
            if cards[index].tag == cards[previousCardIndex!].tag { return }
            // Else -> reset cards (show back)
            cards[index].showBack = true
            cards[previousCardIndex!].showBack = true
        }
        
        private func toggleCard(index cardIndex: Int) {
            cards[cardIndex].showBack.toggle()
            lastToggledCardIndex = cardIndex
        }
    }

    
    // CoreLogicTests/CoreLogicTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 18/7/25.
    
    import XCTest
    import CoreLogic
    
    final class CoreLogicTests: XCTestCase {
        
        func test_game_init() throws {
            let game = Game(cards: FunkoCard.allCards)
            XCTAssertEqual(game.cards, FunkoCard.allCards)
        }
        
        func test_toggleCard_togglesCard() throws {
            let card = anyCard(tag: 0)
            let game = Game(cards: [card])
            game.toggleCardAndResetIfNeeded(index: 0)
            XCTAssertEqual(game.cards[0].showBack, false)
        }
        
        func test_isFirstPairMovement() throws {
            let card1 = anyCard(tag: 1)
            let card2 = anyCard(tag: 2)
            let card3 = anyCard(tag: 3)
            let card4 = anyCard(tag: 4)
            
            let game = Game(cards: [card1, card2, card3, card4])
            
            game.toggleCardAndResetIfNeeded(index: 0)
            XCTAssertTrue(game.userStartedNewPairMatch)
            
            game.toggleCardAndResetIfNeeded(index: 1)
            XCTAssertFalse(game.userStartedNewPairMatch)
            
            game.toggleCardAndResetIfNeeded(index: 2)
            XCTAssertTrue(game.userStartedNewPairMatch)
            
            game.toggleCardAndResetIfNeeded(index: 3)
            XCTAssertFalse(game.userStartedNewPairMatch)
        }
        
        func test_lastToggledCardIndex() {
            let game = Game(cards: [anyCard(), anyCard(), anyCard(), anyCard()])
            XCTAssertNil(game.lastToggledCardIndex)
            
            game.toggleCardAndResetIfNeeded(index: 0)
            XCTAssertEqual(game.lastToggledCardIndex, 0)
            
            game.toggleCardAndResetIfNeeded(index: 1)
            XCTAssertEqual(game.lastToggledCardIndex, 1)
            
            game.toggleCardAndResetIfNeeded(index: 2)
            XCTAssertEqual(game.lastToggledCardIndex, 2)
            
            game.toggleCardAndResetIfNeeded(index: 3)
            XCTAssertEqual(game.lastToggledCardIndex, 3)
        }
        
        func test_togglesCardAndResetIfNeeded_resetsCardsIfCardsDontMatch() throws {
            let card1 = anyCard(tag: 0)
            let card2 = anyCard(tag: 2)
            let card3 = anyCard(tag: 3)
            
            let game = Game(cards: [card1, card2, card3])
            game.toggleCardAndResetIfNeeded(index: 0)
            game.toggleCardAndResetIfNeeded(index: 2)
            
            XCTAssertEqual(game.cards[0].showBack, true)
            XCTAssertEqual(game.cards[2].showBack, true)
        }
        
        func test_togglesCardAndResetIfNeeded_doesntResetCardsIfCardsMatch() throws {
            
            let game = Game(cards: [anyCard(), anyCard()])
            game.toggleCardAndResetIfNeeded(index: 0)
            game.toggleCardAndResetIfNeeded(index: 1)
            
            XCTAssertEqual(game.cards[0].showBack, false)
            XCTAssertEqual(game.cards[1].showBack, false)
        }
        
        
        func anyCard(tag: Int = 0) -> FunkoCard {
            FunkoCard(image: "any-image", tag: tag)
        }
    }

    
    
    
    // Shared/Models.swift
    //
    //  Models.swift
    //  GuessTheFunko
    //
    //  Created by Alex Chase on 3/2/23.
    //
    
    import Foundation
    import UIKit
    
    struct FunkoCard: Identifiable {
        let id = UUID().uuidString
        let uiImage: UIImage
        let tag: Int
        var showBack: Bool = true
        
        init(uiImage: UIImage, tag: Int) {
            self.uiImage = uiImage
            self.tag = tag
        }
        
        init(tag: Int) {
            self.init(uiImage: .init(named: "\(tag)")!, tag: tag)
        }
        
        ///  Provides an array of all the cards available.
        ///  NOTE: default ordering places matches as horizontal neighbors (handled on vm with .shuffle)
        static let allCards: [FunkoCard] = {
            // valid cards have tags from 1 to 8 inclusive
            (1...8).reduce(into: [FunkoCard](), {
                // Add a card
                $0.append(FunkoCard(tag: $1))
                // Add a match for the card
                $0.append(FunkoCard(tag: $1))
            })
        }()
    }

    
    
    // SwiftUI_version/ContentView.swift
    //
    //  ContentView.swift
    //  GuessTheFunko
    //
    //  Created by Alex Chase on 3/17/23.
    //
    
    import SwiftUI
    
    struct ContentView: View {
        
        @StateObject private var viewModel = ContentViewModel()
        
        var body: some View {
            // https://stackoverflow.com/questions/57244713/get-index-in-foreach-in-swiftui
            VStack(alignment: .center) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.cards.indices, id: \.self) { index in
                        let card = viewModel.cards[index]
                        Image(uiImage: card.showBack ? UIImage(named: "cardBack")! : card.uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .onTapGesture {
                                viewModel.handleCardTap(at: index)
                            }
                    }
                }
                .padding(.horizontal)
                
                Text(viewModel.isGameOver ? "Game Over" : "Score \(viewModel.score)" )
                    .font(.title2)
                    .padding()
                
                Button("Play Again") {
                    viewModel.playAgain()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .opacity(viewModel.isGameOver ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isGameOver) //optimization
            }
        }
        
        let columns = [
            GridItem(.fixed(80)),
            GridItem(.fixed(80)),
            GridItem(.fixed(80)),
            GridItem(.fixed(80))
        ]
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

    
    // SwiftUI_version/ContentViewModel.swift
    //
    //  ContentViewModel.swift
    //  GuessTheFunkoSwiftUI
    //
    //  Created by Nicholas Boleky on 6/26/25.
    //
    
    import Foundation
    @MainActor
    class ContentViewModel: ObservableObject {
        @Published var cards: [FunkoCard] = FunkoCard.allCards.shuffled() //googled randomizing array
        @Published var score: Int = 0
        @Published var isGameOver: Bool = false
        
        private var firstFlippedIndex: Int?
        private var isFlippingBack = false //optimization
        
        func handleCardTap(at index: Int) {
            //check its face down (if face up we ignore), check we arent handling two cards already
            guard cards[index].showBack,
                    !isFlippingBack
            else { return }
            cards[index].showBack = false //first, flips the tapped card
            
            //this if condition checks if this is the second card being flipped. If this is the second, it will compare the tag of the first flipped index with the card that was just being fipped. if they match, score increases, else the flipping back sequence begins
            if let firstIndex = firstFlippedIndex {
                if cards[firstIndex].tag == cards[index].tag {
                    score += 1
                    firstFlippedIndex = nil
                    //leave matched cards face up
                    //check game over after scoring
                    //https://stackoverflow.com/questions/29588158/check-if-all-elements-of-an-array-have-the-same-value-in-swift
    //                if cards.allSatisfy({ !$0.showBack }) {
    //                    isGameOver = true
    //                }
                    if score == cards.count / 2 {
                        isGameOver = true
                    }
                } else {
                    isFlippingBack = true
                    //https://stackoverflow.com/questions/59682446/how-to-trigger-an-action-after-x-seconds-in-swiftui
                    Task {
                        try? await Task.sleep(nanoseconds: 500000000)
                        cards[firstIndex].showBack = true
                        cards[index].showBack = true
                        firstFlippedIndex = nil
                        isFlippingBack = false
                    }
                }
            } else {
                firstFlippedIndex = index
            }
        }
        
        func playAgain() {
            cards = FunkoCard.allCards.shuffled()
                score = 0
                firstFlippedIndex = nil
                isFlippingBack = false
                isGameOver = false
            }
    }

    
    // SwiftUI_version/GuessTheFunkoSwiftUIApp.swift
    //
    //  GuessTheFunkoSwiftUIApp.swift
    //  GuessTheFunkoSwiftUI
    //
    //  Created by Abe Hunt on 8/1/23.
    //
    
    import SwiftUI
    
    @main
    struct GuessTheFunkoSwiftUIApp: App {
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }

    
    // UIKit_version/AppDelegate.swift
    import UIKit
    
    @main
    class AppDelegate: UIResponder, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            return true
        }
        
        // MARK: UISceneSession Lifecycle
        
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }

    
    
    // UIKit_version/SceneDelegate.swift
    import UIKit
    import SwiftUI
    
    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        
        var window: UIWindow?
        
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
            // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
            // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
            guard let scene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: scene)
            window?.rootViewController = ViewController()
            window?.makeKeyAndVisible()
        }
        
        func sceneDidDisconnect(_ scene: UIScene) {
            // Called as the scene is being released by the system.
            // This occurs shortly after the scene enters the background, or when its session is discarded.
            // Release any resources associated with this scene that can be re-created the next time the scene connects.
            // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        }
        
        func sceneDidBecomeActive(_ scene: UIScene) {
            // Called when the scene has moved from an inactive state to an active state.
            // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        }
        
        func sceneWillResignActive(_ scene: UIScene) {
            // Called when the scene will move from an active state to an inactive state.
            // This may occur due to temporary interruptions (ex. an incoming phone call).
        }
        
        func sceneWillEnterForeground(_ scene: UIScene) {
            // Called as the scene transitions from the background to the foreground.
            // Use this method to undo the changes made on entering the background.
        }
        
        func sceneDidEnterBackground(_ scene: UIScene) {
            // Called as the scene transitions from the foreground to the background.
            // Use this method to save data, release shared resources, and store enough scene-specific state information
            // to restore the scene back to its current state.
        }
        
        
    }

    
    
    // UIKit_version/ViewController.swift
    import UIKit
    import CoreLogic
    
    final class ViewController: UIViewController {
        let game = Game(cards: FunkoCard.allCards.shuffled())
        lazy var rootView = makeGameUI()
        
        var tapHandler: (Int, UIButton) -> Void = { _,_ in }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tapHandler =  { [weak self] index, btn in
                btn.setImage(self?.game.cards[index].toggledImage, for: .normal)
                self?.game.toggleCardAndResetIfNeeded(index: index)
                self?.reloadData()
            }
            
            view.backgroundColor = .white
            drawGameState()
        }
        
        func reloadData() {
            rootView.resultLabel.text = "Score: \(game.score)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.rootView.buttons.forEach { cardID, btn in
                    let matchingCard = self?.game.cards.first(where: {$0.id == cardID })
                    btn.setImage(matchingCard?.uiImage, for: .normal)
                }
            }
        }
    }

    extension ViewController {
        // @todo: this could be ideally abstracted into its own uiview
        // with delegation methods
        typealias GameUI = (stack: UIStackView, resultLabel: UILabel, buttons: [String: UIButton])
        func makeGameUI() -> GameUI {
            var buttons = [String: UIButton]()
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            let rows: Int = 4
            let columns: Int = 4
            
            for row in 0 ..< rows {
                let horizontalSv = UIStackView()
                horizontalSv.axis = .horizontal
                horizontalSv.alignment = .fill
                horizontalSv.distribution = .fillEqually
                horizontalSv.spacing = 5
                
                for col in 0 ..< columns {
                    let button = UIButton()
                    
                    let index = row*columns + col
                    let card = game.cards[index]
                    buttons[card.id] = button
                    button.setImage(card.uiImage, for: .normal)
                    button.imageView?.contentMode = .scaleAspectFit
                    button.addAction(UIAction(handler: {[weak self] _ in
                        self?.tapHandler(index, button)
                    }), for: .touchUpInside)
                    horizontalSv.addArrangedSubview(button)
                }
                stackView.addArrangedSubview(horizontalSv)
            }
            
            let resultLabel = UILabel()
            resultLabel.text = "Result:"
            resultLabel.textAlignment = .center
            stackView.addArrangedSubview(resultLabel)
            return (stackView, resultLabel, buttons)
        }
        
        func drawGameState() {
            let stackView = rootView.stack
            view.addSubview(stackView)
            
            let width = self.view.bounds.width - 20
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            stackView.widthAnchor.constraint(equalToConstant: width).isActive = true
            stackView.heightAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0).isActive = true
        }
    }

    
    extension FunkoCard {
        
        var toggledImage: UIImage {
            showBack ? faceImage : backImage
        }
        
        var uiImage: UIImage {
            showBack ? backImage : faceImage
        }
        
        private var backImage: UIImage {
            .init(named: "cardBack")!
        }
        
        private var faceImage: UIImage {
            .init(named: "\(tag)")!
        }
        
    }


// swiftui-intermediary-representation:
    import XCTest
    import SwiftUI
    import CustomDump
    
    enum ViewNode: Equatable {
        case vstack([ViewNode])
        case hstack([ViewNode])
        case zstack([ViewNode])
        case button([ViewNode])
        case group ([ViewNode])
        case text (String)
        case image(String)
    }

    extension ViewNode {
        static func vstack(_ children: ViewNode...) -> Self {
            vstack(children)
        }
        
        static func hstack(_ children: ViewNode...) -> Self {
            hstack(children)
        }
        
        static func zstack(_ children: ViewNode...) -> Self {
            zstack(children)
        }
        
        static func group(_ children: ViewNode...) -> Self {
            group(children)
        }
        
        static func button(_ children: ViewNode...) -> Self {
            button(children)
        }
    }

    struct ViewNodeFactory {
        func parseView(_ view: Any) -> ViewNode? {
            let mirror = Mirror(reflecting: view)
            let typeString = String(describing: type(of: view))
            
            
            if typeString.contains("Optional") {
                let mirror = Mirror(reflecting: view)
                if mirror.displayStyle == .optional {
                    if let child = mirror.children.first {
                        return parseView(child.value)
                    }
                    return nil
                }
            }
            
            if typeString.contains("Text"), let storage = mirror.descendant("storage") {
                let storageMirror = Mirror(reflecting: storage)
                if let anyTextStorage = storageMirror.descendant("anyTextStorage") {
                    let keyMirror = Mirror(reflecting: anyTextStorage)
                    if let key = keyMirror.descendant("key", "key") as? String {
                        return .text(key)
                    }
                }
            }
            
            if typeString.contains("Image"), let provider = mirror.descendant("provider", "base"), let name = Mirror(reflecting: provider).descendant("name") {
                let name = String(describing: name)
                return .image(name)
            }
            
            if let tree = mirror.descendant("_tree") {
                let treeMirror = Mirror(reflecting: tree)
                if let content = treeMirror.descendant("content") {
                    let children = parseChildren(content)
                    if typeString.contains("VStack") { return .vstack(children) }
                    if typeString.contains("HStack") { return .hstack(children) }
                    if typeString.contains("ZStack") { return .zstack(children) }
                }
            }
            
            if typeString.contains("Button"), let label = mirror.descendant("label") {
                return .button(parseChildren(label))
            }
            
            if typeString.contains("Group"), let content = mirror.descendant("content") {
                return .group(parseChildren(content))
            }
            
            return nil
        }
        
        func parseChildren(_ content: Any) -> [ViewNode] {
            let mirror = Mirror(reflecting: content)
            let typeString = String(describing: type(of: content))
            
            if typeString.contains("TupleView"), let value = mirror.descendant("value") {
                let valueMirror = Mirror(reflecting: value)
                return valueMirror.children.compactMap { parseView($0.value) }
            }
            
            if let singleNode = parseView(content) {
                return [singleNode]
            }
            
            return []
        }
    }

    @MainActor
    class SwiftUIViewNodeTests: XCTestCase {
        struct MyView: View {
            @State var some = "some"
            var body: some View {
                VStack {
                    HStack {
                        Button("hello world") {}
                        Image("someImage")
                        if true {
                            ZStack {
                                Text("Hola")
                                Text("Mundo")
                            }
                        }
                    }
                    Group {
                        Text("Hola")
                        Text("Mundo")
                    }
                    Text("Hola")
                    Text("Mundo")
                }
            }
        }
        
        
        func test() throws {
            let sut = ViewNodeFactory()
            dump(MyView().body)
            let node = try XCTUnwrap(sut.parseView(MyView().body))
            expectNoDifference(node, .vstack(
                .hstack(
                    .button(.text("hello world")),
                    .image("someImage"),
                    .zstack(
                        .text("Hola"),
                        .text("Mundo")
                    )
                ),
                .group(
                    .text("Hola"),
                    .text("Mundo")
                ),
                .text("Hola"),
                .text("Mundo")
            ))
        }
    }

// timeline:
    // ContentView.swift
    import SwiftUI
    
    struct ContentView: View {
        var body: some View {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }
        }
    }

    
    // MyApp.swift
    import SwiftUI
    
    @main
    struct MyApp: App {
        var body: some Scene {
            WindowGroup {
                ItemListComposer()
            }
        }
    }

    import SwiftUI
    
    struct ItemsState: Equatable {
        var movies = [Item]()
        var isLoading = true
    }

    struct Item: Identifiable, Equatable {
        let id: UUID
        let title: String
    }

    struct ItemList: View {
        @Binding var state: ItemsState
        
        var body: some View {
            List {
                ForEach(state.movies) { movie in
                    Text(movie.title)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(movie)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                }
            }
            .toolbar {
                Button {
                    addMovie()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        
        private func addMovie() {
            let newMovie = Item(id: UUID(), title: "Item \(UUID().uuidString.prefix(8))")
            state.movies.append(newMovie)
        }
        
        private func delete(_ movie: Item) {
            state.movies.removeAll { $0.id == movie.id }
        }
    }

    @MainActor
    final class StateTimeline_B<State> {
        private let clock = ContinuousClock()
        private var snapshots: [(instant: ContinuousClock.Instant, state: State)] = []
        
        func add(_ state: State) {
            snapshots.append((clock.now, state))
        }
    }

    struct Counter: View {
        let count: Int
        @Binding var action: Action?
        enum Action {
            case increase
            case decrease
        }
        
        var body: some View {
            VStack {
                Text(count.description)
                Button("+") { action = .increase }
                Button("-") { action = .decrease }
            }
        }
    }

    @MainActor
    func Reducer<T>(_ reduce: @escaping (T) -> Void) -> Binding<T?> {
        .init(get: { .none }, set: { $0.map(reduce) })
    }

    struct CounterStore: View {
        @State var count = 0
        
        var body: some View {
            Counter(
                count: count,
                action: Reducer { action in
                    reduce(&count, action)
                }
            )
        }
        
        func reduce(_ state: inout Int, _ action: Counter.Action) {
            switch action {
            case .increase: state += 1
            case .decrease: state -= 1
            }
        }
    }

    @MainActor
    class StateTimeline<State: Sendable> {
        private var _history = [Date: State]()
        
        var history: [TimeInterval: State] {
            guard let firstDate = _history.keys.min() else { return [:] }
            return _history.reduce(into: [TimeInterval: State]()) {
                let offset = $1.key.timeIntervalSince(firstDate)
                $0[offset] = $1.value
            }
        }
        
        func add(_ state: State) {
            _history[Date()] = state
        }
        
        func replay() -> AsyncStream<State> {
            let sortedHistory = _history.sorted { $0.key < $1.key }
            
            return AsyncStream { continuation in
                let task = Task {
                    for i in 0..<sortedHistory.count {
                        let current = sortedHistory[i]
                        continuation.yield(current.value)
                        
                        if i < sortedHistory.count - 1 {
                            let next = sortedHistory[i + 1]
                            let duration = next.key.timeIntervalSince(current.key)
                            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                        }
                    }
                    continuation.finish()
                }
                
                continuation.onTermination = { _ in task.cancel() }
            }
        }
    }

    @MainActor
    struct ItemListComposer: View {
        @State var state = ItemsState()
        private let tl = StateTimeline<ItemsState>()
        @State var isReplaying = false
        @State var showHistorySheet = false
        
        var body: some View {
            NavigationStack {
                ItemList(state: $state.onChange(tl.add))
                    .disabled(isReplaying)
                    .animation(.linear, value: state)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button {
                                Task { await replay() }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .disabled(isReplaying)
                        }
                        
                        ToolbarItem(placement: .bottomBar) {
                            
                            Button("Show history") {
                                showHistorySheet = true
                            }
                        }
                    }
                    .sheet(isPresented: $showHistorySheet) {
                        NavigationStack {
                            List {
                                ForEach(tl.history.keys.sorted(), id: \.self) { timeInterval in
                                    Section(header: Text("T + \(String(format: "%.2f", timeInterval))s")) {
                                        if let historicalState = tl.history[timeInterval] {
                                            ForEach(historicalState.movies) { movie in
                                                Text(movie.title)
                                                    .font(.caption)
                                            }
                                            if historicalState.movies.isEmpty {
                                                Text("No movies")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                            .navigationTitle("History")
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
            }
        }
        
        
        func replay() async {
            isReplaying = true
            for await states in tl.replay() {
                state = states
            }
            isReplaying = false
        }
    }

    
    extension Binding {
        @MainActor
        func onChange(_ observe: @escaping (Value) -> Void) -> Self {
            .init(get: { self.wrappedValue }, set: { self.wrappedValue  = $0 ; observe($0) })
        }
    }

    
    // Package.swift
    // swift-tools-version: 6.0
    
    // WARNING:
    // This file is automatically generated.
    // Do not edit it by hand because the contents will be replaced.
    
    import PackageDescription
    import AppleProductTypes
    
    let package = Package(
        name: "timeline",
        platforms: [
            .iOS("16.0")
        ],
        products: [
            .iOSApplication(
                name: "timeline",
                targets: ["AppModule"],
                bundleIdentifier: "me.crisfe.course.timeline",
                teamIdentifier: "V73WZ9Y4HH",
                displayVersion: "1.0",
                bundleVersion: "1",
                appIcon: .placeholder(icon: .boat),
                accentColor: .presetColor(.brown),
                supportedDeviceFamilies: [
                    .pad,
                    .phone
                ],
                supportedInterfaceOrientations: [
                    .portrait,
                    .landscapeRight,
                    .landscapeLeft,
                    .portraitUpsideDown(.when(deviceFamilies: [.pad]))
                ]
            )
        ],
        targets: [
            .executableTarget(
                name: "AppModule",
                path: "."
            )
        ],
        swiftLanguageVersions: [.v6]
    )

// paper:
    // CodePaperApp.swift
    // © 2026  Cristian Felipe Patiño Rojas. Created on 15/3/26.
    
    import SwiftUI
    
    @main
    struct CodePaperApp: App {
        @StateObject var engine = TaskPaperEngine()
        var body: some Scene {
            WindowGroup {
                CodepaperView(engine: engine)
                    .navigationTitle(engine.currentFileURL?.lastPathComponent ?? "Untitled")
                    .onOpenURL(perform: engine.loadExternalFile)
                
            }
            .commands {
                CommandGroup(replacing: .saveItem) {
                    Button("Save") {
                        engine.saveFile()
                    }
                    .keyboardShortcut("s", modifiers: .command)
                }
                
                CommandGroup(replacing: .importExport) {
                    Button("Open...") {
                        engine.openFile()
                    }
                    .keyboardShortcut("o", modifiers: .command)
                }
            }
        }
    }

    
    
    // ContentView.swift
    import SwiftUI
    import Combine
    import UniformTypeIdentifiers
    
    // MARK: - TaskPaperEngine
    class TaskPaperEngine: ObservableObject {
        @Published var rawText: String = "// Proyecto A:\n\t// Tarea 1:\n\t\t// Subtarea 1.1:\n\t\t\tprint(\"hello\")\n// Proyecto B:\n\tprint(\"mundo\")"
        @Published var focusRange: ClosedRange<Int>? = nil
        @Published var consoleOutput: String = ""
        @Published var currentFileURL: URL? = nil
        
        @Published var navStack: [Int] = []
        @Published var forwardStack: [Int] = []
        @Published var foldedIds: Set<Int> = []
        
        var rootNavID: Int? { navStack.last }
        private let fm = FileManager.default
        
        var currentScopeName: String? {
            guard let rootID = rootNavID else { return nil }
            let lines = rawText.components(separatedBy: .newlines)
            guard rootID < lines.count else { return "FOLDER" }
            let line = lines[rootID]
            var displayName = line.trimmingCharacters(in: .whitespaces)
            if displayName.hasPrefix("//") { displayName = String(displayName.dropFirst(2)) }
            return displayName.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ":", with: "").uppercased()
        }
        
        var navigationNodes: [(id: Int, text: String, depth: Int, visualLevel: Int, hasChildren: Bool)] {
            let lines = rawText.components(separatedBy: .newlines)
            let all = allScopes(in: lines)
            var visibleNodes: [(id: Int, text: String, depth: Int, hasChildren: Bool)] = []
            var skipUntilDepth: Int? = nil
            
            for (index, node) in all.enumerated() {
                if let skipDepth = skipUntilDepth {
                    if node.depth > skipDepth { continue }
                    else { skipUntilDepth = nil }
                }
                let hasChildren = (index + 1 < all.count) && (all[index + 1].depth > node.depth)
                if let rootID = rootNavID {
                    if node.id <= rootID { continue }
                    let rootDepth = getDepth(lines[rootID])
                    if node.depth <= rootDepth { break }
                    visibleNodes.append((node.id, node.text, node.depth, hasChildren))
                } else {
                    visibleNodes.append((node.id, node.text, node.depth, hasChildren))
                }
                if foldedIds.contains(node.id) { skipUntilDepth = node.depth }
            }
            let sortedDepths = Array(Set(visibleNodes.map { $0.depth })).sorted()
            return visibleNodes.map { node in
                let level = sortedDepths.firstIndex(of: node.depth) ?? 0
                return (node.id, node.text, node.depth, level, node.hasChildren)
            }
        }
        
        private func allScopes(in lines: [String]) -> [(id: Int, text: String, depth: Int)] {
            lines.enumerated().compactMap { (i, line) in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard trimmed.hasSuffix(":") else { return nil }
                var displayName = trimmed
                if displayName.hasPrefix("//") { displayName = String(displayName.dropFirst(2)) }
                displayName = displayName.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ":", with: "")
                return (id: i, text: displayName, depth: getDepth(line))
            }
        }
        
        // --- NAVEGACIÓN ---
        func navigateTo(_ id: Int) {
            if rootNavID != id {
                navStack.append(id)
                forwardStack.removeAll()
            }
        }
        func goBack() { guard let last = navStack.popLast() else { return }; forwardStack.append(last) }
        func goForward() { guard let next = forwardStack.popLast() else { return }; navStack.append(next) }
        func toggleFold(_ id: Int) {
            if foldedIds.contains(id) { foldedIds.remove(id) } else { foldedIds.insert(id) }
        }
        func setFocus(at index: Int) {
            let lines = rawText.components(separatedBy: .newlines)
            let baseDepth = getDepth(lines[index])
            var end = index + 1
            while end < lines.count && (getDepth(lines[end]) > baseDepth || lines[end].trimmingCharacters(in: .whitespaces).isEmpty) { end += 1 }
            focusRange = index...(end - 1)
        }
        
        // --- BINDING ---
        var focusedText: Binding<String> {
            Binding(
                get: {
                    guard let range = self.focusRange else { return self.rawText }
                    let lines = self.rawText.components(separatedBy: .newlines)
                    let safeRange = range.clamped(to: 0...(lines.count - 1))
                    if self.rootNavID == safeRange.lowerBound {
                        let contentStart = safeRange.lowerBound + 1
                        guard contentStart <= safeRange.upperBound else { return "" }
                        let rootDepth = self.getDepth(lines[safeRange.lowerBound]) + 4
                        return lines[contentStart...safeRange.upperBound].map { String(self.dropLeadingVisualWidth($0, width: rootDepth)) }.joined(separator: "\n")
                    }
                    let rootDepth = self.getDepth(lines[safeRange.lowerBound])
                    return lines[safeRange].map { String(self.dropLeadingVisualWidth($0, width: rootDepth)) }.joined(separator: "\n")
                },
                set: { newValue in
                    guard let range = self.focusRange else { self.rawText = newValue; return }
                    let linesBefore = self.rawText.components(separatedBy: .newlines)
                    let safeRange = range.clamped(to: 0...(linesBefore.count - 1))
                    let isNavMode = (self.rootNavID == safeRange.lowerBound)
                    let headerPadding = String(linesBefore[safeRange.lowerBound].prefix(while: { $0 == " " || $0 == "\t" }))
                    var finalLines: [String] = []
                    if isNavMode {
                        finalLines.append(linesBefore[safeRange.lowerBound])
                        let contentPadding = headerPadding + "\t"
                        finalLines.append(contentsOf: newValue.components(separatedBy: .newlines).map { $0.isEmpty ? "" : contentPadding + $0 })
                    } else {
                        finalLines = newValue.components(separatedBy: .newlines).map { $0.isEmpty ? "" : headerPadding + $0 }
                    }
                    var linesArray = linesBefore
                    linesArray.replaceSubrange(safeRange, with: finalLines)
                    self.rawText = linesArray.joined(separator: "\n")
                    self.focusRange = safeRange.lowerBound...(safeRange.lowerBound + finalLines.count - 1)
                }
            )
        }
        
        // --- ARCHIVOS (Restaurado) ---
        func openFile() {
            let panel = NSOpenPanel(); panel.allowedContentTypes = [.swiftSource, .text, .plainText]
            if panel.runModal() == .OK, let url = panel.url { loadExternalFile(from: url) }
        }
        func loadExternalFile(from url: URL) {
            if let content = try? String(contentsOf: url, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.rawText = content; self.currentFileURL = url; self.focusRange = nil
                    self.navStack = []; self.forwardStack = []; self.foldedIds = []
                }
            }
        }
        func saveFile() {
            guard let url = currentFileURL else { saveAsFile(); return }
            try? rawText.write(to: url, atomically: true, encoding: .utf8)
        }
        func saveAsFile() {
            let panel = NSSavePanel(); panel.allowedContentTypes = [.swiftSource, .plainText]
            if panel.runModal() == .OK, let url = panel.url {
                try? rawText.write(to: url, atomically: true, encoding: .utf8)
                self.currentFileURL = url
            }
        }
        
        // --- UTILIDADES ---
        func getDepth(_ line: String) -> Int {
            let prefix = line.prefix(while: { $0 == " " || $0 == "\t" })
            return prefix.reduce(0) { $0 + ($1 == "\t" ? 4 : 1) }
        }
        func dropLeadingVisualWidth(_ line: String, width: Int) -> Substring {
            var currentWidth = 0
            var dropIndex = line.startIndex
            for char in line {
                if currentWidth >= width || (char != " " && char != "\t") { break }
                currentWidth += (char == "\t" ? 4 : 1)
                dropIndex = line.index(after: dropIndex)
            }
            return line[dropIndex...]
        }
        func runCurrentScope() {
            let codeLines = focusedText.wrappedValue.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).hasSuffix(":") }
            let tmpURL = fm.temporaryDirectory.appendingPathComponent("temp_run.swift")
            try? codeLines.joined(separator: "\n").write(to: tmpURL, atomically: true, encoding: .utf8)
            let process = Process(); process.executableURL = URL(fileURLWithPath: "/usr/bin/env"); process.arguments = ["swift", tmpURL.path]
            let pipe = Pipe(); process.standardOutput = pipe; process.standardError = pipe
            try? process.run(); process.waitUntilExit()
            if let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) {
                DispatchQueue.main.async { self.consoleOutput = output.isEmpty ? "Finalizado" : output }
            }
        }
    }

    // MARK: - CodepaperView
    
    
    struct CodepaperView: View {
        @ObservedObject var engine: TaskPaperEngine
        
        var body: some View {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Button(action: { engine.goBack() }) { Image(systemName: "chevron.left") }
                                .buttonStyle(.plain).disabled(engine.navStack.isEmpty).keyboardShortcut(.leftArrow, modifiers: .command)
                            Button(action: { engine.goForward() }) { Image(systemName: "chevron.right") }
                                .buttonStyle(.plain).disabled(engine.forwardStack.isEmpty).keyboardShortcut(.rightArrow, modifiers: .command)
                        }
                        Text(engine.currentScopeName ?? "OUTLINE").font(.caption).bold().foregroundColor(.secondary)
                        Spacer()
                    }.padding().frame(height: 50)
                    
                    List {
                        if engine.navStack.isEmpty {
                            HStack {
                                Color.clear.frame(width: 12)
                                Text("Home").font(.system(.callout, design: .monospaced)).fontWeight(engine.focusRange == nil ? .bold : .regular)
                            }.contentShape(Rectangle()).onTapGesture { engine.focusRange = nil }
                        }
                        ForEach(engine.navigationNodes, id: \.id) { node in
                            navigationRow(node: node).padding(.leading, CGFloat(node.visualLevel * 14))
                        }
                    }
                }.frame(width: 250).background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: engine.runCurrentScope) { Image(systemName: "play.fill") }.keyboardShortcut("r", modifiers: .command)
                    }.padding([.top, .horizontal])
                    
                    TextEditor(text: engine.focusedText)
                        .font(.system(.body, design: .monospaced)).scrollContentBackground(.hidden).padding()
                    Divider()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("CONSOLE").font(.caption).bold().padding([.top, .leading])
                        TextEditor(text: .constant(engine.consoleOutput)).font(.system(.subheadline, design: .monospaced)).scrollContentBackground(.hidden).padding(8).frame(height: 150).background(Color.black.opacity(0.05))
                    }
                }
            }.frame(minWidth: 900, minHeight: 600).onOpenURL(perform: engine.loadExternalFile)
        }
        
        func navigationRow(node: (id: Int, text: String, depth: Int, visualLevel: Int, hasChildren: Bool)) -> some View {
            let isFolded = engine.foldedIds.contains(node.id)
            let isFocused = engine.focusRange?.lowerBound == node.id
            return HStack(spacing: 4) {
                Group {
                    if node.hasChildren {
                        Image(systemName: isFolded ? "chevron.right" : "chevron.down").font(.system(size: 8, weight: .black)).foregroundColor(.secondary).frame(width: 12, height: 24).contentShape(Rectangle()).onTapGesture { engine.toggleFold(node.id) }
                    } else { Color.clear.frame(width: 12, height: 24) }
                }
                Text(node.text).font(.system(.callout, design: .monospaced)).fontWeight(isFocused ? .bold : .regular).frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle()).onTapGesture { engine.setFocus(at: node.id) }
                    .simultaneousGesture(TapGesture(count: 2).onEnded { engine.setFocus(at: node.id); engine.navigateTo(node.id) })
            }.frame(height: 24)
        }
    }

// preview:
    import SwiftUI
    import UIKit
    import CryptoKit
    
    // 1. Representable para mostrar el UIViewController compilado
    struct ViewControllerRepresentable: UIViewControllerRepresentable {
        let vc: UIViewController
        func makeUIViewController(context: Context) -> UIViewController { vc }
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }

    // 2. Wrapper para NSCache
    class CachedVC: NSObject {
        let vc: UIViewController
        init(_ vc: UIViewController) { self.vc = vc }
    }

    struct ContentView: View {
        @State private var code: String = """
    import SwiftUI
    
    struct MiVista: View {
        @State private var count = 0
        var body: some View {
            VStack(spacing: 30) {
                Text("Contador: \\(count)")
                    .font(.title)
                
                Button("Incrementar") {
                    count += 1
                }
            }
        }
    }
    """
        @State private var remoteVC: UIViewController?
        @State private var errorMessage: String = ""
        @State private var compilationID = UUID()
        @State private var isCompiling = false
        @State private var isTaskRunning = false
        
        private let cache = NSCache<NSString, CachedVC>()
        
        var body: some View {
            HStack(spacing: 0) {
                // EDITOR
                VStack(spacing: 0) {
                    TextEditor(text: $code)
                        .frame(minWidth: 350)
                        .autocorrectionDisabled(true)
                        .keyboardType(.asciiCapable) // Fuerza teclado estándar
                        .textInputAutocapitalization(.never)
                    
                    if !errorMessage.isEmpty {
                        ScrollView {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 11, design: .monospaced))
                                .padding()
                        }
                        .frame(height: 150)
                        .background(Color(UIColor.secondarySystemBackground))
                    }
                    
                    HStack {
                        if isCompiling {
                            ProgressView().padding(.leading)
                        }
                        Spacer()
                        Button("Renderizar (Cmd+R)") {
                            handleRKey()
                        }
                        .keyboardShortcut("r", modifiers: .command)
                        .padding()
                    }
                }
                .frame(width: 450)
                
                Divider()
                
                // PREVIEW (Simulador iPhone)
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                    if let vc = remoteVC {
                        ViewControllerRepresentable(vc: vc)
                            .id(compilationID)
                            .frame(width: 393, height: 852)
                            .background(Color(UIColor.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.black, lineWidth: 10))
                            .shadow(radius: 30)
                    } else {
                        Text("Escribe código y pulsa Cmd+R").foregroundColor(.secondary)
                    }
                }
                .frame(minWidth: 500)
            }
        }
        
        // --- Lógica de Compilación ---
        
        func handleRKey() {
            let hash = SHA256.hash(data: Data(code.utf8)).compactMap { String(format: "%02x", $0) }.joined()
            
            if let cached = cache.object(forKey: hash as NSString) {
                print("🚀 Cache Hit!")
                self.remoteVC = cached.vc
                self.compilationID = UUID()
                self.errorMessage = ""
            } else {
                isCompiling = true
                startCompilation(hash: hash)
            }
        }
        
        func startCompilation(hash: String) {
            if isTaskRunning { return }
            isTaskRunning = true
            
            // 1. Extraer nombre de la struct
            let pattern = #"struct\s+(\w+)\s*:\s*View"#
            let regex = try? NSRegularExpression(pattern: pattern)
            let structName = regex?.firstMatch(in: code, range: NSRange(code.startIndex..., in: code))
                .map { String(code[Range($0.range(at: 1), in: code)!]) } ?? "MiVista"
            
            // 2. Preparar archivos temporales
            let ts = Int(Date().timeIntervalSince1970)
            let swiftFile = NSTemporaryDirectory() + "UserCode_\(ts).swift"
            let dylibFile = NSTemporaryDirectory() + "UserCode_\(ts).dylib"
            
            let finalCode = """
    import SwiftUI
    import UIKit
    
    \(code)
    
    @_cdecl("makeUserView")
    public func makeUserView() -> UnsafeMutableRawPointer {
        let vc = UIHostingController(rootView: \(structName)())
        return Unmanaged.passRetained(vc).toOpaque()
    }
    """
            try? finalCode.write(toFile: swiftFile, atomically: true, encoding: .utf8)
            
            DispatchQueue.global(qos: .userInitiated).async {
                // 3. Invocación dinámica de NSTask para evitar SIGABRT en Catalyst
                guard let taskClass = NSClassFromString("NSTask") as? NSObject.Type else {
                    DispatchQueue.main.async { self.errorMessage = "Error: NSTask no disponible"; self.isCompiling = false; self.isTaskRunning = false }
                    return
                }
                
                let task = taskClass.init()
                let sdk = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
                
                // NOTA: Cambia arm64 por x86_64 si estás en un Mac con Intel
                let args = [
                    "-sdk", sdk,
                    "-target", "arm64-apple-ios14.0-macabi",
                    "-F", "\(sdk)/System/iOSSupport/System/Library/Frameworks",
                    "-I", "\(sdk)/System/iOSSupport/usr/include",
                    "-emit-library", "-Onone", "-o", dylibFile, swiftFile
                ]
                
                task.setValue("/usr/bin/swiftc", forKey: "launchPath")
                task.setValue(args, forKey: "arguments")
                
                let errorPipe = Pipe()
                task.setValue(errorPipe, forKey: "standardError")
                
                let launchSelector = NSSelectorFromString("launch")
                let waitUntilExitSelector = NSSelectorFromString("waitUntilExit")
                
                if task.responds(to: launchSelector) {
                    task.perform(launchSelector)
                    task.perform(waitUntilExitSelector)
                    
                    let status = task.value(forKey: "terminationStatus") as? Int32 ?? -1
                    
                    if status == 0 {
                        if let handle = dlopen(dylibFile, RTLD_NOW),
                            let sym = dlsym(handle, "makeUserView") {
                            let f = unsafeBitCast(sym, to: (@convention(c) () -> UnsafeMutableRawPointer).self)
                            let ptr = f()
                                
                            DispatchQueue.main.async {
                                let vc = Unmanaged<UIViewController>.fromOpaque(ptr).takeRetainedValue()
                                self.cache.setObject(CachedVC(vc), forKey: hash as NSString)
                                self.remoteVC = vc
                                self.compilationID = UUID()
                                self.errorMessage = ""
                                self.isCompiling = false
                                self.isTaskRunning = false
                            }
                        }
                    } else {
                        let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        let errStr = String(data: data, encoding: .utf8) ?? "Error desconocido"
                        DispatchQueue.main.async {
                            self.errorMessage = errStr
                            self.isCompiling = false
                            self.isTaskRunning = false
                        }
                    }
                }
            }
        }
    }

    //import Runestone
    //
    //struct TextViewRepresentable: UIViewRepresentable {
    //    func updateUIView(_ uiView: UIViewType, context: Context) {
    //        
    //    }
    //    
    //    
    //    func makeUIView(context: Context) -> some UIView {
    //        let tv = TextView()
    //        setCustomization(on: tv)
    //        return tv
    //    }
    //    
    //    private func setCustomization(on textView: TextView) {
    //        textView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    //        textView.showLineNumbers = true
    //        textView.lineHeightMultiplier = 1.2
    //        textView.kern = 0.3
    //        textView.showSpaces = true
    //        textView.showNonBreakingSpaces = true
    //        textView.showTabs = true
    //        textView.showLineBreaks = true
    //        textView.showSoftLineBreaks = true
    //        textView.isLineWrappingEnabled = false
    //        textView.showPageGuide = true
    //        textView.pageGuideColumn = 80
    //        textView.autocorrectionType = .no
    //        textView.autocapitalizationType = .none
    //        textView.smartQuotesType = .no
    //        textView.smartDashesType = .no
    //    }
    //    
    //    
    //    
    //}

// oc:
    // p12-tally-goals.swift
    
    // TallyGoals/App/Architecture/Actions.swift
    //
    //  Actions.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import ComposableArchitecture
    import CoreData
    
    /// The AppAction enum models the actions of the app
    /// This actions are send to the store by using the send method which take an action as argument
    /// Actions are handle by the reducer
    enum AppAction: Equatable {
        
        // MARK: - CRUD Behaviours
        case createBehaviour(
            id: UUID,
            emoji: String,
            name: String
        )
        
        case readBehaviours
        case makeBehaviourState(_ state: BehaviourState)
        
        case updateBehaviour(
            id: UUID,
            emoji: String,
            name: String
        )
        
        case updateFavorite(id: UUID, favorite: Bool)
        case updateArchive(id: UUID, archive: Bool)
        case updatePinned(id: UUID, pinned: Bool)
        
        case deleteBehaviour(id: UUID)
        
        // MARK: CRUD Entries
        case addEntry(behaviour: UUID)
        case deleteEntry(behaviour: UUID)
        
        case setOverlay(overlay: Overlay?)
    }

    
    // TallyGoals/App/Architecture/Aliases.swift
    //
    //  Aliases.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import ComposableArchitecture
    
    /// As described by pointfree.co:
    /// _A store represents the runtime that powers the application. It is the object that you will pass around to views that need to interact with the application._
    /// AppStore is a typealias to make code cleaner when passing store across views
    typealias AppStore = Store<AppState, AppAction>
    
    /// View store is an observable version of the store. Whenever the store changes,
    /// views "listening" to the viewStore will be updated if needed
    /// AppViewStore is a typealias to make code cleaner when passing viewStore across views
    typealias AppViewStore = ViewStore<AppState, AppAction>
    
    /// Whenever  an action is send to the store,
    /// the app reducer handles it
    typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>
    
    
    // TallyGoals/App/Architecture/Environment.swift
    //
    //  Environment.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import ComposableArchitecture
    
    /// The environment is the depenciens handler
    /// here we declare all the needed dependencies
    struct AppEnvironment {
        let behavioursRepository: BehaviourRepository
    }

    extension AppEnvironment {
        static var instance: AppEnvironment {
            .init(
                behavioursRepository: container.behaviourRepository
            )
        }
    }

    
    // TallyGoals/App/Architecture/Reducer.swift
    import ComposableArchitecture
    import CoreData
    
    /// Whenever  an action is send to the store,
    /// the app reducer handles it
    let appReducer = AppReducer { state, action, env in
        
        switch action {
            
        case .createBehaviour(let id, let emoji, let name):
            return env.behavioursRepository
                .createBehaviour(id: id, emoji: emoji, name: name)
                .catchToEffect()
                .map { _ in AppAction.readBehaviours }
            
        case .readBehaviours:
            state.behaviourState = .loading
            return env.behavioursRepository
            .fetchBehaviours()
            .catchToEffect()
            .map { result in
                var behaviourState: BehaviourState = .idle
                switch result {
                case .success(let behaviours):
                    if behaviours.count > 0 {
                    behaviourState = .success(behaviours)
                    } else {
                        behaviourState = .empty
                    }
                case .failure(let error):
                    behaviourState = .error(error.localizedDescription)
                }
                return .makeBehaviourState(behaviourState)
            }
            
        case .makeBehaviourState(let behaviourState):
            state.behaviourState = behaviourState
            return .none
            
        case .updateFavorite(let id, let favorite):
            return env.behavioursRepository
                .updateFavorite(id: id, favorite: favorite)
                .catchToEffect()
                .map { _ in AppAction.readBehaviours }
            
            
        case .updateArchive(let id, let archived):
            return env.behavioursRepository
                .updateArchived(id: id, archived: archived)
                .catchToEffect()
                .map { _ in AppAction.readBehaviours }
            
            
        case .updatePinned(let id, let pinned):
            return env.behavioursRepository
                .updatePinned(id: id, pinned: pinned)
                .catchToEffect()
                .map { _ in AppAction.readBehaviours }
            
            
        case .updateBehaviour(let id, let emoji, let name):
            return env.behavioursRepository
                .updateBehaviour(id: id, emoji: emoji, name: name)
                .catchToEffect()
                .map { _ in AppAction.readBehaviours }
            
            
        case .deleteBehaviour(let id):
            return env.behavioursRepository
                .deleteBehaviour(id: id)
                .catchToEffect()
                .map { _ in AppAction.readBehaviours }
            
            
        case .deleteEntry(let id):
            return env.behavioursRepository
            .deleteLastEntry(for: id)
            .catchToEffect()
            .map { _ in AppAction.readBehaviours }
            
            
        case .addEntry(let behaviourId):
            return env.behavioursRepository
            .createEntity(for: behaviourId)
            .catchToEffect()
            .map { _ in AppAction.readBehaviours }
            
            
        case .setOverlay(let overlay):
            state.overlay = overlay
            return .none
        }
    }

    
    // TallyGoals/App/Architecture/State.swift
    //
    //  State.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    import ComposableArchitecture
    import CoreData
    import SwiftUI
    
    
    /// The AppState is responsible to holds the states of the app
    /// that are needed in all views.
    /// This allows a view to be automatically be reloaded as a side-effect of an action in other view
    /// which allows for cleaner code (don't need to reload through callbacks/notifications/delegates...)
    struct AppState: Equatable {
        
        var behaviourState: BehaviourState = .idle
        var overlay: Overlay?
    }

    
    
    // TallyGoals/App/Tabbar.swift
    import ComposableArchitecture
    import SwiftUI
    import SwiftUItilities
    import SwiftWind
    
    struct Tabbar: View {
        
        let store: Store<AppState, AppAction>
        @State var selection: Int = 0
        var body: some View {
            
            WithViewStore(store) { viewStore in
                
                TabView(selection: $selection) {
                    
                    
                    HomeScreen(store: store)
                        .navigationTitle("Compteurs")
                        .navigationify()
                        .navigationViewStyle(.stack)
                        .tag(0)
                        .tabItem {
                            Label("Compteurs", systemImage: "house")
                        }
                    
                    ExploreScreen(viewStore: viewStore)
                        .navigationTitle("Découvrir")
                        .navigationify()
                        .navigationViewStyle(.stack)
                        .tag(1)
                        .tabItem {
                            Label("Découvrir", systemImage: "plus.rectangle.fill")
                        }
                    
                    ArchivedScreen(store: store)
                        .navigationTitle("Archive")
                        .navigationify()
                        .navigationViewStyle(.stack)
                        .tag(2)
                        .tabItem {
                            Label("Archive", systemImage: "archivebox")
                        }
                }
                .overlay(overlay(viewStore: viewStore))
            }
        }
        
        @ViewBuilder
        func overlay(viewStore: AppViewStore) -> some View {
            switch viewStore.state.overlay {
            case .exploreDetail(let category):
                PresetCategoryDetailScreen(model: category, viewStore: viewStore)
            case .error(let title, let message):
                ErrorView(title: title, message: message, viewStore: viewStore)
            case .none:
                EmptyView()
            }
        }
    }

    
    // TallyGoals/App/TallyGoalsApp.swift
    //
    //  TallyGoalsApp.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 27/05/2022.
    //
    
    import ComposableArchitecture
    import SwiftUI
    
    
    /// Entry point of the application
    @main
    struct TallyGoalsApp: App {
        
        @AppStorage("showOnboarding") var showOnboarding: Bool = true
        
        init() {
            UIBarButtonItem.hideBackButtonLabel()
            UINavigationBar.setupFonts()
        }
        
        var body: some Scene {
            WindowGroup {
                
                if showOnboarding {
                    OnboardingScreen(store: container.store)
                } else {
                    Tabbar(store: container.store)
                }
            }
        }
    }

    
    // TallyGoals/Data/BehaviourRepository.swift
    import Combine
    import ComposableArchitecture
    import CoreData
    import AVFAudio
    
    final class BehaviourRepository {
        
        private let context: NSManagedObjectContext
        
        init(context: NSManagedObjectContext) {
            self.context = context
        }
        
        func fetchBehaviours() -> Effect<[Behaviour], ErrorCase> {
            Deferred { [context] in
                Future<[Behaviour], ErrorCase> { [context] promise in
                        do {
                            
                            let request: NSFetchRequest<BehaviourEntity> = BehaviourEntity.fetchRequest()
                            let result: [BehaviourEntity] = try context.fetch(request)
                            let behaviours = try result.mapBehaviorsEntities()
                            promise(.success(behaviours))
                            
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                }
            }
            .eraseToEffect()
        }
        
        func createBehaviour(id: UUID, emoji: String, name: String) -> Effect<Void, ErrorCase> {
            Deferred { [context] in
                Future<Void, ErrorCase> { [context] promise in
                    context.perform {
                        do {
                            let entity = BehaviourEntity(context: context)
                            entity.id = id
                            entity.emoji = emoji
                            entity.name = name
                            entity.favorite = false
                            entity.archived = false
                            entity.pinned = false
                            
                            try context.save()
                            promise(.success(()))
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                    }
                }
            }
            .eraseToEffect()
        }
        
        func deleteBehaviour(id: UUID) -> Effect<Void, ErrorCase> {
            Deferred { [context] in
                Future<Void, ErrorCase> { [context] promise in
                    context.perform {
                        do {
                            let idPredicate = NSPredicate(format: "id == %@", id as CVarArg)
                            let behaviourRequest: NSFetchRequest<BehaviourEntity>
                            
                            behaviourRequest = BehaviourEntity.fetchRequest()
                            behaviourRequest.predicate = idPredicate
                            
                            guard let object = try context.fetch(behaviourRequest).first else {
                                promise(.failure(.notFoundEntity))
                                return
                            }
                            
                            context.delete(object)
                            promise(.success(()))
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                    }
                }
            }
            .eraseToEffect()
        }
        
        func updateBehaviour
        (id: UUID, emoji: String, name: String)
        -> Effect<Void, ErrorCase> {
            Deferred { [context] in
                Future<Void, ErrorCase> { [context] promise in
                    context.perform {
                        do {
                            
                            let idPredicate = NSPredicate(format: "id == %@", id as CVarArg)
                            let behaviourRequest: NSFetchRequest<BehaviourEntity>
                            
                            behaviourRequest = BehaviourEntity.fetchRequest()
                            behaviourRequest.predicate = idPredicate
                            
                            guard let object = try context.fetch(behaviourRequest).first else {
                                promise(.failure(.notFoundEntity))
                                return
                            }
                            
                            object.setValue(emoji, forKey: "emoji")
                            object.setValue(name, forKey: "name")
                            try context.save()
                            
                            promise(.success(()))
                            
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                    }
                }
            }
            .eraseToEffect()
        }
        
        func updateArchived
        (id: UUID, archived: Bool) -> Effect<Void, ErrorCase> {
            Deferred { [context] in
                Future<Void, ErrorCase> { [context] promise in
                    context.perform {
                        do {
                            let idPredicate = NSPredicate(format: "id == %@", id as CVarArg)
                            let behaviourRequest: NSFetchRequest<BehaviourEntity>
                            
                            behaviourRequest = BehaviourEntity.fetchRequest()
                            behaviourRequest.predicate = idPredicate
                            
                            guard let object = try context.fetch(behaviourRequest).first else {
                                promise(.failure(.notFoundEntity))
                                return
                            }
                            object.setValue(archived, forKey: "archived")
                            object.setValue(false, forKey: "favorite")
                            object.setValue(false, forKey: "pinned")
                            try context.save()
                            promise(.success(()))
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                    }
                }
            }
            .eraseToEffect()
        }
        
        func updateFavorite
        (id: UUID, favorite: Bool) -> Effect<Void, ErrorCase> {
            Deferred { [context] in
                Future<Void, ErrorCase> { [context] promise in
                    context.perform {
                        do {
                            
                            let idPredicate = NSPredicate(format: "id == %@", id as CVarArg)
                            let behaviourRequest: NSFetchRequest<BehaviourEntity>
                            
                            behaviourRequest = BehaviourEntity.fetchRequest()
                            behaviourRequest.predicate = idPredicate
                            
                            guard let object = try context.fetch(behaviourRequest).first else {
                                promise(.failure(.notFoundEntity))
                                return
                            }
                            
                            object.setValue(favorite, forKey: "favorite")
                            try context.save()
                            promise(.success(()))
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                    }
                }
            }
            .eraseToEffect()
        }
        
        func updatePinned
        (id: UUID, pinned: Bool) -> Effect<Void, ErrorCase> {
            Deferred { [context] in
                Future<Void, ErrorCase> { [context] promise in
                    context.perform {
                        do {
                            let idPredicate = NSPredicate(format: "id == %@", id as CVarArg)
                            let behaviourRequest: NSFetchRequest<BehaviourEntity>
                            
                            behaviourRequest = BehaviourEntity.fetchRequest()
                            behaviourRequest.predicate = idPredicate
                            
                            guard let object = try context.fetch(behaviourRequest).first else {
                                promise(.failure(.notFoundEntity))
                                return
                            }
                            object.setValue(pinned, forKey: "pinned")
                            try context.save()
                            promise(.success(()))
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                    }
                }
            }
            .eraseToEffect()
        }
        
        func createEntity(for behaviourId: UUID) -> Effect<Void, ErrorCase> {
            Deferred { [context] in
                Future<Void, ErrorCase> { [context] promise in
                    context.perform {
                        do {
                            let idPredicate = NSPredicate(format: "id == %@", behaviourId as CVarArg)
                            let behaviourRequest: NSFetchRequest<BehaviourEntity>
                            
                            behaviourRequest = BehaviourEntity.fetchRequest()
                            behaviourRequest.predicate = idPredicate
                            
                            guard let behaviour = try context.fetch(behaviourRequest).first else {
                                promise(.failure(.notFoundEntity))
                                return
                            }
                            
                            let entry = EntryEntity(context: context)
                            entry.date = Date()
                            behaviour.addToEntries(entry)
                            try context.save()
                            
                            promise(.success(()))
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                    }
                }
            }
            .eraseToEffect()
        }
        
        func deleteLastEntry(for behaviourId: UUID) -> Effect<Void, ErrorCase> {
            Deferred { [context] in
                Future<Void, ErrorCase> { [context] promise in
                    context.perform {
                        
                        do {
                            let idPredicate = NSPredicate(format: "id == %@", behaviourId as CVarArg)
                            let behaviourRequest: NSFetchRequest<BehaviourEntity>
                            
                            behaviourRequest = BehaviourEntity.fetchRequest()
                            behaviourRequest.predicate = idPredicate
                            
                            guard let behaviour = try context.fetch(behaviourRequest).first else {
                                promise(.failure(.notFoundEntity))
                                return
                            }
                            
                            let fetchRequest: NSFetchRequest<EntryEntity>
                            fetchRequest = EntryEntity.fetchRequest()
                            let allEntries = try context.fetch(fetchRequest)
                            
                            let behaviourEntries = allEntries.filter { entry in
                                entry.behaviour == behaviour
                            }
                            
                            if let last = behaviourEntries.last {
                                context.delete(last)
                            }
                            
                            try context.save()
                            
                            promise(.success(()))
                        } catch {
                            promise(.failure(.genericDbError(error.localizedDescription)))
                        }
                        
                    }
                }
            }
            .eraseToEffect()
        }
    }

    
    
    // TallyGoals/Data/Local.swift
    //
    //  Local.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 26/06/2022.
    //
    
    import Foundation
    
    var presetsCategories: [PresetCategory] {
        
        var cat1 = PresetCategory(emoji: "🙏", name: "Religion & Spiritualité")
        
        cat1.presets = [
            Preset(name: "Prières profondes", isFeatured: true),
            Preset(name: "Répetition de mantra: Je pardonne X"),
            Preset(name: "Aider quelqu'un", isFeatured: true),
            Preset(name: "Jeûne")
        ]
        
        var cat2 = PresetCategory(emoji: "💪", name: "Volonté et discipline")
        cat2.presets = [
            Preset(name: "Resister une tentation", isFeatured: true),
            Preset(name: "Recompense retardée", isFeatured: true),
            Preset(name: "Se lever dès que l'alarme sonne"),
            Preset(name: "Faire quelque chose d'intimidant", isFeatured: true),
            Preset(name: "Sortir de la zone de confort", isFeatured: true),
            Preset(name: "Douche froide"),
            Preset(name: "Commencer par la tâche plus difficile"),
            Preset(name: "Resister l'envie d'acheter quelque chose qu'on n'a pas planifié d'acheter"),
            Preset(name: "Resister l'envie de manger quelque chose qu'on n'a pas planifié de manger")
        ]
        
        var cat3 = PresetCategory(emoji: "🌻", name: "Améliorer le monde")
        cat3.presets = [
            Preset(name: "Appeler ses proches"),
            Preset(name: "Aider quelqu'un", isFeatured: true),
            Preset(name: "Faire une action sociale", isFeatured: true)
        ]
        
        
        var cat4 = PresetCategory(emoji: "💧", name: "Clarté mentale")
        cat4.presets = [
        Preset(name: "Planifier le lendemain"),
        Preset(name: "Ranger bureau à la fin de la journée"),
        Preset(name: "Faire la vaiselle juste après manger", isFeatured: true),
        Preset(name: "Éteindre le wifi"),
        Preset(name: "Activité sans multitâche"),
        Preset(name: "Introspecter à la fin de la journée"),
        Preset(name: "Se déconnecter des résaux sociaux au retour du travail")
        ]
        
        var cat5 = PresetCategory(emoji: "💰", name: "Finances personnelles")
        cat5.presets = [
        Preset(name: "Lire un article sur les criptomonnais"),
        Preset(name: "Resister l'envie d'acheter quelque chose qu'on n'a pas planifié d'acheter")
    ]
        
        var cat6 = PresetCategory(emoji: "🙂", name: "Bienêtre")
        cat6.presets = [
        Preset(name: "Faire une promenade"),
        Preset(name: "Dopamine detox"),
        Preset(name: "Jeûne"),
        Preset(name: "Pensée négative automatique", isFeatured: true),
        Preset(name: "Resister envie de mal parler de quelqu'un avec qui on a eu un conflit")
    ]
        
        
        var cat7 = PresetCategory(emoji: "⏰", name: "Gestion du temps")
        cat7.presets = [
        Preset(name: "Se lever à 7:00"),
        Preset(name: "Se coucher à las 22:30")
    ]
        
        var cat8 = PresetCategory(emoji: "🏋", name: "Sport")
        cat8.presets = [
        Preset(name: "Aller en vélo aux travail"),
        Preset(name: "Aller à pied au travail"),
        Preset(name: "Faire du running")
        ]
        
        var cat9 = PresetCategory(emoji: "🥗", name: "Alimentation")
        cat9.presets = [
        Preset(name: "Repas ketogénique"),
        Preset(name: "Repas avec une grande part de salada"),
        Preset(name: "Journée sans sucre", isFeatured: true)
    ]
        
        return [cat1, cat2, cat3, cat4, cat5, cat6, cat7, cat8, cat9]
    }

    
    // TallyGoals/Data/Persistence.swift
    //
    //  Persistence.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 27/05/2022.
    //
    
    import CoreData
    
    struct PersistenceController {
        
        static let shared = PersistenceController()
        
        struct MockBehaviour {
            let id = UUID()
            let emoji: String
            let name: String
            let archived: Bool
            let favorite: Bool
            let pinned: Bool
        }
        
        static var preview: PersistenceController = {
            let result = PersistenceController(inMemory: true)
            let viewContext = result.container.viewContext
            
            let initBehaviours = [
                MockBehaviour(
                    emoji: "💧",
                    name: "Éteindre devices",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "💪",
                    name: "Resister une tentation",
                    archived: false,
                    favorite: true,
                    pinned: true
                ),
                MockBehaviour(
                    emoji: "🥗",
                    name: "Manger keto" ,
                    archived: true,
                    favorite: false,
                    pinned: true
                ),
                MockBehaviour(
                    emoji: "💪",
                    name: "Retarder récompense",
                    archived: false,
                    favorite: false,
                    pinned: true
                ),
                MockBehaviour(
                    emoji: "👔",
                    name: "Repasser vêtements",
                    archived: false,
                    favorite: false,
                    pinned: true
                ),
                MockBehaviour(
                    emoji: "⏰",
                    name: "Se coucher à 22:30",
                    archived: false,
                    favorite: false,
                    pinned: true
                ),
                MockBehaviour(
                    emoji: "💧",
                    name: "Planifier le lendemain",
                    archived: false,
                    favorite: false,
                    pinned: true
                ),
                MockBehaviour(
                    emoji: "🙏",
                    name: "Jeûne",
                    archived: false,
                    favorite: false,
                    pinned: true
                ),
                MockBehaviour(
                    emoji: "💧",
                    name: "Éteindre le wifi",
                    archived: false,
                    favorite: false,
                    pinned: true
                ),
                MockBehaviour(
                    emoji: "⏰",
                    name: "Se lever à 7",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "⏰",
                    name: "Se lever dès que l'alarme sonne",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "🧽",
                    name: "Faire la vaiselle just après manger",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "💧",
                    name: "Activité sans multitask / pratique déliberée",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "🙏",
                    name: "Appeler un proche",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "🙏",
                    name: "Aider quelqu'un",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "🥶",
                    name: "Douches froides",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "🏋️‍♀️",
                    name: "Pompes",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "🏋️‍♀️",
                    name: "Tractions",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
                MockBehaviour(
                    emoji: "🙏",
                    name: "Respirer avant d'agir",
                    archived: false,
                    favorite: false,
                    pinned: false
                ),
            ]
            
    //    initBehaviours.forEach { behaviour in
    //      let entity = BehaviourEntity(context: viewContext)
    //      entity.id = behaviour.id
    //      entity.emoji = behaviour.emoji
    //      entity.name = behaviour.name
    //      entity.archived = behaviour.archived
    //      entity.favorite = behaviour.favorite
    //      entity.pinned = behaviour.pinned
    //      viewContext.perform {
    //        try! viewContext.save()
    //      }
    //    }
            
            return result
        }()
        
        let container: NSPersistentCloudKitContainer
        
        init(inMemory: Bool = false) {
            
            container = NSPersistentCloudKitContainer(name: "TallyGoals")
            
            if inMemory {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
            
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                        Typical reasons for an error here include:
                        * The parent directory does not exist, cannot be created, or disallows writing.
                        * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                        * The device is out of space.
                        * The store could not be migrated to the current model version.
                        Check the error message to determine what the actual problem was.
                        */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
        }
    }

    
    // TallyGoals/DI/Container.swift
    import CoreData
    let container = Container()
    
    // MARK - Dependency injection, use Swinject instead
    final class Container {
        
        var store: AppStore {
            .init(
                initialState: AppState(),
                reducer: appReducer,
                environment: .instance
            )
        }
        
        var context: NSManagedObjectContext {
    //    PersistenceController.preview.container.viewContext
            PersistenceController.shared.container.viewContext
        }
        
        var behaviourRepository: BehaviourRepository {
            .init(context: context)
        }
    }

    
    // TallyGoals/Domain/Models/Behaviour.swift
    import SwiftUI
    import SwiftWind
    import CoreData
    
    struct Behaviour: Equatable, Identifiable {
        let id: UUID
        var emoji: String
        var name: String
        var pinned: Bool = false
        var archived: Bool = false
        var favorite: Bool = false
        var count: Int
    }

    
    // TallyGoals/Domain/Models/Entry.swift
    import CoreData
    import Foundation
    
    struct Entry: Equatable, Identifiable {
        let id: UUID
        let behaviourId: NSManagedObjectID
        let date: Date
    }

    struct Goal: Equatable, Identifiable {
        let id: NSManagedObjectID
        let behaviourId: NSManagedObjectID
        let timeStamp: Date
        let goal: Int
        let archived: Bool
    }

    struct Presets: Equatable, Identifiable {
        let id: NSManagedObjectID
        let emoji: String
        let name: String
    }

    
    // TallyGoals/Domain/Models/Error.swift
    //
    //  Error.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 26/06/2022.
    //
    
    import Foundation
    
    enum ErrorCase: Error {
        case genericDbError(String)
        case entityLacksProperty
        case notFoundEntity
        
        
        var title: String {
            switch self {
            case .genericDbError(_):
                return "Fetching db error"
            case .entityLacksProperty:
                return "Db entity problem"
            case .notFoundEntity:
                return "Entity not found"
            }
        }
        
        var message: String {
            switch self {
            case .genericDbError(let errorMessage):
                return errorMessage
            case .entityLacksProperty:
                return "Unable to retrieve all the properties for the entity"
            case .notFoundEntity:
                return "Not entity with id"
            }
        }
    }

    
    // TallyGoals/Domain/Models/Overlay.swift
    //
    //  Overlay.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 26/06/2022.
    //
    
    import Foundation
    
    /// Overlay model for presenting a view above the tabBar
    enum Overlay: Equatable {
        case exploreDetail(PresetCategory)
        case error(title: String, message: String)
    }

    
    // TallyGoals/Domain/Models/Presets.swift
    //
    //  Presets.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 19/06/2022.
    //
    
    import Foundation
    
    struct Preset: Identifiable, Equatable {
        var id: String { name }
        let name: String
        let description: String?
        let isFeatured: Bool
        
        init(
            name: String,
            description: String? = nil,
            isFeatured: Bool = false
        ) {
            self.name = name
            self.description = description
            self.isFeatured = isFeatured
        }
    }

    struct PresetCategory: Identifiable, Equatable {
        
        let id: UUID
        let emoji: String
        let name: String
        var presets: [Preset]
        
        init(id: UUID = UUID(), emoji: String, name: String, presets: [Preset] = []) {
            self.id = id
            self.emoji = emoji
            self.name = name
            self.presets = presets
        }
    }

    
    // TallyGoals/Domain/States/BehaviourState.swift
    enum BehaviourState: Equatable {
        case idle
        case loading
        case success([Behaviour])
        case error(String)
        case empty
        
        static
        func make(from array: [Behaviour]) -> BehaviourState {
            if array.isEmpty {
                return .empty
            } else {
                return .success(array)
            }
        }
    }

    
    // TallyGoals/Extensions/Constants/Alerts.swift
    //
    //  Alerts.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    
    extension Alert {
        static func deleteAlert(action: @escaping SimpleAction) -> Alert {
            Alert(
                title: Text("Êtes vous sûr de vouloir éliminer ce compteur?"),
                message: Text("Cette action est définitive"),
                primaryButton: .destructive(Text("Éliminer"), action: action),
                secondaryButton: .default(Text("Cancel"))
            )
        }
    }

    
    // TallyGoals/Extensions/Constants/CGFloat.swift
    //
    //  CGFloat.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 29/05/2022.
    //
    
    import SwiftUI
    
    extension CGFloat {
        static let horizontal = Self.s4
        
        static let pinnedCellSpacing = Self.s2
        static let pinnedCellRadius = Self.s4
        static let swipeActionWidth = Self.s16
        static let swipeActionTotalWidth = Self.swipeActionWidth * 2
        static let swipeActionsThreshold = Self.swipeActionWidth * 4
        static let swipeActionLaunchingOffset = Self.s3
    }

    
    // TallyGoals/Extensions/Constants/Color.swift
    //
    //  Color.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 29/05/2022.
    //
    
    import SwiftUI
    import SwiftWind
    
    extension Color {
        static let behaviourRowBackground = Color(uiColor: .systemBackground)
        static let rowPressedColor: WindColor = .sky
        
        static var defaultBackground = Color(UIColor.secondarySystemBackground)
    }

    
    // TallyGoals/Extensions/Extensions.swift
    import SwiftUI
    
    extension Text {
        
        @ViewBuilder
        static func unwrap(_ optional: String?) -> some View {
            if let safeValue = optional {
                Text(safeValue)
            } else {
                EmptyView()
            }
        }
    }

    extension Text {
        
        func roundedFont(_ style: Font.TextStyle) -> Text {
            self.font(.system(style, design: .rounded))
        }
    }

    extension View {
        func roundedFont(_ style: Font.TextStyle) -> some View {
            self.font(.system(style, design: .rounded))
        }
    }

    
    extension String: Identifiable {
        public var id: String { self }
    }

    extension View {
        
        // MARK: - Move to swiftuitilities
        func navigationify() -> some View {
            NavigationView {
                self
            }
        }
        
        func x(_ value: CGFloat) -> some View {
            self.offset(x: value)
        }
        
        func y(_ value: CGFloat) -> some View {
            self.offset(y: value)
        }
        
        func xy(_ value: CGFloat) -> some View {
            self
            .x(value)
            .y(value)
        }
        
        func bindHeight(to value: Binding<CGFloat>) -> some View {
            self
                .modifier(BindingSizeModifier(value: value, dimension: .height))
            
        }
        
        func bindWidth(to value: Binding<CGFloat>) -> some View {
            self
                .modifier(BindingSizeModifier(value: value, dimension: .width))
        }
        
        
        func highPriorityTapGesture(perform action: @escaping () -> Void) -> some View {
            self.highPriorityGesture(
                TapGesture()
                    .onEnded(action)
            )
        }
        
        func simultaneusLongGesture(perform action: @escaping () -> Void, animated: Bool = true) -> some View {
            self.simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        if animated {
                            withAnimation { action() }
                        } else {
                            action()
                        }
                    }
            )
        }
        
        @ViewBuilder
        func highPriorityTapGesture(if condition: Bool, action: @escaping () -> Void) -> some View {
            if condition {
                self.highPriorityTapGesture(perform: action)
            } else {
                self
            }
        }
        
        @ViewBuilder
        func highPriorityGesture<T>(if condition: Bool, _ gesture: T, including mask: GestureMask = .all) -> some View where T : Gesture {
            if condition {
                self.highPriorityGesture(gesture)
            } else {
                self
            }
        }
    }

    extension View {
        func vibrate(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType = .success) {
            UIImpactFeedbackGenerator.shared.impactOccurred()
        }
    }

    extension ViewModifier {
        func vibrate(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType = .success) {
            UIImpactFeedbackGenerator.shared.impactOccurred()
        }
    }

    struct BindingSizeModifier: ViewModifier {
        
        @Binding var value: CGFloat
        
        let dimension: Dimension
        
        enum Dimension {
            case width
            case height
        }
        
        func body(content: Content) -> some View {
            content.background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        switch dimension {
                        case .width:
                            value = geo.size.width
                        case .height:
                            value = geo.size.width
                        }
                    }
            }
            )
        }
    }

    extension Int {
        var string: String {
            "\(self)"
        }
        
        var cgFloat: CGFloat {
            CGFloat(self)
        }
    }

    extension Int: Identifiable {
        public var id: Self {
            self
        }
    }

    extension Array {
        var isNotEmpty: Bool {
            !self.isEmpty
        }
    }

    extension Array {
        var count: CGFloat {
            self.count.cgFloat
        }
    }

    extension Array {
        func getOrNil(index: Int) -> Element? {
            guard self.indices.contains(index) else { return nil }
            return self[index]
        }
    }

    extension UIBarButtonItem {
        
        /// Hides navigation back button label
        static func hideBackButtonLabel() {
            Self.appearance(
                whenContainedInInstancesOf:
                    [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type])
                .setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal
                )
        }
    }

    extension Bool {
        static var isDarkMode: Bool {
            UITraitCollection.current.userInterfaceStyle == .dark
        }
    }

    typealias NotificationFeedback = UINotificationFeedbackGenerator
    extension NotificationFeedback {
        static let shared = UINotificationFeedbackGenerator()
    }

    
    extension Array where Element == BehaviourEntity {
        
        func mapBehaviorsEntities() throws -> [Behaviour] {
            
            let behaviours: [Behaviour] = try self.map { entity in
                guard
                    let emoji = entity.emoji,
                    let name = entity.name,
                    let id = entity.id
                else {
                    throw ErrorCase.entityLacksProperty
                }
                
                return Behaviour(
                    id: id,
                    emoji: emoji,
                    name: name,
                    pinned: entity.pinned,
                    archived: entity.archived,
                    favorite: entity.favorite,
                    count: entity.entries?.count ?? 0
                )
            }
            
            return behaviours
        }
    }

    
    // TallyGoals/Extensions/SimpleAction.swift
    //
    //  SimpleAction.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import Foundation
    
    typealias SimpleAction = () -> Void
    
    
    // TallyGoals/Extensions/UIImpactFeedbackGenerator.swift
    //
    //  UIImpactFeedbackGenerator.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import UIKit
    
    extension UIImpactFeedbackGenerator {
        
        static var shared: UIImpactFeedbackGenerator {
            UIImpactFeedbackGenerator(style: .medium)
        }
    }

    
    // TallyGoals/Extensions/UINavigationBar.swift
    //
    //  UINavigationBar.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    import UIKit
    
    extension UINavigationBar {
        
        /// Setups default fonts for the navigation bar
        static func setupFonts() {
            var largeTitleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
            let largeTitleDescriptor = largeTitleFont.fontDescriptor.withDesign(.rounded)?
            .withSymbolicTraits(.traitBold)
            
            largeTitleFont = UIFont(descriptor: largeTitleDescriptor!, size: largeTitleFont.pointSize)
            
            var inlineFont = UIFont.preferredFont(forTextStyle: .body)
            let inlineDescriptor = inlineFont.fontDescriptor.withDesign(.rounded)?
                .withSymbolicTraits(.traitBold)
            
            inlineFont = UIFont(descriptor: inlineDescriptor!, size: inlineFont.pointSize)
            
            UINavigationBar.appearance().largeTitleTextAttributes = [.font : largeTitleFont]
            UINavigationBar.appearance().titleTextAttributes = [.font: inlineFont]
        }
    }

    
    // TallyGoals/Screens/Add/AddScreen.swift
    import Combine
    import ComposableArchitecture
    import SwiftUI
    
    struct AddScreen: View {
        @Environment(\.presentationMode) var presentationMode
        let store: Store<AppState, AppAction>
        
        @State var emoji: String = ""
        @State var name : String = ""
        
        var body: some View {
            WithViewStore(store) { viewStore in
                
                Form {
                    
                    EmojiTextField("Emoji", text: $emoji)
                    TextField("Titre",   text: $name)
                }
                .toolbar { 
                    Text("Enregistrer")
                        .onTap {
                            viewStore.send(
                                .createBehaviour(
                                    id: UUID(),
                                    emoji: emoji, 
                                    name: name
                                ))
                            pop()
                        }
                        .disabled(
                            emoji.isEmpty || name.isEmpty
                        )
                }
                
            }
            .onTapDismissKeyboard()
        }
        
        func pop() {
            presentationMode.wrappedValue.dismiss()
        }
    }

    
    
    // TallyGoals/Screens/Archive/ArchivedScreen.swift
    import ComposableArchitecture
    import SwiftUI
    
    struct ArchivedScreen: View {
        
        let store: Store<AppState, AppAction>
        
        var body: some View {
            WithViewStore(store) { viewStore in
                
                switch viewStore.state.behaviourState {
                case .idle, .loading:
                    ProgressView()
                case .success(let model):
                    let model = getArchived(from: model)
                    
                    if model.isEmpty {
                        ListEmptyView(symbol: "archivebox")
                    } else { 
                        LazyVStack {
                            ForEach(model) { item in
                                BehaviourRow(
                                    model: item,
                                    archived: true,
                                    viewStore: viewStore
                                )
                            }
                            
                            Spacer()
                        }
                        
                        .scrollify()
                    }
                case .empty:
                    ListEmptyView(symbol: "archivebox")
                case .error(let message):
                    Text(message)
                }
            }
        } 
        
        func getArchived(from behaviourList: [Behaviour]) -> [Behaviour] {
            behaviourList.filter { $0.archived }
        }
    }

    
    // TallyGoals/Screens/Edit/BehaviourEditScreen.swift
    import ComposableArchitecture
    import SwiftUI
    
    struct BehaviourEditScreen: View {
        
        @Environment(\.presentationMode) var presentationMode
        let viewStore: AppViewStore
        let item: Behaviour
        
        @State var emoji: String
        @State var name: String
        
        var body: some View {
                VStack {
                    
                    Form { 
                        
                        Section { 
                            TextField("Emoji", text: $emoji)
                                .onChange(of: emoji) { newValue in
                                    emoji = String(newValue.prefix(1))
                                }
                            TextField("Titre", text: $name)
                        }
                    }
                    
                }
                .toolbar { 
                    Text("Enregistrer")
                        .onTap {
                            viewStore.send(
                                .updateBehaviour(
                                    id: item.id, 
                                    emoji: emoji,
                                    name: name
                                ))
                            pop()
                        }
                        .disabled(
                            emoji == item.emoji && name == item.name
                        )
                }
        }
        
        func pop() {
            presentationMode.wrappedValue.dismiss()
        }
    }

    
    // TallyGoals/Screens/Explore/ExplorePresetCard.swift
    //
    //  ExplorePresetCard.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 19/06/2022.
    //
    
    import SwiftUI
    import SwiftWind
    
    struct ExplorePresetCard: View {
        
        @State var showDetail = false
        let model: PresetCategory
        let viewStore: AppViewStore
        
        var body: some View {
    //    Color.clear
    //    .background(.thinMaterial)
            background
            .cornerRadius(.s3)
            .aspectRatio(1, contentMode: .fit)
            .overlay(labelStack)
            .onTap {
                viewStore.send(.setOverlay(overlay: .exploreDetail(model)))
                
            }
            .buttonStyle(.plain)
            .navigationLink(detailScreen, $showDetail)
        }
        
        
        
        var background: some View {
            VerticalLinearGradient(colors: [
                .isDarkMode ? WindColor.zinc.c600 : WindColor.zinc.c100,
                .isDarkMode ? WindColor.zinc.c700 : WindColor.zinc.c200
            ])
        }
        
        var detailScreen: some View {
            PresetCategoryDetailScreen(model: model, viewStore: viewStore)
        }
        
        var labelStack: some View {
            VStack(spacing: .s6) {
                Text(model.emoji)
    //      .font(.system(size: .s14))
                .font(.largeTitle)
                Text(model.name)
                .roundedFont(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .s28)
                .multilineTextAlignment(.center)
            }
        }
    }

    
    // TallyGoals/Screens/Explore/ExploreScreen.swift
    //
    //  ExploreScreen.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 13/06/2022.
    //
    
    import SwiftUI
    import SwiftUItilities
    import SwiftWind
    
    
    
    
    struct ExploreScreen: View {
        @State var showDetail = false
        @GestureState var isPressed = false
        
        @Namespace var namespace
        let viewStore: AppViewStore
        
        
        private let columns = [
            GridItem(.flexible(), spacing: .s4),
            GridItem(.flexible(), spacing: .s4)
        ]
        
        let feauredModel = presetsCategories.map { presetCategory in
            return (presetCategory, presetCategory.presets.filter { $0.isFeatured })
        }
        
        var body: some View {
                DefaultVStack {
                    
                    LazyVGrid(columns: columns, spacing: .s4) {
                        
                        ForEach(presetsCategories) { category in
                            ExplorePresetCard(model: category, viewStore: viewStore)
                        }
                    }
                }
                .horizontal(.s4)
                .vertical(.s6)
                .scrollify()
        }
    }

    
    // TallyGoals/Screens/Explore/PresetCategoryDetailScreen.swift
    //
    //  PresetCategoryDetailScreen.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 19/06/2022.
    //
    
    import SwiftUI
    import SwiftUItilities
    
    struct PresetCategoryDetailScreen: View {
        
        let model: PresetCategory
        let viewStore: AppViewStore
        
        var body: some View {
            VStack {
                Text(model.emoji)
                    .top(.s6)
                    .font(.largeTitle)
                Text(model.name)
                    .roundedFont(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .top(.s2)
                
                DefaultVStack {
                    ForEach(model.presets) { preset in
                        PresetRow(
                            emoji: model.emoji,
                            model: preset,
                            viewStore: viewStore
                        )
                        .padding(.s3)
                    }
                }
                .horizontal(.horizontal)
            }
            .scrollify()
            .overlay(
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .size(.s5)
                    .onTap {
                        viewStore.send(.setOverlay(overlay: nil))
                    }
                    .buttonStyle(.plain)
                    .padding(.s4)
                ,alignment: .topTrailing
            )
            .background(
                Color.clear.background(.thinMaterial)
            )
        }
    }

    
    // TallyGoals/Screens/Explore/PresetRow.swift
    //
    //  PresetRow.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 19/06/2022.
    //
    
    import SwiftUI
    import SwiftWind
    
    struct PresetRow: View {
        
        @State var added: Bool = false
        
        let emoji: String
        let model: Preset
        let viewStore: AppViewStore
        
        var body: some View {
            HStack {
                Text(model.name)
                    .roundedFont(.body)
                Spacer()
                addButton
            }
        }
        
        var addButton: some View {
            Text(added ? "Rajouté".uppercased() : "Rajouter".uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .vertical(.s1h)
                .horizontal(.s3)
                .background(background.cornerRadius(.s60))
                .onTap {
                    viewStore.send(
                        .createBehaviour(
                            id: UUID(),
                            emoji: emoji,
                            name: model.name
                        )
                    )
                    added = true
                }
                .disabled(added)
                .animation(.spring(), value: added)
        }
        
        @ViewBuilder
        var background: some View {
            .isDarkMode ? WindColor.neutral.c600 : WindColor.neutral.c100
        }
    }

    
    
    // TallyGoals/Screens/Goals/GoalsScreen.swift
    import ComposableArchitecture
    import SwiftUI
    
    struct GoalRow: View {
        
        @State var done: Int = .zero
        let goal: Int = 20
        
        private var goalLabel: String {
            done.string + " / " + goal.string
        }
        
        private var progression: Double {
            Double(done) / Double(goal)
        }
        
        var body: some View {
            
            VStack {
                HStack {
                    Text("⏰")
                    
                    Text("Levantarse a las 7:00 AM")
                    
                    
                    Spacer()
                    Text(goalLabel)
                    
                }
                .font(.caption)
                
                GeometryReader { geo in
                    Rectangle()
                        .foregroundColor(Color(UIColor.secondarySystemBackground))
                        .height(1)
                        .overlay(
                            Rectangle()
                                .width(geo.size.width * progression)
                                .foregroundColor(.blue300)
                                .height(1),
                            alignment: .leading
                        )
                }
            }
            //.vertical(8)
            .onTap {
                withAnimation { done += 1 }
            }
            .buttonStyle(.plain)
            
        }
    }

    struct LongTermGoalRow: View {
        
        @State var done: Int = .zero
        let goal: Int = 80
        
        private var goalLabel: String {
            done.string + " / " + goal.string
        }
        
        private var progression: Double {
            Double(done) / Double(goal) 
        }
        
        private var level: Int {
            Int(Double(done) / Double(goal) * 10) 
        }
        
        var body: some View {
            HStack {
                Circle()
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 2.0, 
                            lineCap: .round, 
                            lineJoin: .round)
                    )
                    .foregroundColor(Color.defaultBackground)
                    .size(50)
                    .overlay(
                        Image(level.string)
                            .resizable()
                            .size(40)
                            .clipShape(Circle())
                    )
                    .overlay(
                        Circle()
                            .trim(
                                from: 0.0, 
                                to: CGFloat(min(progression, 1.0)
                                                        )
                            )
                            .stroke(
                                style: StrokeStyle(
                                    lineWidth: 2.0, 
                                    lineCap: .round, 
                                    lineJoin: .round)
                            )
                            .foregroundColor(.blue300)
                            .rotationEffect(Angle(degrees: 270.0))
                        
                    )
                
                
                Text("💧 Behaviour name")
                
                Spacer()
                
                Text(goalLabel)
            }
            .font(.caption)
            .onTap {
                withAnimation {
                    done += 1
                }
            }
            .buttonStyle(.plain)
        }
        
        var levelBadge: some View {
            Text("Lvl \(level)")
                .fontWeight(.bold)
                .font(.caption2)
                .foregroundColor(.blue300)
                .horizontal(4)
                .background(
                    Color(UIColor.secondarySystemBackground)
                        .cornerRadius(12)
                )
                .x(4)
                .y(4)
        }
    }

    struct GoalsScreen: View {
        @State var selection: Int = .zero
        let store: AppStore
        
        var body: some View {
            WithViewStore(store) { viewStore in
                
                LazyVStack {
                    
                    Picker("What is your favorite color?", selection: $selection) {
                        
                        Text("Short term").tag(0)
                        Text("Long term").tag(1)
                        
                    }
                    .pickerStyle(.segmented)
                    .bottom(24)
                    
                    switch selection {
                    case 0:
                        ForEach(1...10, id: \.self) { int in
                            GoalRow()
                        }
                    case 1:
                        ForEach(1...10, id: \.self) { int in
                            LongTermGoalRow()
                        }
                    default: EmptyView()
                    }
                    
                    
                    
                }
                .horizontal(24)
                .bottom(24)
                .scrollify()
                
                
            }
            .navigationTitle("Goals")    
            .toolbar {
                Image(systemName: "plus")
                    .onTap(navigateTo: AddGoalScreen(store: store)) 
            }
        }
        
        
    }

    struct AddGoalScreen: View {
        
        @State var count: Int = .zero
        
        let store: AppStore
        
        var body: some View {
            WithViewStore(store) { viewStore in
                VStack {
                    HStack {
                        Text("Goal")
                        Spacer()
                        Text("-")
                            .onTap(perform: decrease)
                        Text(count.string)
                        Text("+")
                            .onTap(perform: increment)
                    }
                    Spacer()
                }
                .horizontal(8)
                .toolbar {
                    Text("Save")
                        .onTap {
                            print("tapped saved button")
                        }
                        .disabled(true)
                }
                
            }
        }
        
        func decrease() {
            guard count > 0 else { return }
            count -= 1
        }
        
        func increment() {
            count += 1
        }
    }

    
    // TallyGoals/Screens/Home/ArrayFilters.swift
    //
    //  ArrayFilters.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 29/05/2022.
    //
    
    import Foundation
    
    extension Array where Element == Behaviour {
        
        var defaultFilter: Self {
            self
                .filter { !$0.archived }
                .filter { !$0.pinned }
                .sorted(by: { $0.name < $1.name })
                .sorted(by: { $0.emoji < $1.emoji })
        }
        
        var pinnedFilter: Self {
            self
                .filter { !$0.archived }
                .filter { $0.pinned }
                .sorted(by: { $0.name < $1.name })
                .sorted(by: { $0.emoji < $1.emoji })
        }
    }

    
    // TallyGoals/Screens/Home/Grid/BehaviourCard.swift
    //
    //  BehaviourCard.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    import SwiftWind
    import SwiftUItilities
    
    struct BehaviourCard: View {
        
        @State var showEditingScreen = false
        @State var showDeletingAlert = false
        
        let model: Behaviour
        let viewStore: AppViewStore
        
        var body: some View {
                background
                .cornerRadius(.s4)
                .aspectRatio(1, contentMode: .fill)
                .overlay(
                    Text(model.emoji)
                    .font(.caption)
                    .padding()
                    , alignment: .topTrailing
                )
    //      .overlay(chevronIcon, alignment: .topLeading)
                .overlay(labelStack, alignment: .bottomLeading)
                .onTap(perform: increase)
                .buttonStyle(.plain)
                .contextMenu { contextMenuContent }
                .navigationLink(editScreen, $showEditingScreen)
                .alert(isPresented: $showDeletingAlert) { .deleteAlert(action: delete) }
        }
        
        @ViewBuilder
        var contextMenuContent: some View {
            Label("Unpin", systemImage: "pin").onTap(perform: unpin)
            Label("Decrease", systemImage: "minus.circle").onTap(perform: decrease).displayIf(model.count > 0)
            Label("Edit", systemImage: "pencil").onTap(perform: goToEditScreen)
            Label("Archive", systemImage: "archivebox").onTap(perform: archive)
            
            Button(role: .destructive) {
                showDeletingAlert = true
            } label: {
                Label("Delete", systemImage: "trash").onTap {}
            }
        }
        
    //  var chevronIcon: some View {
    //    Image(systemName: "chevron.right")
    //    .foregroundColor(WindColor.gray.c400)
    //    .padding(.s3)
    //    .displayIf(viewStore.state.isEditingMode)
    //  }
        
        var labelStack: some View {
            DefaultVStack {
                Text(model.count.string)
                    .fontWeight(.bold)
                    .font(.system(.title2, design: .rounded))
                Text(model.name)
                    .fontWeight(.bold)
                    .font(.system(.caption, design: .rounded))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(.isDarkMode ? .white : WindColor.zinc.c700)
            .padding(.s3)
        }
        
        var editScreen: some View {
            BehaviourEditScreen(
                viewStore: viewStore,
                item: model,
                emoji: model.emoji,
                name: model.name
            )
        }
        
        var background: some View {
            VerticalLinearGradient(colors: [
                .isDarkMode ? WindColor.zinc.c600 : WindColor.zinc.c100,
                .isDarkMode ? WindColor.zinc.c700 : WindColor.zinc.c200
            ])
        }
        
        func delete() {
            viewStore.send(.deleteBehaviour(id: model.id))
        }
        
        func goToEditScreen() {
            showEditingScreen = true
        }
        
        func archive() {
            viewStore.send(.updateArchive(id: model.id, archive: true))
        }
        
        func unpin() {
            viewStore.send(.updatePinned(id: model.id, pinned: false))
        }
        
        func decrease() {
            vibrate()
            viewStore.send(.deleteEntry(behaviour: model.id))
        }
        
        func increase() {
            vibrate()
            viewStore.send(.addEntry(behaviour: model.id))
        }
    }

    
    // TallyGoals/Screens/Home/Grid/BehaviourGrid.swift
    import Algorithms
    import ComposableArchitecture
    import SwiftUI
    import SwiftUItilities
    import SwiftWind
    
    struct BehaviourGrid: View {
        
        @State private var page: Int = .zero
        @State private var cellHeight: CGFloat = .zero
        
        let model: [Behaviour]
        let store: AppStore
        
        
        private let columns = [
            GridItem(.flexible(), spacing: .pinnedCellSpacing),
            GridItem(.flexible(), spacing: .pinnedCellSpacing),
            GridItem(.flexible(), spacing: .pinnedCellSpacing)
        ]
        
        private var tabViewHeight: CGFloat {
            let numberOfRows: CGFloat = 2
            return cellHeight * numberOfRows + .pinnedCellSpacing
        }
        
        private var chunkedModel: [[Behaviour]] {
            model.chunks(ofCount: 6).map(Array.init)
        }
        
        var body: some View {
            WithViewStore(store) { viewStore in
                
                if model.count > 3 {
                TabView(selection: $page) {
                    ForEach(0...chunkedModel.count - 1) { index in
                        let chunk = chunkedModel[index]
                        grid(model: chunk, viewStore: viewStore)
                        .horizontal(.horizontal)
                    }
                    
                }
                .height(tabViewHeight)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .overlay(indexView, alignment: .bottomTrailing)
                    
                } else {
                    grid(
                        model: model,
                        viewStore: viewStore,
                        addFillers: false
                    )
                    .horizontal(.horizontal)
                }
            }
            .animation(.easeInOut, value: model)
        }
        
        var indexView: some View {
                PagerIndexView(
                    currentIndex: page,
                    maxIndex: chunkedModel.count - 1
                )
                .x(-.horizontal)
                .y(.s4)
                .displayIf(chunkedModel.count > 1)
        }
        
        func grid(model: [Behaviour], viewStore: AppViewStore, addFillers: Bool = true) -> some View {
            LazyVGrid(columns: columns, alignment: .leading, spacing: .pinnedCellSpacing) {
                ForEach(model) { item in
                    BehaviourCard(model: item, viewStore: viewStore)
                        .bindHeight(to: $cellHeight)
                }
                
                if addFillers {
                    fills(delta: 6 - model.count)
                }
            }
        }
        
        @ViewBuilder
        func fills(delta: Int) -> some View {
            if delta > 0 {
                
                ForEach(1...delta) { _ in
                    emptyCell
                }
            }
        }
        
        var emptyCell: some View {
            Color.clear
            .aspectRatio(1, contentMode: .fill)
        }
    }

    
    
    // TallyGoals/Screens/Home/HomeScreen.swift
    import Algorithms
    import ComposableArchitecture
    import CoreData
    import SwiftUI
    import SwiftUItilities
    import SwiftWind
    
    struct HomeScreen: View {
        
        let store: Store<AppState, AppAction>
        @State var emoji = ""
        var body: some View {
            
            WithViewStore(store) { viewStore in
                
                VStack {
                    switch viewStore.state.behaviourState {
                    case .idle, .loading:
                        progressView(viewStore: viewStore)
                    case .success(let model):
                        
                        
                        DefaultVStack {
                            
                            BehaviourGrid(
                                model: model.pinnedFilter,
                                store: store
                            )
                            .top(.s6)
                            .displayIf(model.pinnedFilter.isNotEmpty)
                            
                                LazyVStack(spacing: 0) {
                                    ForEach(model.defaultFilter) { item in
                                        BehaviourRow(
                                            model: item,
                                            viewStore: viewStore
                                        )
                                    }
                                }
                                .background(Color.behaviourRowBackground)
                                .top(model.pinnedFilter.isEmpty ? .zero : .s4)
                                .bottom(.s6)
                                .animation(.easeInOut, value: model.defaultFilter)
                            
                            
                        }
                        .scrollify()
                        .onTapDismissKeyboard()
                        .overlay(
                            emptyView.displayIf(model.defaultFilter.isEmpty && model.pinnedFilter.count <= 3)
                        )
                        
                    case .empty:
                        emptyView
                    case .error(let message):
                        Text(message)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Image(systemName: "plus")
                            .onTap {
                                AddScreen(store: store)
                            }
                    }
                }
            }
        }
    }

    
    // MARK: - UI components
    private extension HomeScreen {
        
        func progressView
        (viewStore: AppViewStore) -> some View {
            ProgressView()
                .onAppear {
                    viewStore.send(.readBehaviours)
                }
        }
        
        var emptyView: some View {
            ListEmptyView(symbol: "house")
        }
    }

    
    
    // TallyGoals/Screens/Home/Row/BehaviourRow.swift
    //
    //  BehaviourRow.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 27/05/2022.
    //
    
    import SwiftUI
    import SwiftUItilities
    import SwiftWind
    import ComposableArchitecture
    
    struct BehaviourRow: View {
        
        @State var showEditScreen = false
        @State var showDeletingAlert = false
        
        let model: Behaviour
        let archived: Bool
        let viewStore: AppViewStore
        
        init(model: Behaviour, archived: Bool = false, viewStore: AppViewStore) {
            self.model = model
            self.viewStore = viewStore
            self.archived = archived
        }
        
        
        var body: some View {
            
            rowCell
                .background(Color.behaviourRowBackground)
                .navigationLink(editScreen, $showEditScreen)
                .sparkSwipeActions(
                    leading: archived ? [] : leadingActions,
                    trailing: trailingActions
                )
                .onTap(perform: increase)
                .buttonStyle(.plain)
                .alert(isPresented: $showDeletingAlert) { .deleteAlert(action: delete) }
        }
        
        var rowCell: some View {
            HStack(spacing: 0) {
                
                Text(model.emoji)
                    .font(.caption2)
                    .grayscale(archived ? 1 : 0)
                
                Text(model.count.string)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .horizontal(.s3)
                
                    Text(model.name)
                        .fontWeight(.bold)
                        .font(.system(.body, design: .rounded))
                        .lineLimit(2)
                
                    Spacer()
            }
            .horizontal(.horizontal)
            .vertical(.s3)
            .overlay(divider, alignment: .bottomTrailing)
        }
    }

    // MARK: - SwipeActions
    private extension BehaviourRow {
        var leadingActions: [SwipeAction] {
            [
                SwipeAction(
                    label: "Épingler",
                    systemSymbol: "pin.fill",
                    action: pin,
                    backgroundColor: .blue500
                ),
                SwipeAction(
                    label: "Éditer",
                    systemSymbol: "pencil",
                    action: goToEditScreen,
                    backgroundColor: .lime600
                ),
                SwipeAction(
                    label: "Réduir d'une unité",
                    systemSymbol: "minus.circle",
                    action: decrease,
                    backgroundColor: .yellow600
                )
            ]
        }
        
        var trailingActions: [SwipeAction] {
            [
                SwipeAction(
                    label: "Effacer",
                    systemSymbol: "trash",
                    action: showAlert,
                    backgroundColor: .red500
                ),
                SwipeAction(
                    label: archived ? "Désarchiver" : "Archiver",
                    systemSymbol: "archivebox",
                    action: archive,
                    backgroundColor: .orange400
                )
            ]
        }
    }

    // MARK: - UI
    private extension BehaviourRow {
        var editScreen: some View {
            BehaviourEditScreen(
                viewStore: viewStore,
                item: model,
                emoji: model.emoji,
                name: model.name
            )
        }
        
        var divider: some View {
            let color = .isDarkMode ? WindColor.gray.c800 : WindColor.gray.c100
            return Rectangle()
                .foregroundColor(color)
                .height(.px)
        }
    }

    // MARK: - Methods
    private extension BehaviourRow {
        
        func increase() {
            vibrate()
            withAnimation {
                guard !archived else { return }
                viewStore.send(.addEntry(behaviour: model.id))
            }
        }
        
        func decrease() {
            guard model.count > 0 else {
                vibrate(.error)
                return
            }
            
            vibrate()
            withAnimation {
                viewStore.send(.deleteEntry(behaviour: model.id))
            }
        }
        
        func goToEditScreen() {
            showEditScreen = true
        }
        
        func pin() {
            viewStore.send(.updatePinned(id: model.id, pinned: true))
        }
        
        func archive() {
            viewStore.send(.updateArchive(id: model.id, archive: !archived))
        }
        
        func delete() {
            viewStore.send(.deleteBehaviour(id: model.id))
        }
        
        func showAlert() {
            showDeletingAlert = true
        }
    }

    
    // TallyGoals/Screens/Onboarding/OnboardingScreen.swift
    //
    //  OnboardingScreen.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 26/06/2022.
    //
    import ComposableArchitecture
    import SwiftUI
    
    struct OnboardingScreen: View {
        @AppStorage("showOnboarding") var showOnboarding: Bool = true
        @State var page: Int = .zero
        let store: AppStore
        private let betterWorldModel = presetsCategories.filter { $0.emoji == "🌻" }.first!
        
        var body: some View {
            
            WithViewStore(store) { viewStore in
                TabView(selection: $page) {
                    
                    VStack(spacing: 0) {
                        
                        Text("Bienvenu a TallyGoals")
                            .roundedFont(.title)
                            .fontWeight(.bold)
                        
                        Text("L'application qui vous aide à améliorer le monde a travers la réeducation du comportement")
                            .top(.s2)
                        
                        Text("Suivant")
                            .top(.s6)
                            .onTap {
                                page += 1
                            }
                        
                    }
                    .tag(0)
                    .horizontal(.horizontal)
                    
                    VStack {
                        Text("Pour utiliser l'application, vous chossirez le(s) comportement(s) que vous souhaitez adopter")
                        
                        Text("Par example:")
                            .fontWeight(.bold)
                            .top(.s2)
                        
                        Text("🙏 Aider quelqu'un")
                        
                        
                        Text("Compris")
                            .onTap { page += 1 }
                            .top(.s6)
                    }
                    .tag(1)
                    .horizontal(.horizontal)
                    
                    VStack {
                        Text("Chaque fois que vous adoptez ce comportement:")
                            .roundedFont(.headline)
                            .fontWeight(.bold)
                        
                        
                        Text("1. Ouvrez l'application")
                            .top(.s2)
                        Text("2. Incrementez le compteur associé")
                        
                        Text("Suivant")
                            .top(.s6)
                            .onTap {
                                page += 1
                            }
                    }
                    .tag(2)
                    .horizontal(.horizontal)
                    
                    
                    VStack {
                        
                        Text("En ce faisant, vous:")
                            .roundedFont(.headline)
                        Text("1. Prenez conscience du comportement, des situations et des opportunités pour l'adopter")
                            .top(.s4)
                        Text("2. Obtenez la satisfaction d'incrementer le compteur")
                            .top(.s1)
                        
                        Text("Compris")
                            .top(.s6)
                            .onTap {
                                page += 1
                            }
                    }
                    .tag(3)
                    .horizontal(.horizontal)
                    
                    VStack {
                        
                        Text("Quelques examples")
                            .roundedFont(.headline)
                        
                        ForEach(betterWorldModel.presets) { item in
                            PresetRow(
                                emoji: "🌻",
                                model: item,
                                viewStore: viewStore
                            )
                        }
                        
                        Text("Compris")
                            .top(.s6)
                            .onTap {
                                showOnboarding = false
                            }
                    }
                    .tag(4)
                    .horizontal(.horizontal)
                }
                
                .roundedFont(.body)
                .multilineTextAlignment(.center)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }

    
    
    
    // TallyGoals/UI/BindingPressStyle.swift
    //
    //  BindingPressStyle.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 19/06/2022.
    //
    
    import SwiftUI
    
    struct BindingPressStyle: ButtonStyle {
        
        @Binding var isPressed: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .onChange(of: configuration.isPressed) { newValue in
                    isPressed = newValue
                }
        }
    }

    
    // TallyGoals/UI/EmojiField.swift
    //
    //  EmojiField.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    
    struct EmojiField: View {
        @Binding var text: String
        let placeholder: String
        
        init(
            _ placeholder: String,
            text: Binding<String>
        ) {
            self._text = text
            self.placeholder = placeholder
        }
        
        var body: some View {
            TextField("Emoji", text: $text)
                .onChange(of: text) { newValue in
                    guard newValue.containsEmoji else {
                        text = ""
                        return
                    }
                    if newValue.count == 2 {
                        text = String(newValue[1])
                    } else {
                        text = String(newValue.prefix(1))
                    }
                }
        }
    }

    extension Character {
            /// A simple emoji is one scalar and presented to the user as an Emoji
            var isSimpleEmoji: Bool {
                    guard let firstScalar = unicodeScalars.first else { return false }
                    return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
            }
        
            /// Checks if the scalars will be merged into an emoji
            var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
        
            var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
    }

    extension String {
            var isSingleEmoji: Bool { count == 1 && containsEmoji }
        
            var containsEmoji: Bool { contains { $0.isEmoji } }
        
            var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
        
            var emojiString: String { emojis.map { String($0) }.reduce("", +) }
        
            var emojis: [Character] { filter { $0.isEmoji } }
        
            var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
    }

    
    extension StringProtocol {
            subscript(_ offset: Int)                     -> Element     { self[index(startIndex, offsetBy: offset)] }
            subscript(_ range: Range<Int>)               -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
            subscript(_ range: ClosedRange<Int>)         -> SubSequence { prefix(range.lowerBound+range.count).suffix(range.count) }
            subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
            subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence { prefix(range.upperBound) }
            subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence { suffix(Swift.max(0, count-range.lowerBound)) }
    }

    class UIEmojiTextField: UITextField {
        
            override func awakeFromNib() {
                    super.awakeFromNib()
            }
        
            func setEmoji() {
                    _ = self.textInputMode
            }
        
            override var textInputContextIdentifier: String? {
                            return ""
            }
        
            override var textInputMode: UITextInputMode? {
                var emojiMode: UITextInputMode?
                    for mode in UITextInputMode.activeInputModes {
                            if mode.primaryLanguage == "emoji" {
                                    self.keyboardType = .default // do not remove this
                                    emojiMode = mode
                            }
                    }
                    return emojiMode
            }
    }

    struct EmojiTextField: UIViewRepresentable {
        let placeholder: String
            @Binding var text: String
        
        init(
            _ placeholder: String,
            text: Binding<String>
        ) {
            self._text = text
            self.placeholder = placeholder
        }
        
            func makeUIView(context: Context) -> UIEmojiTextField {
                    let emojiTextField = UIEmojiTextField()
                    emojiTextField.placeholder = placeholder
                    emojiTextField.text = text
                    emojiTextField.delegate = context.coordinator
                    return emojiTextField
            }
        
            func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
                    uiView.text = text
            }
        
            func makeCoordinator() -> Coordinator {
                    Coordinator(parent: self)
            }
        
            class Coordinator: NSObject, UITextFieldDelegate {
                    var parent: EmojiTextField
                
                    init(parent: EmojiTextField) {
                            self.parent = parent
                    }
                
                    func textFieldDidChangeSelection(_ textField: UITextField) {
                            DispatchQueue.main.async { [weak self] in
                                guard let newValue = textField.text else { return }
                                    self?.parent.text = textField.text ?? ""
                                
                                guard newValue.containsEmoji else {
                                    self?.parent.text = ""
                                    return
                                }
                                if newValue.count == 2 {
                                    self?.parent.text = String(newValue[1])
                                } else {
                                    self?.parent.text = String(newValue.prefix(1))
                                }
                                
                            }
                    }
            }
    }

    
    // TallyGoals/UI/ErrorView.swift
    //
    //  ErrorView.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 26/06/2022.
    //
    
    import SwiftUI
    import SwiftUItilities
    
    struct ErrorView: View {
        
        let title: String
        let message: String
        let viewStore: AppViewStore
        
        var body: some View {
            VStack(spacing: 0) {
                Text(title)
                    .roundedFont(.body)
                    .bold()
                
                Text(message)
                .top(.s1)
                
                Text("Ok")
                    .onTap {
                        viewStore.send(.setOverlay(overlay: nil))
                    }
                .top(.s1)
            }
            .padding()
            .width(.s48)
            .cornerRadius(.s6)
            .background(.thinMaterial)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
    }

    
    // TallyGoals/UI/ListEmptyView.swift
    //
    //  ListEmptyView.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 26/06/2022.
    //
    
    import SwiftUI
    struct ListEmptyView: View {
        
        let symbol: String
        
        var body: some View {
            Image(systemName: symbol)
                .resizable()
                .width(50)
                .height(40)
                .foregroundColor(.gray)
                .opacity(0.2)
        }
    }

    
    // TallyGoals/UI/PagerIndexView.swift
    //
    //  PagerIndexView.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    import SwiftWind
    
    struct PagerIndexView: View {
        
        let currentIndex: Int
        let maxIndex: Int
        
        var body: some View {
            HStack {
                ForEach(0...maxIndex) { index in
                    let isSelected = currentIndex == index
                    Circle()
                        .size(.s1)
                        .foregroundColor(foreground(isSelected: isSelected))
                        .animation(.easeInOut, value: isSelected)
                }
            }
            .padding(.s1)
            .animation(.easeInOut, value: maxIndex)
        }
        
        @ViewBuilder
        var background: some View {
            if .isDarkMode {
                WindColor.neutral.c500
            } else {
                WindColor.neutral.c300
            }
        }
        
        func foreground(isSelected: Bool) -> Color {
            if isSelected {
                if .isDarkMode {
                    return WindColor.neutral.c200
                } else {
                    return WindColor.neutral.c500
                }
            } else {
                if .isDarkMode {
                    return WindColor.neutral.c500
                } else {
                    return WindColor.neutral.c200
                }
            }
        }
    }

    
    // TallyGoals/UI/toDo/Legacify/FavoriteScreen.swift
    //import ComposableArchitecture
    //import SwiftUI
    //
    //struct FavoritesScreen: View {
    //  
    //  let store: Store<AppState, AppAction>
    //  
    //  var body: some View {
    //    WithViewStore(store) { viewStore in
    //      
    //      switch viewStore.behaviourState {
    //      case .idle, .loading:
    //        ProgressView()
    //          .onAppear {
    //            viewStore.send(.readBehaviours)
    //          }
    //      case .success(let model):
    //        let model = getFavorites(from: model)
    //        
    //        if model.isEmpty {
    //          ListEmptyView(symbol: "star.fill")
    //        } else {
    //          List(model) { item in
    //            ListRow(
    //              store: store,
    //              item: item
    //            )
    //              .onTap {
    //                withAnimation {
    //                  viewStore.send(
    //                    .addEntry(behaviour: item.id)
    //                  )
    //                }
    //              }
    //              .buttonStyle(.plain)
    //              .swipeActions(edge: .trailing) {
    //                swipeActionStack(
    //                  viewStore: viewStore,
    //                  item: item
    //                )
    //              }
    //              .swipeActions(edge: .leading) {
    //                Label("Pin", systemImage: "pin")
    //                  .onTap {
    //                    withAnimation {
    //                      viewStore.send(.updatePinned(
    //                        id: item.id,
    //                        pinned: !item.pinned
    //                      )
    //                      )
    //                    }
    //                  }
    //                  .tint(item.pinned ? .gray : .indigo)
    //              }
    //          }
    //          .navigationTitle("Favorites")
    //        }
    //      case .empty:
    //        Text("Not items yet")
    //      case .error(let message):
    //        Text(message)
    //      }
    //    }
    //  }
    //  
    //  @ViewBuilder
    //  func swipeActionStack
    //  (viewStore: AppViewStore, item: Behaviour) -> some View {
    //    Label("Favorite", systemImage: "star")
    //      .onTap {
    //        viewStore.send(.updateFavorite(
    //          id: item.id,
    //          favorite: false)
    //        )
    //      }
    //      .tint(.gray)
    //    
    //    Button(role: .destructive) {
    //      withAnimation {
    //        viewStore.send(.deleteBehaviour(id: item.id))
    //      }
    //    } label: {
    //      Label("Delete", systemImage: "trash.fill")
    //    }
    //  }
    //  
    //  func getFavorites
    //  (from behaviourList: [Behaviour]) -> [Behaviour] {
    //    behaviourList
    //      .filter { $0.favorite }
    //      .filter { !$0.archived }
    //      .sorted(by: { $0.emoji < $1.emoji })
    //      .sorted(by: { $0.name < $1.name })
    //      .sorted(by: { $0.pinned && !$1.pinned })
    //  }
    //}
    //
    
    
    
    // TallyGoals/UI/toDo/Legacify/LegacyBehaviourCard.swift
    //import ComposableArchitecture
    //import CoreData
    //import SwiftUI
    //import SwiftUItilities
    //import SwiftWind
    //
    //struct LegacyBehaviourCard: View {
    //  
    //  @State var showEdit: Bool = false
    //  
    //  let model: Behaviour
    //  let store: AppStore
    //  
    //  var body: some View {
    //    WithViewStore(store) { viewStore in
    //      VStack(alignment: .leading) {
    //        Rectangle()
    //          .foregroundColor(Color(UIColor.secondarySystemBackground))
    //          .size(80)
    //          .cornerRadius(8)
    //          .overlay(Text(model.emoji))
    //          .overlay(
    //            
    //            Badge(number: getCount(
    //              behaviourId: model.id, 
    //              viewStore: viewStore
    //            ), color: model.color)
    //              .x(10)
    //              .y(-10)
    //            ,
    //            alignment: .topTrailing
    //            
    //          )
    //          .onTap {
    //            viewStore.send(.addEntry(behaviour: model.id))
    //          }
    //        
    //        
    //        Text(model.name)
    //          .width(80)
    //          .font(.caption)
    //          .lineLimit(2)
    //          .fixedSize(
    //            horizontal: false, 
    //            vertical: true
    //          )
    //          .height(40)
    //        
    //      }
    ////      .background(editLink)
    //      .contextMenu {
    //        Label("Edit", systemImage: "pencil")
    //          .onTap {
    //            showEdit = true
    //          }
    //        Label("Unpin", systemImage: "pin")
    //          .onTap {
    //            viewStore.send(.updatePinned(id: model.id, pinned: false))
    //          }
    //      }
    //    }
    //  }
    //  
    ////  var editLink: some View {
    ////    EmptyNavigationLink(
    ////      destination: behaviourEditScreen,
    ////      isActive: $showEdit
    ////    )
    ////  }
    //  
    ////  var behaviourEditScreen: some View {
    ////    BehaviourEditScreen(
    ////      store: store,
    ////      item: model,
    ////      emoji: model.emoji,
    ////      name: model.name
    ////    )
    ////  }
    //}
    //
    //struct Badge: View {
    //  
    //  let number: Int
    //  let color: WindColor
    //  let small: Bool
    //  let dark: Bool
    //  
    //  init(number: Int, color: WindColor, small: Bool = false, dark: Bool = true) {
    //    self.number = number
    //    self.color = color
    //    self.small = small
    //    self.dark = dark
    //  }
    //  
    //  var body: some View {
    //    Circle()
    //      .foregroundColor(dark ? color.c500 : color.c100)
    //      .size(small ? .s4 : .s5)
    //      .shadow(
    //        color: small ? color.c200 : color.c300,
    //        radius: small ? .px : .s1,
    //        x:  small ? .px : .s05,
    //        y:  small ? .px : .s05
    //      )
    //      .overlay(
    //        Text(number.string)
    //          .font(small ? .caption2 : .caption)
    //          .fontWeight(.bold)
    //          .foregroundColor(dark ? color.c50 : color.c500)
    //      )
    //  }
    //}
    
    
    // TallyGoals/UI/toDo/Legacify/LegacyBehaviourCaroussel.swift
    //import SwiftUI
    //
    //struct LegacyBehaviourCaroussel: View {
    //  
    //  let model: [Behaviour]
    //  let store: AppStore
    //  
    //  var body: some View {
    //    
    //    if model.isEmpty {
    //      EmptyView()
    //    } else {
    //      VStack {
    //        
    //        HStack {
    //          
    //          Spacer()
    //          Text("See all")
    //        }
    //        .horizontal(24)
    //        
    //        HStack(spacing: 12) {
    //          
    //          ForEach(model) { item in
    //            
    //            LegacyBehaviourCard(
    //              model: item, 
    //              store: store
    //            )
    //              .leading(item == model.first ? 24 : 0)
    //              .trailing(item == model.last ? 24 : 0)
    //          }
    //        }
    //        .top(10)
    //        .scrollify(.horizontal)
    //      }
    //    }
    //  }
    //}
    
    
    
    // TallyGoals/UI/toDo/Legacify/LegacyBlinkinCard.swift
    ////
    ////  LegacyBlinkinCard.swift
    ////  TallyGoals
    ////
    ////  Created by Cristian Rojas on 03/06/2022.
    ////
    //import ComposableArchitecture
    //import CoreData
    //import SwiftUI
    //import SwiftWind
    //
    //struct CardView: View {
    //
    //  @GestureState var isPressing = false
    //  @State var isAnimating = false
    //  @State var isDialogPresented = false
    //  @State var isScaling = false
    //
    //  let model: Behaviour
    //  let store: AppStore
    //
    //  var body: some View {
    //    WithViewStore(store) { viewStore in
    //      Group {
    //
    //        ZStack {
    //          
    //          Card(
    //            emoji: model.emoji,
    //            name: model.name,
    //            color: .blue,
    //            behaviourId: model.id,
    //            viewStore: viewStore,
    //            showCount: true
    //          )
    //            .opacity(viewStore.state.isEditingPinned ? 0 : 1)
    //            .opacity(isPressing ? 0.1 : 1)
    //            .scaleEffect(isPressing ? 0.9 : 1)
    //            .animation(.easeInOut(duration: 0.2).repeatCount(1, autoreverses: true), value: isPressing)
    //            .highPriorityGesture(
    //              TapGesture().onEnded {
    //                viewStore.send(.addEntry(behaviour: model.id))
    //              }
    //            )
    //            .simultaneousGesture(
    //              LongPressGesture(minimumDuration: 0.8, maximumDistance: 1)
    //                .updating($isPressing) { currentState, gestureState, transaction in
    //                  gestureState = currentState
    //                }
    //                .onEnded { _ in
    //
    //                  withAnimation {
    //                    viewStore.send(.startEditingPinned)
    //                  }
    //                }
    //            )
    //
    //          if viewStore.state.isEditingPinned {
    //            BlinkinCard(
    //              model: model,
    //              store: store
    //            )
    //          }
    //        }
    //      }
    //    }
    //  }
    //
    //  var regularComponent: some View {
    //    VStack {
    //
    //      Rectangle()
    //        .fill(Color(uiColor: .secondarySystemBackground))
    //        .size(80)
    //        .cornerRadius(12)
    //        .overlay(
    //          Text(model.emoji)
    //        )
    //
    //      let name = model.name.count < 12 ? model.name + "\n" : model.name
    //      Text(name)
    //        .font(.caption2)
    //        .multilineTextAlignment(.center)
    //        .lineLimit(2)
    //        .fixedSize(
    //          horizontal: false,
    //          vertical: true
    //        )
    //    }
    //    .opacity(isPressing ? 0.05 : 1)
    //
    //  }
    //
    //  var blinkingComponent: some View {
    //    regularComponent
    //      .overlay(deleteButton, alignment: .topLeading)
    //      .rotate(isAnimating ? 4 : 0)
    //      .animation(
    //        Animation.linear(duration: 0.1).repeatForever(),
    //        value: isAnimating
    //      )
    //      .onAppear {
    //        isAnimating = true
    //      }
    //  }
    //
    //  @ViewBuilder
    //  var deleteButton: some View {
    //    Circle()
    //      .foregroundColor(.gray200)
    //      .size(20)
    //      .overlay(
    //        Text("—")
    //          .font(.caption)
    //          .foregroundColor(.black)
    //          .fontWeight(.bold)
    //          .y(-1)
    //      )
    //      .x(-6)
    //      .y(-6)
    //      .onTapGesture {
    //        isDialogPresented = true
    //        print("Delete")
    //      }
    //  }
    //
    //}
    //
    //struct BlinkinCard: View {
    //
    //  @State var isAnimating = false
    //  @State var isPresentingDialog = false
    //  @State var showEditView = false
    //  @State var showDeletingAlert = false
    //
    //  let model: Behaviour
    //  let store: AppStore
    //
    //  var body: some View {
    //
    //    WithViewStore(store) { viewStore in
    //      Card(
    //        emoji: model.emoji,
    //        name: model.name,
    //        color: .gray,
    //        behaviourId: model.id,
    //        viewStore: viewStore,
    //        showCount: false
    //      )
    //        .overlay(deleteButton, alignment: .topLeading)
    //        .rotate(isAnimating ? 4 : 0)
    //        .animation(
    //          Animation.linear(duration: 0.1).repeatForever(),
    //          value: isAnimating
    //        )
    ////        .navigationLink(editScreen, $showEditView)
    //        .onTap {
    //          showEditView = true
    //        }
    //        .buttonStyle(.plain)
    //        .onAppear {
    //          isAnimating = true
    //        }
    //        .alert(isPresented: $showDeletingAlert) {
    //          Alert(
    //            title: Text("Are you sure you want to delete the item?"),
    //            message: Text("This action cannot be undone"),
    //            primaryButton: .destructive(Text("Delete"), action: { viewStore.send(.deleteBehaviour(id: model.id))}),
    //            secondaryButton: .default(Text("Cancel"))
    //          )
    //        }
    //        .confirmationDialog("Edit", isPresented: $isPresentingDialog, titleVisibility: .hidden) {
    //          Button("Delete", role: .destructive) {
    //            showDeletingAlert = true
    //          }
    //
    //          Button("Unpin") {
    //
    //            withAnimation {
    //              viewStore.send(.stopEditingPinned)
    //              viewStore.send(.updatePinned(id: model.id, pinned: false))
    //            }
    //          }
    //
    //          Button("Archive") {
    //            viewStore.send(.stopEditingPinned)
    //            viewStore.send(.archive(id: model.id))
    //          }
    //        }
    //    }
    //  }
    //
    //
    //  @ViewBuilder
    //  var deleteButton: some View {
    //    Circle()
    //      .foregroundColor(.gray200)
    //      .size(20)
    //      .overlay(
    //        Text("—")
    //          .font(.caption)
    //          .foregroundColor(.black)
    //          .fontWeight(.bold)
    //          .y(-1)
    //      )
    //      .x(-6)
    //      .y(-6)
    //      .onTapGesture {
    //        //isEditing = false
    //        isPresentingDialog = true
    //        print("Delete")
    //      }
    //  }
    //
    ////  var editScreen: some View {
    ////    BehaviourEditScreen(
    ////      store: store,
    ////      item: model,
    ////      emoji: model.emoji,
    ////      name: model.name
    ////    )
    ////  }
    //
    //}
    //
    //struct Card: View {
    //
    //  let emoji: String
    //  let name: String
    //  let color: WindColor
    //  let behaviourId: NSManagedObjectID
    //  let viewStore: AppViewStore
    //  let showCount: Bool
    //
    //  var safeName: String {
    //    name.count < 15 ? name + "\n" : name
    //  }
    //
    //  var body: some View {
    //
    //    VStack {
    //
    //      Rectangle()
    //        .fill(color.c100)
    //        .size(80)
    //        .cornerRadius(12)
    //        .overlay(Text(emoji))
    //        .overlay(badge(viewStore), alignment: .topTrailing)
    //
    ////      Text(safeName)
    ////        .font(.caption2)
    ////        .multilineTextAlignment(.center)
    ////        .lineLimit(1)
    ////        .fixedSize(
    ////          horizontal: false,
    ////          vertical: true
    ////        )
    //    }
    //  }
    //
    //
    //  func badge(_ viewStore: AppViewStore) -> some View {
    //    Badge(number: 0, color: WindColor.blue)
    //      .x(.s2)
    //      .y(-.s2)
    //      .displayIf(showCount)
    //  }
    //}
    //
    //extension View {
    //  func rotate(_ angles: Double) -> some View {
    //    self.rotationEffect(Angle(degrees: angles))
    //  }
    //}
    //
    
    
    // TallyGoals/UI/toDo/Legacify/ListRow.swift
    //import CoreData
    //import ComposableArchitecture
    //import SwiftUI
    //import SwiftUItilities
    //import SwiftWind
    //
    //
    //
    //struct NewRow: View {
    //  
    //  let model: Behaviour
    //  let color: WindColor
    //  
    //  var body: some View {
    //    VStack {
    //      HStack(alignment: .center) {
    //        
    //        Text("0")
    //          .font(.title)
    //          .fontWeight(.black)
    //        
    //        Text(model.emoji + " " + model.name)
    //          .font(.caption)
    //        
    //        Spacer()
    //        
    //        Rectangle()
    //          .foregroundColor(color.c800)
    //          .size(36)
    //          .overlay(Text("-"))
    //          .cornerRadius(5)
    //        //.trailing(12)
    //        
    //        Rectangle()
    //          .foregroundColor(color.c800)
    //          .size(36)
    //          .overlay(Text("+"))
    //          .cornerRadius(5)
    //      }
    //      .horizontal(24)
    //      .vertical(12)
    //      
    //      Rectangle()
    //        .foregroundColor(color.c700)
    //        .height(1)
    //    }
    //    
    //    .background(color.c900)
    //  }
    //}
    //
    //struct Row: View {
    //  
    //  @State var offset: CGFloat = .zero
    //  @State var showEditScreen = false
    //  @State var isEditing = false
    //  
    //  let model: Behaviour
    //  let store: AppStore
    //  
    //  var body: some View {
    //    WithViewStore(store) { viewStore in
    //      DefaultVStack {
    //        HStack {
    //          Text(model.emoji)
    //          Text(model.name)
    //          Spacer()
    //          Text(getCount(
    //            behaviourId:model.id,
    //            viewStore:viewStore
    //          ))
    //        }
    //        .padding(10)
    //        .background(Color(UIColor.systemBackground))
    //        .offset(x: offset)
    //        .simultaneousGesture(
    //          LongPressGesture()
    //            .onEnded { _ in
    //              //showEditScreen = true
    //              withAnimation {
    //                isEditing.toggle()
    //              }
    //            }
    //        )
    //        .highPriorityGesture(
    //          TapGesture()
    //            .onEnded {
    //              withAnimation {
    //                
    //                NotificationCenter.collapseRowList()
    //                guard offset == 0 else {
    //                  return
    //                }
    //                guard !isEditing else {
    //                  isEditing = false
    //                  return
    //                }
    //                viewStore.send(.addEntry(behaviour: model.id))
    //              }
    //            }
    //        )
    //        .background(
    //          //                    DefaultHStack {
    //          //
    //          //
    //          //                        SwipeActionView(
    //          //                            tintColor: .yellow50,
    //          //                            backColor: .yellow500,
    //          //                            systemSymbol: "pin",
    //          //                            offset: $offset
    //          //                        ) {
    //          //                            viewStore.send(
    //          //                                .updatePinned(id: model.id, pinned: true)
    //          //                            )
    //          //                        }
    //          //
    //          //                        Spacer()
    //          //
    //          //                        SwipeActionView(
    //          //                            tintColor: .orange50,
    //          //                            backColor: .orange500,
    //          //                            systemSymbol: "archivebox",
    //          //                            offset: $offset
    //          //                        ) {
    //          //                            viewStore.send(.updateArchive(id: model.id, archive: true))
    //          //                        }
    //          //
    //          //                        SwipeActionView(
    //          //                            tintColor: .red50,
    //          //                            backColor: .red700,
    //          //                            systemSymbol: "trash",
    //          //                            offset: $offset
    //          //                        ) {
    //          //                            viewStore.send(.deleteBehaviour(id: model.id))
    //          //                        }
    //          //                    }
    //        )
    //        .gesture(
    //          DragGesture()
    //            .onChanged { value in
    //              
    //              let width = value.translation.width
    //              offset = width
    //            }
    //            .onEnded { value in
    //              let width = value.translation.width
    //              
    //              if width > 1 {
    //                withAnimation { offset = 40 }
    //              } else if width < -80 {
    //                withAnimation { offset = -80 }
    //              } else if width < -40 {
    //                withAnimation { offset = -40 }
    //              } else {
    //                withAnimation { offset = 0 }
    //              }
    //            }
    //        )
    //        
    //        if isEditing {
    //          
    //          Rectangle()
    //            .cornerRadius(8)
    //            .height(80)
    //            .horizontal(16)
    //            .bottom(16)
    //            .foregroundColor(.black)
    //        }
    //        
    //        Divider()
    //      }
    //      .onReceive(NotificationCenter.collapseRowNotification) { _ in
    //        guard offset != 0 else { return }
    //        withAnimation { offset = 0 }
    //      }
    //      //            .navigationLink(
    //      //                editScreen,
    //      //                $showEditScreen
    //      //            )
    //    }
    //    
    //  }
    //  
    //  //    var editScreen: some View {
    //  //        BehaviourEditScreen(
    //  //            store: store,
    //  //            item: model,
    //  //            emoji: model.emoji,
    //  //            name: model.name
    //  //        )
    //  //    }
    //  //
    //
    //}
    //
    //
    //struct ListRow: View {
    //  
    //  @State var showDetail = false
    //  let store: AppStore
    //  let item: Behaviour
    //  let archive: Bool
    //  
    //  init(
    //    store: AppStore,
    //    item: Behaviour,
    //    archive: Bool = false
    //  ) {
    //    self.store = store
    //    self.item = item
    //    self.archive = archive
    //  }
    //  
    //  var body: some View {
    //    WithViewStore(store) { viewStore in
    //      HStack {
    //        
    //        //if !archive {
    //        Rectangle()
    //          .width(2)
    //          .foregroundColor(color)
    //        //Image(systemName: item.favorite ? "star.fill" : "star")
    //        //.resizable()
    //        //.size(10)
    //        //.foregroundColor(item.favorite ? .yellow : .gray)
    //        //.opacity(item.favorite ? 1 : 0.2)
    //        
    //        //}
    //        
    //        Text(item.emoji)
    //          .grayscale(archive ? 1 : 0)
    //        Text(item.name)
    //        
    //        Spacer()
    //        
    //        let count = getCount(
    //          behaviourId: item.id,
    //          viewStore: viewStore
    //        )
    //        
    //        Text(count.string)
    //      }
    //      //            .background(detailLinkTwo)
    //      .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12))
    //      .onTapGesture {
    //        withAnimation {
    //          if viewStore.adding {
    //            viewStore.send(
    //              .addEntry( behaviour: item.id)
    //            )
    //          } else {
    //            viewStore.send(
    //              .deleteEntry(behaviour: item.id)
    //            )
    //          }
    //        }
    //      }
    //      .onLongPressGesture {
    //        print("longpress")
    //        showDetail = true
    //      }
    //    }
    //  }
    //  
    //  
    //  var color: Color {
    //    item.pinned
    //    ? .indigo : .clear
    //  }
    //  
    //  var testLink: some View {
    //    Text("link")
    //  }
    //  //
    //  //    var detailLink: some View {
    //  //        EmptyNavigationLink(
    //  //            destination: editScreen,
    //  //            isActive: $showDetail
    //  //        )
    //  //            .disabled(true)
    //  //    }
    //  //
    //  //    var editScreen: some View {
    //  //        BehaviourEditScreen(
    //  //            store: store,
    //  //            item: item,
    //  //            emoji: item.emoji,
    //  //            name: item.name
    //  //        )
    //  //    }
    //  //
    //  //    var detailLinkTwo: some View {
    //  //        NavigationLink(destination: editScreen, isActive: $showDetail) {
    //  //            EmptyView()
    //  //        }
    //  //        .hidden()
    //  //        .buttonStyle(PlainButtonStyle())
    //  //        .disabled(true)
    //  //    }
    //  
    //}
    //
    //
    
    
    // TallyGoals/UI/toDo/Legacify/SequenceCard.swift
    //
    //  SequenceCard.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 14/06/2022.
    //
    
    import SwiftUI
    
    struct SequenceCard: View {
        
        @GestureState var isPressing = false
        @State var translation: CGSize = .zero
        @State var width: CGFloat = .zero
        
        var body: some View {
            VStack {
                
                Color(uiColor: .secondarySystemBackground)
                    .aspectRatio(312/500, contentMode: .fit)
                    .cornerRadius(24)
                    .overlay(
                        VStack() {
                            Text("👔")
                                .font(.largeTitle)
                            Text("x1")
                                .font(.caption)
                            
                            Text("Planchar ropa título largo dfdfdfdfddf")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .top(12)
                        }
                    )
                    .overlay(
                        HStack(spacing: 24) {
                            Image(systemName: isPressing ? "x.circle.fill" : "x.circle")
                                .resizable()
                                .size(40)
                                .foregroundColor(.red)
                                .scaleEffect(isPressing ? 0.8 : 1)
                                .animation(.easeInOut(duration: 0.15), value: isPressing)
                                .highPriorityGesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            print("did tap")
                                        }
                                )
                                .simultaneousGesture(
                                    LongPressGesture()
                                        .updating($isPressing) { currentState, gestureState, transaction in
                                            gestureState = currentState
                                        }
                                        .onEnded { _ in
                                            print("Ended")
                                        }
                                )
                            
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .size(40)
                                .foregroundColor(.green)
                        }
                            .y(-20)
                        , alignment: .bottom
                    )
                    .horizontal(24)
                    .x(translation.width)
                    .y(translation.height)
                    .rotationEffect(.degrees(translation.width / 200) * 25, anchor: .bottom)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                translation = value.translation
                            }
                            .onEnded { _ in
                                withAnimation {
                                    translation = .zero
                                }
                            }
                    )
                
                
                
            }
        }
    }

    
    // TallyGoals/UI/toDo/Legacify/ShakeEffect.swift
    //
    //  ShakeEffect.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 29/05/2022.
    //
    
    import SwiftUI
    
    struct ShakeEffect: GeometryEffect {
        
        var animatableData: CGFloat
        
        private let const: CGFloat = .s2
        func modifier(_ x: CGFloat) -> CGFloat {
            const * sin(x * .pi * 2)
        }
        
        func effectValue(size: CGSize) -> ProjectionTransform {
            let transform = ProjectionTransform(CGAffineTransform(translationX: const + modifier(animatableData), y: 0))
            return transform
        }
    }

    
    // TallyGoals/UI/toDo/Modularize/SwipeActions/Manager.swift
    //
    //  Manager.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import Combine
    import SwiftUI
    
    final class SwipeManager: ObservableObject {
        
        @Published var swipingId: UUID?
        @Published var rowIsOpened: Bool = false
        
        var cancellables = Set<AnyCancellable>()
        
        static let shared = SwipeManager()
        private init() {}
        
        func collapse() {
            rowIsOpened = false
        }
    }

    
    // TallyGoals/UI/toDo/Modularize/SwipeActions/Regular/SwipeActionModifier.swift
    //
    //  SwipeActionModifier.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    import Combine
    import SwiftUItilities
    
    struct SwipeActionModifier: ViewModifier {
        
        @State var offset = CGFloat.zero
        
        private let id = UUID()
        let leading: [SwipeAction]
        let trailing: [SwipeAction]
        
        /// Sends current item id to the manager
        /// This allows to collapse all the non-current row actions
        func sink() {
            SwipeManager.shared.$swipingId.dropFirst().sink { swipingId in
                guard let swipingId = swipingId else {
                    resetOffset()
    //        SwipeManager.shared.collapse()
                    return
                }
                if id != swipingId {
                    resetOffset()
                }
            }
            .store(in: &SwipeManager.shared.cancellables)
            
            SwipeManager.shared.$rowIsOpened.dropFirst().sink { isOpened in
                if !isOpened {
                    resetOffset()
                }
            }
            .store(in: &SwipeManager.shared.cancellables)
        }
        
        func body(content: Content) -> some View {
            
            content
                .onAppear(perform: sink)
                .background(content)
                .x(offset)
                .background(actions)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged(onChangedEvent)
                        .onEnded(onEndedEvent)
                )
        }
        
        var actions: some View {
            DefaultHStack {
                
                leadingActions
                trailingActions
            }
        }
        
        var totalLeadingWidth: CGFloat {
                .swipeActionItemWidth * leading.count
        }
        
        var leadingActions: some View {
            ZStack(alignment: .leading) {
                ForEach(leading.reversed().indices, id: \.self) { index in
                    let action = leading.reversed()[index]
                    let realIndex = leading.firstIndex(of: action)!
                    let factor = (realIndex + 1).cgFloat
                    let width = .swipeActionItemWidth * factor
                    let dynamicWidth = offset / leading.count * factor
                    let maxWidth = dynamicWidth < width ? dynamicWidth : width
                    let shouldExpand = offset > totalLeadingWidth && realIndex == 0
                    
                    let callback = {
                        action.action()
                        resetOffset()
                    }
                    
                    SwipeActionView(
                        width: maxWidth,
                        action: action,
                        callback: callback
                    )
                    .width(shouldExpand ? totalLeadingWidth : maxWidth)
                }
            }
            .alignX(.leading)
            .displayIf(leading.isNotEmpty)
        }
        
        func actionView(_ action: SwipeAction, width: CGFloat) -> some View {
            let iconWidth = CGFloat.s4
            let iconOffset = (.swipeActionItemWidth - iconWidth) / 2
            return action.backgroundColor
                .overlay(
                    Image(systemName: "action.systemSymbol")
                        .resizable()
                        .foregroundColor(.red)
                        .size(iconWidth)
                        .x(-iconOffset)
                    
                    ,
                    alignment: .trailing
                )
        }
        
        var trailingActions: some View {
            HStack {
                Spacer()
                Text("Trailing")
            }
            .displayIf(trailing.isNotEmpty)
        }
        
        func resetOffset() {
            // .timingCurve(0.5, 0.5, 0.8, 0.7
            withAnimation(.easeOut(duration: 0.45)) { offset = .zero }
        }
        
        var isOpened: Bool { offset >= totalLeadingWidth }
        
        @State private var shouldHapticFeedback: Bool = true
        @State private var shouldSendId: Bool = true
        
        func onChangedEvent(_ value: DragGesture.Value) {
            
            let width = value.translation.width
            if shouldSendId {
            SwipeManager.shared.swipingId = id
                shouldSendId = false
            }
            guard !isOpened else {
    //      print("isOpened")
                if offset > totalLeadingWidth && shouldHapticFeedback {
                NotificationFeedback.shared.notificationOccurred(.success)
                    shouldHapticFeedback = false
                }
                let maxAddOffset = width < .s2 ? width : .s2
                withAnimation { offset = totalLeadingWidth + maxAddOffset }
                
                
                return
            }
            
            withAnimation {
    //      print("Modifiying offset...")
                offset = width
            }
        }
        
        func onEndedEvent(_ value: DragGesture.Value) {
            
            let width = value.translation.width
            
            shouldHapticFeedback = true
            shouldSendId = true
            
            
            guard leading.isNotEmpty else {
                return
            }
            
            
            if isOpened && (offset + width) > totalLeadingWidth {
                leading.first?.action()
            }
            
                if width > .s28 && width < totalLeadingWidth {
                    withAnimation {
                        offset = totalLeadingWidth
                        SwipeManager.shared.rowIsOpened = true
                    }
                } else if width > totalLeadingWidth {
                    leading.first?.action()
                    resetOffset()
                    SwipeManager.shared.rowIsOpened = false
                } else {
                    resetOffset()
                    SwipeManager.shared.rowIsOpened = false
                }
            
        }
    }

    
    // TallyGoals/UI/toDo/Modularize/SwipeActions/Regular/SwipeActions.swift
    //
    //  SwipeActions.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 02/06/2022.
    //
    import SwiftUI
    import SwiftUItilities
    
    struct SwipeAction: Identifiable, Equatable {
        
        let id: UUID = UUID()
        let label: String?
        let systemSymbol: String
        let action: () -> Void
        let backgroundColor: Color
        let tintColor: Color
        
        init(
            label: String?,
            systemSymbol: String,
            action: @escaping () -> Void,
            backgroundColor: Color = .black,
            tintColor: Color = .white
        ) {
            self.label = label
            self.systemSymbol = systemSymbol
            self.action = action
            self.backgroundColor = backgroundColor
            self.tintColor = tintColor
        }
        
        static func == (
            lhs: SwipeAction,
            rhs: SwipeAction
        ) -> Bool {
            lhs.id == rhs.id
        }
    }

    extension CGFloat {
        static let swipeActionItemWidth = CGFloat.s1 * 18
    }

    extension View {
        
        func swipeActions(
            leading: [SwipeAction] = [],
            trailing: [SwipeAction] = []
        ) -> some View {
            
            self.modifier(
                SwipeActionModifier(
                    leading: leading,
                    trailing: trailing
                )
            )
        }
    }

    
    
    // TallyGoals/UI/toDo/Modularize/SwipeActions/Regular/SwipeActionsView.swift
    //
    //  SwipeActionsView.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 29/05/2022.
    //
    
    import SwiftUI
    import SwiftWind
    
    struct SwipeActionView: View {
        
        @State var width: CGFloat
        let action: SwipeAction
        let callback: () -> Void
        private var iconOffset: CGFloat { (.swipeActionItemWidth - width) / 2 }
        
        var body: some View {
            return action.backgroundColor
                .overlay(
                    Image(systemName: action.systemSymbol)
                        .foregroundColor(action.tintColor)
                        .bindWidth(to: $width)
                        .x(-iconOffset)
                    ,
                    alignment: .trailing
                )
                .onTap(perform: callback)
                .buttonStyle(.plain)
        }
    }

    
    // TallyGoals/UI/toDo/Modularize/SwipeActions/Spark/SparkSwipeActionModifier.swift
    //
    //  SparkSwipeActionModifier.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    
    struct SparkSwipeActionModifier: ViewModifier {
        
        @State var width = CGFloat.zero
        @State var offset = CGFloat.zero
        @State var currentLeadingIndex = Int.zero
        @State var currentTrailingIndex = Int.zero
        @State var shouldHapticFeedback = true
        
        let leading: [SwipeAction]
        let trailing: [SwipeAction]
        
        func body(content: Content) -> some View {
            content
            .bindWidth(to: $width)
            .x(offset)
            .background(leadingGestures)
            .background(trailingGestures)
            .onChange(of: currentLeadingIndex, perform: handleIndexChange(_:))
            .onChange(of: currentTrailingIndex, perform: handleIndexChange(_:))
            .gesture(drag)
        }
        
        func handleIndexChange(_ index: Int) {
            guard index > 0 else { return }
            UIImpactFeedbackGenerator.shared.impactOccurred()
            
            #if DEBUG
            print("index changed: \(index)")
            #endif
        }
        
        @ViewBuilder
        var leadingGestures: some View {
            
            if leading.isEmpty {
                EmptyView()
            } else {
                
                let initOffset = -.s6 + offset
                let treasholdReached = initOffset > .s3
                
                ZStack {
                    ForEach(0...leading.count - 1) { index in
                        let isCurrent = index == currentLeadingIndex
                        let item = leading[index]
                        item.backgroundColor
                            .opacity(treasholdReached ? 1 : 0)
                            .opacity(isCurrent ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: isCurrent)
                    }
                    .overlay(leadingGestureLabels, alignment: .leading)
                }
            }
        }
        
        @ViewBuilder
        var trailingGestures: some View {
            
            if trailing.isEmpty {
                EmptyView()
            } else {
                
                
                let initOffset = .s6 + offset
                let treasholdReached = initOffset < -.s3
                
                ZStack {
                    ForEach(0...trailing.count - 1) { index in
                        let isCurrent = index == currentTrailingIndex
                        let item = trailing[index]
                        item.backgroundColor
                        .opacity(treasholdReached ? 1 : 0)
                        .opacity(isCurrent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: isCurrent)
                    }
                    .overlay(trailingGestureLabels, alignment: .trailing)
                }
            }
        }
        
        @ViewBuilder
        var trailingGestureLabels: some View {
            let initOffset = .s6 + offset
            let treasholdReached = initOffset < -.s3
            let item = trailing.getOrNil(index: currentTrailingIndex)
            
            if let item = item {
                HStack {
                    
                    if let label =  item.label {
                        Text(label)
                            .opacity(treasholdReached ? 1 : 0)
                    }
                    
                    Image(systemName: item.systemSymbol)
                    
                }
                .foregroundColor(item.tintColor)
                .x(treasholdReached ? -.s3 : initOffset)
            } else {
                EmptyView()
            }
        }
        
        @ViewBuilder
        var leadingGestureLabels: some View {
            let initOffset = -.s6 + offset
            let treasholdReached = initOffset > .s3
            let item = leading.getOrNil(index: currentLeadingIndex)
            
            if let item = item {
                HStack {
                    
                    Image(systemName: item.systemSymbol)
                    if let label =  item.label {
                        Text(label)
                            .opacity(treasholdReached ? 1 : 0)
                    }
                }
                .foregroundColor(item.tintColor)
                .x(treasholdReached ? .s3 : initOffset)
            } else {
                EmptyView()
            }
        }
        
        var drag: some Gesture {
            DragGesture()
            .onChanged(handleDragChange)
            .onEnded(handleDragEnd)
        }
        
        func handleDragChange(_ value: DragGesture.Value) {
            
            let horizontalTranslation = value.translation.width
            
            if horizontalTranslation > .s8 && shouldHapticFeedback {
                UIImpactFeedbackGenerator.shared.impactOccurred()
                shouldHapticFeedback = false
            }
            
            if horizontalTranslation < -.s8 && shouldHapticFeedback {
                UIImpactFeedbackGenerator.shared.impactOccurred()
                shouldHapticFeedback = false
            }
            
            withAnimation {
                offset = horizontalTranslation
            }
            
            let factor = horizontalTranslation / width
            
            currentLeadingIndex = Int(factor * leading.count)
            
            if horizontalTranslation < 0 {
                currentTrailingIndex = abs(Int(factor * trailing.count))
                print(currentTrailingIndex)
            }
        }
        
        func handleDragEnd(_ value: DragGesture.Value) {
            
            let horizontalTranslation = value.translation.width
            
            shouldHapticFeedback = true
            
            if horizontalTranslation >= .s12 {
                leading.getOrNil(index: currentLeadingIndex)?.action()
            }
            
            if horizontalTranslation <= -.s12 {
                trailing.getOrNil(index: currentTrailingIndex)?.action()
            }
            
            resetOffset()
        }
        
        func resetIndex() {
            withAnimation { currentLeadingIndex = 0 }
        }
        
        func resetOffset() {
            withAnimation { offset = 0 }
        }
    }

    
    // TallyGoals/UI/toDo/Modularize/SwipeActions/Spark/View+sparkSwipeActions.swift
    //
    //  View+sparkSwipeActions.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    
    extension View {
        func sparkSwipeActions(
            leading: [SwipeAction] = [],
            trailing: [SwipeAction] = []
        ) -> some View {
            self.modifier(SparkSwipeActionModifier(leading: leading, trailing: trailing))
        }
    }

    
    // TallyGoals/UI/toDo/Modularize/VerticalLinearGradient.swift
    //
    //  VerticalLinearGradient.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    
    struct VerticalLinearGradient: View {
        let colors: [Color]
        var body: some View {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    
    // TallyGoals/UI/toDo/Modularize/WindColors.swift
    //
    //  WindColors.swift
    //  TallyGoals
    //
    //  Created by Cristian Rojas on 03/06/2022.
    //
    
    import SwiftUI
    import SwiftWind
    
    /// Enum allows iteration for demo purposes (showing all colors)
    /// This will replace the WindColor struct on SwiftWind on a future release
    enum WindColors: Int, CaseIterable {
        case slate
        case gray
        case zinc
        case neutral
        case stone
        case red
        case orange
        case yellow
        case lime
        case green
        case emerald
        case teal
        case cyan
        case sky
        case blue
        case indigo
        case violet
        case amber
        case purple
        case fuchsia
        case pink
        case rose
        
        
        var color: WindColor {
            switch self {
                
            case .amber:
                return .amber
            case .purple:
                return .purple
            case .slate:
                return .slate
            case .gray:
                return .gray
            case .zinc:
                return .zinc
            case .neutral:
                return .neutral
            case .stone:
                return .stone
            case .red:
                return .red
            case .orange:
                return .orange
            case .yellow:
                return .yellow
            case .lime:
                return .lime
            case .green:
                return .green
            case .emerald:
                return .emerald
            case .teal:
                return .teal
            case .cyan:
                return .cyan
            case .sky:
                return .sky
            case .blue:
                return .blue
            case .indigo:
                return .indigo
            case .violet:
                return .violet
            case .fuchsia:
                return .fuchsia
            case .pink:
                return .pink
            case .rose:
                return .rose
            }
        }
        
        var t50: Color {
            switch self {
            case .slate:
                return .slate50
            case .gray:
                return .gray50
            case .zinc:
                return .zinc50
            case .neutral:
                return .neutral50
            case .stone:
                return .stone50
            case .red:
                return .red50
            case .orange:
                return .orange50
            case .yellow:
                return .yellow50
            case .lime:
                return .lime50
            case .green:
                return .green50
            case .emerald:
                return .emerald50
            case .teal:
                return .teal50
            case .cyan:
                return .cyan50
            case .sky:
                return .sky50
            case .blue:
                return .blue50
            case .indigo:
                return .indigo50
            case .violet:
                return .violet50
            case .amber:
                return .amber50
            case .purple:
                return .purple50
            case .fuchsia:
                return .fuchsia50
            case .pink:
                return .pink50
            case .rose:
                return .rose50
            }
        }
    }

    
    // TallyGoalsTests/BehaviourRepositoryActions.swift
    //
    //  TallyGoalsTests.swift
    //  TallyGoalsTests
    //
    //  Created by Cristian Rojas on 27/05/2022.
    //
    //import ComposableArchitectureTestSupport
    import ComposableArchitecture
    import XCTest
    @testable import TallyGoals
    
    
    /// **Behaviour Repository:**
    /// - Tests each action of the architecture related to the Behaviour Repository
    /// - Indirectly test their implementations by the reducer.
    /// - Indirectly test CoreData by using a inMemory viewContext
    class BehaviourRepositoryTests: XCTestCase {
        
        var environment: AppEnvironment!
        
        override func setUpWithError() throws {
            
            /// Set environment on each test
            let inMemoryContext = PersistenceController(inMemory: true).container.viewContext
            let repository = BehaviourRepository(context: inMemoryContext)
            environment = AppEnvironment(behavioursRepository: repository)
        }
        
        override func tearDownWithError() throws {
            /// Reset environment on each test
            environment = nil
        }
        
        /// When fetching the database on first time, we should get an empty state (no behaviours)
        func testReadBehavioursOnFirstLaunch() {
            
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: environment
            )
            
            /// If we send the readBehaviours action,
            /// That should mutate behaviourState from 'idle' to loading
            store.send(.readBehaviours) {
                $0.behaviourState = .loading
            }
            
            /// Then, once the databaseFetched, we should:
            /// - Receive an makeBehaviourState action
            /// - Get an empty behaviourState
            store.receive(.makeBehaviourState(.empty)) {
                $0.behaviourState = .empty
            }
        }
        
        func testCreateBehaviour() {
            
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: environment
            )
            
            let id = UUID()
            let emoji = "💧"
            let name = "Testing"
            
            let expectedBehaviours = [Behaviour(
                id: id,
                emoji: emoji,
                name: name,
                count: 0
            )]
            
            let expectedBehaviourState: BehaviourState = .success(expectedBehaviours)
            
            store.send(.createBehaviour(id: id, emoji: emoji, name: name))
            
            wait()
            
            store.receive(.readBehaviours) {
                $0.behaviourState = .loading
            }
            
            store.receive(.makeBehaviourState(expectedBehaviourState)) {
                $0.behaviourState = expectedBehaviourState
            }
        }
        
        func testUpdateFavorite() {
            updateBehaviour(action: .favorite)
        }
        
        func testUpdatePinned() {
            updateBehaviour(action: .pin)
        }
        
        func testUpdateArchive() {
            updateBehaviour(action: .archive)
        }
        
        func testUpdateBehaviourMetaData() {
            var behaviour = Behaviour(
                id: UUID(),
                emoji: "🙂",
                name: "Be happy",
                count: 0
            )
            
            var expectedState = BehaviourState.success([behaviour])
            
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: environment
            )
            
            // MARK: - Create the behaviour
            store.send(.createBehaviour(
                id: behaviour.id,
                emoji: behaviour.emoji,
                name: behaviour.name
            ))
            
            wait()
            
            store.receive(.readBehaviours) {
                $0.behaviourState = .loading
            }
            store.receive(.makeBehaviourState(expectedState)) {
                $0.behaviourState = expectedState
            }
            
            
            /// Updated behaviour
            behaviour = Behaviour(
                id: behaviour.id,
                emoji: "🙂",
                name: "New name",
                count: behaviour.count
            )
            
            expectedState = .success([behaviour])
            
            
            store.send(.updateBehaviour(
                id: behaviour.id,
                emoji: behaviour.emoji,
                name: behaviour.name
            ))
            
            wait()
            
            store.receive(.readBehaviours) { $0.behaviourState = .loading }
            store.receive(.makeBehaviourState(expectedState)) {
                $0.behaviourState = expectedState
            }
        }
        
        func testDeleteBehaviour() {
            let behaviour = Behaviour(
                id: UUID(),
                emoji: "🙂",
                name: "Be happy",
                count: 0
            )
            
            let expectedFirstState = BehaviourState.success([behaviour])
            
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: environment
            )
            
            store.send(.createBehaviour(
                id: behaviour.id,
                emoji: behaviour.emoji,
                name: behaviour.name
            ))
            
            wait()
            
            store.receive(.readBehaviours) {
                $0.behaviourState = .loading
            }
            
            store.receive(.makeBehaviourState(expectedFirstState)) {
                $0.behaviourState = expectedFirstState
            }
            
            store.send(.deleteBehaviour(id: behaviour.id))
            
            wait()
            store.receive(.readBehaviours) {
                $0.behaviourState = .loading
            }
            store.receive(.makeBehaviourState(.empty)) {
                $0.behaviourState = .empty
            }
        }
        
        func testAddEntry() {
            var behaviour = Behaviour(
                id: UUID(),
                emoji: "🙂",
                name: "Be happy",
                count: 0
            )
            
            var expectedState = BehaviourState.success([behaviour])
            
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: environment
            )
            
            store.send(.createBehaviour(
                id: behaviour.id,
                emoji: behaviour.emoji,
                name: behaviour.name
            ))
            
            wait(timeout: 0.05)
            
            store.receive(.readBehaviours) {
                $0.behaviourState = .loading
            }
            
            store.receive(.makeBehaviourState(expectedState)) {
                $0.behaviourState = expectedState
            }
            
            behaviour.count += 1
            expectedState = .success([behaviour])
            
            store.send(.addEntry(behaviour: behaviour.id))
            
            wait()
            
            store.receive(.readBehaviours) { $0.behaviourState = .loading}
            store.receive(.makeBehaviourState(expectedState)) {
                $0.behaviourState = expectedState
            }
        }
        
        func testDeleteEntry() {
            var behaviour = Behaviour(
                id: UUID(),
                emoji: "🙂",
                name: "Be happy",
                count: 0
            )
            
            var expectedState = BehaviourState.success([behaviour])
            
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: environment
            )
            
            store.send(.createBehaviour(
                id: behaviour.id,
                emoji: behaviour.emoji,
                name: behaviour.name
            ))
            wait()
            store.receive(.readBehaviours) {
                $0.behaviourState = .loading
            }
            store.receive(.makeBehaviourState(expectedState)) {
                $0.behaviourState = expectedState
            }
            
            behaviour.count += 1
            expectedState = .success([behaviour])
            
            store.send(.addEntry(behaviour: behaviour.id))
            wait()
            store.receive(.readBehaviours) { $0.behaviourState = .loading}
            store.receive(.makeBehaviourState(expectedState)) {
                $0.behaviourState = expectedState
            }
            
            behaviour.count -= 1
            expectedState = .success([behaviour])
            
            store.send(.deleteEntry(behaviour: behaviour.id))
            wait()
            store.receive(.readBehaviours) { $0.behaviourState = .loading }
            store.receive(.makeBehaviourState(expectedState)) {
                $0.behaviourState = expectedState
            }
        }
        
        private enum UpdateAction {
            case favorite
            case archive
            case pin
        }
        
        private func updateBehaviour(action: UpdateAction) {
            
            var behaviour = Behaviour(
                id: UUID(),
                emoji: "🙂",
                name: "Be happy",
                count: 0
            )
            
            var expectedState = BehaviourState.success([behaviour])
            
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: environment
            )
            
            store.send(.createBehaviour(
                id: behaviour.id,
                emoji: behaviour.emoji,
                name: behaviour.name
            ))
            
            wait()
            
            store.receive(.readBehaviours) {
                $0.behaviourState = .loading
            }
            
            store.receive(.makeBehaviourState(expectedState)) {
                $0.behaviourState = expectedState
            }
            
            
            switch action {
            case .favorite:
                behaviour.favorite = true
                expectedState = BehaviourState.success([behaviour])
                
                store.send(.updateFavorite(id: behaviour.id, favorite: true))
                wait()
                store.receive(.readBehaviours) {
                    $0.behaviourState = .loading
                }
                store.receive(.makeBehaviourState(expectedState)) {
                    $0.behaviourState = expectedState
                }
            case .archive:
                behaviour.archived = true
                expectedState = BehaviourState.success([behaviour])
                
                store.send(.updateArchive(id: behaviour.id, archive: true))
                wait()
                store.receive(.readBehaviours) {
                    $0.behaviourState = .loading
                }
                store.receive(.makeBehaviourState(expectedState)) {
                    $0.behaviourState = expectedState
                }
            case .pin:
                behaviour.pinned = true
                expectedState = BehaviourState.success([behaviour])
                
                store.send(.updatePinned(id: behaviour.id, pinned: true))
                wait()
                store.receive(.readBehaviours) {
                    $0.behaviourState = .loading
                }
                store.receive(.makeBehaviourState(expectedState)) {
                    $0.behaviourState = expectedState
                }
            }
        }
        
        /// If test fail with the following error:
        /// _"An effect returned for this action is still running. It must complete before the end of the test"_.
        /// That means, that specific test needs some more time in order to wait for the returned action to finish running,
        /// If that's the case you could override the default timeout (time to wait) argument by incrementing it a little
        private func wait(timeout: Double = 0.001) {
            _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: timeout)
        }
        
    }

    
    // TallyGoalsTests/OtherStateActionsTests.swift
    //
    //  OtherStateActionsTests.swift
    //  TallyGoalsTests
    //
    //  Created by Cristian Rojas on 25/06/2022.
    //
    import ComposableArchitecture
    import XCTest
    @testable import TallyGoals
    
    /*
    
        Tests the overlay manager on state
        */
        
    class OtherStateActionsTests: XCTestCase {
        
            override func setUpWithError() throws {
            }
        
            override func tearDownWithError() throws {
            }
        
        func testSetOverlay() {
            
            let store = TestStore(
                initialState: AppState(),
                reducer: appReducer,
                environment: AppEnvironment(behavioursRepository: BehaviourRepository(context: PersistenceController.preview.container.viewContext))
            )
            
            let presetCategory = PresetCategory(
                emoji: "💧",
                name: "Mental clarity"
            )
            
            let overlayModel = Overlay.exploreDetail(presetCategory)
            
            store.send(.setOverlay(overlay: overlayModel)) {
                $0.overlay = overlayModel
            }
        }
        
    }

    
    
    // p2-rpg.swift
    
    // rpg/main.swift
    /*
    
    main.swift
    
    
    
        /$$$$$$$  /$$$$$$$   /$$$$$$  /$$      /$$                 /$$
        | $$__  $$| $$__  $$ /$$__  $$| $$$    /$$$                | $$
        | $$  \ $$| $$  \ $$| $$  \__/| $$$$  /$$$$  /$$$$$$   /$$$$$$$ /$$$$$$$   /$$$$$$   /$$$$$$$ /$$$$$$$
        | $$$$$$$/| $$$$$$$/| $$ /$$$$| $$ $$/$$ $$ |____  $$ /$$__  $$| $$__  $$ /$$__  $$ /$$_____//$$_____/
        | $$__  $$| $$____/ | $$|_  $$| $$  $$$| $$  /$$$$$$$| $$  | $$| $$  \ $$| $$$$$$$$|  $$$$$$|  $$$$$$
        | $$  \ $$| $$      | $$  \ $$| $$\  $ | $$ /$$__  $$| $$  | $$| $$  | $$| $$_____/ \____  $$\____  $$
        | $$  | $$| $$      |  $$$$$$/| $$ \/  | $$|  $$$$$$$|  $$$$$$$| $$  | $$|  $$$$$$$ /$$$$$$$//$$$$$$$/
        |__/  |__/|__/       \______/ |__/     |__/ \_______/ \_______/|__/  |__/ \_______/|_______/|_______/
        
                                                                                                                                                                                                                    
        */
        
    
    
    import Foundation
    
    let game = Game()
    game.start()
    
    
    // rpg/Model/Character.swift
    //
    //  Character.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 15/07/2020.
    //  MIT 
    //
    
    import Foundation
    
    class Character {
        
            /// Defines the character's name as an empty string. It will be defined later on
            var name : String = ""
            /// Defines the health of the Character
            var health : Int
            /// Creates a weapon for the character
            var weapon : Weapon
            /// Defines the emoji of the character
            var emoji : String
            /// Defines the healing power
            var healingPower : Int
        
        
            init(health: Int, weapon: Weapon, emoji: String, healingPower: Int) {
                
                    self.health = health
                    self.weapon = weapon
                    self.emoji = emoji
                    self.healingPower = healingPower
                
            }
        
            convenience init() { self.init(health: 100, weapon: Weapon(), emoji: "👤", healingPower: 10) }
        
            /// Heal a team member
            func healComrade(character: Character) { character.health += healingPower }
            /// Attack a member of the other team
            func attackEnemy(character: Character) { character.receiveDamage(damage: weapon.power) }
        
            /// Receive's damage if attacked by the enemy
            func receiveDamage(damage: Int) {
                    health -= damage
                    health = health < 0 ? 0 : health
            }
        
    }

    // PROTOCOLS AND HELPERS
    
    extension Character: Equatable {
            /// Allows to distinguish characters
            static func ==(firstCharacter: Character, secondCharacter: Character) -> Bool {
                    return firstCharacter.name == secondCharacter.name
            }
            /// Checks if a character is dead
            func isDead() -> Bool { return health <= 0 }
    }

    
    // rpg/Model/Characters/Archer.swift
    //
    //  Archer.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 30/07/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import Foundation
    
    class Archer : Character {
        
            init() {
                    super.init(health: 100, weapon: Arc(), emoji: "🏹", healingPower: 15)
            }
    }

    
    // rpg/Model/Characters/Knight.swift
    //
    //  Knight.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 30/07/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import Foundation
    
    class Knight : Character {
        
            init() {
                    super.init(health: 130, weapon: Sword(), emoji: "🗡", healingPower: 10)
            }
    }

    
    // rpg/Model/Characters/Magician.swift
    //
    //  Magician.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 30/07/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import Foundation
    
    class Magician : Character {
        
            init() {
                    super.init(health: 60, weapon: Wand(), emoji: "🧙🏻‍♂️", healingPower: 35)
            }
    }

    
    // rpg/Model/Game.swift
    //
    //  Game.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 16/07/2020.
    //  MIT
    //
    
    import Foundation
    
    class Game {
            /// Stores the players
            var players = [Player(), Player()]
            /// Creates an object "text" with all the text that we will print to the user
            var text = Text()
            /// Stores the number of characters per team (in the array player.team)
            var numberOfCharacters = 3
            /// Start the game
            func start() {
                
                    text.setLang()
                    welcome()
                    //chooseCharacterNumber()
                    namingPlayers()
                    play()
                    gameStats()
                    restart()
            }
        
            /// Allows user to choose the number of characters and limits his choice to a choosen range
            func chooseCharacterNumber() { numberOfCharacters = Utilities.waitForInput(message: text.chooseNumberOfCharacters, condition: 2...10) }
        
            /// Welcomes the user and prints the game's logo
            func welcome() {
                    print("\(text.welcome)\n\n")
                    print("  /$$$$$$$  /$$$$$$$   /$$$$$$  /$$      /$$                 /$$\n | $$__  $$| $$__  $$ /$$__  $$| $$$    /$$$                | $$\n | $$  \\ $$| $$  \\ $$| $$  \\__/| $$$$  /$$$$  /$$$$$$   /$$$$$$$ /$$$$$$$   /$$$$$$   /$$$$$$$ /$$$$$$$\n | $$$$$$$/| $$$$$$$/| $$ /$$$$| $$ $$/$$ $$ |____  $$ /$$__  $$| $$__  $$ /$$__  $$ /$$_____//$$_____/\n | $$__  $$| $$____/ | $$|_  $$| $$  $$$| $$  /$$$$$$$| $$  | $$| $$  \\ $$| $$$$$$$$|  $$$$$$|  $$$$$$\n | $$  \\ $$| $$      | $$  \\ $$| $$\\  $ | $$ /$$__  $$| $$  | $$| $$  | $$| $$_____/ \\____  $$\\____  $$\n | $$  | $$| $$      |  $$$$$$/| $$ \\/  | $$|  $$$$$$$|  $$$$$$$| $$  | $$|  $$$$$$$ /$$$$$$$//$$$$$$$/\n |__/  |__/|__/       \\______/ |__/     |__/ \\_______/ \\_______/|__/  |__/ \\_______/|_______/|_______/\n\n")
            }
        
            /// Creates the players and his team
            func namingPlayers() {
                
                    for i in 0..<players.count {
                            var name = ""
                            repeat {
                                    print("👤 Player \(i+1), \(text.chooseYourName)")
                                    name = readLine()!.normalize()
                            } while name.isBlank
                        
                            players[i].name = name
                            players[i].createCharacters()
                        
                    }
            }
        
            /// Made players chose their moves in alternating turns
            func play() {
                    while players[0].teamIsDead() == false && players[1].teamIsDead() == false {
                            players[0].move(against: players[1])
                            players[0].count += 1
                            if players[1].teamIsDead() == false {
                                    players[1].move(against: players[0])
                                    players[1].count += 1
                            }
                    }
            }
        
            /// Shows information about the winner (name, characters alive...) and the number of movements of both players
            func gameStats() {
                
                    for player in players {
                            if player.teamHealth > 0 {
                                    print("🔥🔥🔥🔥🔥")
                                    print("\(player.name) \(text.won) 💪!")
                                    print("\(player.team.count) \(text.leftoutof) \(numberOfCharacters): ")
                                    for character in player.team {
                                            print("\(character.name) 💉: \(character.health) + 💪: \(character.weapon.power)")
                                    }
                                
                            }
                            print("\(player.name): \(player.count) \(text.movements)") 
                        
                    }
            }
        
            /// Allows the user to choose wether restart the game or not at the end of a match
            func restart() {
                    var choice = ""
                    repeat {
                            print("Restart y/n")
                            choice = readLine()!
                    } while choice != "y" && choice != "n"
                
                    if choice == "y" { reset() ; start() } else { return }
            }
        
            ///Resets the game by removing the old players
            func reset() { players.removeAll() ; players = [Player(), Player()] }
    }

    
    // rpg/Model/Player.swift
    //
    //  Player.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 15/07/2020.
    //  MIT
    //
    
    import Foundation
    
    class Player {
            /// Player's name. Declared empty becasue we well use game.namingPlayers()
            var name = ""
            /// Array that contains the members of the team
            var team = [Character]()
            /// Creates a count variable we'll update with every move of the player
            var count = Int()
            /// Returns the total health of the team.
            var teamHealth : Int {
                    var total : Int = Int()
                    for character in team {
                            total += character.health
                    }
                    return total
            }
        
            /// Checks if all the team members are dead
            func teamIsDead() -> Bool {
                    return teamHealth == 0
            }
            /// Creates the caracter's inside the player.team array
            func createCharacters() {
                
                    // Creates characters and appends them to the array "team"
                    while team.count < game.numberOfCharacters {
                            let message = "\n\n\(name), \(game.text.chooseKind) \(team.count + 1)\n"
                                    + "\n1.\n🗡 \(game.text.knight)\n💉: 130. 💪: 35. 👨‍⚕️: 10"
                                    + "\n2.\n🏹 \(game.text.archer)\n💉: 100. 💪: 60. 👨‍⚕️: 15"
                                    + "\n3.\n🧙🏻‍♂️ \(game.text.magician)\n💉: 60. 💪: 75. 👨‍⚕️: 35"
                            let input = Utilities.waitForInput(message: message, condition: 1...3)
                        
                            var character = Character()
                            switch input {
                            case 1:
                                    character = Knight()
                            case 2:
                                    character = Archer()
                            case 3:
                                    character = Magician()
                            default:
                                    break
                            }
                        
                            var characterName = ""
                            var names = [String]()
                            repeat {
                                    print("\(game.text.nameCharacter) \(team.count + 1). \(game.text.nameConstraints)")
                                    characterName = readLine()!.normalize()
                            } while characterName.isBlank || Utilities.nameExists(names: names, name: characterName)
                        
                            print(characterName)
                            character.name = characterName
                            names.append(characterName)
                            team.append(character)
                    }
                
            }
        
            /// Allows user to attack or to heal a team member
            func move(against player: Player) {
                    let message = "\n\n\(game.text.turn) \(name)"
                            + "\n1.⚔️ \(game.text.attack)"
                            + "\n2.💉 \(game.text.heal)\n"
                
                    let action = Utilities.waitForInput(message: message, condition: 1...2)
                    action == 1 ? attack(against: player) : heal()
                
            }
            /// Allows user to chose the team member that's going to attack and the enemy that will be attacked
            func attack(against player: Player) {
                
                    let range = self.rangeTeam()
                    let attackerIndex = Utilities.waitForInput(message: game.text.whoAttacks + range, condition: 1...team.count) - 1
                    let attacker = team[attackerIndex]
                
                    Weapon.randomWeapon(character: attacker)
                
                
                    let rangeEnemy = player.rangeTeam()
                    let enemyIndex = Utilities.waitForInput(message: game.text.whoIsAttacked + rangeEnemy, condition: 1...player.team.count) - 1
                    let enemy = player.team[enemyIndex]
                
                    attacker.attackEnemy(character: enemy)
                
                    if enemy.isDead() {
                        
                            print("\(enemy.name) \(game.text.isDead) \n")
                            let characterIndex = player.team.firstIndex(of: enemy)
                            player.team.remove(at: characterIndex!)
                        
                    } else { print("\(enemy.name) \(game.text.healthIs) \(enemy.health)") }
            }
        
            /// Allows user to increase one of his members health
            func heal() {
                
                    let range = self.rangeTeam()
                
                    let healerIndex = Utilities.waitForInput(message: game.text.whoHeals + range, condition: 1...team.count) - 1
                    let healer = team[healerIndex]
                
                    let comradeIndex = Utilities.waitForInput(message: game.text.whoIsHealed + range, condition: 1...team.count) - 1
                    let comrade = team[comradeIndex]
                
                    healer.healComrade(character: comrade)
                    print("\(comrade.name) \(game.text.healthIs) \(comrade.health)")
            }
        
            /// Returns a string with information (name, health, power...) about all the members of the team
            func rangeTeam() -> String {
                
                    var range = ""
                    for i in 0..<self.team.count {
                            let teamInfo = "\n\(i+1). \(team[i].emoji) \(team[i].name). 💉: \(team[i].health). 💪: \(team[i].weapon.power). 👨‍⚕️ \(team[i].healingPower)"
                            range.append(teamInfo)
                    }
                    return range
            }
        
    }

    
    // rpg/Model/Text.swift
    //
    //  Lang.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 16/07/2020.
    //  MIT
    //
    
    /// Declares all the strings we're going to print to the user in the game
    struct Text {
        
            var welcome = "\n\nWelcome to RPG madness"
            var chooseYourName = "what's your name?"
            var nameCharacter = "Name the character"
            var nameConstraints = "Name can't be empty nor taken"
            var chooseKind = "Choose the kind of the character"
            var character = "Character"
            var won = "won"
            var attack = "Attack"
            var heal = "Heal"
            var whoAttacks = "Who's going to attack?"
            var whoHeals = "Who's going to heal?"
            var whoIsAttacked = "Who's going to be attacked?"
            var whoIsHealed = "Who's going to be healed?"
            var healthIs = "health is now:"
            var isDead = "is dead!"
            var chooseNumberOfCharacters = "Choose the number of characters per player (at least 2)"
            var knight = "Knight"
            var magician = "Magician"
            var archer = "Archer"
            var foundWeapon = "has found a weapon. Power: "
            var turn = "Turn:"
            var enterNumber = "Enter number"
            var leftoutof = "left characters out of"
            var movements = "movements"
        
            /// Allows user to choose the game language. Declared as a mutating function because the strings are stored in a struct
            mutating func setLang() {
                
                    let languages = "\n\n\n1. 🥖 Français"
                    + "\n2. 💃🏻 Español"
                    + "\n3. 🏈 English"
                
                    let choice = Utilities.waitForInput(message: languages, condition: 1...3)
                
                    /// Changes the languege of the game strings to the choosen one
                    switch choice {
                    case 1:
                            welcome = "\n\nBienvenu à RPGmadness"
                            chooseYourName = "quel est ton prenom?"
                            nameCharacter = "Donne un nom au personnage"
                            nameConstraints = "Le nom ne peut pas être vide ni repété"
                            chooseKind = "Chossi la classe du personage"
                            character = "Personnage"
                            won = "gagne"
                            attack = "Attaquer"
                            heal = "Guérir"
                            whoAttacks = "Qui va à attaquer?"
                            whoHeals = "Qui va guérir?"
                            whoIsAttacked = "Qui sera attaqué?"
                            whoIsHealed = "Qui sera guéri?"
                            healthIs = "vie:"
                            isDead = "est mort!"
                            chooseNumberOfCharacters = "Choissisez le nombre de personnages par joueur (2 au minimum)"
                            knight = "Chevalier"
                            magician = "Magicien"
                            archer = "Archer"
                            foundWeapon = "a trouvé une arme. Pouvoir de l'arme:"
                            turn = "Tour:"
                            enterNumber = "Rentrez un numéro"
                            leftoutof = "personnages restent sur"
                            movements = "mouvements"
                        
                    case 2:
                            welcome = "\n\nBienvenido a RPGmadness"
                            chooseYourName = "cuál es tu nombre?"
                            nameCharacter = "Da un nombre al personaje"
                            nameConstraints = "El nombre no puede estar vacío ni repetido"
                            chooseKind = "Elije la clase del personaje"
                            character = "Personaje"
                            won = "gana"
                            attack = "Atacar"
                            heal = "Curar"
                            whoAttacks = "Quién va a atacar?"
                            whoHeals = "Quién cura?"
                            whoIsAttacked = "Quién será atacado?"
                            whoIsHealed = "Quién será curado?"
                            healthIs = "vida:"
                            isDead = "ha muerto!"
                            chooseNumberOfCharacters = "Elije el número de personajes por jugador (2 como mínimo)"
                            knight = "Caballero"
                            magician = "Mago"
                            archer = "Arquero"
                            foundWeapon = "ha encontrado un arma. Poder del arma:"
                            turn = "Turno:"
                            enterNumber = "Escribe el número"
                            leftoutof = "personajes de"
                            movements = "movimientos"
                        
                    case 3:
                            return
                    default:
                            break
                    }
            }
        
    }

    
    // rpg/Model/Utilities.swift
    //
    //  Utilities.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 30/07/2020.
    
    
    import Foundation
    
    /// Utility methods to be called within the project
    class Utilities {
        
            /// Readline alike function that returns an Int? (Nil if user's input is a string)
            fileprivate static func readInt() -> Int? {
                    let int : Int? = readLine().flatMap(Int.init(_:))
                    return int
            }
        
            /// Ask till user enters an integer
            fileprivate static func waitForInt() -> Int {
                
                    var number : Int?
                    repeat {
                            number = self.readInt()
                    } while number == nil
                    return number!
            }
        
            /// Asks user to enter an integer ranged between a choosen range.
            static func waitForInput(message: String, condition: ClosedRange<Int>) -> Int {
                    var choice : Int
                    repeat {
                            print(message)
                            choice = self.waitForInt()
                    } while !condition.contains(choice)
                    return choice
            }
        
            /// Checks if a string "name" exists in an array "names" and returns true if so
            static func nameExists(names: [String], name: String) -> Bool {
                    var exists = false
                    if names.firstIndex(of: name) != nil {
                            exists = true
                    }
                    return exists
            }
    }

    extension String {
        
            ///Apply a lowercase & capitalize filter to a string
            func normalize() -> String {
                    var newString = self.lowercased()
                    newString = self.capitalized
                    return newString
            }
            /// Checks if a string is blank
            var isBlank: Bool {
                    return allSatisfy({ $0.isWhitespace })
            }
    }

    
    // rpg/Model/Weapon.swift
    //
    //  Weapon.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 15/07/2020.
    //  MIT
    //
    
    import Foundation
    
    class Weapon {
            /// Defines the power of the weapon
            var power : Int = 40
        
            /// Creates a weapon with a random power
            static func randomWeapon(character: Character) {
                    let random = Int.random(in: 1...3)
                    let matchingNumber = 1
                    if random == matchingNumber {
                            let factor = Double.random(in: 0.5...3.0)
                            let power = Double(character.weapon.power) * factor
                            character.weapon.power = Int(power)
                            print("\(character.name) \(game.text.foundWeapon) \(character.weapon.power)")
                    }
            }
    }

    
    // rpg/Model/Weapons/Arc.swift
    //
    //  Arc.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 30/07/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import Foundation
    
    class Arc : Weapon {
            override init() {
                            super.init()
                            power = 60
                    }
    }

    
    // rpg/Model/Weapons/Sword.swift
    //
    //  Sword.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 30/07/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import Foundation
    
    class Sword : Weapon {
            override init() {
                    super.init()
                    power = 50
            }
    }

    
    // rpg/Model/Weapons/Wand.swift
    //
    //  Wand.swift
    //  rpg
    //
    //  Created by Cristian Rojas on 30/07/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import Foundation
    
    class Wand : Weapon {
                override init() {
                            super.init()
                            power = 70
                    }
    }

    
    
    // p3-instagrid.swift
    
    // p4_Instagrid/AppDelegate.swift
    //
    //  AppDelegate.swift
    //  p4_Instagrid
    //
    //  Created by Cristian Rojas on 18/08/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import UIKit
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
    var window: UIWindow?
        
            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                    // Override point for customization after application launch.
                    return true
            }
        
            // MARK: UISceneSession Lifecycle
            @available(iOS 13, *)
            func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
                    // Called when a new scene session is being created.
                    // Use this method to select a configuration to create the new scene with.
                    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            }
        
            @available(iOS 13, *)
            func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
                    // Called when the user discards a scene session.
                    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
                    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
            }
        
        
    }

    
    
    // p4_Instagrid/Controller/ViewController.swift
    //
    //  ViewController.swift
    //  p4_Instagrid
    //
    //  Created by Cristian Rojas on 18/08/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import UIKit
    
    class ViewController: UIViewController, UINavigationControllerDelegate {
        
            @IBOutlet var layoutCollection: [UIButton]!
            @IBOutlet var gridButtonCollection: [GridButton]!
            @IBOutlet weak var gridView: UIView!
            @IBOutlet weak var swipeLabel: UILabel!
        
            private let selectedCheckboxImage = UIImage(named: "Selected")
            private var imagePicker = UIImagePickerController()
        
            /// Retrieves the pressed button. Useful for changing it's image with the image picker delegate methods
            private var pressedGridButton: GridButton!
        
            /// Retrieves one of the three selected layotus
            private var selectedLayout: Int = 2
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                
                    setSwipeGestures()
                    setSwipeLabelOnLaunch()
                
            }
        
            /// Changes swipelabel text on rotation
            override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
                    swipeLabel.text = fromInterfaceOrientation.isLandscape ? "Swipe up to share" : "Swipe left to share"
            }
        
            /// Allows user to pick an image for the grid by using the imagePicker
            @IBAction func gridButtonPressed(_ sender: UIButton) {
                    if let sender = sender as? GridButton {
                            pressedGridButton = sender
                            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                            imagePicker.allowsEditing = true
                            imagePicker.delegate = self
                            self.present(imagePicker, animated: true)
                    }
            }
        
            /// Allows user to chose the layout
            @IBAction func layoutButtonPressed(_ sender: UIButton) {
                    switch sender.tag {
                    case 1:
                            selectedLayout = 1
                            hideButton(with: 1, sender: sender)
                    case 2:
                            selectedLayout = 2
                            hideButton(with: 3, sender: sender)
                    case 3:
                            selectedLayout = 3
                            clearLayoutButtons()
                            clearGridButtons()
                            sender.setImage(selectedCheckboxImage, for: .normal)
                    default:
                            break
                    }
            }
    }

    // MARK: Private methods
    private extension ViewController {
        
            func setSwipeGestures() {
                    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(shareOnSwipe(_:)))
                    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(shareOnSwipe(_:)))
                
                    swipeUp.direction = .up
                    swipeLeft.direction = .left
                
                    view.addGestureRecognizer(swipeUp)
                    view.addGestureRecognizer(swipeLeft)
            }
        
            /// Creates an activity controller on swipe left or up
            @objc func shareOnSwipe(_ sender: UISwipeGestureRecognizer) {
                    switch selectedLayout {
                    case 1, 2:
                            itemsWithPicture() == 3 ? sharerActivityController(sender: sender) : emptyItemsAlert(sender: sender)
                    case 3:
                            itemsWithPicture() == 4 ? sharerActivityController(sender: sender) : emptyItemsAlert(sender: sender)
                    default:
                            break
                    }
            }
        
            /// Changes swipe label text if the app is launched in landscape mode
            private func setSwipeLabelOnLaunch() {
                    let orientation = UIApplication.shared.statusBarOrientation
                    if orientation.isLandscape {
                            swipeLabel.text = "Swipe left to share"
                    }
            }
        
            /// Returns the number of items of the grid that have a picture (UIButton.backgroundImage != nil)
            func itemsWithPicture() -> Int {
                    var buttonsWithBackground = [GridButton]()
                    gridButtonCollection.forEach {
                            if $0.backgroundImage(for: .normal) != nil {
                                    buttonsWithBackground.append($0)
                            }
                        
                    }
                    return buttonsWithBackground.count
            }
        
            /// Presents an activity controller that allows the user to share a picture of the grid collage
            func sharerActivityController(sender: UISwipeGestureRecognizer) {
                    guard let image = gridView.asImage()
                    else { return }
                
                    let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                
                    presentView(sender: sender, view: activityController)
            }
        
            /// Presents an alert controller if there are empty items of the grid (no picture provided by the user)
            func emptyItemsAlert(sender: UISwipeGestureRecognizer) {
                    let alert = UIAlertController(title: "Empty items", message: "Some of the the grid items haven't a picture yet. Please provide a picture for all the items", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                    presentView(sender: sender, view: alert)
            }
        
            private func presentView(sender: UISwipeGestureRecognizer, view: UIViewController) {
                    let orientation = UIApplication.shared.statusBarOrientation
                    if sender.direction == .up && orientation.isPortrait {
                            self.present(view, animated: true)
                    } else if sender.direction == .left && orientation.isLandscape {
                            self.present(view, animated: true)
                    }
            }
        
            /// Clear checkbox image every time user changes layout
            func clearLayoutButtons() {
                    layoutCollection.forEach {
                            $0.setImage(nil, for: .normal)
                    }
            }
        
            /// Clears grid button image every time user changes layout
            func clearGridButtons() {
                    gridButtonCollection.forEach {
                            $0.setImage(UIImage(named: "Combined Shape"), for: .normal)
                            $0.setBackgroundImage(nil, for: .normal)
                            $0.isHidden = false
                    }
            }
        
            /// Hides a buttton on the grid in order to adapt to the selected layout
            func hideButton(with tag: Int, sender: UIButton) {
                    clearLayoutButtons()
                    clearGridButtons()
                
                    sender.setImage(selectedCheckboxImage, for: .normal)
                
                    gridButtonCollection.forEach {
                            if $0.tag == tag {
                                    $0.isHidden = true
                            }
                    }
            }
    }

    // MARK: UIImagePickerControllerDelegate
    extension ViewController: UIImagePickerControllerDelegate {
        
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                    guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
                
                    pressedGridButton.setPicture(backgroundImage: image)
                    pressedGridButton.layoutIfNeeded()
                    pressedGridButton.subviews.first?.contentMode = .scaleAspectFill
                
                    dismiss(animated: true, completion: nil)
            }
        
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                    dismiss(animated: true, completion: nil)
            }
    }

    
    
    
    // p4_Instagrid/Extension/UIView.swift
    //
    //  UIView.swift
    //  p4_Instagrid
    //
    //  Created by Cristian Rojas on 12/09/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import UIKit
    
    extension UIView {
        
            func asImage() -> UIImage? {
                
                    UIGraphicsBeginImageContext(self.frame.size)
                    guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
                    self.layer.render(in: currentContext)
                    guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
                    UIGraphicsEndImageContext()
                    guard let cgImage = image.cgImage else { return nil }
                    return UIImage(cgImage: cgImage)
            }
    }

    
    
    // p4_Instagrid/SceneDelegate.swift
    //
    //  SceneDelegate.swift
    //  p4_Instagrid
    //
    //  Created by Cristian Rojas on 18/08/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import UIKit
    
    @available(iOS 13, *)
    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        
            var window: UIWindow?
        
        
            func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
                    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
                    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
                    guard let _ = (scene as? UIWindowScene) else { return }
            }
        
            func sceneDidDisconnect(_ scene: UIScene) {
                    // Called as the scene is being released by the system.
                    // This occurs shortly after the scene enters the background, or when its session is discarded.
                    // Release any resources associated with this scene that can be re-created the next time the scene connects.
                    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
            }
        
            func sceneDidBecomeActive(_ scene: UIScene) {
                    // Called when the scene has moved from an inactive state to an active state.
                    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
            }
        
            func sceneWillResignActive(_ scene: UIScene) {
                    // Called when the scene will move from an active state to an inactive state.
                    // This may occur due to temporary interruptions (ex. an incoming phone call).
            }
        
            func sceneWillEnterForeground(_ scene: UIScene) {
                    // Called as the scene transitions from the background to the foreground.
                    // Use this method to undo the changes made on entering the background.
            }
        
            func sceneDidEnterBackground(_ scene: UIScene) {
                    // Called as the scene transitions from the foreground to the background.
                    // Use this method to save data, release shared resources, and store enough scene-specific state information
                    // to restore the scene back to its current state.
            }
        
        
    }

    
    
    // p4_Instagrid/View/GridButton.swift
    //
    //  GridButton.swift
    //  p4_Instagrid
    //
    //  Created by Cristian Rojas on 12/09/2020.
    //  Copyright © 2020 Cristian Rojas. All rights reserved.
    //
    
    import UIKit
    
    class GridButton: UIButton {
        
            func setPicture(backgroundImage: UIImage?) {
                    // Sets Aspect of the backgroundImage
                    self.setImage(nil, for: .normal)
                    self.setBackgroundImage(backgroundImage, for: .normal)
            }
    }

    
    
    // p4-reciplease.swift
    
    // Reciplease/Application/AppDelegate.swift
    //
    //  AppDelegate.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 20/03/2021.
    //
    
    import UIKit
    import CoreData
    
    @main
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
            /// Necessary on iOS11
            var window: UIWindow?
        
            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                    // Override point for customization after application launch.
                    setupTabbar()
                
                    let attrs = [
                            NSAttributedString.Key.foregroundColor: UIColor.darkPurple,
                            NSAttributedString.Key.font: UIFont.textBiggest
                    ]
                
                            UINavigationBar.appearance().titleTextAttributes = attrs
                
                
                
                    return true
            }
        
            // MARK: UISceneSession Lifecycle
            @available(iOS 13.0, *)
            func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
                    // Called when a new scene session is being created.
                    // Use this method to select a configuration to create the new scene with.
                    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            }
        
            @available(iOS 13.0, *)
            func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
                    // Called when the user discards a scene session.
                    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
                    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
            }
    }

    // MARK: - App UI
    private extension AppDelegate {
            func setupTabbar() {
                    let appearance = UITabBar.appearance()
                
                
                    appearance.backgroundColor = .cream
                
                    appearance.shadowImage =  UIImage()
                    appearance.backgroundImage = UIImage()
                
                    let tintColor = UIColor.darkPurple
                
                    appearance.unselectedItemTintColor = tintColor.withAlphaComponent(0.4)
                
                    let attributes = [
                            NSAttributedString.Key.foregroundColor: tintColor,
                    ]
                
                    UITabBar.appearance().tintColor = tintColor
                    UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
            }
    }

    
    // Reciplease/Application/SceneDelegate.swift
    //
    //  SceneDelegate.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 20/03/2021.
    //
    
    import UIKit
    
    @available(iOS 13.0, *)
    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        
            var window: UIWindow?
        
            func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
                    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
                    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
                    guard let _ = (scene as? UIWindowScene) else { return }
            }
        
            func sceneDidDisconnect(_ scene: UIScene) {
                    // Called as the scene is being released by the system.
                    // This occurs shortly after the scene enters the background, or when its session is discarded.
                    // Release any resources associated with this scene that can be re-created the next time the scene connects.
                    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
            }
        
            func sceneDidBecomeActive(_ scene: UIScene) {
                    // Called when the scene has moved from an inactive state to an active state.
                    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
            }
        
            func sceneWillResignActive(_ scene: UIScene) {
                    // Called when the scene will move from an active state to an inactive state.
                    // This may occur due to temporary interruptions (ex. an incoming phone call).
            }
        
            func sceneWillEnterForeground(_ scene: UIScene) {
                    // Called as the scene transitions from the background to the foreground.
                    // Use this method to undo the changes made on entering the background.
            }
        
            func sceneDidEnterBackground(_ scene: UIScene) {
                    // Called as the scene transitions from the foreground to the background.
                    // Use this method to save data, release shared resources, and store enough scene-specific state information
                    // to restore the scene back to its current state.
                
                    // Save changes in the application's managed object context when the application transitions to the background.
    //        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            }
        
        
    }

    
    
    // Reciplease/Data/Api.swift
    //
    //  Api.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 05/04/2021.
    //
    
    import Foundation
    
    enum Api {
            static let edamam: RecipleaseApiInput = RecipleaseApi()
    }

    
    // Reciplease/Data/Cache/CacheManager.swift
    //
    //  CacheManager.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 23/04/2021.
    //
    
    import Foundation
    
    struct CacheManager {
            var recipeImages: [String: Data] = [:]
        
            mutating func clearCache() {
                    recipeImages = [:]
            }
    }

    var cacheManager = CacheManager()
    
    
    // Reciplease/Data/Client/Edamam.swift
    //
    //  Edamam.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 20/03/2021.
    //
    
    import Alamofire
    
    enum Edamam {
            static let baseURL = "https://api.edamam.com/"
            static let apiKey = ""
            static let appId = ""
        
            case getSearch(query: String)
    }

    extension Edamam: URLRequestConvertible {
        
            var path: String {
                    switch self {
                    case .getSearch(_):
                            return "search"
                    }
            }
        
            var method: HTTPMethod {
                    switch self {
                    case .getSearch(_):
                            return .get
                    }
            }
        
        
            var urlComponents: [URLQueryItem] {
                    var components = [URLQueryItem]()
                    components.append(URLQueryItem(name: "app_id", value: Edamam.appId))
                    components.append(URLQueryItem(name: "app_key", value: Edamam.apiKey))
                
                    switch self {
                    case .getSearch(let query):
                            components.append(URLQueryItem(name: "q", value: query))
                        
                    }
                    return components
            }
        
            func asURLRequest() throws -> URLRequest {
                    var urlRequest: URLRequest
                
                    switch self {
                    case .getSearch(_):
                            var components = URLComponents(string: Edamam.baseURL+"/"+path)
                        
                            components?.queryItems = urlComponents
                            components?.queryItems = urlComponents
                        
                            urlRequest = URLRequest(url: (components?.url!)!)
                    }
                
                    return urlRequest
            }
        
    }

    
    // Reciplease/Data/Client/EdamamApi.swift
    //
    //  EdamamApi.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 20/03/2021.
    //
    
    import Alamofire
    
    protocol RecipleaseApiInput {
            func getSearch(query: String, completion: @escaping (Result<RecipeResponse, Error>) -> Void)
    }

    class RecipleaseApi: RecipleaseApiInput {
            func getSearch(query: String, completion: @escaping (Result<RecipeResponse, Error>) -> Void) {
                
                    do {
                            let request = try Edamam.getSearch(query: query).asURLRequest()
                        
                            AF.request(request).responseJSON { (response) in
                                    switch response.result {
                                    case .failure(_):
                                            completion(.failure(Error(type: .networkError)))
                                    case .success:
                                            guard let data = response.data else {
                                                    completion(.failure(Error(type: .noDataError)))
                                                    return
                                            }
                                        
                                            do {
                                                    let recipes = try JSONDecoder().decode(RecipeResponse.self, from: data)
                                                    completion(.success(recipes))
                                                    return
                                            } catch {
                                                    completion(.failure(Error(type: .decodingError)))
                                            }
                                    }
                            }
                    } catch {
                            return
                    }
            }
    }

    
    // Reciplease/Data/CoreData/CoreDataStack.swift
    //
    //  CoreDataStack.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import CoreData
    
    //class CoredataStack {
    //    lazy var persistentContainer: NSPersistentContainer = {
    //        /*
    //         The persistent container for the application. This implementation
    //         creates and returns a container, having loaded the store for the
    //         application to it. This property is optional since there are legitimate
    //         error conditions that could cause the creation of the store to fail.
    //        */
    //        let container = NSPersistentContainer(name: "Reciplease")
    //        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
    //            if let error = error as NSError? {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //
    //                /*
    //                 Typical reasons for an error here include:
    //                 * The parent directory does not exist, cannot be created, or disallows writing.
    //                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
    //                 * The device is out of space.
    //                 * The store could not be migrated to the current model version.
    //                 Check the error message to determine what the actual problem was.
    //                 */
    //                fatalError("Unresolved error \(error), \(error.userInfo)")
    //            }
    //        })
    //        return container
    //    }()
    //
    //    // MARK: - Core Data Saving support
    //
    //    func saveContext () {
    //        let context = persistentContainer.viewContext
    //        if context.hasChanges {
    //            do {
    //                try context.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nserror = error as NSError
    //                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    //            }
    //        }
    //    }
    //}
    
    open class CoreDataStack {
        public static let modelName = "Reciplease"
        
        public static let model: NSManagedObjectModel = {
            // swiftlint:disable force_unwrapping
            let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }()
        // swiftlint:enable force_unwrapping
        
        public init() {
        }
        
        public lazy var mainContext: NSManagedObjectContext = {
            return self.storeContainer.viewContext
        }()
        
        public lazy var storeContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: CoreDataStack.modelName, managedObjectModel: CoreDataStack.model)
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
        
        public func newDerivedContext() -> NSManagedObjectContext {
            let context = storeContainer.newBackgroundContext()
            return context
        }
        
        public func saveContext() {
            saveContext(mainContext)
        }
        
        public func saveContext(_ context: NSManagedObjectContext) {
            if context != mainContext {
                saveDerivedContext(context)
                return
            }
            
            context.perform {
                do {
                    try context.save()
                } catch let error as NSError {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
        
        public func saveDerivedContext(_ context: NSManagedObjectContext) {
            context.perform {
                do {
                    try context.save()
                } catch let error as NSError {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
                
                self.saveContext(self.mainContext)
            }
        }
    }

    
    
    // Reciplease/Data/CoreData/RecipesCoredataManager.swift
    //
    //  RecipeCoredataManager.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import CoreData
    import Foundation
    
    class RecipesCoredataManager {
        
            let stack: CoreDataStack
            let managedObjectContext: NSManagedObjectContext
        
        
            init(stack: CoreDataStack, managedObject: NSManagedObjectContext) {
                    self.stack = stack
                    self.managedObjectContext = managedObject
            }
        
            func storedRecipes() -> [RecipeCD]? {
                    let reportFetch: NSFetchRequest<RecipeCD> = RecipeCD.fetchRequest()
                            do {
                                let results = try managedObjectContext.fetch(reportFetch)
                                return results
                            } catch let error as NSError {
                                print("Fetch error: \(error) description: \(error.userInfo)")
                            }
                            return nil
            }
        
            func add(recipe: RecipeBO) {
                
                    let newRecipe = RecipeCD(context: managedObjectContext)
                
                    newRecipe.uri = recipe.uri
                    newRecipe.label = recipe.label
                    newRecipe.image = recipe.image
                    newRecipe.source = recipe.source
                    newRecipe.url = recipe.url
                    newRecipe.shareAs = recipe.shareAs
                    newRecipe.yield = Int16(recipe.yield ?? 0)
                    newRecipe.ingredients = recipe.ingredients
                    newRecipe.totalTime = Int32(recipe.totalTime)
                
                    stack.saveContext(managedObjectContext)
            }
        
        
            func delete(recipe: RecipeCD) {
                    managedObjectContext.delete(recipe)
                    stack.saveContext(managedObjectContext)
                
            }
    }

    
    // Reciplease/Data/Repository/RecipesRepository.swift
    //
    //  RecipesRepository.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 05/04/2021.
    //
    
    import Foundation
    
    enum SearchViewState: Equatable {
            case loading
            case success(RecipeResponse)
            case error
        
            var isLoading: Bool {
                    self == .loading
            }
    }

    protocol RecipesRepositoryInput {
            var output: RecipesRepositoryOutput? { get set }
            func performSearch(query: String)
    }

    protocol RecipesRepositoryOutput: AnyObject {
            func didPerformSearch(_ result: Result<RecipeResponse, Error>)
            func didUpdate(state: SearchViewState)
    }

    class RecipesRepository: RecipesRepositoryInput {
        
            weak var output: RecipesRepositoryOutput?
            private var api: RecipleaseApiInput
        
            init(api: RecipleaseApiInput = Api.edamam) {
                    self.api = api
            }
        
            func performSearch(query: String) {
                    output?.didUpdate(state: .loading)
                    api.getSearch(query: query) { [weak output] result in
                            output?.didPerformSearch(result)
                    }
            }
    }

    
    // Reciplease/Domain/Model/Api/Recipe.swift
    //
    //  Recipe.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import Foundation
    
    struct Recipe: Equatable {
            let uri: String
            let label: String
            let image: String
            let source: String
            let url: String
            let shareAs: String
            let yield: Int
            let ingredients: [String]
            let totalTime: Int
    }

    extension Recipe: Decodable {
            private enum CodingKeys: String, CodingKey {
                    case uri
                    case label
                    case image
                    case source
                    case url
                    case shareAs
                    case yield
                    case ingredients
                    case totalTime
            }
        
            init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                
                    uri = try container.decode(String.self, forKey: .uri)
                    url = try container.decode(String.self, forKey: .url)
                    label = try container.decode(String.self , forKey: .label)
                    image = try container.decode(String.self, forKey: .image)
                    source = try container.decode(String.self, forKey: .source)
                    shareAs = try container.decode(String.self, forKey: .shareAs)
                    yield = try container.decode(Int.self, forKey: .yield)
                    totalTime = try container.decode(Int.self, forKey: .totalTime)
                
                    let tmpIngredients = try container.decode([Ingredient].self, forKey: .ingredients)
                    ingredients = tmpIngredients.map { $0.text }
                
            }
    }

    
    // Reciplease/Domain/Model/Api/RecipesResponse.swift
    //
    //  RecipesResponse.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 05/04/2021.
    //
    
    import CoreData
    import Foundation
    
    struct RecipeResponse: Equatable {
            let recipes: [Recipe]
    }

    extension RecipeResponse: Decodable {
            private enum CodingKeys: String, CodingKey {
                    case hits
            }
        
            init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    let hits = try container.decode([Hit].self, forKey: .hits)
                    recipes = hits.map { $0.recipe }
            }
    }

    
    // Reciplease/Domain/Model/Error.swift
    //
    //  Error.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 05/04/2021.
    //
    
    import Foundation
    
    enum ErrorType: Equatable {
            case invalidURL
            case noDataError
            case decodingError
            case networkError
        
            var message: String {
                    switch self {
                    case .invalidURL:
                            return "Invalid url"
                    case .noDataError:
                            return "No data found"
                    case .decodingError:
                            return "Fail while decoding"
                    case .networkError:
                            return "Network error"
                    }
            }
    }

    struct Error: Swift.Error {
            let type: ErrorType
    }

    
    // Reciplease/Domain/Model/FoodEmoji.swift
    //
    //  FoodEmoji.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 27/03/2021.
    //
    
    enum FoodEmojis: String, CaseIterable {
            case Chicken = "🍗"
            case Tomato = "🍅"
            case Grappes = "🍇"
            case Melon = "🍈"
            case Watermelon = "🍉"
            case Tangerine = "🍊"
            case Lemon = "🍋"
            case Banana = "🍌"
            case Pineapple = "🍍"
            case Mango = "🥭"
            case Apple = "🍎"
            case Pear = "🍐"
            case Peach = "🍑"
            case Cherries = "🍒"
            case Strawberry = "🍓"
            case Kiwi = "🥝"
            case Coconut = "🥥"
            case Avocado = "🥑"
            case Eggplant = "🍆"
            case Potato = "🥔"
            case Carrot = "🥕"
            case Corn = "🌽"
            case HotPepper = "🌶️"
            case Cucumber = "🥒"
            case LeafyGreen = "🥬"
            case Broccoli = "🥦"
            case Garlic = "🧄" //
            case Onion = "🧅" //
            case Mushroom = "🍄"
            case Peanuts = "🥜"
            case Chestnut = "🌰"
            case Bread = "🍞"
            case Cheese = "🧀"
            case Beef = "🥩"
            case Bacon = "🥓"
            case Taco = "🌮"
            case Burrito = "🌯"
            case Egg = "🥚"
            case Salad = "🥗"
            case Butter = "🧈" //
            case Salt = "🧂"
            case Rice = "🍚"
            case Pasta = "🍝"
            case Shrimp = "🦐"
            case Oyster = "🦪" //
            case IceCream = "🍦"
            case Chocolate = "🍫"
            case Honey = "🍯"
            case Milk = "🥛"
            case Coffee = "☕"
            case Tea = "🍵"
            case Sake = "🍶"
            case Wine = "🍷"
            case Beer = "🍺"
        
            static var model: [String: String] {
                    Dictionary(uniqueKeysWithValues: FoodEmojis.allCases.map{ ($0.name.lowercased(), $0.rawValue) })
            }
        
            var name: String {
                    switch self {
                    case .Chicken: return S.Chicken
                    case .Tomato: return S.Tomato
                    case .Grappes: return S.Grappes
                    case .Melon: return S.Melon
                    case .Watermelon: return S.Watermelon
                    case .Tangerine: return S.Tangerine
                    case .Lemon: return S.Lemon
                    case .Banana: return S.Banana
                    case .Pineapple: return S.Pineapple
                    case .Mango: return S.Mango
                    case .Apple: return S.Apple
                    case .Pear: return S.Pear
                    case .Peach: return S.Peach
                    case .Cherries: return S.Cherries
                    case .Strawberry: return S.Strawberry
                    case .Kiwi: return S.Kiwi
                    case .Coconut: return S.Coconut
                    case .Avocado: return S.Avocado
                    case .Eggplant: return S.Eggplant
                    case .Potato: return S.Potato
                    case .Carrot: return S.Carrot
                    case .Corn: return S.Corn
                    case .HotPepper: return S.HotPepper
                    case .Cucumber: return S.Cucumber
                    case .LeafyGreen: return S.LeafyGreen
                    case .Broccoli: return S.Broccoli
                    case .Garlic: return S.Garlic
                    case .Onion: return S.Onion
                    case .Mushroom: return S.Mushroom
                    case .Peanuts: return S.Peanuts
                    case .Chestnut: return S.Chestnut
                    case .Bread: return S.Bread
                    case .Cheese: return S.Cheese
                    case .Beef: return S.Beef
                    case .Bacon: return S.Bacon
                    case .Taco: return S.Taco
                    case .Burrito: return S.Burrito
                    case .Egg: return S.Egg
                    case .Salad: return S.Salad
                    case .Butter: return S.Butter
                    case .Salt: return S.Salt
                    case .Rice: return S.Rice
                    case .Pasta: return S.Pasta
                    case .Shrimp: return S.Shrimp
                    case .Oyster: return S.Oyster
                    case .IceCream: return S.IceCream
                    case .Chocolate: return S.Chocolate
                    case .Honey: return S.Honey
                    case .Milk: return S.Milk
                    case .Coffee: return S.Coffee
                    case .Tea: return S.Tea
                    case .Sake: return S.Sake
                    case .Wine: return S.Wine
                    case .Beer: return S.Beer
                    }
            }
    }

    
    // Reciplease/Domain/Model/Hit.swift
    //
    //  Hit.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import Foundation
    
    struct Hit: Decodable {
            let recipe: Recipe
    }

    
    // Reciplease/Domain/Model/Ingredient.swift
    //
    //  Ingredient.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import Foundation
    
    
    // MARK: - Ingredient
    struct Ingredient: Equatable, Codable {
            let text: String
        
            enum CodingKeys: String, CodingKey {
                    case text
            }
    }

    
    // Reciplease/Domain/Model/ListType.swift
    //
    //  ListType.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import Foundation
    
    enum ListType {
            case search
            case favorite
    }

    
    // Reciplease/Domain/Model/RecipeBO.swift
    //
    //  RecipeBO.swift
    //  Reciplease
    //
    //  Created by Cristian Rojas on 01/05/2021.
    //
    
    import Foundation
    
    struct RecipeBO {
        
            let uri: String
            let label: String
            let image: String
            let source: String
            let url: String
            let shareAs: String
            let yield: Int
            let ingredients: [String]
            let totalTime: Int
        
            let isFavorite: Bool
        
            init(recipe: Recipe, isFavorite: Bool) {
                    uri = recipe.uri
                    label = recipe.label
                    image = recipe.image
                    source = recipe.source
                    url = recipe.url
                    shareAs = recipe.shareAs
                    yield = recipe.yield
                    ingredients = recipe.ingredients
                    totalTime = recipe.totalTime
                
                    self.isFavorite = isFavorite
            }
        
            init(recipe: RecipeCD) {
                    uri = recipe.uri ?? "Empty string"
                    label = recipe.label ?? "Empty string"
                    image = recipe.image ?? "Empty string"
                    source = recipe.source ?? "Empty string"
                    url = recipe.url ?? ""
                    shareAs = recipe.shareAs ?? "Empty string"
                    yield = Int(recipe.yield)
                    ingredients = recipe.ingredients ?? [ ]
                    totalTime = Int(recipe.totalTime)
                
                
                    isFavorite = true
            }
    }

    
    // Reciplease/Extension/Array+filterDuplicates.swift
    //
    //  Array+filterDuplicates.swift
    //  Reciplease
    //
    //  Created by Cristian Rojas on 29/05/2021.
    //
    
    import Foundation
    
    extension Array where Element: Equatable {
            func filterDuplicates() -> [Element] {
                    var newArray = [Element]()
                    for item in self {
                            if newArray.firstIndex(of: item) == nil {
                                    newArray.append(item)
                            }
                    }
                    return newArray
            }
    }

    
    // Reciplease/Extension/Array+getOrNull.swift
    //
    //  Array+getOrNull.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 05/04/2021.
    //
    
    import Foundation
    
    extension Array {
        
            func getOrNull(at index: Int) -> Element? {
                    indices.contains(index) ? self[index] : nil
            }
    }

    
    // Reciplease/Extension/String+appText.swift
    //
    //  String+appText.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 27/03/2021.
    //
    
    import Foundation
    
    enum S {
        
            // MARK: - Generics
            static let search = "search".localized
            static let attention = "attention".localized
            static let ok = "ok".localized
            static let done = "done".localized
        
            // MARK: - Search
            static let searchHeading = "search_heading".localized
            static let searchSubHeading = "search_subheading".localized
            static let searchPlaceholder = "search_placeholder".localized
            static let searchIngredientList = "search_ingredient_list".localized
            static let searchClearAll = "search_clear_all".localized
        
            static let getDirections = "get_directions".localized
        
            // MARK: - Errors
            static let errorUnknown = "errorUnknown".localized
            static let errorEmptyIngredients = "errorEmptyIngredients".localized
            static let errorIngredientExists = "errorIngredientExists".localized
            static let errorAddingToFavoritres = "error_adding_to_favorites".localized
            static let errorNetwork = "errorNetwork".localized
        
        
            static let favorites = "favorites".localized
            static let noFavoritesYet = "no_favorites_yet".localized
            static let results = "results".localized
            static let noResultsFound = "no_results_found".localized
            static let howToFavorites = "how_to_favorites".localized
        
        
        
            // MARK: - Ingredients
            static let Chicken = "Chicken".localized
            static let Tomato = "Tomato".localized
            static let Grappes = "Grappes".localized
            static let Melon = "Melon".localized
            static let Watermelon = "Watermelon".localized
            static let Tangerine = "Tangerine".localized
            static let Lemon = "Lemon".localized
            static let Banana = "Banana".localized
            static let Pineapple = "Pineapple".localized
            static let Mango = "Mango".localized
            static let Apple = "Apple".localized
            static let Pear = "Pear".localized
            static let Peach = "Peach".localized
            static let Cherries = "Cherries".localized
            static let Strawberry = "Strawberry".localized
            static let Kiwi = "Kiwi".localized
            static let Coconut = "Coconut".localized
            static let Avocado = "Avocado".localized
            static let Eggplant = "Eggplant".localized
            static let Potato = "Potato".localized
            static let Carrot = "Carrot".localized
            static let Corn = "Corn".localized
            static let HotPepper = "HotPepper".localized
            static let Cucumber = "Cucumber".localized
            static let LeafyGreen = "LeafyGreen".localized
            static let Broccoli = "Broccoli".localized
            static let Garlic = "Garlic".localized
            static let Onion = "Onion".localized
            static let Mushroom = "Mushroom".localized
            static let Peanuts = "Peanuts".localized
            static let Chestnut = "Chestnut".localized
            static let Bread = "Bread".localized
            static let Cheese = "Cheese".localized
            static let Beef = "Beef".localized
            static let Bacon = "Bacon".localized
            static let Taco = "Taco".localized
            static let Burrito = "Burrito".localized
            static let Egg = "Egg".localized
            static let Salad = "Salad".localized
            static let Butter = "Butter".localized
            static let Salt = "Salt".localized
            static let Rice = "Rice".localized
            static let Pasta = "Pasta".localized
            static let Shrimp = "Shrimp".localized
            static let Oyster = "Oyster".localized
            static let IceCream = "IceCream".localized
            static let Chocolate = "Chocolate".localized
            static let Honey = "Honey".localized
            static let Milk = "Milk".localized
            static let Coffee = "Coffee".localized
            static let Tea = "Tea".localized
            static let Sake = "Sake".localized
            static let Wine = "Wine".localized
            static let Beer = "Beer".localized
    }

    
    // Reciplease/Extension/String+Localized.swift
    //
    //  Strings+Localized.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 27/03/2021.
    //
    
    import Foundation
    
    extension String {
            var localized: String {
                    NSLocalizedString(self, comment: "")
            }
    }

    
    // Reciplease/Extension/UIColor+Colors.swift
    //
    //  UIColor+Colors.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 27/03/2021.
    //
    
    import UIKit
    
    extension UIColor {
            static let salmon = UIColor(named:"salmon")!
            static let cream = UIColor(named: "cream")!
            static let darkPurple = UIColor(named: "darkPurple")!
            static let darkPurple50 = UIColor(named: "darkPurple50")!
            static let darkerCream = UIColor(named: "darkerCream")!
            static let paleBrown = UIColor(named: "paleBrown")!
            static let blood = UIColor(named: "blood")!
            static let pink = UIColor(named: "pink")!
            static let brightSalmon = UIColor(named:"brightSalmon")!
            static let strongSalmon = UIColor(named: "strongSalmon")!
            static let deepGreen = UIColor(named: "deepGreen")!
        
            static let paleBrown50 = UIColor(named: "paleBrown50")!
            static let cream50 = UIColor(named: "cream50")!
    }

    
    // Reciplease/Extension/UIEdgeInsets+same.swift
    //
    //  UIEdgeInsets+same.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import UIKit
    
    extension UIEdgeInsets {
            static func same(with float: CGFloat) -> UIEdgeInsets {
                    return UIEdgeInsets(top: float, left: float, bottom: float, right: float)
            }
    }

    
    // Reciplease/Extension/UIFont+Fonts.swift
    //
    //  UIFont+Fonts.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 28/03/2021.
    //
    
    import UIKit
    
    extension UIFont {
            class var textBiggest: UIFont {
                    return UIFont(name: "FuturaPT-Bold", size: 24.0)!
            }
        
            class var textBig: UIFont {
                    return UIFont(name: "FuturaPT-Bold", size: 18.0)!
            }
        
            class var textMedium: UIFont {
                    return UIFont(name: "FuturaPT-Medium", size: 16.0)!
            }
        
            class var textSmall: UIFont {
                    return UIFont(name: "FuturaPT-Medium", size: 12.0)!
            }
    }

    
    // Reciplease/Extension/UITextField+addDoneToolbar.swift
    //
    //  UITextField+addDoneToolbar.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 05/04/2021.
    //
    
    import Foundation
    import UIKit
    
    extension UITextField {
            func addDoneToolbar(onDone: (target: Any, action: Selector)? = nil) {
                    let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
                
                    let toolbar: UIToolbar = UIToolbar()
                    toolbar.barStyle = .default
                    toolbar.items = [
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                            UIBarButtonItem(title: S.done, style: .done, target: onDone.target, action: onDone.action)
                    ]
                
                    toolbar.sizeToFit()
                
                    self.inputAccessoryView = toolbar
            }
        
            @objc func doneButtonTapped() { self.resignFirstResponder() }
    }

    
    
    // Reciplease/Extension/UIViewController+escapeKeyboard.swift
    //
    //  UIViewController+escapeKeyboard.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 28/03/2021.
    //
    
    import UIKit
    
    extension UIViewController {
            func escapeKeyboard() {
                    let closeKeyboard = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
                
                    self.view.addGestureRecognizer(closeKeyboard)
            }
        
            @objc func dismissKeyboard() {
                    view.endEditing(true)
            }
    }

    
    // Reciplease/Extension/UIViewController+showAlert.swift
    //
    //  UIViewController+showAlert.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 04/04/2021.
    //
    
    import UIKit
    
    extension UIViewController {
        
            func showAlert(message: String) {
                    let alert = UIAlertController(title: S.attention, message: message, preferredStyle: UIAlertController.Style.alert)
                
                    let okAction = UIAlertAction(title: S.ok, style: .default)
                
                    alert.addAction(okAction)
                    present(alert, animated: true)
            }
    }

    
    // Reciplease/Routing/NSObject+NameOfClass.swift
    //
    //  NSObject+NameOfClass.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import Foundation
    
    
    extension NSObject {
            class var nameOfClass: String {
                    NSStringFromClass(self).components(separatedBy: ".").last!
            }
    }

    
    // Reciplease/Routing/Presentable.swift
    //
    //  Presentable.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import UIKit
    
    
    protocol Presentable {
            func toPresent() -> UIViewController?
    }

    extension UIViewController: Presentable {
        
            func toPresent() -> UIViewController? {
                    self
            }
    }

    
    // Reciplease/Routing/Routable.swift
    //
    //  Routable.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import UIKit
    
    protocol Routable {
            /// Router build with a navigationController if available
            var router: RouterProtocol? { get }
    }

    extension UIViewController: Routable {
            var router: RouterProtocol? {
                    guard let nc = navigationController else { return nil }
                    return Router(rootController: nc)
            }
    }

    
    // Reciplease/Routing/RouterProtocol.swift
    //
    //  RouterProtocol.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import UIKit
    
    // MARK: Router protocols
    protocol RouterProtocol {
        
            func present(_ module: Presentable?)
            func present(_ module: Presentable?, animated: Bool)
            func present(_ module: Presentable?, withNavigationController: Bool, isFullScreen: Bool)
        
            func push(_ module: Presentable?)
            func push(_ module: Presentable?, hideBottomBar: Bool)
            func push(_ module: Presentable?, animated: Bool)
            func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?)
            func push(_ module: Presentable?, animated: Bool, hideBottomBar: Bool, completion: (() -> Void)?)
        
            func popModule()
            func popModule(animated: Bool)
        
            func dismissModule()
            func dismissModule(animated: Bool, completion: (() -> Void)?)
        
            func popToRootModule(animated: Bool)
    }

    
    class Router: RouterProtocol {
        
            private weak var rootController: UINavigationController?
        
            init(rootController: UINavigationController) {
                    self.rootController = rootController
            }
        
            func present(_ module: Presentable?) {
                    present(module, animated: true)
            }
        
            func present(_ module: Presentable?, animated: Bool) {
                    guard let controller = module?.toPresent() else { return }
                    rootController?.present(controller, animated: animated, completion: nil)
            }
        
            func presdent(_ module: Presentable?, animated: Bool, withNavigationController: Bool) {
                    guard let controller = module?.toPresent() else { return }
                    if withNavigationController {
                            let navVC = UINavigationController(rootViewController: controller)
                            navVC.modalPresentationStyle = .none
                            rootController?.present(navVC, animated: animated, completion: nil)
                    } else {
                            rootController?.present(controller, animated: animated, completion: nil)
                    }
            }
        
            func present(_ module: Presentable?, withNavigationController: Bool, isFullScreen: Bool) {
                    guard let controller = module?.toPresent() else { return }
                    var vc = controller
                    if withNavigationController {
                            vc = UINavigationController(rootViewController: controller)
                    }
                
                    if isFullScreen {
                            vc.modalPresentationStyle = .fullScreen
                    }
                    rootController?.present(vc, animated: true, completion: nil)
            }
        
            func push(_ module: Presentable?) {
                    push(module, animated: true)
            }
        
            func push(_ module: Presentable?, hideBottomBar: Bool) {
                    push(module, animated: true, hideBottomBar: hideBottomBar, completion: nil)
            }
        
            func push(_ module: Presentable?, animated: Bool) {
                    push(module, animated: animated, completion: nil)
            }
        
            func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?) {
                    push(module, animated: animated, hideBottomBar: false, completion: completion)
            }
        
            func push(_ module: Presentable?, animated: Bool, hideBottomBar: Bool, completion: (() -> Void)?) {
                    guard
                            let controller = module?.toPresent(),
                            (controller is UINavigationController == false)
                            else { assertionFailure("Deprecated push UINavigationController."); return }
                
                    controller.hidesBottomBarWhenPushed = hideBottomBar
                    rootController?.pushViewController(controller, animated: animated)
            }
        
            func popModule() {
                    popModule(animated: true)
            }
        
            func popModule(animated: Bool) {
                    rootController?.popViewController(animated: animated)
            }
        
            func dismissModule() {
                    dismissModule(animated: true, completion: nil)
            }
        
            func dismissModule(animated: Bool, completion: (() -> Void)?) {
                    rootController?.dismiss(animated: animated, completion: completion)
            }
        
            func popToRootModule(animated: Bool) {
                    rootController?.popToRootViewController(animated: animated)
            }
        
            func toPresent() -> UIViewController? {
                    rootController
            }
        
    }

    
    // Reciplease/Routing/RoutingNavigationOption.swift
    //
    //  RoutingNavigationOption.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import Foundation
    
    struct RoutingNavigationOption {
            let type: RoutingType
            let withNavigationController: Bool
            let isFullScreen: Bool
        
            init(type: RoutingType = .push,
                        withNavigationController: Bool = false,
                        isFullScreen: Bool = false) {
                    self.type = type
                    self.withNavigationController = withNavigationController
                    self.isFullScreen = isFullScreen
            }
    }

    
    // Reciplease/Routing/RoutingType.swift
    //
    //  RoutingType.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import Foundation
    
    enum RoutingType {
            case push
            case present
    }

    
    
    // Reciplease/Routing/Storyboards.swift
    //
    //  Storyboards.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import Foundation
    
    enum Storyboards: String {
            case list = "List"
            case search = "Search"
            case detail = "Detail"
    }

    
    // Reciplease/Routing/UIViewController+Storyboards.swift
    //
    //  UIViewController+Storyboards.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import UIKit
    
    extension UIViewController {
            private class func instantiateControllerInStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, identifier: String) -> T {
                    return storyboard.instantiateViewController(withIdentifier: identifier) as! T
            }
        
            class func controllerInStoryboard(_ storyboard: UIStoryboard, identifier: String) -> Self {
                    return instantiateControllerInStoryboard(storyboard, identifier: identifier)
            }
        
            class func controllerInStoryboard(_ storyboard: UIStoryboard) -> Self {
                    return controllerInStoryboard(storyboard, identifier: nameOfClass)
            }
        
            class func controllerFromStoryboard(_ storyboard: Storyboards) -> Self {
                    return controllerInStoryboard(UIStoryboard(name: storyboard.rawValue, bundle: nil), identifier: nameOfClass)
            }
    }

    
    // Reciplease/Screens/Detail/DetailModuleFactory.swift
    //
    //  DetailModuleFactory.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import UIKit
    
    class DetailModuleFactory {
            class func makeModule(model: RecipeBO) -> DetailViewController {
                    let view = DetailViewController()
                    view.model = model
                    return view
            }
    }

    
    // Reciplease/Screens/Detail/DetailView/Components/DetailMetaView.swift
    //
    //  DetailMetaView.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import UIKit
    
    class DetailMetaView: UIView {
        
            private lazy var label: UILabel = {
                    let view = UILabel()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.font = .textSmall
                    return view
            }()
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
                    setupUI()
            }
        
            required init?(coder: NSCoder) {
                    super.init(coder: coder)
                    setupUI()
            }
        
        
            private func setupUI() {
                
                    // MARK: - Form
                    layer.cornerRadius = 12
                    layer.masksToBounds = true
                    backgroundColor = .darkerCream
                    label.textColor = .paleBrown
                
                    // MARK: - Costraints
                    addSubview(label)
                    NSLayoutConstraint.activate([
                            label.centerYAnchor.constraint(equalTo: centerYAnchor),
                            label.centerXAnchor.constraint(equalTo: centerXAnchor)
                    ])
            }
        
            func setLabel(_ label: String) {
                    self.label.text = label
            }
        
    }

    
    // Reciplease/Screens/Detail/DetailView/Components/FavoriteButton.swift
    //
    //  FavoriteButton.swift
    //  Reciplease
    //
    //  Created by Cristian Rojas on 22/05/2021.
    //
    
    import UIKit
    
    class FavoriteButton: UIButton {
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
            }
        
            required init?(coder: NSCoder) {
                    super.init(coder: coder)
            }
        
            private var isFavorite: Bool = false {
                    didSet {
                            setupState()
                    }
            }
        
            func setState(favorite: Bool) {
                    isFavorite = favorite
            }
        
            private func setupState() {
                    isFavorite ? setFavoriteUI() : setNotFavoriteUI()
            }
        
            func toggle() {
                    isFavorite.toggle()
            }
        
            private func setFavoriteUI() {
                    setImage(UIImage(named: "icHeartFilled")!, for: .normal)
                    tintColor = .red
            }
        
            private func setNotFavoriteUI() {
                    setImage(UIImage(named: "icHeart"), for: .normal)
                    tintColor = .darkPurple
            }
    }

    
    // Reciplease/Screens/Detail/DetailView/Components/RecipeMetaDataView.swift
    //
    //  RecipeMetaDataView.swift
    //  Reciplease
    //
    //  Created by Cristian Rojas on 30/05/2021.
    //
    
    import UIKit
    
    class RecipeMetaDataView: UIStackView {
        
            private lazy var timeView: UILabel = {
                    let view = UILabel()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.font = .textSmall
                    return view
            }()
        
            private lazy var yieldView: UILabel = {
                    let view = UILabel()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.font = .textSmall
                    return view
            }()
        
            required init(coder: NSCoder) {
                    super.init(coder: coder)
                    commonInit()
            }
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
                    commonInit()
            }
        
            private func commonInit() {
                    backgroundColor = .paleBrown50
                    layer.cornerRadius = 4
                
                    addArrangedSubview(timeView)
                    addArrangedSubview(yieldView)
            }
        
            func hideTimeLabel() {
                    timeView.isHidden = true
            }
        
            func hideYieldLabel() {
                    yieldView.isHidden = true
            }
        
            func setTimeLabel(_ time: Int) {
                    timeView.text = "⏱" + " " + "\(time)"
            }
        
            func setYieldLabel(_ yield: Int) {
                    yieldView.text = "👍" + " " + "\(yield)"
            }
    }

    
    // Reciplease/Screens/Detail/DetailView/DetailView.swift
    //
    //  DetailView.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import Alamofire
    import CoreData
    import UIKit
    
    class DetailView: UIView {
        
            lazy var picture: UIImageView = {
                    let view = UIImageView()
                    view.contentMode = .scaleAspectFill
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
            }()
        
            lazy var contentView: UIView = {
                    let view = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.backgroundColor = .cream
                    return view
            }()
        
            lazy var titleLabel: UILabel = {
                    let view = UILabel()
                    view.font = .textBiggest
                    view.numberOfLines = 0
                    view.textColor = .darkPurple
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
            }()
        
            lazy var favoriteButton: FavoriteButton = {
                    let view = FavoriteButton()
                    view.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
            }()
        
            lazy var totalTimeView: DetailMetaView = {
                    let view = DetailMetaView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
            }()
        
            lazy var ingredientsTableView: UITableView = {
                    let view = UITableView()
                    view.backgroundView = nil
                    view.backgroundColor = .clear
                    view.tableFooterView = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
            }()
        
            lazy var ingredientsLabel: UILabel = {
                    let view = UILabel()
                    view.font = .textMedium
                    view.textColor = .darkPurple
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
            }()
        
            lazy var getButton: DefaultButton = {
                    let view = DefaultButton()
                    view.addTarget(self, action: #selector(getButtonPressed), for: .touchUpInside)
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
            }()
        
            lazy var informationStackView: RecipeMetaDataView = {
                    let view = RecipeMetaDataView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.axis = .vertical
                    view.spacing = UIStackView.spacingUseSystem
                    view.isLayoutMarginsRelativeArrangement = true
                    view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                    return view
            }()
        
            var model: RecipeBO!
            var delegate: DetailViewDelegate?
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
                    commonInit()
            }
        
            required init?(coder: NSCoder) {
                    super.init(coder: coder)
                    commonInit()
            }
    }

    private extension DetailView {
        
            @objc
            func favoriteButtonPressed() {
                    delegate?.didTapFavoriteButton(model)
            }
        
            @objc
            func getButtonPressed() {
                    delegate?.didTapGetDirectionButton()
            }
    }

    
    // Reciplease/Screens/Detail/DetailView/DetailView+commonInit.swift
    //
    //  DetailView+setupUI.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import UIKit
    
    // MARK: - UI methods
    extension DetailView {
            func commonInit() {
                    backgroundColor = .red
                    setupConstraints()
                    ingredientsTableView.showsVerticalScrollIndicator = false
            }
        
            func setupConstraints() {
                    addSubview(picture)
                    picture.image = UIImage(named: "recipe-placeholder")!
                    NSLayoutConstraint.activate([
                            picture.topAnchor.constraint(equalTo: topAnchor),
                            picture.leadingAnchor.constraint(equalTo: leadingAnchor),
                            picture.trailingAnchor.constraint(equalTo: trailingAnchor),
                            picture.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4)
                    ])
                
                    addSubview(contentView)
                    contentView.layer.cornerRadius = 44
                    contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    NSLayoutConstraint.activate([
                            contentView.topAnchor.constraint(equalTo: picture.bottomAnchor, constant: -40),
                            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
                    ])
                
                    addSubview(favoriteButton)
                    NSLayoutConstraint.activate([
                            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
                            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
                            favoriteButton.widthAnchor.constraint(equalToConstant: 24)
                    ])
                
                    contentView.addSubview(titleLabel)
                    NSLayoutConstraint.activate([
                            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
                            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor, constant: -8)
                    ])
                
                    addSubview(getButton)
                    NSLayoutConstraint.activate([
                            getButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                            getButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                            getButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                            getButton.heightAnchor.constraint(equalToConstant: 48)
                    ])
                
                    contentView.addSubview(ingredientsTableView)
                    NSLayoutConstraint.activate([
                            ingredientsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                            ingredientsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                            ingredientsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
                            ingredientsTableView.bottomAnchor.constraint(equalTo: getButton.topAnchor)
                    ])
                
                    addSubview(informationStackView)
                    NSLayoutConstraint.activate([
                            informationStackView.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: -12),
                            informationStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                        
                    ])
            }
    }

    
    // Reciplease/Screens/Detail/DetailView/DetailView+setValues.swift
    //
    //  DetailView+setValues.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import Alamofire
    import CoreData
    import UIKit
    
    extension DetailView {
        
            func setTableViewController(_ delegateAndDataSource: UITableViewDelegate & UITableViewDataSource) {
                    ingredientsTableView.delegate = delegateAndDataSource
                    ingredientsTableView.dataSource = delegateAndDataSource
            }
        
            func set(model: RecipeBO) {
                    self.model = model
                    setPicture(with: model)
                    setTitleLabel(model.label)
                    setButtonLink(model.shareAs)
                    setButtonTitle(S.getDirections)
                    setTimeCountLabel(model.totalTime)
                    setYieldLabel(model.yield)
                    setFavoriteState(model.isFavorite)
            }
        
            func setFavoriteState(_ favorite: Bool) {
                    favoriteButton.setState(favorite: favorite)
            }
        
            private func setPicture(with model: RecipeBO) {
                    if let cachedData = cacheManager.recipeImages[model.label],
                            let image = UIImage(data: cachedData) {
                            picture.image = image
                    } else {
                            setPicture(with: model.image, and: model.label)
                    }
            }
        
            private func setPicture(with url: String, and label: String) {
                
                    AF.request(url, method: .get).response{ response in
                        
                            switch response.result {
                            case .success(let responseData):
                                
                                    guard
                                            let safeData = responseData,
                                            let image = UIImage(data: safeData) else
                                    {
                                            return
                                    }
                                
                                    cacheManager.recipeImages[label] = safeData
                                    self.picture.image = image
                                
                            case .failure(let error):
                                    /// @nth
                                    print("error--->",error)
                            }
                    }
            }
        
            private func setButtonLink(_ url: String) { }
            private func setButtonTitle(_ title: String) {
                    getButton.setTitle(title, for: .normal)
            }
        
            private func setTitleLabel(_ label: String) {
                    titleLabel.text = label
            }
        
            private func setIngredientsLabel(_ label: String) {
                    ingredientsLabel.text = label
            }
        
            private func setTimeCountLabel(_ time: Int) {
                    informationStackView.setTimeLabel(time)
                    if time == 0 {
                            informationStackView.hideTimeLabel()
                    }
                
            }
        
            private func setYieldLabel(_ yield: Int) {
                    informationStackView.setYieldLabel(yield)
                    if yield == 0 {
                            informationStackView.hideYieldLabel()
                    }
            }
    }

    
    // Reciplease/Screens/Detail/DetailViewController.swift
    //
    //  DetailViewController.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/04/2021.
    //
    
    import Alamofire
    import CoreData
    import UIKit
    import SafariServices
    
    
    protocol DetailViewDelegate {
            func didTapFavoriteButton(_ checkModel: RecipeBO)
            func didTapGetDirectionButton()
    }

    protocol DetailViewControllerDelegate: AnyObject {
            func detailsViewControllerDidDelete(recipe: RecipeBO)
    }

    class DetailViewController: UIViewController {
        
            private lazy var rootView: DetailView = {
                    let view = DetailView()
                    view.delegate = self
                    return view
            }()
        
            var model: RecipeBO!
            weak var delegate: DetailViewControllerDelegate?
        
            lazy var stack = CoreDataStack()
            lazy var managedObject = stack.mainContext
            lazy var coredataManager = RecipesCoredataManager(stack: stack, managedObject: managedObject)
        
            override func loadView() {
                    view = rootView
            }
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                    rootView.set(model: model)
                    rootView.setTableViewController(self)
                    setupNavbar()
            }
        
            private func setupNavbar() {
                    navigationController?.navigationBar.prefersLargeTitles = false
            }
    }

    extension DetailViewController: DetailViewDelegate {
        
            func didTapFavoriteButton(_ model: RecipeBO) {
                    if model.isFavorite {
                        
                            guard let coredataRecipes = coredataManager.storedRecipes() else { return }
                        
                            guard let recipe = coredataRecipes
                                            .filter({ $0.url == model.url })
                                            .first else
                            {
                                    showAlert(message: S.errorAddingToFavoritres)
                                    return
                            }
                            coredataManager.delete(recipe: recipe)
                            delegate?.detailsViewControllerDidDelete(recipe: model)
                    } else {
                            coredataManager.add(recipe: model)
                    }
                
                
                    rootView.favoriteButton.toggle()
            }
        
            func didTapGetDirectionButton() {
                    if let safeURL = URL(string: model.shareAs) {
                                    let config = SFSafariViewController.Configuration()
                                    config.entersReaderIfAvailable = true
                        
                            let vc = SFSafariViewController(url: safeURL, configuration: config)
                                    present(vc, animated: true)
                            }
            }
    }

    extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                    model.ingredients.count
            }
        
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    let cell = UITableViewCell()
                    let cellModel = model.ingredients
                    cell.textLabel?.text = cellModel[indexPath.row]
                    cell.backgroundColor = .clear
                    cell.textLabel?.font = .textMedium
                    cell.textLabel?.textColor = .darkPurple
                    cell.selectionStyle = .none
                
                    return cell
            }
    }

    
    // Reciplease/Screens/List/Components/RecipeTableViewCell.swift
    //
    //  RecipeCell.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 16/04/2021.
    //
    
    import Alamofire
    import UIKit
    
    
    class RecipeTableViewCell: UITableViewCell {
        
            static let identifier: String = "RecipeCell"
        
            @IBOutlet weak var picture: UIImageView!
            @IBOutlet weak var titleLabel: UILabel!
            @IBOutlet weak var likeCountLabel: UILabel!
            @IBOutlet weak var timeLabel: UILabel!
            @IBOutlet weak var timeView: UIView!
        
            override func layoutSubviews() {
                    setupUI()
            }
        
        
            func configure(model: RecipeBO) {
                
                    titleLabel.text = model.label
                    timeLabel.text = "\(model.totalTime) MIN"
                    likeCountLabel.text? = "👍 \(model.yield)"
                
                    if model.totalTime == 0 {
                            timeView.isHidden = true
                    }
                
            }
        
            func set(image: UIImage) {
                    picture.image = image
            }
        
            func setImage(with url: String, and label: String) {
                
                    AF.request(url, method: .get).response { [weak self] response in
                            guard let self = self else { return }
                            switch response.result {
                            case .success(let responseData):
                                
                                    guard
                                            let safeData = responseData,
                                            let safeImage = UIImage(data: safeData)
                                    else {
                                            self.set(image: UIImage(named: "recipe-placeholder")!)
                                            return
                                    }
                                
                                    cacheManager.recipeImages[label] = safeData
                                    self.set(image: safeImage)
                                
                                
                            case .failure(let error):
                                    self.set(image: UIImage(named: "recipe-placeholder")!)
                                    #if DEBUG
                                    print(error)
                                    #endif
                            }
                    }
            }
        
            private func setupUI() {
                
                    layer.cornerRadius = 28
                    layer.masksToBounds = true
                    backgroundColor = .brightSalmon
                
                    picture.layer.cornerRadius = 28
                    picture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                
                    titleLabel.font = .textBiggest
                    likeCountLabel.font = .textMedium
    //        timeLabel.font = .textSmall
                
                    titleLabel.textColor = .darkPurple
                    likeCountLabel.textColor = .darkPurple
                    timeLabel.textColor =  .darkPurple
                
                    timeView.layer.cornerRadius = 12
            }
        
    }

    
    // Reciplease/Screens/List/ListModuleFactory.swift
    //
    //  ListModuleFactory.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import Foundation
    
    class ListModuleFactory {
            class func makeModule(model: [RecipeBO], type: ListType) -> ListViewController {
                    let view = ListViewController.controllerFromStoryboard(.list)
                    view.model = model
                    view.type = type
                    return view
            }
    }

    
    // Reciplease/Screens/List/ListViewController.swift
    //
    //  ListViewController.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 27/03/2021.
    //
    
    import Alamofire
    import UIKit
    
    class ListViewController: UIViewController {
        
            @IBOutlet weak var tableView: UITableView!
            @IBOutlet weak var emtpyStateView: UIView!
            @IBOutlet weak var emptyStateImage: UIImageView!
            @IBOutlet weak var emptyLabel: UILabel!
        
            var model: [RecipeBO] = [ ]
            var type: ListType = .search
        
            override func viewDidAppear(_ animated: Bool) {
                    super.viewDidAppear(animated)
                    setupState()
            }
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                    setupUI()
            }
        
            private func setupUI() {
                
                    setupType()
                    setupTableView()
                    setupNavigationBar()
                
                    emptyLabel.font = .textMedium
                    emptyLabel.textColor = .blood
                    emtpyStateView.isHidden = true
            }
        
            /// Setups view state.
            /// If model is empty we should give feedback to the user
            private func setupState() {
                    if model.isEmpty {
                            tableView.isHidden = true
                            emtpyStateView.isHidden = false
                    } else {
                            tableView.isHidden = false
                            emtpyStateView.isHidden = true
                    }
                
                    tableView.reloadData()
            }
        
            private func setupType() {
                    if type == .favorite {
                            navigationItem.title = S.favorites
                            emptyStateImage.image = UIImage(named: "empty-favorites")!
                            emptyLabel.text = S.noFavoritesYet + "\n" + S.howToFavorites
                    } else {
                            navigationItem.title = S.results
                            emptyStateImage.image = UIImage(named: "empty-search")!
                            emptyLabel.text = S.noResultsFound
                    }
            }
        
            private func setupTableView() {
                    tableView.backgroundView = nil
                    tableView.backgroundColor = .clear
                    tableView.separatorColor = .clear
                    tableView.showsVerticalScrollIndicator = false
                    tableView.delegate = self
                    tableView.dataSource = self
            }
        
            private func setupNavigationBar() {
                    navigationController?.navigationBar.tintColor = UIColor.darkPurple
                
                    navigationController?.navigationBar.largeTitleTextAttributes =
                            [NSAttributedString.Key.foregroundColor: UIColor.darkPurple,
                                NSAttributedString.Key.font: UIFont.textBiggest]
                
                    navigationController?.navigationBar.barTintColor = .cream
                    navigationController?.navigationBar.shadowImage = UIImage()
            }
    }

    // MARK:- Table View Delegate
    extension ListViewController: UITableViewDataSource, UITableViewDelegate {
        
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
                
                    guard
                            let model = model.getOrNull(at:indexPath.section),
                            let cell = tableView.dequeueReusableCell(withIdentifier: RecipeTableViewCell.identifier, for: indexPath) as? RecipeTableViewCell
                    else {
                            return UITableViewCell()
                    }
                
                    if
                            let cachedData = cacheManager.recipeImages[model.label],
                            let image = UIImage(data: cachedData) {
                                
                            cell.set(image: image)
                    } else {
                            cell.setImage(with: model.image, and: model.label)
                    }
                
                    cell.configure(model: model)
                
                    return cell
            }
        
            func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                    180
            }
        
            func numberOfSections(in tableView: UITableView) -> Int {
                    model.count
            }
        
            // There is just one row in every section
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                    1
            }
        
            // Set the spacing between sections
            func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
                    28
            }
        
            // Make the background color show through
            func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                    let headerView = UIView()
                    headerView.backgroundColor = UIColor.clear
                    return headerView
            }
        
            // method to run when table view cell is tapped
            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                    let view = DetailModuleFactory.makeModule(model: model[indexPath.section])
                    view.delegate = self
                    router?.push(view)
            }
    }

    extension ListViewController: DetailViewControllerDelegate {
            func detailsViewControllerDidDelete(recipe: RecipeBO) {
                    model.removeAll { $0.url == recipe.url }
                    tableView.reloadData()
            }
    }

    
    // Reciplease/Screens/Search/Components/CollectionView/TagCollectionViewCell.swift
    //
    //  TagCollectionViewCell.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 04/04/2021.
    //
    
    import UIKit
    
    class TagCollectionViewCell: UICollectionViewCell {
            @IBOutlet var tagLabel: UILabel!
            override func awakeFromNib() {
                    super.awakeFromNib()
                    setupUI()
            }
        
            private func setupUI() {
                
                    // MARK: - Background
                    layer.cornerRadius = 20
                    layer.masksToBounds = true
                    backgroundColor = .brightSalmon
                
                    // MARK: - Label
                    tagLabel.font = .textSmall
                    tagLabel.textColor = .blood
            }
    }

    
    // Reciplease/Screens/Search/Components/CollectionView/TagFlowLayout.swift
    //
    //  TagFlowLayout.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 05/04/2021.
    //
    
    import UIKit
    
    class Row {
            var attributes = [UICollectionViewLayoutAttributes]()
            var spacing: CGFloat = 0
        
            init(spacing: CGFloat) {
                    self.spacing = spacing
            }
        
            func add(attribute: UICollectionViewLayoutAttributes) {
                    attributes.append(attribute)
            }
        
            func tagLayout(collectionViewWidth: CGFloat) {
                    let padding = 10
                    var offset = padding
                    for attribute in attributes {
                            attribute.frame.origin.x = CGFloat(offset)
                            offset += Int(attribute.frame.width + spacing)
                    }
            }
    }

    class TagFlowLayout: UICollectionViewFlowLayout {
            override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
                    guard let attributes = super.layoutAttributesForElements(in: rect) else {
                            return nil
                    }
                
                    var rows = [Row]()
                    var currentRowY: CGFloat = -1
                
                    for attribute in attributes {
                            if currentRowY != attribute.frame.origin.y {
                                    currentRowY = attribute.frame.origin.y
                                    rows.append(Row(spacing: 10))
                            }
                            rows.last?.add(attribute: attribute)
                    }
                
                    rows.forEach { $0.tagLayout(collectionViewWidth: collectionView?.frame.width ?? 0) }
                    return rows.flatMap { $0.attributes }
            }
    }

    
    // Reciplease/Screens/Search/Components/SearchButton.swift
    //
    //  SearchButton.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 04/04/2021.
    //
    
    import UIKit
    
    @IBDesignable
    class SearchButton: UIButton {
        
            private var activityIndicator = FoodActivityIndicator()
        
            var isLoading: Bool = false {
                    didSet {
                            isEnabled = !isLoading
                            handleLoadingState()
                    }
            }
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
                    setupButton()
            }
        
            required init?(coder aDecoder: NSCoder) {
                    super.init(coder: aDecoder)
                    setupButton()
            }
        
            private func handleLoadingState() {
                    if isLoading {
                            activityIndicator.startAnimating()
                            clearIcon()
                            setTitleColor(.clear, for: .normal)
                    } else {
                            activityIndicator.stopAnimating()
                            setupIcon()
                            setTitleColor(.white, for: .normal)
                    }
            }
        
            private func setupButton() {
                
                    setTitleColor(.white, for: .normal)
                    setTitleColor(.white, for: .highlighted)
                    setTitleColor(.white, for: .selected)
                    layer.cornerRadius = frame.height / 2
                    titleLabel?.font = .textMedium
                    backgroundColor = .strongSalmon
                
                    setupIcon()
                    setupIndicator()
            }
        
            private func setupIndicator() {
                    activityIndicator.hidesWhenStopped = true
                    addSubview(activityIndicator)
                    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                            activityIndicator.widthAnchor.constraint(equalToConstant: 40)
                    ])
            }
        
            private func setupIcon() {
                    let icon = UIImage(named: "icSearchButton")!.withRenderingMode(.alwaysOriginal)
                    setImage(icon, for: .normal)
                    imageView?.contentMode = .scaleAspectFit
                    imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
                
            }
        
            private func clearIcon() {
                    let icon = UIImage()
                    setImage(icon, for: .normal)
            }
    }

    
    // Reciplease/Screens/Search/SearchVC+CollectionView.swift
    //
    //  SearchVC+CollectionView.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 04/04/2021.
    //
    
    import UIKit
    
    extension SearchViewController:
            UICollectionViewDataSource,
            UICollectionViewDelegate,
            UICollectionViewDelegateFlowLayout {
                
            func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                    dataSource.count
            }
                
            func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                    guard
                            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell
                    else {
                            return TagCollectionViewCell()
                    }
                
                
                    if let value = FoodEmojis.model[dataSource[indexPath.row]] {
                            cell.tagLabel.text = value + " " + dataSource[indexPath.row]
                    } else {
                            cell.tagLabel.text = dataSource[indexPath.row]
                    }
                
                    cell.tagLabel.preferredMaxLayoutWidth = collectionView.frame.width - 32
                    return cell
            }
                
            func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
                    dataSource.remove(at: indexPath.item)
                    collectionView.reloadData()
                
            }
    }

    
    // Reciplease/Screens/Search/SearchVC+SetupUI.swift
    //
    //  SearchVC+SetupUI.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 28/03/2021.
    //
    
    import UIKit
    
    extension SearchViewController {
        
            func setupUI() {
                
                    setupCollectionView()
                
                    subHeadingLabel.text = S.searchSubHeading
                    subHeadingLabel.font = .textMedium
                    subHeadingLabel.textColor = .darkPurple
                
                    ingredientsLabel.text = S.searchIngredientList
                    ingredientsLabel.font = .textBig
                    ingredientsLabel.textColor = .darkPurple
                
                    clearButton.imageEdgeInsets = UIEdgeInsets.same(with: 18)
                    clearButton.backgroundColor = .pink
                    clearButton.tintColor = .blood
                    clearButton.layer.cornerRadius = 52 / 2
                    clearButton.layer.masksToBounds = true
                
                
                    searchBarView.backgroundColor = .darkerCream
                    searchBarView.layer.cornerRadius = 26
                
                
                    appendButton.layer.cornerRadius = 22
                    appendButton.layer.masksToBounds = true
                    searchTextField.delegate = self
                    searchTextField.font = UIFont.textMedium
                    searchTextField.textColor = .darkPurple
                    searchTextField.attributedPlaceholder = NSAttributedString(
                            string: S.searchPlaceholder,
                            attributes: [
                                    NSAttributedString.Key.foregroundColor: UIColor.paleBrown,
                                    NSAttributedString.Key.font: UIFont.textSmall
                            ])
                
                    searchButton.setTitle(S.search, for: .normal)
                
                    setupNavbar()
                    setupIngredientsSection()
            }
        
            private func setupCollectionView() {
                    collectionView.delegate = self
                    collectionView.dataSource = self
                    let layout = TagFlowLayout()
                    layout.estimatedItemSize = CGSize(width: 140, height: 40)
                    collectionView.collectionViewLayout = layout
            }
        
            private func setupNavbar() {
                
                    navigationItem.title = S.searchHeading
                    navigationController?.navigationBar.prefersLargeTitles = true
                
                    // Clears shadow
                    navigationController?.navigationBar.shadowImage = UIImage()
                    navigationController?.navigationBar.barTintColor = UIColor.cream50
                    navigationController?.navigationBar.largeTitleTextAttributes =
                            [NSAttributedString.Key.foregroundColor: UIColor.darkPurple,
                                NSAttributedString.Key.font: UIFont.textBiggest]
            }
        
            func setupIngredientsSection() {
                    if dataSource.isEmpty {
                            hideIngredientSection()
                    } else {
                            showIngredientSection()
                    }
            }
        
            private func hideIngredientSection() {
                    ingredientsSectionHeader.isHidden = true
                    collectionView.isHidden = true
                    searchButton.isHidden = true
                    clearButton.isHidden = true
            }
        
            private func showIngredientSection() {
                    ingredientsSectionHeader.isHidden = false
                    clearButton.isHidden = false
                    collectionView.isHidden = false
                    searchButton.isHidden = false
            }
    }

    extension SearchViewController: UITextFieldDelegate {
            func textFieldDidBeginEditing(_ textField: UITextField) {
                
                    UIView.animate(withDuration: 0.4) {
                            self.searchBarView.backgroundColor = .white
                            self.searchBarView.layer.shadowColor = UIColor.black.cgColor
                            self.searchBarView.layer.shadowOpacity = 0.2
                            self.searchBarView.layer.shadowOffset = .zero
                            self.searchBarView.layer.shadowRadius = 2
                        
                            self.searchTextField.attributedPlaceholder = NSAttributedString(
                                    string: S.searchPlaceholder,
                                    attributes: [
                                            NSAttributedString.Key.font: UIFont.textMedium
                                    ])
                        
                            self.appendButton.backgroundColor = .deepGreen
                            self.appendButton.tintColor = .white
                    }
            }
        
            func textFieldDidEndEditing(_ textField: UITextField) {
                    UIView.animate(withDuration: 0.4) {
                            self.searchBarView.backgroundColor = .darkerCream
                            self.searchBarView.layer.shadowColor = UIColor.clear.cgColor
                            self.searchTextField.attributedPlaceholder = NSAttributedString(
                                    string: S.searchPlaceholder,
                                    attributes: [
                                            NSAttributedString.Key.font: UIFont.textSmall
                                    ])
                        
                            self.appendButton.backgroundColor = .pink
                            self.appendButton.tintColor = .blood
                    }
                
            }
    }

    
    // Reciplease/Screens/Search/SearchViewController.swift
    //
    //  SearchViewController.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 27/03/2021.
    //
    
    import UIKit
    
    class SearchViewController: UIViewController {
        
            @IBOutlet weak var subHeadingLabel: UILabel!
            @IBOutlet weak var searchTextField: UITextField! {
                    didSet { searchTextField.addDoneToolbar() }
            }
        
            @IBOutlet weak var searchBarView: UIView!
            @IBOutlet weak var appendButton: UIButton!
            @IBOutlet weak var ingredientsSectionHeader: UIStackView!
            @IBOutlet weak var ingredientsLabel: UILabel!
            @IBOutlet weak var clearButton: UIButton!
            @IBOutlet weak var collectionView: UICollectionView!
            @IBOutlet weak var searchButton: SearchButton!
        
        
            private lazy var repository: RecipesRepositoryInput = {
                    let repo = RecipesRepository()
                    repo.output = self
                    return repo
            }()
        
        
            lazy var stack = CoreDataStack()
            lazy var managedObject = stack.mainContext
            lazy var coredataManager = RecipesCoredataManager(stack: stack, managedObject: managedObject)
        
            var dataSource: [String] = [] {
                    didSet {
                            setupIngredientsSection()
                    }
            }
        
            var api: RecipleaseApiInput = RecipleaseApi()
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                
                    setupUI()
            }
        
        
            @IBAction func appendButtonPressed(_ sender: Any) {
                    guard
                            let safeIngredients = searchTextField.text?.replacingOccurrences(of: " ", with: "")
                    else {
                            dismissKeyboard()
                            showAlert(message: S.errorUnknown)
                            return
                    }
                
                    guard !safeIngredients.isEmpty else {
                            dismissKeyboard()
                            showAlert(message: S.errorEmptyIngredients)
                            return
                    }
                
                    let ingredients = safeIngredients.components(separatedBy: ",")
                
                    dataSource.append(contentsOf: ingredients)
                    dataSource = dataSource.filterDuplicates()
                    dismissKeyboard()
                    searchTextField.text = ""
                    collectionView.reloadData()
            }
        
            @IBAction func clearButtonPressed(_ sender: Any) {
                    dataSource = [ ]
                    collectionView.reloadData()
            }
        
            @IBAction func searchButtonPressed(_ sender: Any) {
                    searchButton.isLoading = true
                    let query = dataSource.joined(separator: "+")
                    repository.performSearch(query: query)
            }
    }

    extension SearchViewController: RecipesRepositoryOutput {
            func didPerformSearch(_ result: Result<RecipeResponse, Error>) {
                    switch result {
                    case .success(let response):
                            didUpdate(state: .success(response))
                    case .failure(_):
                            didUpdate(state: .error)
                    }
            }
        
            func didUpdate(state: SearchViewState) {
                    searchButton.isLoading = state.isLoading
                    switch state {
                    case .success(let response):
                        
                            guard let coredataRecipes = coredataManager.storedRecipes() else { return }
                        
                            let recipesBO: [RecipeBO] = response.recipes.map { recipe in
                                            let isFavorite = coredataRecipes.contains{ $0.url == recipe.url }
                                            return RecipeBO(recipe: recipe, isFavorite: isFavorite)
                                    }
                        
                            router?.push(ListModuleFactory.makeModule(model: recipesBO, type: .search))
                    case .error:
                            showAlert(message: S.errorNetwork)
                    default: break
                    }
            }
    }

    
    // Reciplease/Screens/Tabbar/TabbarViewController.swift
    //
    //  ViewController.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 20/03/2021.
    //
    import CoreData
    import UIKit
    
    class TabbarViewController: UITabBarController {
        
            lazy var stack = CoreDataStack()
            lazy var managedObject = stack.mainContext
            lazy var coredataManager = RecipesCoredataManager(stack: stack, managedObject: managedObject)
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                    self.delegate = self
            }
    }

    // MARK: - TabbarController Delegate
    extension TabbarViewController: UITabBarControllerDelegate {
        
        
            func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
                
                    if
                            let navigationController = viewController as? UINavigationController,
                            let safeFavoritesViewController = navigationController.viewControllers.first as? ListViewController
                            {
                            injectCoreDataModel(into: safeFavoritesViewController)
                    }
            }
        
            /// CoreData dependency injection into the Favorites Screen.
            /// Needed because we're using the same viewController to show search results
            private func injectCoreDataModel(into viewController: ListViewController) {
                
                
                    guard let coreDataRecipes = coredataManager.storedRecipes() else { return }
                
                    let model: [RecipeBO] = coreDataRecipes.map { RecipeBO(recipe: $0) }
                
                    viewController.type = .favorite
                    viewController.model = model
                
            }
    }

    
    // Reciplease/Screens/Tabbar/ViewController.swift
    //
    //  ViewController.swift
    //  Reciplease
    //
    //  Created by Cristian Rojas on 20/03/2021.
    //
    
    import Alamofire
    import UIKit
    
    class TabbarViewController: UIViewController {
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                    // Do any additional setup after loading the view.
            }
        
        
    }

    
    
    // Reciplease/UI/DefaultButton.swift
    //
    //  DefaultButton.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 01/05/2021.
    //
    
    import UIKit
    
    class DefaultButton: UIButton {
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
            }
        
            required init?(coder: NSCoder) {
                    super.init(coder: coder)
            }
        
            override func layoutSubviews() {
                    super.layoutSubviews()
                    backgroundColor = .pink
                    titleLabel?.font = .textMedium
                    titleLabel?.textColor = .blood
                    layer.cornerRadius = frame.height / 2
                    layer.masksToBounds = true
            }
    }

    
    // Reciplease/UI/FoodActivityIndicator.swift
    //
    //  Loader.swift
    //  Reciplease
    //
    //  Created by Cristian Felipe Patiño Rojas on 27/03/2021.
    //
    
    import UIKit
    
    @IBDesignable
    class FoodActivityIndicator: UIView {
        
            private let emojiLabel = UILabel()
            private var timer: Timer?
            private var index = 0
        
            var hidesWhenStopped: Bool = true
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
                    setupButton()
            }
        
            required init?(coder aDecoder: NSCoder) {
                    super.init(coder: aDecoder)
                    setupButton()
            }
        
            private func setupButton() {
                
                    backgroundColor = .clear
                
                    setupLabel()
            }
        
            private func setupLabel() {
                    addSubview(emojiLabel)
                    emojiLabel.font = emojiLabel.font.withSize(24)
                    emojiLabel.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                            emojiLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                            emojiLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    ])
            }
        
            func startAnimating() {
                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
                    if hidesWhenStopped { self.isHidden = false }
            }
        
            func startRotating() {
                    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
                    rotateAnimation.fromValue = 0.0
                    rotateAnimation.toValue = -Double.pi * 2
                    rotateAnimation.duration = 1.0
                    rotateAnimation.repeatCount = .infinity
                
                    emojiLabel.layer.add(rotateAnimation, forKey: nil)
            }
        
            func stopAnimating() {
                    timer?.invalidate()
                    if hidesWhenStopped { self.isHidden = true }
            }
        
            @objc
            func fireTimer() {
                    DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            if let emoji = FoodEmojis.allCases.getOrNull(at: self.index) {
                                    self.index += 1
                                    self.emojiLabel.text = emoji.rawValue
                            } else {
                                    self.index = 0
                                    self.emojiLabel.text = FoodEmojis.allCases[self.index].rawValue
                            }
                    }
            }
    }

    
    // RecipleaseTests/Data/CoreData/RecipesCoredataManagerTests.swift
    //
    //  RecipleaseCoredataManagerTests.swift
    //  RecipleaseTests
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/05/2021.
    //
    
    import CoreData
    import XCTest
    @testable import Reciplease
    
    class RecipesCoredataManagerTests: XCTestCase {
        
            var coreDataStack: CoreDataStack!
            var manager: RecipesCoredataManager!
        
            override func setUp() {
                    super.setUp()
                    coreDataStack = TestCoreDataStack()
                    manager = RecipesCoredataManager(
                            stack: coreDataStack,
                            managedObject: coreDataStack.mainContext
                    )
            }
        
            override func tearDown() {
                    coreDataStack = nil
                    manager = nil
            }
        
            func testAddRecipe() {
                
                    let newRecipe = RecipeBO(
                            recipe: Recipe(
                                    uri: "",
                                    label: "",
                                    image : "",
                                    source: "",
                                    url: "",
                                    shareAs: "",
                                    yield: 10,
                                    ingredients: [],
                                    totalTime: 0),
                            isFavorite: false)
                
                    manager.add(recipe: newRecipe)
            }
        
            func testRootContextIsSavedAfterAddingReport() {
                
                    let derivedContext = coreDataStack.newDerivedContext()
                
                    manager = RecipesCoredataManager(
                            stack: coreDataStack,
                            managedObject: derivedContext
                    )
                
                    expectation(
                            forNotification: .NSManagedObjectContextDidSave,
                            object: coreDataStack.mainContext
                    ) { _ in
                            return true
                    }
                
                    derivedContext.perform {
                            self.manager.add(recipe:
                                                                    RecipeBO(
                                                                            recipe: Recipe(
                                                                                    uri: "",
                                                                                    label: "",
                                                                                    image : "",
                                                                                    source: "",
                                                                                    url: "",
                                                                                    shareAs: "",
                                                                                    yield: 10,
                                                                                    ingredients: [],
                                                                                    totalTime: 0),
                                                                            isFavorite: false))
                    }
                
                    waitForExpectations(timeout: 2.0) { error in
                            XCTAssertNil(error, "Save did not occur")
                    }
            }
        
            func testFetchRecipes() {
                
                    let recipe = Recipe(
                            uri: "\(UUID())",
                            label: "Paella",
                            image : "",
                            source: "",
                            url: "",
                            shareAs: "",
                            yield: 0,
                            ingredients: [],
                            totalTime: 0
                    )
                
                    let newRecipe = RecipeBO(recipe: recipe, isFavorite: false)
                    self.manager.add(recipe: newRecipe)
                
                    let fetchedRecipes = manager.storedRecipes()
                
                    XCTAssertNotNil(fetchedRecipes)
                    XCTAssertTrue(fetchedRecipes?.count == 1)
                    XCTAssertTrue(recipe.uri == fetchedRecipes?.first?.uri)
                    XCTAssertTrue(recipe.label == fetchedRecipes?.first?.label)
            }
        
            func testDeleteRecipe() {
                
                    let recipe = Recipe(
                            uri: "\(UUID())",
                            label: "",
                            image : "",
                            source: "",
                            url: "",
                            shareAs: "",
                            yield: 0,
                            ingredients: [],
                            totalTime: 0
                    )
                
                    let newRecipe = RecipeBO(recipe: recipe, isFavorite: false)
                    self.manager.add(recipe: newRecipe)
                
                    var fetchedRecipes = manager.storedRecipes()
                    XCTAssertTrue(fetchedRecipes?.count == 1)
                    XCTAssertTrue(recipe.uri == fetchedRecipes?.first?.uri)
                
                    manager.delete(recipe: fetchedRecipes!.first!)
                
                    fetchedRecipes = manager.storedRecipes()
                
                    XCTAssertTrue(fetchedRecipes?.isEmpty ?? false)
            }
    }

    
    // RecipleaseTests/Data/CoreData/TestCoreDataStack.swift
    //
    //  CoreDataTests.swift
    //  RecipleaseTests
    //
    //  Created by Cristian Felipe Patiño Rojas on 17/05/2021.
    //
    
    import CoreData
    @testable import Reciplease
    
    class TestCoreDataStack: CoreDataStack {
        override init() {
            super.init()
            
            
            /// Creates an in-memory persistent store
            let persistentStoreDescription = NSPersistentStoreDescription()
            persistentStoreDescription.type = NSInMemoryStoreType
            
            
            let container = NSPersistentContainer(
                name: CoreDataStack.modelName,
                managedObjectModel: CoreDataStack.model)
            
            container.persistentStoreDescriptions = [persistentStoreDescription]
            
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            storeContainer = container
        }
    }

    
    // RecipleaseTests/Data/Repository/Dependencies/MockRecipeApi.swift
    //
    //  MockRecipeApi.swift
    //  RecipleaseTests
    //
    //  Created by Cristian Felipe Patiño Rojas on 22/05/2021.
    //
    
    import Foundation
    @testable import Reciplease
    
    class MockRecipeApi: RecipleaseApiInput {
        
            var withError = false
            static let mockResponse: RecipeResponse = RecipeResponse(recipes: [])
        
            func getSearch(query: String, completion: @escaping (Result<RecipeResponse, Error>) -> Void) {
                    if withError {
                            completion(.failure(Error(type: .networkError)))
                    } else {
                            completion(.success(MockRecipeApi.mockResponse))
                    }
            }
    }

    
    // RecipleaseTests/Data/Repository/Dependencies/MockRecipesRepositoryOutput.swift
    //
    //  MockRecipesRepositoryOutput.swift
    //  RecipleaseTests
    //
    //  Created by Cristian Felipe Patiño Rojas on 22/05/2021.
    //
    
    import Foundation
    @testable import Reciplease
    
    class MockRecipesRepositoryOutput: RecipesRepositoryOutput {
            var result: Result<RecipeResponse, Error>?
            var states: [SearchViewState] = []
        
            func didUpdate(state: SearchViewState) {
                    states.append(state)
            }
        
            func didPerformSearch(_ result: Result<RecipeResponse, Error>) {
                    self.result = result
                    switch result {
                    case .success(let response):
                            didUpdate(state: .success(response))
                    case .failure(_):
                            didUpdate(state: .error)
                    }
            }
    }

    
    // RecipleaseTests/Data/Repository/RecipesRepositoryTests.swift
    //
    //  RecipesRepositoryTests.swift
    //  RecipleaseTests
    //
    //  Created by Cristian Felipe Patiño Rojas on 05/04/2021.
    //
    
    import XCTest
    @testable import Reciplease
    
    class RecipesRepositoryTests: XCTestCase {
        
            /// SUT dependences
            var api: MockRecipeApi!
            var output: MockRecipesRepositoryOutput!
        
            /// SUT protocol
            var sut: RecipesRepositoryInput!
        
            override func setUp() {
                
                    /// SUT Dependencies
                    api = MockRecipeApi()
                    output = MockRecipesRepositoryOutput()
                
                    /// SUT  object
                    sut = RecipesRepository(api: api)
                    sut.output = output
            }
        
            override func tearDown() {
                    api = nil
                    output = nil
                    sut = nil
            }
        
            func testPerformResearch_WithSuccess() {
                    sut.performSearch(query: "")
                    if case .success = output.result {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testPerformSearch_WithFailure() {
                    api.withError = true
                    sut.performSearch(query: "")
                    if case .failure = output.result {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testPerformResearch_WithSuccess_SetsSuccessState() {
                    sut.performSearch(query: "test")
                    XCTAssertEqual(output.states.count, 2)
                    XCTAssertEqual(output.states.last, .success(MockRecipeApi.mockResponse))
            }
        
            func testPerformResearch_WithFailure_SetsErrorState() {
                    api.withError = true
                    sut.performSearch(query: "")
                    XCTAssertEqual(output.states.count, 2)
                    XCTAssertEqual(output.states.last, .error)
            }
    }

    
    // RecipleaseTests/Extensions/UIColorTests.swift
    //
    //  UIColor.swift
    //  RecipleaseTests
    //
    //  Created by Cristian Felipe Patiño Rojas on 27/03/2021.
    //
    
    import XCTest
    @testable import Reciplease
    
    class UIColorTests: XCTestCase {
        
            func testColors() {
                    XCTAssertNotEqual(UIColor.salmon, nil)
                    XCTAssertNotEqual(UIColor.cream, nil)
                    XCTAssertNotEqual(UIColor.darkPurple, nil)
            }
    }

    
    
    // p5-baluchon.swift
    
    // Baluchon/Application/AppDelegate.swift
    //
    //  AppDelegate.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import UIKit
    
    @main
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
            // Needed for iOS 12 and earlier versions
            var window: UIWindow?
        
            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
                    setupTabBar()
                    return true
            }
        
            // MARK: UISceneSession Lifecycle
            @available(iOS 13, *)
            func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
                    // Called when a new scene session is being created.
                    // Use this method to select a configuration to create the new scene with.
                    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
            }
            @available(iOS 13, *)
            func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
                    // Called when the user discards a scene session.
                    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
                    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
            }
        
            func applicationWillEnterForeground(_ application: UIApplication) {
                    postWillEnterForegroundNotification()
            }
        
            func postWillEnterForegroundNotification() {
                    NotificationCenter.default.post(name: .willEnterForeground, object: nil)
            }
    }

    // MARK: - Private
    private extension AppDelegate {
            func setupTabBar() {
                    let appearance = UITabBar.appearance()
                
                
                    appearance.backgroundColor = .azure
                
                    appearance.shadowImage =  UIImage.getShadow()
                    appearance.backgroundImage = UIImage()
                
                    appearance.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.4)
                
                    let attributes = [
                            NSAttributedString.Key.foregroundColor: UIColor.white,
                    ]
                
                    UITabBar.appearance().tintColor = .white
                    UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
            }
    }

    
    // Baluchon/Application/SceneDelegate.swift
    //
    //  SceneDelegate.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import UIKit
    
    @available(iOS 13, *)
    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        
            var window: UIWindow?
        
        
            func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
                    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
                    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
                    guard let _ = (scene as? UIWindowScene) else { return }
            }
        
            func sceneDidDisconnect(_ scene: UIScene) {
                    // Called as the scene is being released by the system.
                    // This occurs shortly after the scene enters the background, or when its session is discarded.
                    // Release any resources associated with this scene that can be re-created the next time the scene connects.
                    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
            }
        
            func sceneDidBecomeActive(_ scene: UIScene) {
                    // Called when the scene has moved from an inactive state to an active state.
                    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
            }
        
            func sceneWillResignActive(_ scene: UIScene) {
                    // Called when the scene will move from an active state to an inactive state.
                    // This may occur due to temporary interruptions (ex. an incoming phone call).
            }
        
            func sceneWillEnterForeground(_ scene: UIScene) {
                    // Called as the scene transitions from the background to the foreground.
                    // Use this method to undo the changes made on entering the background.
            }
        
            func sceneDidEnterBackground(_ scene: UIScene) {
                    // Called as the scene transitions from the foreground to the background.
                    // Use this method to save data, release shared resources, and store enough scene-specific state information
                    // to restore the scene back to its current state.
            }
        
        
    }

    
    
    // Baluchon/Data/Registry/Registry.swift
    //
    //  Registry.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import Foundation
    
    enum Registry {
            static let defaults = UserDefaults.standard
        
            static func clear() {
                    UserDefaults.standard.removeObject(forKey: .fetchingDate)
                    UserDefaults.standard.removeObject(forKey: .exchangeRate)
            }
    }

    extension String {
            static let exchangeRate = "exchangeRate"
            static let fetchingDate = "fetchingDate"
    }

    
    // Baluchon/Data/Repository/ExchangeRepository.swift
    //
    //  ExchangeRepository.swift
    //  Baluchon
    //
    //  Created by cris on 19/12/2020.
    //
    
    import Foundation
    
    protocol ExchangeRepositoryOutput: class {
            func didFetchExchange(result: Result<ExchangeResponse, Error>)
            func didUpdate(state: ExchangeViewState)
    }

    protocol ExchangeRepositoryInput {
            func fetchExchange()
            var output: ExchangeRepositoryOutput? { get set }
    }

    class ExchangeRepository: ExchangeRepositoryInput {
        
            weak var output: ExchangeRepositoryOutput?
            private let api: FixerApiInput
        
            init(api: FixerApiInput) {
                    self.api = api
            }
        
            func fetchExchange() {
                    output?.didUpdate(state: .loading)
                    api.getRate { [weak self] result in
                            self?.output?.didFetchExchange(result: result)
                    }
            }
    }

    
    // Baluchon/Data/Repository/TranslationRepository.swift
    //
    //  TranslationRepository.swift
    //  Baluchon
    //
    //  Created by cris on 19/12/2020.
    //
    
    import Foundation
    
    protocol TranslationRepositoryOutput: class {
            func didFetchTranslation(result: Result<TranslationResponse, Error>)
            func didUpdate(state: TranslationViewState)
    }

    protocol TranslationRepositoryInput {
            func fetchTranslation(query: String)
            var output: TranslationRepositoryOutput? { get set }
    }

    class TranslationRepository: TranslationRepositoryInput {
        
            weak var output: TranslationRepositoryOutput?
            var api: GoogleTranslateApiInput?
        
            init(api: GoogleTranslateApiInput) {
                    self.api = api
            }
        
            func fetchTranslation(query: String) {
                    output?.didUpdate(state: .loading)
                    api?.getTranslation(query: query) { [weak self] result in
                            self?.output?.didFetchTranslation(result: result)
                    }
            }
    }

    
    // Baluchon/Data/Repository/WeatherRepository.swift
    //
    //  WeatherRepository.swift
    //  Baluchon
    //
    //  Created by cris on 17/12/2020.
    //
    
    import Foundation
    
    //typealias WeatherViewState = WeatherViewController.State
    
    protocol WeatherRepositoryOutput: class {
            func didFetchLocalWeather(result: Result<WeatherResponse, Error>)
            func didFetchDestinationWeather(result: Result<WeatherResponse, Error>)
            func didUpdateDestination(state: WeatherViewState)
            func didUpdateLocal(state: WeatherViewState)
    }

    protocol WeatherRepositoryInput {
            func fetchWeather()
            func fetchDestinationWeather()
            func fetchLocalWeather()
        
            var api: OpenWeatherApiInput? { get set }
            var output: WeatherRepositoryOutput? { get set }
    }

    class WeatherRepository: WeatherRepositoryInput {
        
            weak var output: WeatherRepositoryOutput?
            var api: OpenWeatherApiInput?
        
            init(api: OpenWeatherApiInput) {
                    self.api = api
            }
        
            func fetchWeather() {
                    fetchLocalWeather()
                    fetchDestinationWeather()
            }
        
            func fetchLocalWeather() {
                    output?.didUpdateLocal(state: .loadingLocal)
                    api?.getLocalWeather { [weak self] result in
                            switch result {
                            case .success(let response):
                                    self?.output?.didFetchLocalWeather(result: .success(response))
                            case .failure(let error):
                                    self?.output?.didFetchLocalWeather(result: .failure(error))
                            }
                    }
            }
        
            func fetchDestinationWeather() {
                    output?.didUpdateDestination(state: .loadingDestination)
                    api?.getDestinationWeather { [weak self] result in
                            switch result {
                            case .success(let response):
                                    self?.output?.didFetchDestinationWeather(result: .success(response))
                            case .failure(let error):
                                    self?.output?.didFetchDestinationWeather(result: .failure(error))
                            }
                    }
            }
        
    }

    
    // Baluchon/Data/Services/Api.swift
    //
    //  Api.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    enum Api {
            static let googleTranslate = GoogleTranslateApi()
            static let fixer = FixerApi()
            static let openWeather = OpenWeatherApi()
    }

    
    // Baluchon/Data/Services/Fixer/Fixer.swift
    //
    //  Fixer.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import Foundation
    
    enum Fixer {
            static let apiKey  = ""
            static let baseURL = "http://data.fixer.io/api/latest"
        
            case eurUSD
            case usdEUR
    }

    // MARK: - Router
    extension Fixer {
        
            var url: URL? {
                    switch self {
                    case .eurUSD:
                            return buildURL(from: "EUR", to: "USD")
                    case .usdEUR:
                            return buildURL(from: "USD", to: "EUR")
                    }
            }
        
            private func buildURL(from: String, to: String) -> URL? {
                    var components = URLComponents(string: Fixer.baseURL)!
                
                    let queryItemToken = URLQueryItem(name: "access_key", value: Fixer.apiKey)
                    let queryItemFrom = URLQueryItem(name: "base", value: from)
                    let queryItemTo = URLQueryItem(name: "symbols", value: to)
                
                    components.queryItems = [queryItemToken,
                                                                        queryItemFrom,
                                                                        queryItemTo]
                    return components.url
            }
    }

    
    // Baluchon/Data/Services/Fixer/FixerApi.swift
    //
    //  FixerApi.swift
    //  Baluchon
    //
    //  Created by cris on 19/12/2020.
    //
    
    import Foundation
    
    protocol FixerApiInput {
            func getRate(completion: @escaping ((Result<ExchangeResponse, Error>) -> Void))
    }

    class FixerApi: FixerApiInput {
        
            func getRate(completion: @escaping ((Result<ExchangeResponse, Error>) -> Void)) {
                    URLSession.decode(url: Fixer.eurUSD.url, into: ExchangeResponse.self, with: completion)
            }
    }

    
    // Baluchon/Data/Services/GoogleTranslate/GoogleTranslate.swift
    //
    //  GoogleTranslate.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import Foundation
    
    enum GoogleTranslate {
        
            static let apiKey  = ""
            static let baseURL = "https://translation.googleapis.com/language/translate/v2"
        
            case translate(query: String)
    }

    
    // MARK: - Router
    extension GoogleTranslate {
        
            var url: URL? {
                    switch self {
                    case .translate(let query):
                            return buildURL(query: query)
                    }
            }
        
            func buildURL(query: String) -> URL? {
                    var components = URLComponents(string: GoogleTranslate.baseURL)!
                
                    let queryItemToken  = URLQueryItem(name: "key", value: GoogleTranslate.apiKey)
                    let queryItemQuery  = URLQueryItem(name: "q", value: query)
                    let queryItemTarget = URLQueryItem(name: "target", value: "en")
                
                    components.queryItems = [queryItemToken,
                                                                        queryItemQuery,
                                                                        queryItemTarget]
                    return components.url
            }
    }

    
    // Baluchon/Data/Services/GoogleTranslate/GoogleTranslateApi.swift
    //
    //  GoogleTranslateApi.swift
    //  Baluchon
    //
    //  Created by cris on 19/12/2020.
    //
    
    import Foundation
    
    protocol GoogleTranslateApiInput {
            func getTranslation(query: String, completion: @escaping ((Result<TranslationResponse, Error>) -> Void))
    }

    class GoogleTranslateApi: GoogleTranslateApiInput {
            func getTranslation(query: String, completion: @escaping ((Result<TranslationResponse, Error>) -> Void)) {
                    let url = GoogleTranslate.translate(query: query).url
                    URLSession.decode(url: url, into: TranslationResponse.self, with: completion)
            }
    }

    
    // Baluchon/Data/Services/OpenWeather/OpenWeather.swift
    //
    //  OpenWeathermap.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import Foundation
    
    // MARK: - OpenWeatherMap Service
    enum OpenWeather {
            static let apiKey  = ""
            static let baseURL = "https://api.openweathermap.org/data/2.5/weather"
        
            case newYork
            case chartres
    }

    // MARK: - Router
    extension OpenWeather {
        
            var url: URL? {
                    switch self {
                    case .newYork:
                            return buildURL(with: "new+york")
                    case .chartres:
                            return buildURL(with: "chartres")
                    }
            }
        
            private func buildURL(with city: String) -> URL? {
                    var components = URLComponents(string: OpenWeather.baseURL)!
                
                    let queryItemQuery = URLQueryItem(name: "q", value: city)
                    let queryItemToken = URLQueryItem(name: "appid", value: OpenWeather.apiKey)
                    let queryItemMode  = URLQueryItem(name: "mode", value: "json")
                    let queryItemUnits = URLQueryItem(name: "units", value: "metric")
                    let queryItemsLang = URLQueryItem(name: "lang", value: "fr")
                
                    components.queryItems = [queryItemQuery,
                                                                        queryItemToken,
                                                                        queryItemMode,
                                                                        queryItemUnits,
                                                                        queryItemsLang]
                    return components.url
            }
    }

    
    // Baluchon/Data/Services/OpenWeather/OpenWeatherApi.swift
    //
    //  OpenWeatherMapApi.swift
    //  Baluchon
    //
    //  Created by cris on 17/12/2020.
    //
    
    import Foundation
    
    protocol OpenWeatherApiInput {
            func getLocalWeather(completion: @escaping (Result<WeatherResponse, Error>) -> Void)
            func getDestinationWeather(completion: @escaping (Result<WeatherResponse, Error>) -> Void)
    }

    class OpenWeatherApi: OpenWeatherApiInput {
        
            func getLocalWeather(completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
                    URLSession.decode(url: OpenWeather.chartres.url, into: WeatherResponse.self, with: completion)
            }
        
            func getDestinationWeather(completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
                    URLSession.decode(url: OpenWeather.newYork.url, into: WeatherResponse.self, with: completion)
            }
    }

    
    // Baluchon/Domain/Model/Api/ExchangeResponse.swift
    //
    //  ExchangeResponse.swift
    //  Baluchon
    //
    //  Created by cris on 19/12/2020.
    //
    
    import Foundation
    
    struct ExchangeResponse: Decodable, Equatable {
            let rates: Rates
    }

    
    // Baluchon/Domain/Model/Api/TranslationResponse.swift
    //
    //  TranslationResponse.swift
    //  Baluchon
    //
    //  Created by cris on 19/12/2020.
    //
    
    import Foundation
    
    struct TranslationResponse: Decodable, Equatable {
            let data: TranslationData
    }

    
    // Baluchon/Domain/Model/Api/WeatherResponse.swift
    //
    //  WeatherResponse.swift
    //  Baluchon
    //
    //  Created by cris on 18/12/2020.
    //
    
    import Foundation
    
    struct WeatherResponse: Decodable, Equatable {
            let name: String
            let main: WeatherTemp
            let weather: [Weather]
    }

    
    // Baluchon/Domain/Model/Error.swift
    //
    //  NetworkError.swift
    //  Baluchon
    //
    //  Created by cris on 17/12/2020.
    //
    
    import Foundation
    
    enum ErrorType: Equatable {
            case invalidURL
            case noDataError
            case decodingError
            case networkError
        
            var message: String {
                    switch self {
                    case .invalidURL:
                            return "Invalid url"
                    case .noDataError:
                            return "No data found"
                    case .decodingError:
                            return "Fail while decoding"
                    case .networkError:
                            return "Network error"
                    }
            }
    }

    struct Error: Swift.Error {
            let type: ErrorType
    }

    
    // Baluchon/Domain/Model/Rates.swift
    //
    //  Rates.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/01/2021.
    //
    // MARK: - Rates
    struct Rates: Decodable, Equatable {
            let usd: Float
        
            enum CodingKeys: String, CodingKey {
                    case usd = "USD"
            }
    }

    
    // Baluchon/Domain/Model/Symbols.swift
    //
    //  Symbols.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import Foundation
    
    enum Symbols {
            case eur
            case usd
        
            var string: String {
                    switch self {
                    case .eur: return "€"
                    case .usd: return "$"
                    }
            }
    }

    
    // Baluchon/Domain/Model/Translation.swift
    //
    //  Translation.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/01/2021.
    //
    
    // MARK: - DataClass
    struct TranslationData: Decodable, Equatable {
            let translations: [Translation]
    }

    // MARK: - Translation
    struct Translation: Decodable, Equatable {
            let translatedText: String
            let detectedSourceLanguage: String
    }

    
    // Baluchon/Domain/Model/Weather.swift
    //
    //  Weather.swift
    //  Baluchon
    //
    //  Created by cris on 03/12/2020.
    //
    
    import Foundation
    
    struct Weather: Decodable, Equatable {
            let id: Int
            let description: String
        
            var icon: String {
                    switch id {
                    case 200 ... 299:
                            return "bolt"
                    case 300 ... 399:
                            return "drizzle"
                    case 500 ... 599:
                            return "rain"
                    case 600 ... 699:
                            return "snow"
                    case 700 ... 799:
                            return "fog"
                    case 800:
                            return "sun"
                    case 801 ... 899:
                            return "cloud"
                    default:
                            return  "unknown"
                    }
            }
    }

    
    // Baluchon/Domain/Model/WeatherTemp.swift
    //
    //  WeatherTemp.swift
    //  Baluchon
    //
    //  Created by cris on 18/12/2020.
    //
    
    import Foundation
    
    struct WeatherTemp: Decodable, Equatable {
            let temp: Double
    }

    
    // Baluchon/Extension/Data+mapResponse.swift
    //
    //  Data+decode.swift
    //  Baluchon
    //
    //  Created by cris on 17/12/2020.
    //
    
    import Foundation
    
    extension Data {
        
            static let JSONdecoder = JSONDecoder()
            func mapResponse<T: Decodable>(into type: T.Type) -> T? {
                    do {
                            let data = try Data.JSONdecoder.decode(type, from: self)
                            return data
                    } catch {
                            return nil
                    }
            }
    }

    
    // Baluchon/Extension/Date+intervalGreatherThanDay.swift
    //
    //  Date+intervalGreatherThanDay.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 07/03/2021.
    //
    
    import Foundation
    
    extension Date {
            func moreThanADay(from date: Date) -> Bool {
                
                    /// Define a day interval in seconds = 24h * 60m * 60s
                    let dayInterval: TimeInterval = 24 * 60 * 60
                
                    /// Compare
                    let interval = self.timeIntervalSince(date)
                
                    return interval > dayInterval
            }
    }

    
    // Baluchon/Extension/NotificationName+values.swift
    //
    //  NotificationName+values.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 27/02/2021.
    //
    
    import UIKit
    
    extension Notification.Name {
            static let keyboardWillShow = UIResponder.keyboardWillShowNotification
            static let keyboardWillHide = UIResponder.keyboardWillHideNotification
            static let willEnterForeground = Notification.Name(rawValue: "WillEnterForeground")
    }

    
    // Baluchon/Extension/String+appTexts.swift
    //
    //  String+appTexts.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 07/02/2021.
    //
    
    import Foundation
    
    enum S {
        
            // MARK: - Generics
            static let french = "french".localized
            static let english = "english".localized
            static let ok = "ok".localized
            static let retry = "retry".localized
            static let attention = "attention".localized
        
            // MARK: - Weather
            static let weather = "weather".localized
        
            // MARK: - Exchange
            static let convert = "convert".localized
            static var formatedRate: (Float) -> (String) = { rate in
                    let rateString = String(format: "%.2f", rate) + Symbols.usd.string
                    return "1\(Symbols.eur.string) = \(rateString)"
            }
        
            // MARK: - Translation
            static let translate = "translate".localized
            static let translateInputPlaceholder = "translate_input_placeholder".localized
            static let translateOutputPlaceholder = "translate_output_placeholder".localized
        
            // MARK: - Error
            static let errorLocalWeather = "error_local_weather".localized
            static let errorDestinationWeather = "error_destination_weather".localized
            static let errorExchange = "error_exchange".localized
            static let errorTranslation = "error_translation".localized
            static let errorDate = "error_casting_date".localized
    }

    
    
    // Baluchon/Extension/String+localized.swift
    //
    //  Strings+localize.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 07/02/2021.
    //
    
    import Foundation
    
    extension String {
            var localized: String {
                    NSLocalizedString(self, comment: "")
            }
    }

    
    // Baluchon/Extension/UIColor.swift
    //
    //  UIColor.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 06/02/2021.
    //
    
    import UIKit
    
    extension UIColor {
            class var azure: UIColor {
                    return UIColor(named: "azure")!
            }
        
            class var greyWhite: UIColor {
                    return UIColor(named: "greyWhite")!
            }
        
            class var lightGrey: UIColor {
                    return UIColor(named: "lightGrey")!
            }
    //    class var white: UIColor {
    //        return UIColor(named: "white")!
    //    }
    }

    
    // Baluchon/Extension/UIImage+getShadow.swift
    //
    //  UIImage+getShadow.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import UIKit
    
    extension UIImage {
            static func getShadow() -> UIImage {
                    let gradientLayer = CAGradientLayer()
                    gradientLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 10)
                
                    let color1 = UIColor.black.cgColor.copy(alpha: 0.2)!
                    let color2: CGColor = UIColor.white.cgColor.copy(alpha: 0)!
                    gradientLayer.colors = [color2, color1]
                
                    UIGraphicsBeginImageContext(gradientLayer.bounds.size)
                    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    return image!
            }
    }

    
    // Baluchon/Extension/UIView+gradients.swift
    //
    //  UIView+gradients.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import UIKit
    
    extension UIView {
            // For insert layer in Foreground
            func addBlackGradientLayerInForeground(frame: CGRect, colors:[UIColor]){
            let gradient = CAGradientLayer()
            gradient.frame = frame
            gradient.colors = colors.map{$0.cgColor}
            self.layer.addSublayer(gradient)
            }
            // For insert layer in background
            func addBlackGradientLayerInBackground(frame: CGRect, colors:[UIColor]){
            let gradient = CAGradientLayer()
            gradient.frame = frame
            gradient.colors = colors.map{$0.cgColor}
            self.layer.insertSublayer(gradient, at: 0)
            }
    }

    
    
    // Baluchon/Extension/UIView+loadViewFromNib.swift
    //
    //  UIView+loadViewFromNib.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 23/01/2021.
    //
    
    import Foundation
    import UIKit
    
    extension UIView {
            func loadViewFromNib(nibName: String) -> UIView? {
                    let bundle = Bundle(for: type(of: self))
                    let nib = UINib(nibName: nibName, bundle: bundle)
                    return nib.instantiate(withOwner: self, options: nil).first as? UIView
            }
    }

    //    private func commonInit() {
    //        Bundle.main.loadNibNamed("WeatherItemView", owner: self, options: nil)
    //        addSubview(contentView)
    //        contentView.frame = self.bounds
    //        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    //    }
    
    
    // Baluchon/Extension/UIViewController+escapeKeyboard.swift
    //
    //  UIViewController+escapeKeyboard.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import UIKit
    
    extension UIViewController {
            func escapeKeyboard() {
                    let closeKeyboard = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
                
                    self.view.addGestureRecognizer(closeKeyboard)
            }
        
            @objc func dismissKeyboard() {
                    view.endEditing(true)
            }
    }

    
    // Baluchon/Extension/UIViewController+showAlert.swift
    //
    //  UIViewController+showAlert.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import UIKit
    
    extension UIViewController {
            func showErrorAlert(message: String, retryAction: @escaping () -> ()) {
                    let alert = UIAlertController(title: S.attention, message: message, preferredStyle: UIAlertController.Style.alert)
                
                    let okAction = UIAlertAction(title: S.ok, style: .default)
                
                    let retryAction = UIAlertAction(title: S.retry, style: .default) { _ in
                            retryAction()
                    }
                
                    alert.addAction(okAction)
                    alert.addAction(retryAction)
                    present(alert, animated: true)
            }
    }

    
    // Baluchon/Extension/URLSession+decode.swift
    //
    //  URLSession.swift
    //  Baluchon
    //
    //  Created by cris on 18/12/2020.
    //
    
    import Foundation
    
    extension URLSession {
        
            static let shared = URLSession(configuration: .default)
            static func decode<T: Decodable>(url: URL?, into type: T.Type, with completion: @escaping (Result<T, Error>) -> Void) {
                
                    guard let safeURL = url else {
                            completion(.failure(Error(type: .invalidURL)))
                            return
                    }
                
                    #if DEBUG
                    print(safeURL)
                    #endif
                
                    let task = shared.dataTask(with: safeURL) { (data, response, error) in
                        
                            guard error == nil else {
                                    completion(.failure(Error(type: .networkError)))
                                    return
                            }
                        
                            guard let safeData = data else {
                                    completion(.failure(Error(type: .noDataError)))
                                    return
                            }
                        
                            guard let decodedData = safeData.mapResponse(into: type) else {
                                    completion(.failure(Error(type: .decodingError)))
                                    return
                            }
                        
                            completion(.success(decodedData))
                    }
                    task.resume()
            }
    }

    
    // Baluchon/Screen/Exchange/ExchangeViewController.swift
    //
    //  ExchangeViewController.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import UIKit
    
    class ExchangeViewController: UIViewController, ExchangeRepositoryOutput, UITextFieldDelegate {
        
            @IBOutlet weak var textField: UITextField!
            @IBOutlet weak var resultLabel: UILabel!
            @IBOutlet weak var rateLabel: UILabel!
            @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
            @IBOutlet weak var rateContainer: UIView!
            @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
            var rate: Float = 0.0 {
                    didSet {
                            self.rateLabel.text = S.formatedRate(rate)
                    }
            }
        
        
            lazy var repository: ExchangeRepositoryInput = {
                    let repo = ExchangeRepository(api: Api.fixer)
                    repo.output = self
                    return repo
            }()
        
            enum Operations {
                    case multiply
                    case divide
            }
        
            override func viewWillAppear(_ animated: Bool) {
                    super.viewWillAppear(animated)
                    addObservers()
                    setupKeyboardHandler()
            }
        
            override func viewWillDisappear(_ animated: Bool) {
                    super.viewWillDisappear(animated)
                    removeObservers()
            }
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                    setupUI()
                    fetchExchange()
                
                    //@todo:
                    textField.delegate = self
                    textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingChanged)
            }
        
            private func fetchExchange() {
                    guard let exchangeRate = UserDefaults.standard.value(forKey: .exchangeRate) as? Float else {
                            repository.fetchExchange()
                            return
                    }
                    rate = exchangeRate
                    refetchIfNeeded()
            }
        
            @objc
            private func refetchIfNeeded() {
                
                    guard let lastFetchingDate = UserDefaults.standard.value(forKey: .fetchingDate) as? Date else {
                            didUpdate(state: .error(S.errorDate))
                            return
                    }
                
                    let currentDate = Date()
                
                    if currentDate.moreThanADay(from: lastFetchingDate) {
                            UserDefaults.standard.setValue(currentDate, forKey: .fetchingDate)
                            repository.fetchExchange()
                    }
            }
        
            private func addObservers() {
                    NotificationCenter.default.addObserver(
                            self,
                            selector: #selector(keyboardWillShow),
                            name: .keyboardWillShow, object: nil)
                    NotificationCenter.default.addObserver(
                            self,
                            selector: #selector(refetchIfNeeded),
                            name: .willEnterForeground, object: nil)
            }
        
            private func removeObservers() {
                    NotificationCenter.default.removeObserver(self, name: .keyboardWillShow, object: nil)
                    NotificationCenter.default.removeObserver(self, name: .willEnterForeground, object: nil)
            }
        
            func textFieldDidBeginEditing(_ textField: UITextField) {
                    guard let safeFieldText = textField.text else { return }
                    if safeFieldText.isEmpty {
                            resultLabel.text = "0"
                    } else {
                    convertCurrency()
                    }
            }
    }

    // MARK: - Setup UI
    private extension ExchangeViewController {
        
            func setupUI() {
                
                    activityIndicator.hidesWhenStopped = true
                
                    rateContainer.layer.borderColor = UIColor.lightGrey.cgColor
                    rateContainer.layer.borderWidth = 3.0
                    rateContainer.layer.cornerRadius = rateContainer.frame.height / 2
            }
        
            func setupKeyboardHandler() {
                
                    textField.becomeFirstResponder()
                    escapeKeyboard()
            }
        
            func convertCurrency() {
                
                    guard
                            let stringNumber = textField.text,
                            let numberToConvert: Float = Float(stringNumber)
                    else { return }
                
                    guard !stringNumber.isEmpty else {
                            self.resultLabel.text = "0"
                            return
                    }
                
                    guard let rate = UserDefaults.standard.value(forKey: .exchangeRate) as? Float  else {
                            didUpdate(state: .error("Error casting exchange rate"))
                            return
                    }
                
                    let result = numberToConvert * rate
                    self.resultLabel.text = "\(result)"
            }
        
            @objc func keyboardWillShow(notification: NSNotification) {
                
                    guard let userInfo = notification.userInfo else { return }
                    guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                    let keyboardFrame = keyboardSize.cgRectValue
                    if bottomConstraint.constant == 0 {
                            bottomConstraint.constant -= keyboardFrame.height
                    }
            }
    }

    
    // Baluchon/Screen/Exchange/ExchangeViewController+didFetch.swift
    //
    //  ExchangeDidFetch.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import Foundation
    
    extension ExchangeViewController {
            func didFetchExchange(result: Result<ExchangeResponse, Error>) {
                    switch result {
                    case .success(let response):
                            didUpdate(state: .success(response))
                    case .failure(let error):
                            didUpdate(state: .error(error.type.message))
                    }
            }
    }

    
    // Baluchon/Screen/Exchange/ExchangeViewController+didUpdate.swift
    //
    //  ExchangeDidUpdate.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import Foundation
    
    extension ExchangeViewController {
        
            func didUpdate(state: ExchangeViewState) {
                    if state.isLoading {
                            activityIndicator.startAnimating()
                            self.rateLabel.isHidden = true
                    } else {
                            DispatchQueue.main.async { [weak self] in
                                    self?.activityIndicator.stopAnimating()
                            }
                    }
                
                    switch state {
                    case .success(let response):
                            DispatchQueue.main.async { [weak self] in
                                    let rate: Float = response.rates.usd
                                    self?.setUserDefaults(rate: rate)
                                    self?.formatAndDisplay(rate: rate)
                            }
                    case .error(let error):
                            DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.showErrorAlert(message: S.errorExchange, retryAction: self.repository.fetchExchange)
                            }
                            #if DEBUG
                            print(error)
                            #endif
                    default: break
                    }
            }
    }

    private extension ExchangeViewController {
            func setUserDefaults(rate: Float) {
                    UserDefaults.standard.setValue(rate, forKey: .exchangeRate)
                    UserDefaults.standard.setValue(Date(), forKey: .fetchingDate)
            }
        
            func formatAndDisplay(rate: Float) {
                    rateLabel.text = S.formatedRate(rate)
                    rateLabel.isHidden = false
            }
    }

    
    // Baluchon/Screen/Exchange/ExchangeViewState.swift
    //
    //  ExchangeViewState.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    enum ExchangeViewState: Equatable {
            case loading
            case success(ExchangeResponse)
            case error(String)
        
            var isLoading: Bool {
                    self == .loading
            }
    }

    
    // Baluchon/Screen/Translation/TranslationViewController.swift
    //
    //  TranslationViewController.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import UIKit
    
    class TranslationViewController: UIViewController, TranslationRepositoryOutput {
        
            @IBOutlet weak var inputTextView: UITextView!
            @IBOutlet weak var outputTextView: UITextView!
            @IBOutlet weak var componentContainer: UIView!
            @IBOutlet weak var textToTranslateContainer: UIView!
            @IBOutlet weak var translationContainer: UIView!
        
            @IBOutlet weak var inputLangImage: UIImageView!
            @IBOutlet weak var outputLangImage: UIImageView!
        
    //    @IBOutlet weak var inputLangLabel: UILabel!
            @IBOutlet weak var outputLangLabel: UILabel!
            @IBOutlet weak var translationButton: DefaultButton!
        
            lazy var repository: TranslationRepositoryInput = {
                    let repo = TranslationRepository(api: Api.googleTranslate)
                    repo.output = self
                    return repo
            }()
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                    setupUI()
            }
        
            @IBAction func translationButtonPressed(_ sender: Any) {
                    repository.fetchTranslation(query: inputTextView.text)
                    inputTextView.resignFirstResponder()
            }
    }

    // MARK: - Setup UI
    private extension TranslationViewController {
            func setupUI() {
                    let cornerRadius: CGFloat = 10
                
                    inputTextView.text = S.translateInputPlaceholder
                    outputTextView.text = S.translateOutputPlaceholder
                
    //        inputLangLabel.text = S.french
                    outputLangLabel.text = S.english
                
                    outputTextView.textColor = UIColor.lightGray
                    inputTextView.textColor = UIColor.lightGray
                
                    outputTextView.delegate = self
                    inputTextView.delegate = self
                
                    textToTranslateContainer.layer.cornerRadius = cornerRadius
                    textToTranslateContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                
                    translationContainer.layer.cornerRadius = cornerRadius
                    translationContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                
                    componentContainer.layer.cornerRadius = cornerRadius
                
                    componentContainer.layer.shadowColor = UIColor.black.cgColor
                    componentContainer.layer.shadowOpacity = 0.1
                    componentContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
                    componentContainer.layer.shadowRadius = 3
                
                    inputLangImage.layer.cornerRadius = inputLangImage.frame.height / 2
                    outputLangImage.layer.cornerRadius = outputLangImage.frame.height / 2
                
                    escapeKeyboard()
            }
    }

    // MARK: - TextView Delegate methods
    extension TranslationViewController: UITextViewDelegate {
            func textViewDidBeginEditing(_ textView: UITextView) {
                    if textView.textColor == UIColor.lightGray {
                            textView.text = nil
                            textView.textColor = .black
                    }
            }
    }

    
    // Baluchon/Screen/Translation/TranslationViewController+didFetch.swift
    //
    //  TranslationDidFetch.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import UIKit
    
    extension TranslationViewController {
            func didFetchTranslation(result: Result<TranslationResponse, Error>) {
                    switch result {
                    case .success(let response):
                            let translation = response.data.translations[0]
                            didUpdate(state: .success(translation))
                    case .failure(let error):
                            didUpdate(state: .error(error.type.message))
                    }
            }
    }

    
    // Baluchon/Screen/Translation/TranslationViewController+didUpdate.swift
    //
    //  TranslationDidUpdate.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import UIKit
    
    extension TranslationViewController {
            func didUpdate(state: TranslationViewState) {
                    DispatchQueue.main.async { [weak self] in
                            self?.translationButton.isLoading = state.isLoading
                    }
                    switch state {
                    case .success(let data):
                            DispatchQueue.main.async { [weak self] in
                                    self?.outputTextView.text = data.translatedText
                                    if let flag = UIImage(named: data.detectedSourceLanguage) {
                                            self?.inputLangImage.image = flag
                                    } else {
                                            self?.inputLangImage.image = UIImage(named: "unknown")
                                    }
                            }
                    case .error(let error):
                            DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.showErrorAlert(message: S.errorTranslation) {
                                            self.repository.fetchTranslation(query: self.inputTextView.text)
                                    }
                            }
                            #if DEBUG
                            print(error)
                            #endif
                    default: break
                    }
            }
    }

    
    // Baluchon/Screen/Translation/TranslationViewState.swift
    //
    //  TranslationViewState.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    enum TranslationViewState: Equatable {
            case loading
            case success(Translation)
            case error(String)
        
            var isLoading: Bool {
                    self == .loading
            }
    }

    
    
    // Baluchon/Screen/UI/Component/Button/DefaultButton.swift
    //
    //  DefaultButton.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 06/02/2021.
    //
    
    import UIKit
    
    @IBDesignable
    class DefaultButton: UIButton {
        
            private let activityIndicator = UIActivityIndicatorView()
        
            var isLoading: Bool = false {
                    didSet {
                            isEnabled = !isLoading
                            handleLoadingState()
                    }
            }
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
                    setupButton()
            }
        
            required init?(coder aDecoder: NSCoder) {
                    super.init(coder: aDecoder)
                    setupButton()
            }
        
            private func setupButton() {
                    setTitleColor(.white, for: .normal)
                    setTitleColor(.white, for: .highlighted)
                    setTitleColor(.white, for: .selected)
                    layer.cornerRadius = frame.height / 2
                    backgroundColor = .azure
                
                    setupIndicator()
            }
        
            private func setupIndicator() {
                    activityIndicator.hidesWhenStopped = true
                    activityIndicator.color = .white
                    addSubview(activityIndicator)
                    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                            activityIndicator.widthAnchor.constraint(equalToConstant: 40)
                    ])
            }
        
            private func handleLoadingState() {
                    if isLoading {
                            activityIndicator.startAnimating()
                            setTitleColor(.clear, for: .normal)
                    } else {
                            activityIndicator.stopAnimating()
                            setTitleColor(.white, for: .normal)
                    }
            }
    }

    
    // Baluchon/Screen/UI/ErrorView.swift
    //
    //  ErrorView.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 23/01/2021.
    //
    
    import UIKit
    
    class ErrorView: UIView {
            @IBOutlet private weak var descriptionLabel: UILabel!
            @IBOutlet weak var retryButton: UIButton!
        
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
            }
        
            required init?(coder: NSCoder) {
                    super.init(coder: coder)
            }
        
        
            @IBAction func retryButtonPressed(_ sender: UIButton) {
            }
        
    }

    
    // Baluchon/Screen/Weather/Components/WeatherItemView.swift
    //
    //  WeatherItemView.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 23/01/2021.
    //
    
    import UIKit
    
    @IBDesignable
    final class WeatherItemView: UIView {
        
            @IBOutlet private weak var bgImage: UIImageView!
            @IBOutlet private weak var pictoImage: UIImageView!
            @IBOutlet private weak var cityLabel: UILabel!
            @IBOutlet private weak var tmpLabel: UILabel!
            @IBOutlet private weak var stateLabel: UILabel!
            @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
        
            private let cornerRadius: CGFloat = 16
        
            override init(frame: CGRect) {
                    super.init(frame: frame)
                    self.configureView()
            }
        
            required init?(coder: NSCoder) {
                    super.init(coder: coder)
                    self.configureView()
            }
        
            func configureView(cityName: String,
                                                    tmp: String,
                                                    state: String,
                                                    image: String,
                                                    cityImage: String) {
                                                        
                            self.setupUI()
                            self.cityLabel.text = cityName
                            self.tmpLabel.text = "\(tmp) °"
                            self.stateLabel.text = state
                            self.pictoImage.image = UIImage(named: image)
                            self.bgImage.image = UIImage(named: cityImage)
                                                        
            }
        
            func startAnimating() {
                    activityIndicator.startAnimating()
                    cityLabel.isHidden = true
                    tmpLabel.isHidden = true
                    stateLabel.isHidden = true
            }
        
            func stopAnimating() {
                    activityIndicator.stopAnimating()
                
                    cityLabel.isHidden = false
                    tmpLabel.isHidden = false
                    stateLabel.isHidden = false
                
                    guard let first = self.subviews.first else { return }
                    first.backgroundColor = .clear
            }
    }

    private extension WeatherItemView {
            func configureView() {
                    guard let view = self.loadViewFromNib(nibName: "WeatherItemView") else { return }
                    view.frame = self.bounds
                    view.layer.cornerRadius = cornerRadius
                    self.addSubview(view)
                    activityIndicator.hidesWhenStopped = true
            }
        
            func setupUI() {
                    cityLabel.textColor = .white
                    tmpLabel.textColor = .white
                    stateLabel.textColor = .white
                
                    tmpLabel.font = .boldSystemFont(ofSize: 32)
                
                    pictoImage.tintColor = .white
                    bgImage.addBlackGradientLayerInForeground(frame: self.bounds, colors: [UIColor.clear, UIColor.black])
                    bgImage.layer.cornerRadius = 16
            }
    }

    
    // Baluchon/Screen/Weather/WeatherViewController.swift
    //
    //  WeatherViewController.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import UIKit
    
    class WeatherViewController: UIViewController, WeatherRepositoryOutput {
        
            @IBOutlet weak var weatherTitleLabel: UILabel!
            @IBOutlet weak var destinationView: WeatherItemView!
            @IBOutlet weak var localView: WeatherItemView!
        
            lazy var repository: WeatherRepositoryInput = {
                    let repo = WeatherRepository(api: Api.openWeather)
                    repo.output = self
                    return repo
            }()
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                    setupUI()
                    repository.fetchWeather()
            }
        
            private func setupUI() {
                    weatherTitleLabel.text = S.weather
                    weatherTitleLabel.font = .boldSystemFont(ofSize: 28)
            }
    }

    
    // Baluchon/Screen/Weather/WeatherViewController+didFetch.swift
    //
    //  WeatherDidFetch.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import UIKit
    
    extension WeatherViewController {
            func didFetchLocalWeather(result: Result<WeatherResponse, Error>) {
                    switch result {
                    case .success(let response):
                            didUpdateLocal(state: .successLocal(response))
                    case .failure(let error):
                            didUpdateLocal(state: .errorLocal(error.type.message))
                    }
            }
        
            func didFetchDestinationWeather(result: Result<WeatherResponse, Error>) {
                    switch result {
                    case .success(let response):
                            didUpdateDestination(state: .successDestination(response))
                    case .failure(let error):
                            didUpdateDestination(state: .errorDestination(error.type.message))
                    }
            }
    }

    
    // Baluchon/Screen/Weather/WeatherViewController+didUpdate.swift
    //
    //  WeatherDidUpdate.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import UIKit
    
    extension WeatherViewController {
        
            func didUpdateLocal(state: WeatherViewState) {
                    switch state {
                    case .loadingLocal:
                            localView.startAnimating()
                    case .successLocal(let response):
                            configureLocalComponent(with: response)
                    case .errorLocal(let error):
                            DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.showErrorAlert(message: S.errorLocalWeather, retryAction: self.repository.fetchLocalWeather)
                            }
                            #if DEBUG
                            print(error)
                            #endif
                    default: break
                    }
            }
        
            func didUpdateDestination(state: WeatherViewState) {
                    switch state {
                    case .loadingDestination:
                            destinationView.startAnimating()
                    case .successDestination(let response):
                            configureDestinationComponent(with: response)
                    case .errorDestination(let error):
                            DispatchQueue.main.async { [weak self] in
                                    guard let self = self else { return }
                                    self.showErrorAlert(message: S.errorDestinationWeather, retryAction: self.repository.fetchDestinationWeather)
                            }
                        
                            #if DEBUG
                            print(error)
                            #endif
                    default: break
                    }
            }
        
            private func configureLocalComponent(with response: WeatherResponse) {
                    DispatchQueue.main.async() { [weak self] in
                            guard let self = self else { return }
                            self.localView.stopAnimating()
                            guard let first = response.weather.first else { return }
                            self.localView.configureView(cityName: response.name,
                                                                                        tmp: "\(response.main.temp)",
                                                                                        state: first.description.capitalized,
                                                                                        image: first.icon,
                                                                                        cityImage: "chartres")
                    }
            }
        
            private func configureDestinationComponent(with response: WeatherResponse) {
                    DispatchQueue.main.async() { [weak self] in
                            guard let self = self else { return }
                            self.destinationView.stopAnimating()
                            guard let first = response.weather.first else { return }
                            self.destinationView.configureView(
                                    cityName: response.name,
                                    tmp: "\(response.main.temp)",
                                    state: first.description.capitalized,
                                    image: first.icon,
                                    cityImage: "new-york"
                            )
                    }
            }
    }

    
    // Baluchon/Screen/Weather/WeatherViewState.swift
    //
    //  WeatherViewState.swift
    //  Baluchon
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    enum WeatherViewState: Equatable {
            case loadingLocal
            case successLocal(WeatherResponse)
            case errorLocal(String)
        
            case loadingDestination
            case successDestination(WeatherResponse)
            case errorDestination(String)
    }

    
    // BaluchonTests/Data/MockWeatherRepository.swift
    //
    //  MockRepository.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 10/01/2021.
    //
    
    @testable import Baluchon
    
    class MockWeatherRepository: WeatherRepositoryInput {
        
            var output: WeatherRepositoryOutput?
            var api: OpenWeatherApiInput?
        
            var withError: Bool
        
            init(withError: Bool = false,
                        api: OpenWeatherApiInput?,
                        output: WeatherRepositoryOutput?) {
                    self.withError = withError
                    self.api = api
                    self.output = output
            }
        
            func fetchWeather() {}
        
            func fetchDestinationWeather() {
                    api?.getDestinationWeather { [weak self] result in
                            self?.output?.didFetchDestinationWeather(result: result)
                    }
            }
        
            func fetchLocalWeather() {
                    api?.getLocalWeather { [weak self] result in
                            self?.output?.didFetchLocalWeather(result: result)
                    }
            }
    }

    
    // BaluchonTests/Data/Registry/RegistryTests.swift
    //
    //  RegistryTests.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import XCTest
    @testable import Baluchon
    
    class RegistryTests: XCTestCase {
        
            override func setUp() {
                    Registry.clear()
            }
        
            override func tearDown() {
                    Registry.clear()
            }
        
            func testRegistry() {
                    XCTAssertNotEqual(Registry.defaults, nil)
                    XCTAssertEqual(Registry.defaults.bool(forKey: .fetchingDate), false)
            }
        
            func testBeforeAddingAKey_ValueDoesntExists() {
                    if (UserDefaults.standard.value(forKey: .fetchingDate) as? Date) != nil {
                            XCTFail()
                    } else {
                            XCTAssert(true)
                    }
            }
        
            func testWhenAddingKey_ValueIsnNilAnymore() {
                    let currentDate = Date()
                    UserDefaults.standard.setValue(currentDate, forKey: .fetchingDate)
            }
        
            func testValueShouldBeNilOnFirstRun() {
                    let currentDate = Date()
                
                    if (UserDefaults.standard.value(forKey: .fetchingDate) as? Date) != nil {
                            XCTFail()
                    } else {
                            UserDefaults.standard.setValue(currentDate, forKey: .fetchingDate)
                    }
                
                    XCTAssertEqual(UserDefaults.standard.value(forKey: .fetchingDate) as! Date, currentDate)
            }
        
            func testComparingSameValues() {
                    let currentDate = Date()
                    UserDefaults.standard.setValue(currentDate, forKey: .fetchingDate)
                
                    let userDefaultsDate = UserDefaults.standard.value(forKey: .fetchingDate) as! Date
                
                    let interval = userDefaultsDate.timeIntervalSince(currentDate)
                
                    if interval == 0.0 {
                            XCTAssert(true)
                    } else {
                            XCTFail()
                    }
            }
        
            func testComparingDifferentValues() {
                    var dateComponents = DateComponents()
                    dateComponents.year = 1982
                    dateComponents.month = 7
                    dateComponents.day = 21
                
                    let calendar = Calendar(identifier: .gregorian)
                
                    /// FirstDate
                    let firstDate = calendar.date(from: dateComponents)
                
                    /// SecondDate
                    dateComponents.day = 20
                    let secondDate = calendar.date(from: dateComponents)
                
                    UserDefaults.standard.setValue(firstDate, forKey: .fetchingDate)
                
                    let userDefaultsDate = UserDefaults.standard.value(forKey: .fetchingDate) as! Date
                
                    let interval = userDefaultsDate.timeIntervalSince(secondDate!)
                
                    let minute: TimeInterval = 60.0
                    let hour: TimeInterval = 60.0 * minute
                    let day: TimeInterval = 24 * hour
                
                    if interval == day {
                            XCTAssert(true)
                    } else {
                            XCTFail()
                    }
            }
        
            func testComparingGreatherThanADay() {
                    var dateComponents = DateComponents()
                    dateComponents.year = 1982
                    dateComponents.month = 7
                    dateComponents.day = 21
                
                    let calendar = Calendar(identifier: .gregorian)
                
                    /// FirstDate
                    let firstDate = calendar.date(from: dateComponents)
                
                    /// SecondDate
                    dateComponents.day = 20
                    let secondDate = calendar.date(from: dateComponents)
                
                    UserDefaults.standard.setValue(firstDate, forKey: .fetchingDate)
                
                    let userDefaultsDate = UserDefaults.standard.value(forKey: .fetchingDate) as! Date
                
                    let interval = userDefaultsDate.timeIntervalSince(secondDate!)
                
                    let minute: TimeInterval = 60.0
                    let hour: TimeInterval = 60.0 * minute
                    let day: TimeInterval = 24 * hour
                
                    if interval == day {
                            XCTAssert(true)
                    } else {
                            XCTFail()
                    }
            }
        
            func testIsFirstTimeFetching() {
                    if (UserDefaults.standard.value(forKey: .fetchingDate) as? Date) != nil {
                            XCTFail()
                    } else {
                            XCTAssert(true)
                    }
            }
        
            func testUpdatingValue() {
                    let date1 = Date()
                    UserDefaults.standard.setValue(date1, forKey: .fetchingDate)
                
                    let date2 = Date()
                    UserDefaults.standard.setValue(date2, forKey: .fetchingDate)
                
                    XCTAssertEqual(UserDefaults.standard.value(forKey: .fetchingDate) as! Date, date2)
                
            }
    }

    
    // BaluchonTests/Data/Repository/Exchange/FixerRepositoryTests.swift
    //
    //  FixerRepositoryTests.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 17/01/2021.
    //
    
    import XCTest
    @testable import Baluchon
    
    class FixerRepositoryTest: XCTestCase {
        
            var sut: ExchangeRepositoryInput!
            var output: MockFixerRepositoryOutput!
            var api: MockFixerApi!
        
            let expectedResponse = ExchangeResponse(rates: Rates(usd: 20.5))
        
            override func setUp() {
                    output = MockFixerRepositoryOutput()
                    api = MockFixerApi()
                    sut = ExchangeRepository(api: api)
                    sut.output = output
                
                    api.response = expectedResponse
            }
        
            override func tearDown() {}
        
            func testFetchExchangeWithSuccess() {
                    sut.fetchExchange()
                    if case .success = output.model {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testFetchExchangeWithError() {
                    api.withError = true
                    sut.fetchExchange()
                    if case .failure = output.model {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testFetchingChangesStateSuccess() {
                    sut.fetchExchange()
                    XCTAssertEqual(output.states.count, 2)
                    XCTAssertEqual(output.states.last, .success(expectedResponse))
            }
        
            func testFetchingChangesStateFailureCase() {
                    api.withError = true
                    sut.fetchExchange()
                    XCTAssertEqual(output.states.count, 2)
                    XCTAssertEqual(output.states.last, .error("error"))
            }
    }

    
    // BaluchonTests/Data/Repository/Exchange/MockFixerApi.swift
    //
    //  MockFixerApi.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 17/01/2021.
    //
    
    @testable import Baluchon
    
    class MockFixerApi: FixerApiInput {
        
            var response: ExchangeResponse!
            var withError: Bool
        
            init(withError: Bool = false) {
                    self.withError = withError
            }
        
            func getRate(completion: @escaping ((Result<ExchangeResponse, Error>) -> Void)) {
                    if withError {
                            completion(.failure(Error(type:.noDataError)))
                    } else {
                            completion(.success(response))
                    }
            }
    }

    
    // BaluchonTests/Data/Repository/Exchange/MockFixerRepositoryOutput.swift
    //
    //  MockFixerRepositoryOutput.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 17/01/2021.
    //
    @testable import Baluchon
    
    class MockFixerRepositoryOutput: ExchangeRepositoryOutput {
            var model: Result<ExchangeResponse, Error>?
            var states: [ExchangeViewState] = [ ]
            func didFetchExchange(result: Result<ExchangeResponse, Error>) {
                    model = result
                    switch result {
                    case .success(let response):
                            states.append(.success(response))
                    case .failure:
                            states.append(.error("error"))
                    }
            }
        
            func didUpdate(state: ExchangeViewState) {
                    states.append(state)
            }
    }

    
    // BaluchonTests/Data/Repository/Translation/MockTranslateApi.swift
    //
    //  MockTranslateApi.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 17/01/2021.
    //
    
    @testable import Baluchon
    
    class MockTranslateApi: GoogleTranslateApiInput {
        
            var response: TranslationResponse!
            var withError: Bool
            init(withError: Bool = false) {
                    self.withError = withError
            }
        
            func getTranslation(query: String, completion: @escaping ((Result<TranslationResponse, Error>) -> Void)) {
                    if withError {
                            completion(.failure(Error(type: .noDataError)))
                    }  else {
                            completion(.success(response))
                    }
            }
    }

    
    // BaluchonTests/Data/Repository/Translation/MockTranslateRepositoryOutput.swift
    //
    //  MockTranslateRepositoryOutput.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 17/01/2021.
    //
    
    @testable import Baluchon
    
    class MockTranslateRepositoryOutput: TranslationRepositoryOutput {
        
            var model: Result<TranslationResponse, Error>?
            var states: [TranslationViewState] = []
        
            func didFetchTranslation(result: Result<TranslationResponse, Error>) {
                            model = result
                    switch result {
                    case .success:
                            states.append(.success(Translation(translatedText: "", detectedSourceLanguage: "")))
                    case .failure:
                            states.append(.error("error"))
                    }
            }
        
            /// @toDo
            func didUpdate(state: TranslationViewState) {
                    states.append(state)
            }
    }

    
    // BaluchonTests/Data/Repository/Translation/TranslateRepositoryTests.swift
    //
    //  TranslateRepositoryTests.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 17/01/2021.
    //
    
    import XCTest
    @testable import Baluchon
    
    class TranslateRepositoryTests: XCTestCase {
        
            var sut: TranslationRepositoryInput!
            var output: MockTranslateRepositoryOutput!
            var api: MockTranslateApi!
        
            var expectedApiResponse = TranslationResponse(data: TranslationData(translations: []))
        
            override func setUp() {
                    output = MockTranslateRepositoryOutput()
                    api = MockTranslateApi()
                    sut = TranslationRepository(api: api)
                    sut.output = output
                
                    api.response = expectedApiResponse
            }
        
            func testFetchTranslationWithSuccess() {
                    sut.fetchTranslation(query: "tests")
                    if case .success = output.model {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testFetchTranslationWithError() {
                    api.withError = true
                    sut.fetchTranslation(query: "tests")
                    if case .failure = output.model {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testFetchingChangesStateSuccess() {
                    sut.fetchTranslation(query: "test")
                    XCTAssertEqual(output.states.count, 2)
                    XCTAssertEqual(output.states.last, .success(Translation(translatedText: "", detectedSourceLanguage: "")))
            }
        
            func testFetchingChangesStatFailure() {
                    api.withError = true
                    sut.fetchTranslation(query: "test")
                    XCTAssertEqual(output.states.count, 2)
                    XCTAssertEqual(output.states.last, .error("error"))
            }
    }

    
    // BaluchonTests/Data/Repository/Weather/MockWeatherApi.swift
    //
    //  MockWeatherApi.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 14/01/2021.
    //
    
    import Foundation
    @testable import Baluchon
    
    class MockWeatherApi: OpenWeatherApiInput {
        
            var localResponse: WeatherResponse!
            var destinationResponse: WeatherResponse!
        
            var withError: Bool
        
            init(withError: Bool = false) {
                    self.withError = withError
            }
        
            func getLocalWeather(completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
                    if withError {
                            completion(.failure(Error(type: .noDataError)))
                    } else {
                            completion(.success(localResponse))
                    }
            }
        
            func getDestinationWeather(completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
                
                    if withError {
                            completion(.failure(Error(type: .noDataError)))
                    } else {
                            completion(.success(destinationResponse))
                    }
            }
        
    }

    
    // BaluchonTests/Data/Repository/Weather/MockWeatherRepositoryOutput.swift
    //
    //  MockWeatherRepositoryOutput.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 14/01/2021.
    //
    
    import Foundation
    @testable import Baluchon
    
    class MockWeatherRepositoryOutput: WeatherRepositoryOutput {
        
            var localStates: [WeatherViewState] = [ ]
            var destinationStates: [WeatherViewState] = [ ]
            var local: Result<WeatherResponse, Error>?
            var destination: Result<WeatherResponse, Error>?
        
            func didFetchLocalWeather(result: Result<WeatherResponse, Error>) {
                    local = result
                    switch result {
                    case .success(let success):
                            localStates.append(.successLocal(success))
                    case .failure:
                            localStates.append(.errorLocal("error"))
                    }
            }
        
            func didFetchDestinationWeather(result: Result<WeatherResponse, Error>) {
                    destination = result
                    switch result {
                    case .success(let success):
                            destinationStates.append(.successDestination(success))
                    case .failure:
                            destinationStates.append(.errorDestination("error"))
                    }
            }
        
            func didUpdateDestination(state: WeatherViewState) {
                    destinationStates.append(state)
            }
        
            func didUpdateLocal(state: WeatherViewState) {
                    localStates.append(state)
            }
    }

    
    // BaluchonTests/Data/Repository/Weather/OpenWeatherRepositoryTests.swift
    //
    //  WeatherResponseTest.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 10/01/2021.
    //
    
    import XCTest
    @testable import Baluchon
    
    class OpenWeatherRepositoryTests: XCTestCase {
        
            var output: MockWeatherRepositoryOutput!
            var api: MockWeatherApi!
            var sut: WeatherRepository!
        
        
            static var expectedLocalResponse = WeatherResponse(name: "Chartres", main: WeatherTemp(temp: 20), weather: [])
            static var expectedDestinationResponse = WeatherResponse(name: "NewYork", main: WeatherTemp(temp: 20), weather: [])
        
            override func setUp() {
                
                    output = MockWeatherRepositoryOutput()
                    api = MockWeatherApi()
                
                    api.localResponse = OpenWeatherRepositoryTests.expectedLocalResponse
                    api.destinationResponse = OpenWeatherRepositoryTests.expectedDestinationResponse
                
                    sut = WeatherRepository(api: api)
                    sut.output = output
                
            }
        
            override func tearDown() {
                    api = nil
                    output = nil
                    sut = nil
            }
        
            func testFetchLocalWeatherWithSuccess() {
                
                    sut.fetchLocalWeather()
                    if case .success = output.local {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testFetchLocalWeatherWithError() {
                    api.withError = true
                    sut.fetchLocalWeather()
                    if case .failure = output.local {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testFetchDestinatioinWeatherWithSuccess() {
                    sut.fetchDestinationWeather()
                    if case .success = output.destination {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testFetchDestinationlWeatherWithError() {
                    api.withError = true
                    sut.fetchDestinationWeather()
                    if case .failure = output.destination {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testFetchingLocalChangesStateSuccess() {
                    sut.fetchLocalWeather()
                    XCTAssertEqual(output.localStates.count, 2)
                    XCTAssertEqual(output.localStates.last, .successLocal(OpenWeatherRepositoryTests.expectedLocalResponse))
                
                
            }
        
            func testFetchingLocalnChangesStateFailure() {
                    /// With error
                    api.withError = true
                    sut.fetchLocalWeather()
                    XCTAssertEqual(output.localStates.count, 2)
                    XCTAssertEqual(output.localStates.last, .errorLocal("error"))
            }
        
            func testFetchingDestinationChangesStateSuccess() {
                    sut.fetchDestinationWeather()
                    XCTAssertEqual(output.destinationStates.count, 2)
                    XCTAssertEqual(output.destinationStates.last, .successDestination(OpenWeatherRepositoryTests.expectedDestinationResponse))
            }
        
            func testFetchingDestinationChangesStateFailure() {
                    api.withError = true
                    sut.fetchDestinationWeather()
                    XCTAssertEqual(output.destinationStates.count, 2)
                    XCTAssertEqual(output.destinationStates.last, .errorDestination("error"))
            }
    }

    
    // BaluchonTests/Data/Services/ReponseMappingTests.swift
    //
    //  ReponseMappingTests.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import XCTest
    @testable import Baluchon
    
    class ReponseMappingTests: XCTestCase {
        
            func testMapResponse() {
                    guard let weather = decodeJsonFile(filename: "WeatherResponse", decodable: true) else { return }
                
                    XCTAssertEqual(weather.name, "Chartres")
            }
        
            func testMapResponseWithError() {
                    let weather = decodeJsonFile(filename: "UndecodableResponse", decodable: false)
                    XCTAssertEqual(weather, nil)
            }
        
            private func decodeJsonFile(filename: String, decodable: Bool) -> WeatherResponse? {
                    let bundle = Bundle(for: type(of: self))
                
                    guard let url = bundle.url(forResource: filename, withExtension: "json") else {
                            XCTFail("Missing file: \(filename).json")
                            return nil
                    }
                
                    let json = try? Data(contentsOf: url)
                
                    guard let weather = json?.mapResponse(into: WeatherResponse.self) else { return nil }
                    return weather
            }
    }

    
    // BaluchonTests/Extensions/Date+intervalChecker.swift
    //
    //  Date+intervalChecker.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 07/03/2021.
    //
    
    import XCTest
    @testable import Baluchon
    
    class DateTests: XCTestCase {
        
            func testIntervalShouldBeGreather() {
                    var dateComponents = DateComponents()
                
                    dateComponents.year = 2021
                    dateComponents.month = 3
                    dateComponents.day = 7
                
                    let calendar = Calendar(identifier: .gregorian)
                
                    let firstDate = calendar.date(from: dateComponents)
                
                    /// Create seconde date: two days after first date
                    dateComponents.day = 9
                    let secondDate = calendar.date(from: dateComponents)
                
                    if secondDate!.moreThanADay(from: firstDate!) {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testIntervalShouldBeZero() {
                    var dateComponents = DateComponents()
                
                    dateComponents.year = 2021
                    dateComponents.month = 3
                    dateComponents.day = 7
                
                    let calendar = Calendar(identifier: .gregorian)
                
                    let firstDate = calendar.date(from: dateComponents)
                
                    dateComponents.day = 7
                    let secondDate = calendar.date(from: dateComponents)
                
                    let interval = secondDate!.timeIntervalSince(firstDate!)
                    if interval == 0 {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
            func testIntervalShouldBe_3600() {
                    var dateComponents = DateComponents()
                
                    dateComponents.year = 2021
                    dateComponents.month = 3
                    dateComponents.day = 7
                    dateComponents.hour = 14
                
                    let calendar = Calendar(identifier: .gregorian)
                
                    let firstDate = calendar.date(from: dateComponents)
                
                    /// Create seconde date: firstDate + 1 hour
                    dateComponents.hour! += 1
                    let secondDate = calendar.date(from: dateComponents)
                
                    let interval = secondDate!.timeIntervalSince(firstDate!)
                
                    /// 3600s = 1 hour
                    if interval == 3600 {
                            XCTAssert(true)
                    } else {
                            XCTAssert(false)
                    }
            }
        
        
            func testIntervalShouldBeLesser() {
                    var dateComponents = DateComponents()
                
                    dateComponents.year = 2021
                    dateComponents.month = 3
                    dateComponents.day = 7
                    dateComponents.hour = 15
                
                    let calendar = Calendar(identifier: .gregorian)
                
                    let firstDate = calendar.date(from: dateComponents)
                
                    dateComponents.day = 7
                    dateComponents.hour = 16
                    let secondDate = calendar.date(from: dateComponents)
                
                    if secondDate!.moreThanADay(from: firstDate!) {
                            XCTAssert(false)
                    } else {
                            XCTAssert(true)
                    }
            }
    }

    
    // BaluchonTests/Extensions/UIColorTests.swift
    //
    //  UIColorTests.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 06/02/2021.
    //
    
    import UIKit
    import XCTest
    @testable import Baluchon
    
    class UIColorTests: XCTestCase {
        
            func testColorArenFound() {
                    XCTAssertNotEqual(UIColor.azure, nil)
                    XCTAssertNotEqual(UIColor.greyWhite, nil)
                    XCTAssertNotEqual(UIColor.lightGrey, nil)
    //        XCTAssertNotEqual(UIColor.white, nil)
                
            }
    }

    
    // BaluchonTests/Model/SymbolsTests.swift
    //
    //  SymbolsTests.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 20/02/2021.
    //
    
    import XCTest
    @testable import Baluchon
    
    class SymbolsTests: XCTestCase {
        
            func testSymbols() {
                    XCTAssertEqual(Symbols.eur.string,"€")
                    XCTAssertEqual(Symbols.usd.string, "$")
            }
        
    }

    
    // BaluchonTests/Screens/Weather/WeatherVCTests.swift
    //
    //  WeatherVCTests.swift
    //  BaluchonTests
    //
    //  Created by Cristian Rojas on 10/01/2021.
    //
    
    import XCTest
    @testable import Baluchon
    
    
    @available(iOS 13.0, *)
    class WeatherVCTests: XCTestCase {
        
            var sut: WeatherViewController!
            var repository: WeatherRepositoryInput!
        
            override func setUp() {
                    repository = WeatherRepository(api: MockWeatherApi())
                    sut = WeatherViewController()
    //        sut.repository = repository
            }
        
            override func tearDown() {
                    repository = nil
                    sut = nil
            }
        
        
            func testGivenIdleState_WhenLoadModel_ThenStateGoesFromIdleSuccess() {
                    _ = [
                            WeatherViewState.loadingDestination,
                            WeatherViewState.successDestination(WeatherResponse(name: "", main: WeatherTemp(temp: 0.0), weather: []))
                    ]
            }
        
    }

    
    
    
    
    // BaluchonUITests/BaluchonUITests.swift
    //
    //  BaluchonUITests.swift
    //  BaluchonUITests
    //
    //  Created by Cristian Rojas on 19/11/2020.
    //
    
    import XCTest
    
    class BaluchonUITests: XCTestCase {
    }

    
    
    // p6-count-on-me.swift
    
    // CountONMe.playground/Contents.swift
    import Foundation
    
    enum Operands {
            case plus
            case less
            case multiply
            case divide
            case equal
        
            var symbol: String {
                    switch self {
                    case .plus:
                            return "+"
                    case .less:
                            return "-"
                    case .multiply:
                            return "x"
                    case .divide:
                            return "÷"
                    case .equal:
                            return "="
                    }
            }
    }

    var operationsToReduce = ["1", Operands.plus.symbol, "2", Operands.multiply.symbol, "2", "+", "2", Operands.divide.symbol, "2"]
    /*
    
        ["1", "+", "2", "*", "2", "+", "2", "÷", "2"]
        ["1", "+", "4", "+", "2", "÷", "2"]
        ["1", "+", "4", "+", "1"]
        ["5", "+", "1"]
        ["6"]
        
        */
        
    operationsToReduce.firstIndex { operand -> Bool in
            operand == Operands.multiply.symbol || operand == Operands.divide.symbol
    }

    /// Iterate over operations while an operand still here
    
    while operationsToReduce.count > 1 {
        
            var result: Float
        
            let firstIndex = operationsToReduce.firstIndex { operand -> Bool in
                    operand == Operands.multiply.symbol || operand == Operands.divide.symbol
            }
        
            if let index = firstIndex {
                
                    let left = Float(operationsToReduce[index - 1]) ?? 1
                    let operand = operationsToReduce[index]
                    let right = Float(operationsToReduce[index + 1]) ?? 1
                
                    switch operand {
                    case Operands.multiply.symbol:
                            result = left * right
                    case Operands.divide.symbol:
                            result = left / right
                    default:
                            result = 0
                    }
                
                    let array = [index + 1, index, index - 1]
                    for i in array {
                            operationsToReduce.remove(at: i)
                    }
                
                    operationsToReduce.insert("\(result)", at: index-1)
            } else {
                    let left = Float(operationsToReduce[0]) ?? 0
                    let operand = operationsToReduce[1]
                    let right = Float(operationsToReduce[2]) ?? 0
                
                    switch operand {
                    case Operands.plus.symbol:
                            result = left + right
                    case Operands.less.symbol:
                            result = left - right
                    default:
                            result = 0
                    }
                
                    operationsToReduce = Array(operationsToReduce.dropFirst(3))
                    operationsToReduce.insert("\(result)", at: 0)
                
            }
        
    }

    print(operationsToReduce)
    
    
    // CountOnMe/App/AppDelegate.swift
    //
    //  AppDelegate.swift
    //  SimpleCalc
    //
    //  Created by Vincent Saluzzo on 29/03/2019.
    //  Copyright © 2019 Vincent Saluzzo. All rights reserved.
    //
    
    import UIKit
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
        
            var window: UIWindow?
        
        
            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                    // Override point for customization after application launch.
                    return true
            }
        
            func applicationWillResignActive(_ application: UIApplication) {
                    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
                    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
            }
        
            func applicationDidEnterBackground(_ application: UIApplication) {
                    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
                    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
            }
        
            func applicationWillEnterForeground(_ application: UIApplication) {
                    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
            }
        
            func applicationDidBecomeActive(_ application: UIApplication) {
                    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
            }
        
            func applicationWillTerminate(_ application: UIApplication) {
                    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
            }
        
        
    }

    
    
    // CountOnMe/Controller/CalcViewController.swift
    //
    //  ViewController.swift
    //  SimpleCalc
    //
    //  Created by Vincent Saluzzo on 29/03/2019.
    //  Copyright © 2019 Vincent Saluzzo. All rights reserved.
    //
    
    import UIKit
    
    class CalcViewController: UIViewController {
        
            @IBOutlet weak var textView: UITextView!
            @IBOutlet var numberButtons: [UIButton]!
        
            let calculator = Calculator()
        
            override func viewDidLoad() { super.viewDidLoad() }
        
            // View actions
            @IBAction func tappedResetButton(_ sender: UIButton) {
                    textView.text = calculator.reset()
            }
        
            @IBAction func tappedNumberButton(_ sender: UIButton) {
                    tapNumber(sender: sender)
            }
        
            @IBAction func tappedAdditionButton(_ sender: UIButton) {
                    executeCalc(with: Operands.addition)
            }
        
            @IBAction func tappedSubstractionButton(_ sender: UIButton) {
                    executeCalc(with: Operands.substraction)
            }
        
            @IBAction func tappedMultiplicationButton(_ sender: UIButton) {
                    executeCalc(with: Operands.multiplication)
            }
        
            @IBAction func tappedDivisionButton(_ sender: UIButton) {
                    executeCalc(with: Operands.division)
            }
        
            @IBAction func tappedEqualButton(_ sender: UIButton) {
                    tapEqual()
            }
        
    }

    private extension CalcViewController {
        
            var elements: [String] {
                    return textView.text.split(separator: " ").map { "\($0)" }
            }
        
            var expressionHaveResult: Bool {
                    return textView.text.firstIndex(of: "=") != nil
            }
        
        
            func tapNumber(sender: UIButton) {
                    /// Retrieves number
                    guard let numberText = sender.title(for: .normal) else {
                            return
                    }
                
                    /// Clears the textView if its content have a result (tappedEqualButton) or has been cleaned with the "AC" button (textView.text == 0)
                    if textView.text == "0" || expressionHaveResult {
                            textView.text = ""
                    }
                
                    textView.text.append(numberText)
            }
        
            func tapEqual() {
                    if expressionHaveResult {
                            textView.text = calculator.reset()
                    } else {
                            let result = calculator.compute(elements: elements)
                        
                            switch result {
                            case .failure(let error):
                                    presentErrorAlert(with: error.title, and: error.message)
                            case .success(let success):
                                    textView.text.append(" = \(success)")
                            }
                    }
            }
        
            func executeCalc(with operand: Operands) {
                    if calculator.expressionIsCorrect(elements: elements) {
                            textView.text.append(" \(operand.symbol) ")
                    } else {
                            presentErrorAlert(with: CalcError.moreThanOneOperator.title, and: CalcError.moreThanOneOperator.message)
                    }
            }
    }

    extension CalcViewController: UITextViewDelegate {
        
    }

    
    
    // CountOnMe/Extensions/Double+Format.swift
    //
    //  Float+isInt.swift
    //  CountOnMe
    //
    //  Created by Cristian Rojas on 30/10/2020.
    //  Copyright © 2020 Vincent Saluzzo. All rights reserved.
    //
    
    import Foundation
    
    extension Double {
            var format: String {
                    let intMax = Double(Int.max)
                    if self.truncatingRemainder(dividingBy: 1) == 0 && self < intMax {
                            return "\(Int(self))"
                    } else {
                            return "\(self)"
                    }
            }
    }

    
    // CountOnMe/Extensions/UIViewController+PresentAlert.swift
    //
    //  UIViewController+PresentAlert.swift
    //  CountOnMe
    //
    //  Created by Cristian Rojas on 16/10/2020.
    //  Copyright © 2020 Vincent Saluzzo. All rights reserved.
    //
    
    import UIKit
    
    extension UIViewController {
            func presentErrorAlert(with title: String, and message: String) {
                    // passer autre button
                    // extension uiviewcontroller
                    let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
            }
    }

    
    // CountOnMe/Model/CalcError.swift
    //
    //  Constants.swift
    //  CountOnMe
    //
    //  Created by Cristian Rojas on 16/10/2020.
    //  Copyright © 2020 Vincent Saluzzo. All rights reserved.
    //
    
    enum CalcError: Error {
        
            case incorrectExpression
            case notEnoughElements
            case moreThanOneOperator
            case inconvertibleString
        
        
            var title: String {
                    switch self {
                    case .incorrectExpression:
                            return "Expression incorrecte"
                    case .notEnoughElements:
                            return "L'expression n'a pas assez d'éléments"
                    case .moreThanOneOperator:
                            return "Ce n'est pas possible d'ajouter un nouveau operateur"
                    case .inconvertibleString:
                            return "Impossible de convetir"
                    }
            }
        
            var message: String {
                    switch self {
                    case .incorrectExpression:
                            return "Entrez une expression correcte!"
                    case .notEnoughElements:
                            return "Démarrez un nouveau calcul!"
                    case .moreThanOneOperator:
                            return "Un operateur est déja mis!"
                    case .inconvertibleString:
                            return "Il n'est pas possible de convertir le string en float"
                    }
            }
    }

    
    
    // CountOnMe/Model/Calculator.swift
    //
    //  Calculator.swift
    //  CountOnMe
    //
    //  Created by Cristian Rojas on 16/10/2020.
    //  Copyright © 2020 Vincent Saluzzo. All rights reserved.
    //
    
    class Calculator {
        
            func expressionIsCorrect(elements: [String]) -> Bool {
                    return elements.last != Operands.addition.symbol
                            && elements.last != Operands.substraction.symbol
                            && elements.last != Operands.multiplication.symbol
                            && elements.last != Operands.division.symbol
            }
        
            func reset() -> String {
                    return "0"
            }
        
            func compute(elements: [String]) -> Result<String, CalcError> {
                    guard expressionIsCorrect(elements: elements) else {
                            return .failure(CalcError.incorrectExpression)
                    }
                
                    guard expressionHaveEnoughElement(elements: elements) else {
                            return .failure(CalcError.notEnoughElements)
                    }
                
                    var operationsToReduce = elements
                
                    while operationsToReduce.count > 1 {
                            var result: Double = 0.0
                        
                            let firstIndex = operationsToReduce.firstIndex { operand -> Bool in
                                    operand == Operands.multiplication.symbol || operand == Operands.division.symbol
                            }
                        
                            if let index = firstIndex {
                                    do {
                                            try computePrioritaryOperations(operationsToReduce: &operationsToReduce, index: index, result: &result)
                                    } catch {
                                            if let error = error as? CalcError { return .failure(error) }
                                    }
                                
                            } else {
                                    do {
                                            try computeNonPrioritaryOperations(operationsToReduce: &operationsToReduce, result: &result)
                                    } catch {
                                            if let error = error as? CalcError { return .failure(error) }
                                    }
                            }
                    }
                
                    return .success(operationsToReduce.first ?? "")
            }
    }

    
    // MARK: - Private methods
    private extension Calculator {
        
            func expressionHaveEnoughElement(elements: [String]) -> Bool {
                    return elements.count >= 3
            }
        
            func computePrioritaryOperations(operationsToReduce: inout [String], index: Int, result: inout Double) throws {
                    guard let left = Double(operationsToReduce[index - 1]) else { throw CalcError.inconvertibleString }
                    let operand = operationsToReduce[index]
                    guard let right = Double(operationsToReduce[index + 1]) else { throw CalcError.inconvertibleString }
                
                    if operand == Operands.multiplication.symbol {
                            result = left * right
                    } else if operand == Operands.division.symbol {
                            result = left / right
                    }
                
                    let array = [index + 1, index, index - 1]
                    for i in array {
                            operationsToReduce.remove(at: i)
                    }
                
                    operationsToReduce.insert(result.format, at: index - 1)
            }
        
            func computeNonPrioritaryOperations(operationsToReduce: inout [String], result: inout Double) throws {
                    guard let left = Double(operationsToReduce[0]) else { throw CalcError.inconvertibleString }
                    let operand = operationsToReduce[1]
                    guard let right = Double(operationsToReduce[2]) else { throw CalcError.inconvertibleString }
                
                    if operand == Operands.addition.symbol {
                            result = left + right
                    } else if operand == Operands.substraction.symbol {
                            result = left - right
                    }
                
                    operationsToReduce = Array(operationsToReduce.dropFirst(3))
                    operationsToReduce.insert(result.format, at: 0)
            }
    }

            
    
    // CountOnMe/Model/Operands.swift
    //
    //  Operands.swift
    //  CountOnMe
    //
    //  Created by Cristian Rojas on 16/10/2020.
    //  Copyright © 2020 Vincent Saluzzo. All rights reserved.
    //
    
    enum Operands {
            case addition
            case substraction
            case multiplication
            case division
        
        
            var symbol: String {
                    switch self {
                    case .addition:
                            return "+"
                    case .substraction:
                            return "-"
                    case .multiplication:
                            return "x"
                    case .division:
                            return "÷"
                    }
            }
    }

    
    // SimpleCalcTests/SimpleCalcTests.swift
    //
    //  SimpleCalcTests.swift
    //  SimpleCalcTests
    //
    //  Created by Vincent Saluzzo on 29/03/2019.
    //  Copyright © 2019 Vincent Saluzzo. All rights reserved.
    //
    
    import XCTest
    @testable import CountOnMe
    
    class SimpleCalcTests: XCTestCase {
        
            var calculator: Calculator!
        
            override func setUp() {
                    calculator = Calculator()
            }
        
            func testGivenLastCharacterIsntAnOperator_WhenCallingExpressionIsCorrect_ThenWeShouldGetTrue() {
                
                    XCTAssertFalse(calculator.expressionIsCorrect(elements: ["+"]))
                    XCTAssertTrue(calculator.expressionIsCorrect(elements: ["1"]))
            }
        
            func testResetButton() {
                    let reset = calculator.reset()
                    XCTAssertEqual(reset, "0")
            }
        
            // MARK: - Addition & subscraction
        
            func testGiven1plus1_WhenCallingCompute_ThenWeShouldGet2() {
                    let operation = calculator.compute(elements: ["1", Operands.addition.symbol, "1"])
                    XCTAssertEqual(operation, .success("2"))
            }
        
            func testGiven2minus1_WhenCallingCompute_ThenWeShouldGet1() {
                    let operation = calculator.compute(elements: ["2", Operands.substraction.symbol, "1"])
                    XCTAssertEqual(operation, .success("1"))
            }
        
            // MARK: - Multiplcation & Division
        
            func testGiven2times2_WhenCallingCompute_ThenWeShouldGet4() {
                    let operation = calculator.compute(elements: ["2", Operands.multiplication.symbol, "2"])
                    XCTAssertEqual(operation, .success("4"))
            }
        
            func testGiven10divided5_WhenCallingCompute_ThenWeShouldGet2() {
                    let operation = calculator.compute(elements: ["10", Operands.division.symbol, "5"])
                    XCTAssertEqual(operation, .success("2"))
            }
        
            func testGiven5divided2_WhenCallingCompute_ThenWeShouldGet2dot5() {
                    let operation = calculator.compute(elements: ["5", Operands.division.symbol, "2"])
                    XCTAssertEqual(operation, .success("2.5"))
            }
        
            func testGivenNumberIsDividedByZero_WhenCallingCompute_ThenWeShouldGetInfinite() {
                    let operation = calculator.compute(elements: ["1", Operands.division.symbol, "0"])
                    XCTAssertEqual(operation, .success("inf"))
            }
        
            func testGivenZeroIsDividedByNumber_WhenCallingCompute_ThenWeShouldGetZero() {
                    let operation = calculator.compute(elements: ["0", Operands.division.symbol, "2"])
                    XCTAssertEqual(operation, .success("0"))
            }
        
            func testGivenZeroIsMultipliedByNumber_WhenCallingCompute_ThenWeShouldGetZero() {
                    let operation = calculator.compute(elements: ["0", Operands.multiplication.symbol, "2"])
                    XCTAssertEqual(operation, .success("0"))
            }
        
            func testGivenZeroIsDividedByZero_WhenCallingCompute_ThenWeShouldGetNotANumber() {
                    let operation = calculator.compute(elements: ["0", Operands.division.symbol, "0"])
                    XCTAssertEqual(operation, .success("-nan"))
            }
        
            // MARK: - Prioritary order
            func testGiven1plus1times2_WhenCallingCompute_ThenWeShouldGetThree() {
                    let operation = calculator.compute(elements: ["1", Operands.addition.symbol, "1", Operands.multiplication.symbol, "2"])
                    XCTAssertEqual(operation, .success("3"))
            }
        
            // MARK: - Multiplication with Big numbers
            func testGiven1e48Times1e48_WhenCallingCompute_ThenWeShouldGet1e96() {
                    let double: Double = pow(10, 48)
                    let bigNumber = "\(double)"
                    let operation = calculator.compute(elements: [bigNumber, Operands.multiplication.symbol, bigNumber])
                    XCTAssertEqual(operation, .success("1e+96"))
            }
        
            // MARK: - Errors
            func testGivenExpressionIsIncorrect_WhenCallingCompute_ThenWeShouldGetAFailure() {
                    let operation = calculator.compute(elements: ["1", "+"])
                    switch operation {
                    case .success:
                            XCTFail()
                    case .failure(let error):
                            XCTAssertEqual(error, CalcError.incorrectExpression)
                            XCTAssertEqual(error.title, "Expression incorrecte")
                            XCTAssertEqual(error.message, "Entrez une expression correcte!")
                    }
            }
        
            func testGivenExpressionHasntEnoughElements_WhenCallingCompute_ThenWeShouldGetAFailure() {
                
                    let operation = calculator.compute(elements: ["1"])
                    XCTAssertEqual(operation, .failure(CalcError.notEnoughElements))
                
                    switch operation {
                    case .success:
                            XCTFail()
                    case .failure(let error):
                            XCTAssertEqual(error, CalcError.notEnoughElements)
                            XCTAssertEqual(error.title, "L'expression n'a pas assez d'éléments")
                            XCTAssertEqual(error.message, "Démarrez un nouveau calcul!")
                    }
            }
        
            func testGivenElementIsInconvertible_WhenCallingComputeWithPriority_ThenShouldGetCalcErrorInconvertibleString() {
                    var operation = calculator.compute(elements: ["a", Operands.multiplication.symbol, "2"])
                    switch operation {
                    case .success:
                            XCTFail()
                    case .failure(let error):
                            XCTAssertEqual(error.title, "Impossible de convetir")
                            XCTAssertEqual(error.message, "Il n'est pas possible de convertir le string en float")
                    }
                
                    operation = calculator.compute(elements: ["1", Operands.multiplication.symbol, "a"])
                    XCTAssertEqual(operation, .failure(CalcError.inconvertibleString))
            }
        
            func testGivenElementIsInconvertible_WhenCallingComputeWithoutPriority_ThenWeShouldGetCalcErrorInconvertibleString() {
                    var operation = calculator.compute(elements: ["a", Operands.addition.symbol, "1"])
                    XCTAssertEqual(operation, .failure(CalcError.inconvertibleString))
                    operation = calculator.compute(elements: ["1", Operands.addition.symbol, "a"])
                    XCTAssertEqual(operation, .failure(CalcError.inconvertibleString))
            }
        
            // MARK: - Errors not used on calculator class
            func testMoreThanOneOperator() {
                    let error = CalcError.moreThanOneOperator
                    XCTAssertEqual(error.title, "Ce n'est pas possible d'ajouter un nouveau operateur")
                    XCTAssertEqual(error.message, "Un operateur est déja mis!")
            }
        
    }

// code editor:
    import AppKit
    import UniformTypeIdentifiers
    
    
    import AppKit
    
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)
    
    
    // 2. Configurar Ventana y asignar el Controller
    let rect = NSRect(x: 0, y: 0, width: 400, height: 300)
    let window = NSWindow(contentRect: rect, 
                                                styleMask: [.titled, .closable, .resizable], 
                                                backing: .buffered, 
                                                defer: false)

    let viewController = ViewController()
    window.contentViewController = viewController 
    window.title =  "Editor"
    window.makeKeyAndOrderFront(nil)
    
    app.run()
    
    // MARK: - Theme
    
    struct Theme {
            let name: String
            let background:   NSColor
            let plainText:    NSColor
            let keywords:     NSColor
            let strings:      NSColor
            let comments:     NSColor
            let types:        NSColor
            let numbers:      NSColor
            let functions:    NSColor
            let operators:    NSColor
            // Gutter
            let gutterBackground: NSColor
            let gutterActiveLine: NSColor
            let gutterInactiveLine: NSColor
        
            // MARK: - Presets
        
            /// The original "Dark" preset — system colors, matches the app's initial look.
            static let dark = Theme(
                    name:               "Dark",
                    background:         .black,
                    plainText:          .white,
                    keywords:           .systemOrange,
                    strings:            .systemYellow,
                    comments:           .systemGray,
                    types:              NSColor(red: 0.9, green: 0.6, blue: 0.4, alpha: 1),
                    numbers:            .systemYellow,
                    functions:          .systemBlue,
                    operators:          .systemCyan,
                    gutterBackground:   NSColor(white: 0.08, alpha: 1),
                    gutterActiveLine:   NSColor.white.withAlphaComponent(0.85),
                    gutterInactiveLine: NSColor.white.withAlphaComponent(0.25)
            )
        
            /// Xcode Default Dark theme — colors extracted from the official Xcode theme.
            static let xcodeDark = Theme(
                    name:               "Xcode Dark",
                    background:         NSColor(hex: "#292A30"),
                    plainText:          NSColor(hex: "#DFDFE0"),
                    keywords:           NSColor(hex: "#FF7AB2"),  // pink
                    strings:            NSColor(hex: "#FF8170"),  // salmon
                    comments:           NSColor(hex: "#7F8C98"),  // slate gray
                    types:              NSColor(hex: "#DABAFF"),  // soft purple
                    numbers:            NSColor(hex: "#D9C97C"),  // warm yellow
                    functions:          NSColor(hex: "#4EB0CC"),  // sky blue
                    operators:          NSColor(hex: "#DFDFE0"),  // plain text (dimmed punctuation)
                    gutterBackground:   NSColor(hex: "#23232A"),
                    gutterActiveLine:   NSColor(hex: "#DFDFE0").withAlphaComponent(0.85),
                    gutterInactiveLine: NSColor(hex: "#DFDFE0").withAlphaComponent(0.25)
            )
        
            // Active theme — change this to switch themes app-wide.
            static var active: Theme = .dark
    }

    // MARK: - NSColor hex convenience init
    
    private extension NSColor {
            convenience init(hex: String) {
                    let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
                    var rgb: UInt64 = 0
                    Scanner(string: hex).scanHexInt64(&rgb)
                    let r = CGFloat((rgb >> 16) & 0xFF) / 255
                    let g = CGFloat((rgb >>  8) & 0xFF) / 255
                    let b = CGFloat( rgb        & 0xFF) / 255
                    self.init(red: r, green: g, blue: b, alpha: 1)
            }
    }

    // MARK: - HighlightedStorage
    
    final class HighlightedStorage: NSTextStorage {
        
            private let backing = NSMutableAttributedString()
            private let highlighter = SyntaxHighlighter()
        
            override var string: String { backing.string }
        
            override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
                    backing.attributes(at: location, effectiveRange: range)
            }
        
            override func replaceCharacters(in range: NSRange, with str: String) {
                    backing.replaceCharacters(in: range, with: str)
                    edited(.editedCharacters, range: range, changeInLength: (str as NSString).length - range.length)
            }
        
            override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
                    backing.setAttributes(attrs, range: range)
                    edited(.editedAttributes, range: range, changeInLength: 0)
            }
        
            override func processEditing() {
                    let nsString = backing.string as NSString
                    let lineRange = nsString.lineRange(for: editedRange)
                    let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
                    backing.addAttribute(.font, value: font, range: lineRange)
                    backing.addAttribute(.foregroundColor, value: Theme.active.plainText, range: lineRange)
                
                    // Small edits: highlight synchronously — zero latency at the cursor.
                    // Large ranges (file load, big paste): highlight async so UI stays
                    // responsive. Text appears white first, then gets colored.
                    if lineRange.length < 3000 {
                            let attributes = highlighter.computeAttributes(for: backing.string, in: lineRange)
                            for attr in attributes {
                                    backing.addAttribute(.foregroundColor, value: attr.color, range: attr.range)
                            }
                            super.processEditing()
                    } else {
                            super.processEditing()
                            let snapshot  = backing.string
                            let snapRange = lineRange
                            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                                    guard let self else { return }
                                    let attributes = self.highlighter.computeAttributes(for: snapshot, in: snapRange)
                                    DispatchQueue.main.async { [weak self] in
                                            guard let self, self.backing.string == snapshot else { return }
                                            self.beginEditing()
                                            for attr in attributes {
                                                    self.backing.addAttribute(.foregroundColor, value: attr.color, range: attr.range)
                                            }
                                            self.endEditing()
                                    }
                            }
                    }
            }
    }

    // MARK: - VimTextView
    
    class VimTextView: NSTextView {
        
            enum VimMode { case normal, insert, replace }
        
            private let caretLayer = CAShapeLayer()
        
            private var vimMode: VimMode = .normal {
                    didSet { updateCaretVisuals() }
            }
        
            // MARK: - Setup
            func setupVimEditor() {
                    self.wantsLayer = true
                    self.allowsUndo = true
                    self.backgroundColor = Theme.active.background
                    self.insertionPointColor = .controlAccentColor
                    self.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
                    caretLayer.zPosition = 100
                    caretLayer.actions = ["position": NSNull(), "bounds": NSNull(), "path": NSNull()]
                    self.layer?.addSublayer(caretLayer)
                    disableAutomaticFeatures()
                    updateCaretVisuals()
                    setupAutocomplete()
            }
        
            private func disableAutomaticFeatures() {
                    self.isAutomaticQuoteSubstitutionEnabled = false
                    self.isAutomaticDashSubstitutionEnabled = false
                    self.isAutomaticSpellingCorrectionEnabled = false
            }
        
            override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting flag: Bool) {
                    // Guard against invalid ranges — can happen when textView.string is set
                    // and AppKit tries to restore/update selection before layout is ready.
                    let length = (string as NSString).length
                    let safeRanges = ranges.filter { v in
                            let r = v.rangeValue
                            return r.location <= length && NSMaxRange(r) <= length
                    }
                    guard !safeRanges.isEmpty else { return }
                    super.setSelectedRanges(safeRanges, affinity: affinity, stillSelecting: flag)
                    updateCaretPosition()
                    if !ghostSuffix.isEmpty { updateAutocomplete() }
                    if vimMode == .normal {
                            scrollOneLineIfNeeded()
                    }
            }
        
            override func didChangeText() {
                    super.didChangeText()
                    if vimMode == .insert || vimMode == .replace {
                            DispatchQueue.main.async { [weak self] in
                                    guard let self else { return }
                                    NSAnimationContext.runAnimationGroup { ctx in
                                            ctx.duration = 0
                                            self.scrollRangeToVisible(NSMakeRange(self.selectedRange().location, 0))
                                    }
                                    self.gutterNeedsDisplay()
                            }
                    }
            }
        
            /// For normal mode navigation: move viewport by exactly one line if cursor
            /// is outside the visible area — never more.
            func scrollOneLineIfNeeded() {
                    guard let lm = layoutManager,
                                let sv = enclosingScrollView,
                                lm.numberOfGlyphs > 0 else { return }
                
                    let loc   = selectedRange().location
                    let nsStr = string as NSString
                    guard nsStr.length > 0 else { return }
                
                    // Don't force layout if glyphs aren't ready yet — happens during file load
                    guard lm.firstUnlaidCharacterIndex() > loc else { return }
                
                    let origin = textContainerOrigin
                    let glyphIdx: Int
                    if loc >= nsStr.length {
                            glyphIdx = lm.numberOfGlyphs - 1
                    } else {
                            let gr = lm.glyphRange(forCharacterRange: NSMakeRange(loc, 0), actualCharacterRange: nil)
                            glyphIdx = min(gr.location, lm.numberOfGlyphs - 1)
                    }
                    guard glyphIdx >= 0 && glyphIdx < lm.numberOfGlyphs else { return }
                
                    var lineRect = lm.lineFragmentRect(forGlyphAt: glyphIdx, effectiveRange: nil)
                    guard lineRect != .zero else { return }
                    lineRect.origin.x += origin.x
                    lineRect.origin.y += origin.y
                
                    let visible = sv.documentVisibleRect
                    if lineRect.minY < visible.minY {
                            sv.contentView.setBoundsOrigin(NSPoint(x: visible.origin.x, y: lineRect.minY))
                            sv.reflectScrolledClipView(sv.contentView)
                    } else if lineRect.maxY > visible.maxY {
                            sv.contentView.setBoundsOrigin(NSPoint(x: visible.origin.x, y: lineRect.maxY - visible.height))
                            sv.reflectScrolledClipView(sv.contentView)
                    }
            }
        
            private func updateCaretVisuals() {
                    if vimMode == .insert {
                            caretLayer.isHidden = true
                            self.insertionPointColor = .controlAccentColor
                    } else {
                            caretLayer.isHidden = false
                            self.insertionPointColor = .clear
                            let color: NSColor = vimMode == .replace ? .systemRed : .systemGray
                            caretLayer.fillColor = color.withAlphaComponent(0.3).cgColor
                            caretLayer.strokeColor = color.cgColor
                            caretLayer.lineWidth = 1.0
                            updateCaretPosition()
                    }
            }
        
            private func updateCaretPosition() {
                    guard vimMode != .insert,
                                let layoutManager = self.layoutManager,
                                let textContainer = self.textContainer else { return }
                    let loc = self.selectedRange()
                    // Skip if layout hasn't reached the cursor yet — but always allow
                    // position 0 (empty doc or start of file) since it's always laid out.
                    if loc.location > 0 {
                            guard layoutManager.firstUnlaidCharacterIndex() > loc.location else { return }
                    }
                    let glyphRange = layoutManager.glyphRange(forCharacterRange: loc, actualCharacterRange: nil)
                    var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                    let origin = self.textContainerOrigin
                    rect.origin.x += origin.x
                    rect.origin.y += origin.y
                    if rect.size.width <= 1 { rect.size.width = 8 }
                    caretLayer.path = CGPath(rect: rect.insetBy(dx: 0.5, dy: 0.5), transform: nil)
                    caretLayer.frame = self.bounds
            }
        
            override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
                    if vimMode == .insert {
                            super.drawInsertionPoint(in: rect, color: color, turnedOn: flag)
                    }
            }
        
            // MARK: - Key constants
            private let ESC = 53
            private let Caret = 33
            private let BEAKLINE = 10
        
            // MARK: - Pair balancing
            private let pairMap: [Character: Character] = [
                    "(": ")", "[": "]", "{": "}", "<": ">",
                    "\"": "\"", "'": "'", "`": "`",
                    "¿": "?", "¡": "!",
            ]
            private let closers: Set<Character> = [")", "]", "}", ">", "\"", "'", "`", "?", "!"]
        
            override func keyDown(with event: NSEvent) {
                    if event.modifierFlags.contains(.command) {
                            switch event.charactersIgnoringModifiers {
                            case "s", "o":
                                    if let vc = window?.contentViewController as? ViewController {
                                            _ = vc.performKeyEquivalent(with: event)
                                            return
                                    }
                            default: break
                            }
                    }
                    switch vimMode {
                    case .normal:
                            if event.keyCode == Caret {
                                    jumpToFirstNonBlank()
                                    return
                            }
                            // Arrow keys in normal mode — route through our moveUp/moveDown
                            // so scrollOneLineIfNeeded is called correctly.
                            switch event.keyCode {
                            case 125: moveDown(nil); stack.clear(); return   // ↓
                            case 126: moveUp(nil);   stack.clear(); return   // ↑
                            case 123: moveCursor(to: max(0, selectedRange().location - 1)); stack.clear(); return  // ←
                            case 124: moveCursor(to: min((string as NSString).length, selectedRange().location + 1)); stack.clear(); return  // →
                            default: break
                            }
                            if handleNormalMode(event) { return }
                    case .insert:
                            if event.keyCode == ESC {
                                    dismissGhost()
                                    vimMode = .normal
                                    return
                            }
                            if event.keyCode == 48 {
                                    if event.modifierFlags.contains(.shift) {
                                            // Shift+Tab — dedent selection or current line
                                            indentSelectedLines(dedent: true)
                                            return
                                    }
                                    if !ghostSuffix.isEmpty { acceptGhost(); return }
                                    if selectedRange().length > 0 {
                                            indentSelectedLines(dedent: false)
                                            return
                                    }
                            }
                            if event.keyCode == 36 {
                                    if !ghostSuffix.isEmpty { acceptGhost(); return }
                                    handleSmartEnter()
                                    updateAutocomplete()
                                    return
                            }
                            if let char = event.characters?.first,
                                    handlePairBalancing(char: char) {
                                    updateAutocomplete()
                                    return
                            }
                            super.keyDown(with: event)
                            updateAutocomplete()
                    case .replace:
                            if let char = event.characters?.first {
                                    replaceCharacter(at: self.selectedRange().location, with: String(char))
                            }
                            vimMode = .normal
                    }
            }
        
            private func handlePairBalancing(char: Character) -> Bool {
                    let sel = self.selectedRange()
                    let text = self.string as NSString
                    if sel.length > 0, let closer = pairMap[char] {
                            let selected = text.substring(with: sel)
                            let wrapped = String(char) + selected + String(closer)
                            insertAndNotify(wrapped, replacing: sel)
                            self.setSelectedRange(NSMakeRange(sel.location + 1, sel.length))
                            return true
                    }
                    if closers.contains(char) {
                            let loc = sel.location
                            if loc < text.length,
                                    let next = Unicode.Scalar(text.character(at: loc)).map(Character.init),
                                    next == char {
                                    moveCursor(to: loc + 1)
                                    return true
                            }
                    }
                    if let closer = pairMap[char] {
                            let pair = String(char) + String(closer)
                            insertAndNotify(pair, replacing: sel)
                            moveCursor(to: sel.location + 1)
                            return true
                    }
                    return false
            }
        
            override func deleteBackward(_ sender: Any?) {
                    guard vimMode == .insert else { super.deleteBackward(sender); return }
                    let sel = self.selectedRange()
                    let text = self.string as NSString
                    let loc = sel.location
                    if sel.length == 0, loc > 0, loc < text.length,
                            let opener = Unicode.Scalar(text.character(at: loc - 1)).map(Character.init),
                            let expectedCloser = pairMap[opener],
                            let actualCloser  = Unicode.Scalar(text.character(at: loc)).map(Character.init),
                            actualCloser == expectedCloser {
                            insertAndNotify("", replacing: NSMakeRange(loc - 1, 2))
                            updateAutocomplete()
                            return
                    }
                    super.deleteBackward(sender)
                    updateAutocomplete()
            }
        
            private func insertAndNotify(_ string: String, replacing range: NSRange) {
                    guard self.shouldChangeText(in: range, replacementString: string) else { return }
                    self.undoManager?.beginUndoGrouping()
                    self.textStorage?.replaceCharacters(in: range, with: string)
                    self.didChangeText()
                    self.undoManager?.endUndoGrouping()
            }
        
            // Arrow keys go through a different internal path than setSelectedRanges —
            // override them to ensure one-line scroll and gutter redraw in all modes.
            override func moveUp(_ sender: Any?) {
                    super.moveUp(sender)
                    scrollOneLineIfNeeded()
                    gutterNeedsDisplay()
            }
        
            override func moveDown(_ sender: Any?) {
                    super.moveDown(sender)
                    scrollOneLineIfNeeded()
                    gutterNeedsDisplay()
            }
        
            private func gutterNeedsDisplay() {
                    if let lnv = superview?.superview?.subviews.first(where: { $0 is LineNumberView }) {
                            lnv.needsDisplay = true
                    }
            }
        
            private func jumpToFirstNonBlank() {
                    let text = self.string as NSString
                    let lineRange = text.lineRange(for: NSMakeRange(self.selectedRange().location, 0))
                    moveCursor(to: findFirstNonBlank(in: text, range: lineRange))
            }
        
            private func moveCursor(to location: Int) {
                    self.setSelectedRange(NSMakeRange(location, 0))
            }
        
            var stack = CharacterStack()
            var unnamedRegister = ""
        
            // MARK: - Autocomplete
        
            private let ghostLabel: NSTextField = {
                    let f = NSTextField(labelWithString: "")
                    f.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
                    f.textColor = NSColor.white.withAlphaComponent(0.3)
                    f.backgroundColor = .clear
                    f.isBezeled = false
                    f.isEditable = false
                    f.isSelectable = false
                    f.cell?.wraps = false
                    f.cell?.isScrollable = true
                    return f
            }()
        
            private var ghostSuffix: String = ""
        
            func setupAutocomplete() {
                    addSubview(ghostLabel)
            }
        
            func updateAutocomplete() {
                    guard vimMode == .insert else { dismissGhost(); return }
                    let loc = self.selectedRange().location
                    let text = self.string as NSString
                
                    // Don't suggest if cursor is mid-word (character to the right is word char)
                    if loc < text.length,
                            let scalar = Unicode.Scalar(text.character(at: loc)) {
                            let c = Character(scalar)
                            if c.isLetter || c.isNumber || c == "_" { dismissGhost(); return }
                    }
                
                    let prefix = currentWordPrefix(in: text, at: loc)
                    guard !prefix.isEmpty,
                                let match = AutocompleteProvider.shared.suggest(for: prefix),
                                match != prefix
                    else { dismissGhost(); return }
                    ghostSuffix = String(match.dropFirst(prefix.count))
                    ghostLabel.stringValue = ghostSuffix
                    positionGhost(at: loc)
                    ghostLabel.isHidden = false
            }
        
            func dismissGhost() {
                    ghostSuffix = ""
                    ghostLabel.stringValue = ""
                    ghostLabel.isHidden = true
            }
        
            func acceptGhost() {
                    guard !ghostSuffix.isEmpty else { return }
                    insertAndNotify(ghostSuffix, replacing: NSMakeRange(self.selectedRange().location, 0))
                    dismissGhost()
            }
        
            private func positionGhost(at charLocation: Int) {
                    guard let lm = self.layoutManager, let tc = self.textContainer else { return }
                    let glyphRange = lm.glyphRange(forCharacterRange: NSMakeRange(charLocation, 0),
                                                                                    actualCharacterRange: nil)
                    var rect = lm.boundingRect(forGlyphRange: glyphRange, in: tc)
                    let origin = self.textContainerOrigin
                    rect.origin.x += origin.x
                    rect.origin.y += origin.y
                    ghostLabel.sizeToFit()
                    ghostLabel.frame.origin = rect.origin
            }
        
            private func currentWordPrefix(in text: NSString, at location: Int) -> String {
                    // Don't suggest if cursor is mid-word — char to the right is also an identifier char
                    if location < text.length,
                            let scalar = Unicode.Scalar(text.character(at: location)) {
                            let c = Character(scalar)
                            if c.isLetter || c.isNumber || c == "_" { return "" }
                    }
                    var start = location
                    while start > 0 {
                            guard let scalar = Unicode.Scalar(text.character(at: start - 1)) else { break }
                            let c = Character(scalar)
                            guard c.isLetter || c.isNumber || c == "_" else { break }
                            start -= 1
                    }
                    guard start < location else { return "" }
                    return text.substring(with: NSMakeRange(start, location - start))
            }
    }

    // MARK: - Autocomplete provider
    
    final class AutocompleteProvider {
            static let shared = AutocompleteProvider()
            private let keywords: [String]
            private init() {
                    keywords = [
                            "associatedtype","async","await",
                            "break",
                            "case","catch","class","continue","convenience",
                            "default","defer","deinit","didSet",
                            "else","enum","extension",
                            "fallthrough","false","fileprivate","final","for","func",
                            "get","guard",
                            "if","import","in","indirect","infix","init","inout","internal","is",
                            "lazy","let",
                            "mutating",
                            "nil","none","nonisolated",
                            "operator","optional","override",
                            "postfix","precedencegroup","prefix","private","protocol","public",
                            "repeat","required","rethrows","return",
                            "self","set","some","static","struct","subscript","super","switch",
                            "throw","throws","true","try","typealias",
                            "unowned",
                            "var",
                            "weak","while","willSet",
                    ].sorted { a, b in
                            // Shorter matches first; break ties alphabetically
                            a.count != b.count ? a.count < b.count : a < b
                    }
            }
            func suggest(for prefix: String) -> String? {
                    return keywords.first { $0.hasPrefix(prefix) }
            }
    }

    // MARK: - Normal mode
    
    extension VimTextView {
        
            private func replaceCharacter(at location: Int, with newChar: String) {
                    let text = self.string as NSString
                    if location >= text.length { return }
                    let range = NSMakeRange(location, 1)
                    if text.character(at: location) == BEAKLINE { return }
                    if self.shouldChangeText(in: range, replacementString: newChar) {
                            self.undoManager?.beginUndoGrouping()
                            self.textStorage?.replaceCharacters(in: range, with: newChar)
                            self.didChangeText()
                            self.undoManager?.endUndoGrouping()
                            moveCursor(to: location)
                    }
            }
        
            private func handleNormalMode(_ event: NSEvent) -> Bool {
                    guard let char = event.charactersIgnoringModifiers?.first else { return false }
                    let currentLoc = self.selectedRange().location
                    let text = self.string as NSString
                    let length = text.length
                
                    switch char {
                    case "i": vimMode = .insert; stack.clear(); return true
                    case "a": moveCursor(to: min(length, currentLoc + 1)); vimMode = .insert; stack.clear(); return true
                    case "d":
                            if stack.last == "d" { deleteCurrentLine(); stack.pop() }
                            else { stack.clear(); stack.push("d") }
                            return true
                    case "c": stack.clear(); stack.push("c"); return true
                    case "u": self.undoManager?.undo(); stack.clear(); return true
                    case "y":
                            if stack.last == "y" { yankCurrentLine(); stack.pop() }
                            else { stack.clear(); stack.push("y") }
                            return true
                    case "w":
                            if stack.last == "d" { deleteWord(from: currentLoc); stack.pop() }
                            else if stack.last == "c" { changeWord(from: currentLoc); stack.pop() }
                            else if stack.last == "y" { yankWord(from: currentLoc); stack.pop() }
                            else { moveCursor(to: findNextWord(in: text, from: currentLoc)) }
                            stack.clear(); return true
                    case "g":
                            if stack.last == "g" { moveCursor(to: 0); stack.pop() }
                            else { stack.clear(); stack.push("g") }
                            return true
                    case "p": pasteFromRegister(currentLoc: currentLoc, text: text); stack.clear(); return true
                    case "o": openLineBelow(currentLoc: currentLoc, text: text); stack.clear(); return true
                    case "^":
                            let lineRange = text.lineRange(for: NSMakeRange(currentLoc, 0))
                            moveCursor(to: findFirstNonBlank(in: text, range: lineRange))
                            stack.clear(); return true
                    case "x": deleteCharacter(at: currentLoc); stack.clear(); return true
                    case "$":
                            let lineRange = text.lineRange(for: NSMakeRange(currentLoc, 0))
                            var end = lineRange.location + lineRange.length
                            if end > 0 && text.character(at: end - 1) == 10 { end -= 1 }
                            moveCursor(to: max(lineRange.location, end)); stack.clear(); return true
                    case "0":
                            let lineRange = text.lineRange(for: NSMakeRange(currentLoc, 0))
                            moveCursor(to: lineRange.location); stack.clear(); return true
                    case "h": moveCursor(to: max(0, currentLoc - 1)); stack.clear(); return true
                    case "l": moveCursor(to: min(length, currentLoc + 1)); stack.clear(); return true
                    case "j": self.moveDown(nil); stack.clear(); return true
                    case "k": self.moveUp(nil); stack.clear(); return true
                    case "G": moveCursor(to: length); stack.clear(); return true
                    case "b": moveCursor(to: findPreviousWord(in: text, from: currentLoc)); stack.clear(); return true
                    case "r": vimMode = .replace; stack.clear(); return true
                    default: stack.clear(); return true
                    }
            }
        
            private func pasteFromRegister(currentLoc: Int, text: NSString) {
                    guard !unnamedRegister.isEmpty else { return }
                    let insertionPoint: Int
                    if unnamedRegister.hasSuffix("\n") {
                            let lineRange = text.lineRange(for: NSMakeRange(currentLoc, 0))
                            insertionPoint = lineRange.location + lineRange.length
                    } else {
                            insertionPoint = min(text.length, currentLoc + 1)
                    }
                    if self.shouldChangeText(in: NSMakeRange(insertionPoint, 0), replacementString: unnamedRegister) {
                            self.undoManager?.beginUndoGrouping()
                            self.insertText(unnamedRegister, replacementRange: NSMakeRange(insertionPoint, 0))
                            self.didChangeText()
                            self.undoManager?.endUndoGrouping()
                            moveCursor(to: insertionPoint)
                    }
            }
        
            private func openLineBelow(currentLoc: Int, text: NSString) {
                    var endOfLine = text.length
                    if currentLoc < text.length {
                            let searchRange = NSMakeRange(currentLoc, text.length - currentLoc)
                            let nextNewline = text.range(of: "\n", options: [], range: searchRange)
                            if nextNewline.location != NSNotFound { endOfLine = nextNewline.location + 1 }
                    }
                    self.setSelectedRange(NSMakeRange(endOfLine, 0))
                    self.insertText("\n", replacementRange: NSMakeRange(endOfLine, 0))
                    self.setSelectedRange(NSMakeRange(endOfLine, 0))
                    self.vimMode = .insert
            }
        
            private func yankCurrentLine() {
                    let text = self.string as NSString
                    let lineRange = text.lineRange(for: NSMakeRange(self.selectedRange().location, 0))
                    unnamedRegister = text.substring(with: lineRange)
            }
        
            private func yankWord(from location: Int) {
                    let text = self.string as NSString
                    if location >= text.length { return }
                    let end = findNextWord(in: text, from: location)
                    unnamedRegister = text.substring(with: NSMakeRange(location, end - location))
            }
        
            private func deleteCharacter(at location: Int) {
                    let text = self.string as NSString
                    if location >= text.length { return }
                    unnamedRegister = text.substring(with: NSMakeRange(location, 1))
                    let range = NSMakeRange(location, 1)
                    if self.shouldChangeText(in: range, replacementString: "") {
                            self.textStorage?.replaceCharacters(in: range, with: "")
                            self.didChangeText()
                            let newLength = (self.string as NSString).length
                            if location >= newLength && newLength > 0 { moveCursor(to: max(0, newLength - 1)) }
                    }
            }
        
            private func deleteCurrentLine() {
                    let text = self.string as NSString
                    let currentLoc = self.selectedRange().location
                    let lineRange = text.lineRange(for: NSMakeRange(currentLoc, 0))
                    unnamedRegister = text.substring(with: lineRange)
                    if self.shouldChangeText(in: lineRange, replacementString: "") {
                            self.textStorage?.replaceCharacters(in: lineRange, with: "")
                            self.didChangeText()
                            let newLoc = min(lineRange.location, (self.string as NSString).length)
                            let newLineRange = (self.string as NSString).lineRange(for: NSMakeRange(newLoc, 0))
                            moveCursor(to: findFirstNonBlank(in: self.string as NSString, range: newLineRange))
                    }
            }
        
            private func deleteWord(from location: Int) {
                    let text = self.string as NSString
                    if location >= text.length { return }
                    let end = findNextWord(in: text, from: location)
                    let range = NSMakeRange(location, end - location)
                    unnamedRegister = text.substring(with: range)
                    executeDeletion(in: range)
            }
        
            private func executeDeletion(in range: NSRange) {
                    if self.shouldChangeText(in: range, replacementString: "") {
                            self.undoManager?.beginUndoGrouping()
                            self.textStorage?.replaceCharacters(in: range, with: "")
                            self.didChangeText()
                            self.undoManager?.endUndoGrouping()
                    }
            }
        
            private func changeWord(from location: Int) {
                    let text = self.string as NSString
                    if location >= text.length { return }
                    let end = findEndOfWordForChange(in: text, from: location)
                    let range = NSMakeRange(location, end - location)
                    unnamedRegister = text.substring(with: range)
                    if self.shouldChangeText(in: range, replacementString: "") {
                            self.textStorage?.replaceCharacters(in: range, with: "")
                            self.didChangeText()
                            self.vimMode = .insert
                    }
            }
        
            private func findFirstNonBlank(in text: NSString, range: NSRange) -> Int {
                    guard range.length > 0 else { return range.location }
                    let whitespace = CharacterSet.whitespaces
                    var loc = range.location
                    let end = range.location + range.length
                    while loc < end {
                            let c = text.character(at: loc)
                            if c == 10 { break }
                            if let scalar = Unicode.Scalar(c), !whitespace.contains(scalar) { break }
                            loc += 1
                    }
                    return min(loc, text.length)
            }
        
            private func findNextWord(in text: NSString, from location: Int) -> Int {
                    let set = CharacterSet.whitespacesAndNewlines
                    var loc = location
                    while loc < text.length, let s = Unicode.Scalar(text.character(at: loc)), !set.contains(s) { loc += 1 }
                    while loc < text.length, let s = Unicode.Scalar(text.character(at: loc)),  set.contains(s) { loc += 1 }
                    return loc
            }
        
            private func findEndOfWordForChange(in text: NSString, from location: Int) -> Int {
                    let set = CharacterSet.whitespacesAndNewlines
                    var loc = location
                    if loc >= text.length { return text.length }
                    if let s = Unicode.Scalar(text.character(at: loc)), set.contains(s) {
                            while loc < text.length, let s2 = Unicode.Scalar(text.character(at: loc)), set.contains(s2) { loc += 1 }
                            return loc
                    }
                    while loc < text.length, let s = Unicode.Scalar(text.character(at: loc)), !set.contains(s) { loc += 1 }
                    return loc
            }
        
            private func findPreviousWord(in text: NSString, from location: Int) -> Int {
                    if location <= 0 { return 0 }
                    var loc = location - 1
                    let set = CharacterSet.whitespacesAndNewlines
                    while loc > 0, let s = Unicode.Scalar(text.character(at: loc)),     set.contains(s) { loc -= 1 }
                    while loc > 0, let s = Unicode.Scalar(text.character(at: loc - 1)), !set.contains(s) { loc -= 1 }
                    return loc
            }
    }

    // MARK: - Smart indent
    
    extension VimTextView {
        
            func handleSmartEnter() {
                    let sel = self.selectedRange()
                    let loc = sel.location
                    let text = self.string as NSString
                    let lineRange = text.lineRange(for: NSMakeRange(loc, 0))
                    let indent = leadingTabs(in: text, lineRange: lineRange)
                    let charBefore: Character? = loc > 0
                            ? Unicode.Scalar(text.character(at: loc - 1)).map(Character.init) : nil
                    let charAfter: Character? = loc < text.length
                            ? Unicode.Scalar(text.character(at: loc)).map(Character.init) : nil
                    if charBefore == "{" && charAfter == "}" {
                            let insertion = "\n\(indent)\t\n\(indent)"
                            insertAndNotify(insertion, replacing: sel)
                            moveCursor(to: loc + 1 + indent.count + 1)
                    } else {
                            let extraTab = charBefore == "{" ? "\t" : ""
                            let insertion = "\n\(indent)\(extraTab)"
                            insertAndNotify(insertion, replacing: sel)
                            moveCursor(to: loc + insertion.count)
                    }
            }
        
            private func leadingTabs(in text: NSString, lineRange: NSRange) -> String {
                    var count = 0
                    var i = lineRange.location
                    while i < lineRange.location + lineRange.length {
                            guard let scalar = Unicode.Scalar(text.character(at: i)) else { break }
                            if scalar == "\t" { count += 1; i += 1 } else { break }
                    }
                    return String(repeating: "\t", count: count)
            }
        
            /// Indent (or dedent) every line touched by the current selection.
            func indentSelectedLines(dedent: Bool) {
                    let sel  = self.selectedRange()
                    let text = self.string as NSString
                    let firstLine = text.lineRange(for: NSMakeRange(sel.location, 0))
                    let lastLine  = text.lineRange(for: NSMakeRange(max(sel.location, NSMaxRange(sel) - 1), 0))
                    let fullRange = NSUnionRange(firstLine, lastLine)
                    var lines = text.substring(with: fullRange).components(separatedBy: "\n")
                    // Don't process the empty string after a trailing newline
                    let count = lines.last == "" ? lines.count - 1 : lines.count
                    for i in 0..<count {
                            if dedent {
                                    if lines[i].hasPrefix("\t") { lines[i] = String(lines[i].dropFirst()) }
                            } else {
                                    lines[i] = "\t" + lines[i]
                            }
                    }
                    let newText = lines.joined(separator: "\n")
                    insertAndNotify(newText, replacing: fullRange)
                    // Restore a selection that covers the same lines
                    let delta = dedent ? -count : count
                    self.setSelectedRange(NSMakeRange(sel.location, max(0, sel.length + delta)))
            }
    }

    extension VimTextView {
        
            override func performKeyEquivalent(with event: NSEvent) -> Bool {
                    guard event.modifierFlags.contains(.command),
                                event.charactersIgnoringModifiers == "b" else {
                            return super.performKeyEquivalent(with: event)
                    }
                    expandScope()
                    return true
            }
        
            private func expandScope() {
                    let text = self.string as NSString
                    let sel  = self.selectedRange()
                
                    // Step 0: if no selection, first select the current word.
                    if sel.length == 0 {
                            if let wordRange = currentWordRange(in: text, at: sel.location) {
                                    self.setSelectedRange(wordRange)
                                    return
                            }
                    }
                
                    // Step 1: if selection is exactly a word, try to extend it to include
                    // an immediately-following pair (e.g. Person → Person(name: "Cristian")).
                    if sel.length > 0 {
                            let wordEnd = NSMaxRange(sel)
                            if wordEnd < text.length,
                                    let scalar = Unicode.Scalar(text.character(at: wordEnd)) {
                                    let nextChar = Character(scalar)
                                    // Only extend if pair opens immediately after word (no space)
                                    let openerToCloser: [Character: Character] = ["{": "}", "(": ")", "[": "]", "<": ">"]
                                    if let closer = openerToCloser[nextChar],
                                            let (_, close) = enclosingAsymmetricPair(
                                                    in: text, from: wordEnd + 1,
                                                    opener: nextChar, closer: closer) {
                                            let extended = NSMakeRange(sel.location, close - sel.location + 1)
                                            if extended.length > sel.length {
                                                    if let safe = validRange(extended, in: text) {
                                                            self.setSelectedRange(safe)
                                                            return
                                                    }
                                            }
                                    }
                            }
                    }
                
                    // Strategy: find the smallest pair/decl that is strictly larger than sel.
                    // This always moves outward regardless of how sel was created.
                
                    // Collect all candidate ranges that strictly contain sel
                    var candidates: [NSRange] = []
                
                    // Find all enclosing pairs of any kind from cursor (or start of sel)
                    let anchor = sel.length == 0 ? sel.location : sel.location + 1
                
                    // Try every pair type and collect innerBody, fullPair, fullDecl
                    let asymmetric: [(Character, Character)] = [
                            ("{", "}"), ("(", ")"), ("[", "]"),
                            ("¿", "?"), ("¡", "!"),
                    ]
                    let openerToCloser: [Character: Character] = ["{": "}", "(": ")", "[": "]"]
                    for (opener, closer) in asymmetric {
                            var searchLoc = anchor
                            var lastOpen = -1
                            while searchLoc > 0 {
                                    guard let (open, close) = enclosingAsymmetricPair(
                                            in: text, from: searchLoc, opener: opener, closer: closer) else { break }
                                    guard open != lastOpen else { break }
                                    lastOpen = open
                                    let inner = NSMakeRange(open + 1, close - open - 1)
                                    let full  = NSMakeRange(open, close - open + 1)
                                    candidates.append(inner)
                                    candidates.append(full)
                                    if opener == "{" {
                                            candidates.append(fullDeclarationRange(in: text, openBrace: open, closeBrace: close))
                                    }
                                    // Also add word+pair (e.g. Person(…)) if a word precedes the opener
                                    if openerToCloser[opener] != nil,
                                            let wordRange = currentWordRange(in: text, at: open > 0 ? open - 1 : 0),
                                            NSMaxRange(wordRange) == open {
                                            candidates.append(NSMakeRange(wordRange.location, close - wordRange.location + 1))
                                    }
                                    searchLoc = open
                            }
                    }
                    for delim in ["\"", "'", "`"] as [Character] {
                            // Don't search if cursor is sitting on the delimiter itself —
                            // we can't tell if it's an opener or closer without a parser.
                            let cursorChar = anchor < text.length
                                    ? Unicode.Scalar(text.character(at: anchor)).map(Character.init) : nil
                            guard cursorChar != delim else { continue }
                            if let (open, close) = enclosingSymmetricPair(in: text, from: anchor, delimiter: delim) {
                                    candidates.append(NSMakeRange(open + 1, close - open - 1))
                                    candidates.append(NSMakeRange(open, close - open + 1))
                            }
                    }
                
                    // Compute current line range once — used for both = search and line candidate
                    let lineRange = text.lineRange(for: NSMakeRange(anchor > 0 ? anchor - 1 : 0, 0))
                    var lineEnd = NSMaxRange(lineRange)
                    if lineEnd > lineRange.location,
                            let scalar = Unicode.Scalar(text.character(at: lineEnd - 1)),
                            scalar == "\n" { lineEnd -= 1 }
                
                    // Add the RHS of an assignment (after `=`) as a candidate.
                    // Only matches a bare `=` — not ==, !=, <=, >=, +=, -=, *=, /=.
                    let lineStart = lineRange.location
                    var eqPos = -1
                    var i = lineStart
                    while i < lineEnd {
                            guard let scalar = Unicode.Scalar(text.character(at: i)) else { i += 1; continue }
                            if scalar == "=" {
                                    let prev = i > lineStart ? Unicode.Scalar(text.character(at: i - 1)) : nil
                                    let next = i + 1 < text.length ? Unicode.Scalar(text.character(at: i + 1)) : nil
                                    let notAssign: Set<Unicode.Scalar> = ["=", "!", "<", ">", "+", "-", "*", "/"]
                                    if (prev == nil || !notAssign.contains(prev!)) &&
                                            (next == nil || next! != "=") {
                                            eqPos = i; break
                                    }
                            }
                            i += 1
                    }
                    if eqPos >= 0 {
                            var rhsStart = eqPos + 1
                            while rhsStart < lineEnd,
                                        let scalar = Unicode.Scalar(text.character(at: rhsStart)),
                                        scalar == " " || scalar == "\t" { rhsStart += 1 }
                            if rhsStart < lineEnd {
                                    candidates.append(NSMakeRange(rhsStart, lineEnd - rhsStart))
                            }
                    }
                
                    // Also add the current line (trimmed of trailing \n) as a candidate
                    if lineEnd > lineRange.location {
                            candidates.append(NSMakeRange(lineRange.location, lineEnd - lineRange.location))
                    }
                
                    // Filter: must strictly contain sel (larger and starts at or before sel)
                    let strictly = candidates.compactMap { validRange($0, in: text) }.filter { r in
                            r.length > sel.length &&
                            r.location <= sel.location &&
                            NSMaxRange(r) >= NSMaxRange(sel)
                    }
                
                    // Pick the smallest one
                    guard let best = strictly.min(by: { $0.length < $1.length }),
                                let safe = validRange(best, in: text) else { return }
                    self.setSelectedRange(safe)
            }
        
            /// Returns the (open, close) indices of the smallest pair of any kind
            /// that strictly contains `location`. Considers both asymmetric pairs
            /// ({}, (), [], <>) and symmetric pairs (", ', `, ?, !).
            private func smallestEnclosingPair(in text: NSString, from location: Int) -> (Int, Int)? {
                    var best: (Int, Int)? = nil
                
                    // Check all asymmetric pairs
                    let asymmetric: [(Character, Character)] = [
                            ("{", "}"), ("(", ")"), ("[", "]"),
                            ("¿", "?"), ("¡", "!"),
                    ]
                    for (opener, closer) in asymmetric {
                            if let pair = enclosingAsymmetricPair(in: text, from: location,
                                                                                                            opener: opener, closer: closer) {
                                    if best == nil || (pair.1 - pair.0) < (best!.1 - best!.0) {
                                            best = pair
                                    }
                            }
                    }
                
                    // Check symmetric pairs
                    let symmetric: [Character] = ["\"", "'", "`"]
                    for delim in symmetric {
                            if let pair = enclosingSymmetricPair(in: text, from: location, delimiter: delim) {
                                    if best == nil || (pair.1 - pair.0) < (best!.1 - best!.0) {
                                            best = pair
                                    }
                            }
                    }
                
                    return best
            }
        
            /// Finds the innermost asymmetric pair (e.g. `{…}`) containing `location`.
            private func enclosingAsymmetricPair(in text: NSString, from location: Int,
                                                                                        opener: Character, closer: Character) -> (Int, Int)? {
                    var depth = 0
                    var i = location - 1
                    var openIdx: Int? = nil
                    while i >= 0 {
                            guard let scalar = Unicode.Scalar(text.character(at: i)) else { i -= 1; continue }
                            let c = Character(scalar)
                            if c == closer { depth += 1 }
                            else if c == opener {
                                    if depth == 0 { openIdx = i; break }
                                    else { depth -= 1 }
                            }
                            i -= 1
                    }
                    guard let open = openIdx else { return nil }
                    depth = 0
                    var j = open
                    while j < text.length {
                            guard let scalar = Unicode.Scalar(text.character(at: j)) else { j += 1; continue }
                            let c = Character(scalar)
                            if c == opener { depth += 1 }
                            else if c == closer {
                                    depth -= 1
                                    if depth == 0 { return (open, j) }
                            }
                            j += 1
                    }
                    return nil
            }
        
            /// Finds the innermost symmetric pair (e.g. `"…"`) containing `location`.
            private func enclosingSymmetricPair(in text: NSString, from location: Int,
                                                                                        delimiter: Character) -> (Int, Int)? {
                    // Find start of line
                    let lineRange = text.lineRange(for: NSMakeRange(min(location, text.length - 1), 0))
                    let lineStart = lineRange.location
                                                                                            
                    // Count delimiters from line start to location.
                    // If count is even → cursor is outside any pair on this line → no match.
                    // If count is odd → cursor is inside a pair → the last delimiter before
                    // location is the opener.
                    var count = 0
                    var lastDelimPos = -1
                    var i = lineStart
                    while i < location && i < text.length {
                            guard let scalar = Unicode.Scalar(text.character(at: i)) else { i += 1; continue }
                            if Character(scalar) == delimiter {
                                    count += 1
                                    lastDelimPos = i
                            }
                            i += 1
                    }
                                                                                            
                    // Even count → cursor is outside any pair
                    guard count % 2 == 1, lastDelimPos >= 0 else { return nil }
                                                                                            
                    let open = lastDelimPos
                    // Find closing delimiter after location on the same line
                    var j = location
                    while j < text.length {
                            guard let scalar = Unicode.Scalar(text.character(at: j)) else { j += 1; continue }
                            if scalar == "\n" { break }
                            if Character(scalar) == delimiter { return (open, j) }
                            j += 1
                    }
                    return nil
            }
        
            private func enclosingBracePair(in text: NSString, from location: Int) -> (Int, Int)? {
                    enclosingAsymmetricPair(in: text, from: location, opener: "{", closer: "}")
            }
        
            /// Returns the range of the word under/adjacent to `location`, or nil if
            /// the cursor is on whitespace/punctuation.
            private func currentWordRange(in text: NSString, at location: Int) -> NSRange? {
                    guard text.length > 0 else { return nil }
                    let loc = min(location, text.length - 1)
                
                    // Check if cursor is on a word character
                    let isWordChar: (Int) -> Bool = { i in
                            guard i >= 0, i < text.length,
                                        let scalar = Unicode.Scalar(text.character(at: i)) else { return false }
                            let c = Character(scalar)
                            return c.isLetter || c.isNumber || c == "_"
                    }
                
                    // If cursor is not on a word char, try one position to the left
                    var start = loc
                    if !isWordChar(start) {
                            guard start > 0, isWordChar(start - 1) else { return nil }
                            start = start - 1
                    }
                
                    // Expand left
                    var wordStart = start
                    while wordStart > 0 && isWordChar(wordStart - 1) { wordStart -= 1 }
                
                    // Expand right
                    var wordEnd = start
                    while wordEnd < text.length && isWordChar(wordEnd) { wordEnd += 1 }
                
                    guard wordEnd > wordStart else { return nil }
                    return NSMakeRange(wordStart, wordEnd - wordStart)
            }
        
            private func fullDeclarationRange(in text: NSString, openBrace: Int, closeBrace: Int) -> NSRange {
                    var i = openBrace - 1
                    while i >= 0, let s = Unicode.Scalar(text.character(at: i)),
                                s == " " || s == "\t" { i -= 1 }
                    let headerLineRange = text.lineRange(for: NSMakeRange(max(0, i), 0))
                    let loc = headerLineRange.location
                    let len = closeBrace - loc + 1
                    guard len > 0, loc + len <= text.length else {
                            return NSMakeRange(openBrace, max(0, closeBrace - openBrace + 1))
                    }
                    return NSMakeRange(loc, len)
            }
        
            private func validRange(_ r: NSRange, in text: NSString) -> NSRange? {
                    guard r.location <= text.length,
                                r.length >= 0,
                                NSMaxRange(r) <= text.length else { return nil }
                    return r
            }
        
            private func rangeContains(_ outer: NSRange, _ inner: NSRange) -> Bool {
                    outer.location <= inner.location &&
                    outer.location + outer.length >= inner.location + inner.length
            }
    }

    // MARK: - CharacterStack
    
    struct CharacterStack {
            private var a = [Character]()
            var last: Character? { a.last }
            mutating func push(_ element: Character) { a.append(element) }
            @discardableResult mutating func pop() -> Character? { a.popLast() }
            mutating func clear() { a.removeAll() }
    }

    // MARK: - LineNumberView
    
    final class LineNumberView: NSView {
        
            private weak var textView: VimTextView?
            private weak var scrollView: NSScrollView?
        
            static let width: CGFloat = 44
        
            private let gutterFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            private var activeColor:    NSColor { Theme.active.gutterActiveLine }
            private var inactiveColor:  NSColor { Theme.active.gutterInactiveLine }
            private var gutterBg:       NSColor { Theme.active.gutterBackground }
            private var separatorColor: NSColor { Theme.active.gutterActiveLine.withAlphaComponent(0.07) }
        
            // Cache of newline positions — keeps draw() O(log n) instead of O(n).
            // newlinePositions[i] = character index of the i-th '\n' (0-based).
            private var newlinePositions: [Int] = []
        
            init(textView: VimTextView, scrollView: NSScrollView) {
                    self.textView = textView
                    self.scrollView = scrollView
                    super.init(frame: .zero)
                    wantsLayer = true
                    NotificationCenter.default.addObserver(
                            self, selector: #selector(textDidChange),
                            name: NSText.didChangeNotification, object: textView)
                    NotificationCenter.default.addObserver(
                            self, selector: #selector(refresh),
                            name: NSTextView.didChangeSelectionNotification, object: textView)
                    NotificationCenter.default.addObserver(
                            self, selector: #selector(refresh),
                            name: NSView.boundsDidChangeNotification, object: scrollView.contentView)
            }
        
            required init?(coder: NSCoder) { fatalError() }
            deinit { NotificationCenter.default.removeObserver(self) }
        
            override var isFlipped: Bool { true }
        
            @objc private func refresh() { needsDisplay = true }
        
            @objc private func textDidChange() {
                    rebuildNewlineCache()
                    updateWidth()
                    DispatchQueue.main.async { [weak self] in self?.needsDisplay = true }
            }
        
            /// Rebuild the full newline cache. O(n) but only called on text change,
            /// not on every draw/scroll/selection.
            private func rebuildNewlineCache() {
                    guard let tv = textView else { return }
                    let s = tv.string as NSString
                    var positions: [Int] = []
                    positions.reserveCapacity(s.length / 40)  // rough estimate: ~40 chars/line
                    var i = 0
                    while i < s.length {
                            if s.character(at: i) == 10 { positions.append(i) }
                            i += 1
                    }
                    newlinePositions = positions
            }
        
            /// 1-based line number for a character index. O(log n) via binary search.
            private func lineNumber(for charIndex: Int) -> Int {
                    // Binary search: count how many newlines are before charIndex
                    var lo = 0, hi = newlinePositions.count
                    while lo < hi {
                            let mid = (lo + hi) / 2
                            if newlinePositions[mid] < charIndex { lo = mid + 1 } else { hi = mid }
                    }
                    return lo + 1  // 1-based
            }
        
            /// Call after loading a document to rebuild the newline cache.
            func invalidateCache() {
                    rebuildNewlineCache()
                    updateWidth()
                    needsDisplay = true
            }
        
            func updateWidth() {
                    let lineCount = max(1, newlinePositions.count + 1)
                    let digits = max(3, "\(lineCount)".count)
                    let sample = String(repeating: "8", count: digits) as NSString
                    let w = sample.size(withAttributes: [.font: gutterFont]).width
                    let newWidth = ceil(w) + 24
                    if abs(frame.width - newWidth) > 0.5 {
                            frame.size.width = newWidth
                            (window?.contentViewController as? ViewController)?.layoutSubviews()
                    }
            }
        
            override func draw(_ dirtyRect: NSRect) {
                    guard let tv  = textView,
                                let lm  = tv.layoutManager,
                                let tc  = tv.textContainer,
                                let sv  = scrollView else { return }
                
                    gutterBg.setFill()
                    bounds.fill()
                    NSRect(x: bounds.width - 1, y: 0, width: 1, height: bounds.height).fill()
                
                    let content         = tv.string as NSString
                    let visibleRect     = sv.documentVisibleRect
                    let containerOrigin = tv.textContainerOrigin
                    let cursorLoc       = tv.selectedRange().location
                
                    // Cursor line index via binary search — O(log n)
                    let cursorLineIndex = lineNumber(for: min(cursorLoc, max(0, content.length - 1))) - 1
                
                    let visibleGlyphs = lm.glyphRange(forBoundingRect: visibleRect, in: tc)
                    let visibleChars  = lm.characterRange(forGlyphRange: visibleGlyphs, actualGlyphRange: nil)
                
                    let visibleEnd = content.length > 0 &&
                                                        content.character(at: content.length - 1) == 10 &&
                                                        NSMaxRange(visibleChars) >= content.length - 1
                            ? content.length + 1
                            : NSMaxRange(visibleChars)
                
                    // First visible line number via binary search — O(log n)
                    var lineNum = lineNumber(for: visibleChars.location)
                    var currentLineIndex = lineNum - 1
                
                    // Pre-compute label attributes once
                    let activeAttrs:   [NSAttributedString.Key: Any] = [.font: gutterFont, .foregroundColor: activeColor]
                    let inactiveAttrs: [NSAttributedString.Key: Any] = [.font: gutterFont, .foregroundColor: inactiveColor]
                
                    var charIdx = visibleChars.location
                    while charIdx < visibleEnd && charIdx <= content.length {
                            let lineRange = content.lineRange(for: NSMakeRange(charIdx, 0))
                            var lineRect: NSRect
                            if lineRange.length == 0 {
                                    lineRect = lm.extraLineFragmentRect
                                    if lineRect == .zero {
                                            let next = NSMaxRange(lineRange)
                                            if next == charIdx { break }
                                            charIdx = next; continue
                                    }
                            } else {
                                    let glyphs = lm.glyphRange(forCharacterRange: NSMakeRange(charIdx, lineRange.length),
                                                                                            actualCharacterRange: nil)
                                    lineRect = lm.lineFragmentRect(forGlyphAt: glyphs.location, effectiveRange: nil)
                            }
                            lineRect.origin.y += containerOrigin.y
                            let y = lineRect.origin.y - visibleRect.origin.y
                            let attrs = currentLineIndex == cursorLineIndex ? activeAttrs : inactiveAttrs
                            let label = "\(lineNum)" as NSString
                            let size  = label.size(withAttributes: attrs)
                            label.draw(at: CGPoint(x: bounds.width - size.width - 12,
                                                                            y: y + (lineRect.height - size.height) / 2),
                                                    withAttributes: attrs)
                            lineNum += 1
                            currentLineIndex += 1
                            let next = NSMaxRange(lineRange)
                            if next == charIdx { break }
                            charIdx = next
                    }
            }
    }

    // MARK: - NonAnimatingClipView
    // Subclass NSClipView to disable AppKit's built-in scroll animation,
    // which fires when arrow keys move the cursor near the edge of the viewport.
    final class NonAnimatingClipView: NSClipView {
            override func scroll(to newOrigin: NSPoint) {
                    // Call setBoundsOrigin directly — skips the animation path entirely.
                    setBoundsOrigin(newOrigin)
            }
    }

    // MARK: - ViewController
    
    class ViewController: NSViewController {
        
            private var textView: VimTextView!
            private var scrollView: NSScrollView!
            private var lineNumberView: LineNumberView!
            private var currentFileURL: URL?
        
            override func viewDidLoad() {
                    super.viewDidLoad()
                    view.wantsLayer = true
                
                    let storage = HighlightedStorage()
                    let layoutManager = NSLayoutManager()
                    storage.addLayoutManager(layoutManager)
                    let textContainer = NSTextContainer(
                            size: CGSize(width: view.bounds.width, height: .greatestFiniteMagnitude))
                    textContainer.widthTracksTextView = true
                    layoutManager.addTextContainer(textContainer)
                
                    scrollView = NSScrollView()
                    scrollView.hasVerticalScroller = true
                    scrollView.hasHorizontalScroller = false
                    scrollView.borderType = .noBorder
                    scrollView.autoresizingMask = [.width, .height]
                    scrollView.scrollerStyle = .overlay
                    // Replace the default clip view with our non-animating version
                    let clipView = NonAnimatingClipView()
                    clipView.drawsBackground = false
                    scrollView.contentView = clipView
                    scrollView.contentView.postsBoundsChangedNotifications = true
                
                    textView = VimTextView(frame: .zero, textContainer: textContainer)
                    textView.setupVimEditor()
                    textView.isVerticallyResizable = true
                    textView.autoresizingMask = [.width]
                    textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                                                        height: CGFloat.greatestFiniteMagnitude)
                    textView.minSize = NSSize(width: 0, height: 0)
                    scrollView.documentView = textView
                
                    lineNumberView = LineNumberView(textView: textView, scrollView: scrollView)
                    lineNumberView.updateWidth()
                
                    view.addSubview(lineNumberView)
                    view.addSubview(scrollView)
                
                    NotificationCenter.default.addObserver(
                            self, selector: #selector(textDidChange(_:)),
                            name: NSText.didChangeNotification, object: textView)
            }
        
            override func viewDidAppear() {
                    super.viewDidAppear()
                    view.window?.makeFirstResponder(textView)
                    view.window?.delegate = self
                    updateWindowTitle()
                    layoutSubviews()
            }
        
            override func viewDidLayout() {
                    super.viewDidLayout()
                    layoutSubviews()
            }
        
            func layoutSubviews() {
                    let gutterW = lineNumberView.frame.width == 0 ? LineNumberView.width : lineNumberView.frame.width
                    let total   = view.bounds
                    lineNumberView.frame = NSRect(x: 0, y: 0, width: gutterW, height: total.height)
                    scrollView.frame     = NSRect(x: gutterW, y: 0,
                                                                                width: total.width - gutterW, height: total.height)
            }
        
            override func performKeyEquivalent(with event: NSEvent) -> Bool {
                    guard event.modifierFlags.contains(.command) else {
                            return super.performKeyEquivalent(with: event)
                    }
                    switch event.charactersIgnoringModifiers {
                    case "s": saveDocument(); return true
                    case "o": openDocument(); return true
                    default:  return super.performKeyEquivalent(with: event)
                    }
            }
        
            private func saveDocument() {
                    if let url = currentFileURL { write(to: url) } else { saveAs() }
            }
        
            private func saveAs() {
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [.swiftSource, .plainText]
                    panel.nameFieldStringValue = "Untitled.swift"
                    panel.beginSheetModal(for: view.window!) { [weak self] response in
                            guard response == .OK, let url = panel.url else { return }
                            self?.currentFileURL = url
                            self?.write(to: url)
                    }
            }
        
            private func write(to url: URL) {
                    do {
                            try textView.string.write(to: url, atomically: true, encoding: .utf8)
                            currentFileURL = url
                            updateWindowTitle()
                            view.window?.isDocumentEdited = false
                    } catch { presentError(error) }
            }
        
            private func openDocument() {
                    if view.window?.isDocumentEdited == true {
                            let alert = NSAlert()
                            alert.messageText = "Unsaved changes"
                            alert.informativeText = "Open a new file? Unsaved changes will be lost."
                            alert.addButton(withTitle: "Open Anyway")
                            alert.addButton(withTitle: "Cancel")
                            alert.beginSheetModal(for: view.window!) { [weak self] response in
                                    if response == .alertFirstButtonReturn { self?.runOpenPanel() }
                            }
                    } else {
                            runOpenPanel()
                    }
            }
        
            private func runOpenPanel() {
                    let panel = NSOpenPanel()
                    panel.allowedContentTypes = [.swiftSource, .plainText, .sourceCode]
                    panel.allowsMultipleSelection = false
                    panel.canChooseDirectories = false
                    panel.beginSheetModal(for: view.window!) { [weak self] response in
                            guard response == .OK, let url = panel.url else { return }
                            self?.load(url: url)
                    }
            }
        
            func load(url: URL) {
                    do {
                            let content = try String(contentsOf: url, encoding: .utf8)
                            guard let storage = textView.textStorage else { return }
                            // Replace all content in one atomic operation — avoids the race between
                            // string= assignment triggering setSelectedRanges and processEditing.
                            storage.beginEditing()
                            storage.replaceCharacters(in: NSRange(location: 0, length: storage.length),
                                                                                with: content)
                            storage.endEditing()
                            textView.setSelectedRange(NSMakeRange(0, 0))
                            currentFileURL = url
                            updateWindowTitle()
                            view.window?.isDocumentEdited = false
                            lineNumberView.invalidateCache()
                    } catch { presentError(error) }
            }
        
            private func updateWindowTitle() {
                    if let url = currentFileURL {
                            view.window?.title = url.lastPathComponent
                            view.window?.representedURL = url
                    } else {
                            view.window?.title = "Untitled"
                    }
            }
        
            @objc private func textDidChange(_ notification: Notification) {
                    view.window?.isDocumentEdited = true
            }
    }

    // MARK: - NSWindowDelegate
    
    extension ViewController: NSWindowDelegate {
            func windowShouldClose(_ sender: NSWindow) -> Bool {
                    guard sender.isDocumentEdited else { return true }
                    let alert = NSAlert()
                    alert.messageText = "Save changes?"
                    alert.informativeText = "Save \"\(currentFileURL?.lastPathComponent ?? "Untitled")\" before closing?"
                    alert.addButton(withTitle: "Save")
                    alert.addButton(withTitle: "Don't Save")
                    alert.addButton(withTitle: "Cancel")
                    alert.beginSheetModal(for: sender) { [weak self] response in
                            switch response {
                            case .alertFirstButtonReturn:  self?.saveDocument(); sender.close()
                            case .alertSecondButtonReturn: sender.close()
                            default: break
                            }
                    }
                    return false
            }
    }

    // MARK: - SyntaxHighlighter
    
    final class SyntaxHighlighter {
        
            private var theme: [String: NSColor] {
                    let t = Theme.active
                    return [
                            "strong": t.keywords,
                            "em":     t.strings,
                            "sup":    t.comments,
                            "label":  t.types,
                            "num":    t.numbers,
                            "b":      t.functions,
                            "i":      t.operators,
                    ]
            }
        
            private let SWIFT_KEYWORDS = "associatedtype|async|await|break|case|catch|class|continue|convenience|default|defer|deinit|do|else|enum|extension|fallthrough|false|fileprivate|final|for|func|get|guard|if|import|in|indirect|infix|init|inout|internal|is|lazy|let|mutating|nil|none|nonisolated|operator|optional|override|postfix|precedencegroup|prefix|private|protocol|public|repeat|required|rethrows|return|self|set|some|static|struct|subscript|super|switch|throw|throws|true|try|typealias|unowned|var|weak|while|willSet|didSet"
        
            struct TagRule {
                    let tag: String
                    let re: NSRegularExpression
                    let shift: Bool
            }
        
            private let rules: [TagRule]
        
            init() {
                    let rawRules: [(String, String, Bool)] = [
                            ("sup",    "//.+",                                            false),
                            ("em",     "\"[^\"]*\"|'[^']*'",                             false),
                            ("strong", "\\b(\(SWIFT_KEYWORDS))\\b",                      false),
                            ("num",    "\\b\\d+\\.\\d+\\b|\\b\\d+\\b",                  false),
                            ("label",  "\\b[A-Z][\\w\\d]*\\b",                          false),
                            ("b",      "([\\w\\d]+)(?=\\s*\\()",                         true),
                            ("b",      "([\\w\\d]+)(?=\\s*[:=\\.])",                     true),
                            ("i",      "[\\{\\}\\(\\)\\[\\]\\.:,;\\+\\-\\*/&\\|!=<>]+", false),
                    ]
                    rules = rawRules.compactMap { tag, pattern, shift in
                            guard let re = try? NSRegularExpression(pattern: pattern) else { return nil }
                            return TagRule(tag: tag, re: re, shift: shift)
                    }
            }
        
            func computeAttributes(for fullString: String, in limitRange: NSRange) -> [(range: NSRange, color: NSColor)] {
                    var results: [(range: NSRange, color: NSColor)] = []
                    var occupiedRanges = IndexSet()
                    for rule in rules {
                            guard let color = theme[rule.tag] else { continue }
                            rule.re.enumerateMatches(in: fullString, options: [], range: limitRange) { match, _, _ in
                                    guard let match else { return }
                                    let targetRange = rule.shift && match.numberOfRanges > 1 ? match.range(at: 1) : match.range
                                    let swiftRange = targetRange.location ..< (targetRange.location + targetRange.length)
                                    guard !occupiedRanges.intersects(integersIn: swiftRange) else { return }
                                    results.append((targetRange, color))
                                    occupiedRanges.insert(integersIn: swiftRange)
                            }
                    }
                    return results
            }
    }

// mocktail:
    // Package.swift
    // swift-tools-version: 6.1
    import PackageDescription
    
    let package = Package(
        name: "MockTail",
        dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
            .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.0.0")
        ],
        targets: [
            .executableTarget(
                name: "MockTail",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                ]
            ),
            .testTarget(
                name: "MockTailTests",
                dependencies: [
                    .targetItem(name: "MockTail", condition: .none),
                    .product(name: "CustomDump", package: "swift-custom-dump")
                ]
            ),
        ]
    )

    
    // Sources/Data/Request.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    public struct Request {
        public let headers: String
        public let body: String
        
        public init(headers: String, body: String = "") {
            self.headers = headers
            self.body = body
        }
    }

    
    // Sources/Data/Response.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    public struct Response: Equatable {
        public let statusCode: Int
        public let headers: [String: String]
        public let rawBody: String?
        
        public init(statusCode: Int, headers: [String : String], rawBody: String?) {
            self.statusCode = statusCode
            self.headers = headers
            self.rawBody = rawBody
        }
    }

    
    // Sources/Helpers/Array+Extension.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    import Foundation
    
    extension Array {
        func get(at index: Int) -> Element? {
            guard indices.contains(index) else { return nil }
            return self[index]
        }
    }

    // Sources/Helpers/Pipes.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    import Foundation
    
    // Less esoteric version of my beloved `pipes` operator
    func new<T>(_ item: T, withMap map: (inout T) -> Void) -> T {
        item | map
    }

    // Returns new instance of object with the `rhs` map applied
    func |<T>(lhs: T, rhs: (inout T) -> Void) -> T {
        var copy = lhs
        rhs(&copy)
        return copy
    }

    // Maps `A` to `B`.
    // Usage: let intAsString = 3 * String.init
    func |<A, B>(lhs: A, rhs: (A) -> B) -> B {
        rhs(lhs)
    }

    func |<A, B>(lhs: A?, rhs: (A) -> B?) -> B? {
        lhs.flatMap(rhs)
    }

    func |<A, B>(lhs: A?, rhs: ((A) -> B?)?) -> B? {
        guard let rhs = rhs else {
            return nil
        }
        return lhs.flatMap(rhs)
    }

    
    // Sources/Helpers/Requests+Extension.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    import Foundation
    
    extension Request {
        func normalizedURL() -> String? {
            requestHeaders().first?
                .components(separatedBy: " ")
                .get(at: 1)?
                .trimInitialAndLastSlashes()
        }
        
        func requestHeaders() -> [String] {
            headers.components(separatedBy: "\n")
        }
        
        func urlComponents() -> [String] {
            Array(normalizedURL()?.components(separatedBy: "/") ?? [])
        }
        
        func id() -> String? {
            urlComponents().get(at: 1)
        }
        
        func payloadAsJSONItem() -> JSONItem? {
            JSONCoder.decode(body)
        }
        
        func payloadJSONHasID() -> Bool {
            payloadAsJSONItem()?.keys.contains("id") ?? false
        }
        
        func payloadIsInvalidOrEmptyJSON() -> Bool {
            !payloadIsValidNonEmptyJSON()
        }
        
        func payloadIsValidNonEmptyJSON() -> Bool {
            JSONValidator.isValidJSON(body) && !JSONValidator
                .isEmptyJSON(body)
        }
        
        func urlHasNotId() -> Bool {
            route().id == nil
        }
        
        
        func collectionName() -> String? {
            urlComponents().first
        }
        
        enum HTTPMethod: String {
            case GET
            case POST
            case DELETE
            case PUT
            case PATCH
        }
        
        func httpMethod() -> HTTPMethod? {
            guard let verb = requestHeaders().first?.components(separatedBy: " ").first else {
                return nil
            }
            return HTTPMethod(rawValue: verb)
        }
        
        func isPayloadRequired() -> Bool {
            [HTTPMethod.PUT, .PATCH, .POST].contains(httpMethod())
        }
        
        func allItems() -> Bool {
            urlComponents().count == 1
        }
        
        enum ResourceRoute {
            case collection(name: String)
            case item(id: String, collectionName: String)
            case subroute
            
            init(_ urlComponents: [String]) {
                switch urlComponents.count {
                case 1: self = .collection(name: urlComponents[0])
                case 2: self = .item(id: urlComponents[1], collectionName: urlComponents[0])
                default: self = .subroute
                }
            }
            
            var id: String? {
                if case let .item(id, _) = self {
                    return id
                }
                return nil
            }
        }
        
        func route() -> ResourceRoute {
            ResourceRoute(urlComponents())
        }
        
        func hasWrongOrMissingContentType() -> Bool {
            guard let contentType = contentType() else {
                return true
            }
            
            return contentType != "application/json"
        }
        
        func contentType() -> String? {
            for line in requestHeaders() {
                if line.lowercased().starts(with: "content-type:") {
                    return line
                        .dropFirst("content-type:".count)
                        .trimmingCharacters(in: .whitespaces)
                }
            }
            return nil
        }
    }

    
    // Sources/Helpers/Response+Extension.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    import Foundation
    
    public extension Response {
        nonisolated(unsafe) static let badRequest = Response(statusCode: 400)
        nonisolated(unsafe) static let notFound = Response(statusCode: 404)
        nonisolated(unsafe) static let empty = Response(statusCode: 204)
        nonisolated(unsafe) static let OK = Response(statusCode: 200)
        nonisolated(unsafe) static let unsopportedMethod = Response(statusCode: 405)
        nonisolated(unsafe) static let unsupportedMediaType = Response(statusCode: 415)
        
        static func created(_ rawBody: String?) -> Response {
            Response(statusCode: 201, rawBody: rawBody, contentLength: rawBody?.contentLenght())
        }
        
        static func OK(_ rawBody: String?) -> Response {
            Response(statusCode: 200, rawBody: rawBody, contentLength: rawBody?.contentLenght())
        }
    }

    public extension Response {
        init(
            statusCode: Int,
            rawBody: String? = nil,
            contentLength: Int? = nil
        ) {
            let date = Self.dateFormatter.string(from: Date())
            
            let headers = [
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, HEAD, PUT, PATCH, POST, DELETE",
                "Access-Control-Allow-Headers": "content-type",
                "Content-Type": "application/json",
                "Date": date,
                "Connection": "close",
                "Content-Length": contentLength?.description
            ].compactMapValues { $0 }
            
            self.init(statusCode: statusCode, headers: headers, rawBody: rawBody)
        }
        
        static let dateFormatter = new(DateFormatter()) { df in
            df.dateFormat = "EEE',' dd MMM yyyy HH:mm:ss zzz"
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
        }
    }

    
    // Sources/Helpers/String+Extension.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    import Foundation
    
    extension String {
        func contentLenght() -> Int {
            data(using: .utf8)?.count ?? count
        }
        
        func removingBreaklines() -> String {
            self.replacingOccurrences(of: "\n", with: "")
        }
        
        func removingSpaces() -> String {
            self.replacingOccurrences(of: " ", with: "")
        }
        
        func trimInitialAndLastSlashes() -> String {
            var copy = self
            if copy.first == "/" {
                copy.removeFirst()
            }
            if copy.last == "/" {
                copy.removeLast()
            }
            
            return copy
        }
    }

    
    // Sources/JSON/JSONCoder.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    import Foundation
    
    enum JSONCoder {
        static func encode(_ json: JSON) -> String? {
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
            return String(data: data, encoding: .utf8)
        }
        
        static func encode(_ json: JSONItem) -> String? {
            guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
            return String(data: data, encoding: .utf8)
        }
        
        static func decode<T>(_ data: String) -> T? {
            guard let data = data.data(using: .utf8) else { return nil }
            return try? JSONSerialization.jsonObject(with: data, options: []) as? T
        }
    }

    enum JSONValidator {
        static func isValidJSON(_ data: String) -> Bool {
            guard let data = data.data(using: .utf8) else { return false }
            return (try? JSONSerialization.jsonObject(with: data)) != nil
        }
        
        static func isEmptyJSON(_ data: String) -> Bool {
            data.isEmpty || data.removingAllWhiteSpaces() == "{}"
        }
    }

    fileprivate extension String {
        func removingAllWhiteSpaces() -> String {
            self.removingSpaces().removingBreaklines()
        }
    }

    
    // Sources/JSON/JSONRepresentations.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    public typealias JSON = Any
    public typealias JSONItem = [String: JSON]
    public typealias JSONArray = [JSONItem]
    
    public extension JSONArray {
        func getItem(with id: String) -> JSONItem? {
            self.first(where: { $0.getId() == id })
        }
    }

    public extension JSONItem {
        func getId() -> String? {
            self["id"] as? String
        }
        
        func merge(_ item: JSONItem) -> JSONItem {
            new(self) {
                for (key, value) in item { $0[key] = value }
            }
        }
    }

    
    // Sources/main.swift
    
    
    
    // Sources/Parser/HeadersValidator.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    import Foundation
    
    struct HeadersValidator {
        
        let request: Request
        let collections: [String: JSON]
        
        typealias Result = Int?
        
        var errorCode: Result {
            guard request.headers.contains("Host")  else {
                return Response.badRequest.statusCode
            }
            
            guard let _ = request.httpMethod() else {
                return Response.unsopportedMethod.statusCode
            }
            
            guard request.hasWrongOrMissingContentType() && request.isPayloadRequired() else {
                    return nil
            }
            
            return Response.unsupportedMediaType.statusCode
        }
    }

    
    // Sources/Parser/Parser.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    import Foundation
    
    public struct Parser {
        private let collections: [String: JSON]
        private let idGenerator: () -> String
        
        public init(collections: [String : JSON], idGenerator: @escaping () -> String) {
            self.collections = collections
            self.idGenerator = idGenerator
        }
        
        public func parse(_ request: Request) -> Response {
            let validator = HeadersValidator(
                request: request,
                collections: collections
            )
            
            let router = Router(
                request: request,
                collections: collections,
                idGenerator: idGenerator
            )
            
            switch validator.errorCode {
            case .none:
                return router.handleRequest()
            case let .some(errorCode):
                return Response(statusCode: errorCode)
            }
        }
    }

    
    // Sources/Parser/Router.swift
    // Created by Cristian Felipe Patiño Rojas on 5/5/25.
    
    
    import Foundation
    
    struct Router {
        let request: Request
        let collections: [String: JSON]
        let idGenerator: () -> String
        func handleRequest() -> Response {
            switch request.httpMethod() {
            case
                    .PUT   where request.payloadIsInvalidOrEmptyJSON(),
                    .POST  where request.payloadIsInvalidOrEmptyJSON(),
                    .PATCH where request.payloadIsInvalidOrEmptyJSON(),
                
                    .PUT   where request.payloadJSONHasID(),
                    .POST  where request.payloadJSONHasID(),
                    .PATCH where request.payloadJSONHasID(),
                
                    .DELETE where request.urlHasNotId(),
                    .PATCH  where request.urlHasNotId():
                
                return .badRequest
                
            case .GET   : return handleGET()
            case .DELETE: return handleDELETE()
            case .PUT   : return handlePUT()
            case .POST  : return handlePOST()
            case .PATCH : return handlePATCH()
            default: return Response(statusCode: 405)
            }
        }
        
        private func handleGET() -> Response {
            switch request.route() {
            case let .item(id, collection) where !itemExists(id, collection):
                return .notFound
            case let .collection(name) where !collectionExists(name):
                return .notFound
            case let .collection(name):
                return .OK(collections[name] | JSONCoder.encode)
            case let .item(id, collection) where itemExists(id, collection):
                return .OK(getItem(id, on: collection) | JSONCoder.encode)
                
            default: return .badRequest
            }
        }
        
        private func handleDELETE() -> Response {
            switch request.route() {
            case .collection, .subroute:
                return .badRequest
            case let .item(id, collection) where !itemExists(id, collection):
                return .notFound
            case .item:
                return .empty
            }
        }
        
        private func handlePUT() -> Response {
            switch request.route() {
            case let .item(id, collection) where !itemExists(id, collection):
                return .created(request.body)
            #warning("use JSONValidator instead")
            case .item where request.body.isEmpty:
                return .badRequest
            case let .item(id, collection) where request.payloadIsValidNonEmptyJSON():
                let put: JSONItem? = JSONCoder.decode(request.body)
                let existentItem = getItem(id, on: collection)
                let updated = put | existentItem?.merge
                return .OK(updated | JSONCoder.encode)
            default:
                return .badRequest
            }
        }
        
        private func handlePOST() -> Response {
            switch request.route() {
            case .item: return .badRequest
            case let .collection(name) where !collectionExists(name):
                return .notFound
            case .collection:
                let jsonItem = request.payloadAsJSONItem() | { $0?["id"] = idGenerator() }
                return .created(jsonItem | JSONCoder.encode)
            default: return .badRequest
            }
        }
        
        private func handlePATCH() -> Response {
            switch request.route() {
            case let .item(id, collection) where !itemExists(id, collection):
                return .notFound
            case let .item(id, collection):
                let patch = request.payloadAsJSONItem()!
                let item = getItem(id, on: collection)!
                
                let patched = item.merge(patch) | JSONCoder.encode
                return .OK(patched)
            default:
                return .badRequest
            }
        }
        
        private func getItem(_ id: String, on collection: String) -> JSONItem? {
            let items = collections[collection] as? JSONArray
            let item = items?.getItem(with: id)
            return item
        }
        
        private func collectionExists(_ collectionName: String) -> Bool {
            collections.keys.contains(collectionName)
        }
        
        private func containsItemId(_ body: String) -> Bool {
            guard let item: JSONItem = JSONCoder.decode(body) else { return false }
            return item.keys.contains("id") 
        }
        
        private func itemExists(_ id: String, _ collectionName: String) -> Bool {
            (collections[collectionName] as? JSONArray)?.getItem(with: id) != nil
        }
        
        private func jsonArray(_ collection: String) -> JSONArray? {
            collections[collection] as? JSONArray
        }
    }

    
    // Tests/Parser/ParserCommonTests.swift
    //  Created by Cristian Felipe Patiño Rojas on 2/5/25.
    
    import XCTest
    import CustomDump
    import MockTail
    
    
    final class ParserTests: XCTestCase {
        func test_parser_delivers405OnUnsupportedMethod() {
            let sut = makeSUT()
            let request = Request(headers: "Unsupported /recipes HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            expectNoDifference(response, .unsopportedMethod)
        }
    }

    // MARK: - Common
    extension ParserTests {
        func test_parser_delivers400ResponseOnEmptyHeaders() {
            let sut = makeSUT()
            let request = Request(headers: "")
            let response = sut.parse(request)
            expectNoDifference(response, .badRequest)
        }
        
        func test_parser_delivers400OnMalformedHeaders() {
            let sut = makeSUT()
            let request = Request(headers: "GETHTTP/1.1")
            let response = sut.parse(request)
            expectNoDifference(response, .badRequest)
        }
        
        func test_parser_delivers400OnMissingHostHeader() {
            let sut = makeSUT()
            let request = Request(headers: "GET /recipes HTTP/1.1")
            let response = sut.parse(request)
            expectNoDifference(response, .badRequest)
        }
        
        func test_parser_delivers404OnNonExistentCollection() {
            let sut = makeSUT()
            let request = Request(headers: "GET /recipes HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            expectNoDifference(response, .notFound)
        }
        
        func test_parser_delivers404OnDELETEMalformedId() {
            let sut = makeSUT(collections: ["recipes": []])
            let request = Request(headers: "DELETE /recipes/abc HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            expectNoDifference(response, .notFound)
        }
        
        func test_parser_delivers404OnNonExistentResource() {
            let sut = makeSUT(collections: ["recipes": []])
            let request = Request(headers: "GET /recipes/2 HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            expectNoDifference(response, .notFound)
        }
        
        func test_parser_delivers400OnUnknownSubroute() {
            let sut = makeSUT(collections: ["recipes": [1]])
            let request = Request(headers: "GET /recipes/1/helloworld HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            expectNoDifference(response, .badRequest)
        }
        
        func test_parse_delivers415OnPayloadRequiredRequestsMissingContentTypeHeader() {
            let sut = makeSUT(collections: ["recipes": []])
            
            ["POST", "PATCH", "PUT"].forEach { verb in
                let request = Request(headers: "\(verb) /recipes HTTP/1.1\nHost: localhost")
                let response = sut.parse(request)
                
                expectNoDifference(response, .unsupportedMediaType, "Failed on \(verb)")
            }
        }
        
        func test_parse_delivers415OnPayloadRequiredRequestsUnsupportedMediaType() {
            let sut = makeSUT(collections: ["recipes": []])
            
            ["POST", "PATCH", "PUT"].forEach { verb in
                let request = Request(headers: "\(verb) /recipes\nContent-Type: \(anyNonJSONMediaType()) HTTP/1.1\nHost: localhost")
                let response = sut.parse(request)
                
                expectNoDifference(response, .unsupportedMediaType, "Failed on \(verb)")
            }
        }
        
        func test_parse_delivers400OnPayloadAndIDRequiredRequestsWithInvalidJSONBody() {
            let sut = makeSUT(collections: ["recipes": [["id": "1"]]])
            
            ["PATCH", "PUT"].forEach { verb in
                let request = Request(
                    headers: "\(verb) /recipes/1\nContent-Type: application/json\nHost: localhost",
                    body: "invalid json"
                )
                let response = sut.parse(request)
                
                expectNoDifference(response, .badRequest, "Failed on \(verb)")
            }
        }
        
        func test_parse_delivers400OnPayloadRequiredRequestsWithEmptyJSON() {
            expect(.badRequest, on: "{}", for: "PATCH")
            expect(.badRequest, on: "{ }", for: "PATCH")
            expect(.badRequest, on: "{\n}", for: "PATCH")
            expect(.badRequest, on: nil, for: "PATCH")
            expect(.badRequest, on: "{}", for: "PUT")
            expect(.badRequest, on: "{ }", for: "PUT")
            expect(.badRequest, on: "{\n}", for: "PUT")
            expect(.badRequest, on: nil, for: "PUT")
        }
        
        func test_parse_delivers400OnPayloadAndIDRequiredRequestsWithJSONBodyWithDifferentItemId() {
            let item1: JSONItem = ["id": "1", "title": "KFC Chicken"]
            let item2: JSONItem = ["id": "2", "title": "Sushi rolls"]
            let sut = makeSUT(collections: ["recipes": [item1, item2]])
            
            ["PATCH", "POST"].forEach { verb in
                let request = Request(
                    headers: "\(verb) /recipes/1 HTTP/1.1\nHost: localhost\nContent-type: application/json",
                    body: #"{"id":"2","title":"Fried chicken"}"#
                )
                
                let response = sut.parse(request)
                expectNoDifference(response, .badRequest)
            }
        }
        
        func test_parse_delivers400OnIdRequiredRequestWithNoIdOnRequestURL() {
            let sut = makeSUT(collections: ["recipes": [:]])
            ["DELETE", "PATCH", "PUT"].forEach { verb in
                let request = Request(headers: "\(verb) /recipes HTTP/1.1\nHost: localhost\nContent-Type: application/json", body: "any payload")
                let response = sut.parse(request)
                expectNoDifference(response, .badRequest, "Expect failed for \(verb)")
            }
        }
        
        func test_parse_delivers400OnIDRequiredRequestsWhenIDPresentWithinPayloadBody()  {
            let sut = makeSUT(collections: ["recipes": ["id":"1"]])
            ["PATCH", "PUT"].forEach { verb in
                let request = Request(
                    headers: "\(verb) /recipes HTTP/1.1\nHost: localhost\nContent-Type: application/json",
                    body: #"{"id": "2"}"#
                )
                let response = sut.parse(request)
                expectNoDifference(response, .badRequest, "Expect failed for \(verb)")
            }
        }
    }

    extension Response {
        func body() -> NSDictionary? {
            guard
                let rawBody,
                let responseJSON = try? JSONSerialization.jsonObject(with: Data(rawBody.utf8)),
                let responseDict = responseJSON as? NSDictionary
            else {
                return nil
            }
            return responseDict
        }
    }

    
    // Tests/Parser/ParserDELETETests.swift
    // Created by Cristian Felipe Patiño Rojas on 6/5/25.
    
    import MockTail
    import CustomDump
    import XCTest
    
    // MARK: - DELETE
    extension ParserTests {
        func test_DELETE_delivers404OnDeleteRequestToAnUnexistentItem() {
            let sut = makeSUT()
            let request = Request(headers: "DELETE /recipes/1 HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            
            expectNoDifference(response, .notFound)
        }
        
        func test_DELETE_delivers204OnSuccessfulItemDeletion() {
            let item = ["id": "1"]
            let sut = makeSUT(collections: ["recipes": [item]])
            let request = Request(headers: "DELETE /recipes/1 HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            
            expectNoDifference(response, .empty)
        }
    }

    
    // Tests/Parser/ParserGETTests.swift
    // Created by Cristian Felipe Patiño Rojas on 6/5/25.
    import MockTail
    import CustomDump
    
    // MARK: - GET
    extension ParserTests {
        
        func test_GET_delivers200OnRequestOfExistingCollectionWithTrailingSlash() {
            let sut = makeSUT(collections: ["recipes": []])
            let request = Request(headers: "GET /recipes/ HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            expectNoDifference(response.statusCode, 200)
        }
        
        func test_GET_delivers200OnRequestOfExistingEmptyCollection() {
            let sut = makeSUT(collections: ["recipes": []])
            let request = Request(headers: "GET /recipes HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            expectNoDifference(response, .OK("[]"))
        }
        
        func test_GET_delivers200OnRequestOfExistingNonEmptyCollection() {
            let item1 = ["id": 1]
            let item2 = ["id": 2]
            let sut = makeSUT(collections: ["recipes": [item1, item2]])
            let request = Request(headers: "GET /recipes HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            
            expectNoDifference(response, .OK(#"[{"id":1},{"id":2}]"#))
        }
        
        func test_GET_delivers200OnRequestOfExistingItem() {
            let item = ["id": "1"]
            let sut = makeSUT(collections: ["recipes": [item]])
            let request = Request(headers: "GET /recipes/1 HTTP/1.1\nHost: localhost")
            let response = sut.parse(request)
            expectNoDifference(response, .OK(#"{"id":"1"}"#))
        }
    }

    
    // Tests/Parser/ParserPATCHTests.swift
    // Created by Cristian Felipe Patiño Rojas on 6/5/25.
    
    import MockTail
    import CustomDump
    import XCTest
    
    // MARK: - Patch
    extension ParserTests {
        
        func test_PATCH_delivers404OnNonExistentResource() {
            let sut = makeSUT(collections: ["recipes": []])
            let request = Request(
                headers: "PATCH /recipes/1 HTTP/1.1\nHost: localhost\nContent-Type: application/json",
                body: #"{"title":"new-title"}"#
            )
            let response = sut.parse(request)
            expectNoDifference(response, .notFound)
        }
        
        func test_PATCH_delivers400OnValidJSONBodyAndMatchingURLId() {
            let item = ["id": "1"]
            let sut = makeSUT(collections: ["recipes": [item]])
            let request = Request(
                headers: "PATCH /recipes/1 HTTP/1.1\nHost: localhost\nContent-type: application/json",
                body: #"{"id":"1","title":"New title"}"#
            )
            
            let response = sut.parse(request)
            expectNoDifference(response, .badRequest)
        }
        
        
        func test_PATCH_delivers200OnValidJSONBody() throws {
            let original: JSONItem = ["id": "1", "title": "Old title"]
            let sut = makeSUT(collections: ["recipes": [original]])
            let request = Request(
                headers: "PATCH /recipes/1 HTTP/1.1\nHost: localhost\nContent-Type: application/json",
                body: #"{"title":"New title"}"#
            )
            let response = sut.parse(request)
            let expected = Response.OK(#"{"title":"New title","id":"1"}"#)
            
            expectNoDifference(
                try XCTUnwrap(response.body()),
                try XCTUnwrap(expected.body())
            )
        }
    }

    
    // MARK: - Helpers
    extension ParserTests {
        func makeSUT(collections: [String: JSON] = [:], idGenerator: @escaping () -> String = defaultGenrator, ) -> Parser {
            Parser(collections: collections, idGenerator: idGenerator)
        }
        
        static func defaultGenrator() -> String {
            UUID().uuidString
        }
        
        func anyNonJSONMediaType() -> String {
            "application/freestyle"
        }
        
        func nsDictionary(from jsonString: String) -> NSDictionary? {
            guard
                let responseJSON = try? JSONSerialization.jsonObject(with: Data(jsonString.utf8)),
                let responseDict = responseJSON as? NSDictionary
            else {
                return nil
            }
            return responseDict
        }
        
        func expect(
            _ expectedResponse: Response,
            on emptyJSONRepresentation: String?,
            for verb: String,
            file: StaticString = #file,
            line: UInt = #line
        ) {
            let item = ["id": "1"]
            let sut = makeSUT(collections: ["recipes": [item]])
            
            let request = Request(
                headers: "\(verb) /recipes/1 HTTP/1.1\nHost: localhost\nContent-type: application/json",
                body: ""
            )
            
            let response = sut.parse(request)
            expectNoDifference(response, expectedResponse, "Failed on representation \(emptyJSONRepresentation ?? "null") for verb \(verb)")
        }
    }

    
    // Tests/Parser/ParserPOSTTests.swift
    // Created by Cristian Felipe Patiño Rojas on 6/5/25.
    
    import MockTail
    import CustomDump
    import XCTest
    
    // MARK: - POST
    extension ParserTests {
        
        func test_POST_delivers400OnInvalidJSONBody() {
            let sut = makeSUT(collections: ["recipes": [["id": 1]]])
            
            let request = Request(
                headers: "POST /recipes\nContent-Type: application/json\nHost: localhost",
                body: "invalid json"
            )
            let response = sut.parse(request)
            expectNoDifference(response, .badRequest)
        }
        
        func test_POST_delivers400OnJsonBodyWithItemId() {
            let sut = makeSUT(collections: ["recipes": []])
            let request = Request(
                headers: "POST /recipes HTTP/1.1\nHost: localhost\nContent-type: application/json",
                body: #"{"id": 1,"title":"Fried chicken"}"#
            )
            
            let response = sut.parse(request)
            expectNoDifference(response, .badRequest)
        }
        
        func test_POST_delivers201OnValidJSONBody() throws {
            let newId = UUID().uuidString
            let sut = makeSUT(collections: ["recipes": []], idGenerator: {newId})
            let request = Request(
                headers: "POST /recipes HTTP/1.1\nHost: localhost\nContent-type: application/json",
                body: #"{"title":"Fried chicken"}"#
            )
            let response = sut.parse(request)
            let expectedResponse = Response.created("{\"id\":\"\(newId)\",\"title\":\"Fried chicken\"}")
            
            expectNoDifference(response.statusCode, expectedResponse.statusCode)
            expectNoDifference(response.headers, expectedResponse.headers)
            
            let responseBody = try XCTUnwrap(response.rawBody)
            let expectedBody = try XCTUnwrap(expectedResponse.rawBody)
            
            expectNoDifference(
                try XCTUnwrap(nsDictionary(from: responseBody)),
                try XCTUnwrap(nsDictionary(from: expectedBody))
            )
        }
    }

        
    
    // Tests/Parser/ParserPUTTests.swift
    // Created by Cristian Felipe Patiño Rojas on 6/5/25.
    
    import MockTail
    import XCTest
    import CustomDump
    
    // MARK: - PUT
    extension ParserTests {
        
        func test_PUT_delivers201OnRequestOfNonExistingResource() {
            let sut = makeSUT(collections: ["recipes": []])
            let request = Request(
                headers: "PUT /recipes/1 HTTP/1.1\nHost: localhost\nContent-type: application/json",
                body: #"{"title":"French fries"}"#
            )
            
            let response = sut.parse(request)
            expectNoDifference(response, .created(#"{"title":"French fries"}"#))
        }
        
        func test_PUT_delivers200OnRequestWithValidJSONBody() {
            let item = ["id": "1"]
            let sut = makeSUT(collections: ["recipes": [item]])
            let request = Request(
                headers: "PUT /recipes/1 HTTP/1.1\nHost: localhost\nContent-type: application/json",
                body: #"{"title":"New title"}"#
            )
            
            let response = sut.parse(request)
            let expected = Response.OK(#"{"id":"1","title":"New title"}"#)
            expectNoDifference(
                response.body(),
                expected.body()
            )
        }
    }

    
// swiftdown:
    // example/sources/main.swift
    // Hello world
    //
    //
    func helloWorld() {
        print("Hello world!")
    }

    helloWorld()
    
    
    // Package.swift
    // swift-tools-version: 6.1
    // The swift-tools-version declares the minimum version of Swift required to build this package.
    
    import PackageDescription
    
    let package = Package(
        name: "swiftdown",
        platforms: [.macOS(.v13)],
        dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
            .package(url: "https://github.com/JohnSundell/Splash", from: "0.1.0"),
            .package(url: "https://github.com/crisfeim/package-mini-swift-server", branch: "main")
        ],
        targets: [
            .target(name: "Core", dependencies: ["Splash"]),
            .executableTarget(
                name: "swiftdown",
                dependencies: [
                    "Core",
                    .product(name: "MiniSwiftServer", package: "package-mini-swift-server"),
                    .product(name: "ArgumentParser", package: "swift-argument-parser")
                ]
            ),
            .testTarget(
                name: "CoreTests",
                dependencies: ["Core", "swiftdown", .product(name: "MiniSwiftServer", package: "package-mini-swift-server")],
                resources: [.copy("input")]
            )
        ]
    )


    // Sources/Core/App/Swiftdown.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    
    public struct Swiftdown: FileHandler {
        
        let runner         : Runner
        
        let syntaxParser   : Parser
        let logsParser     : Parser
        let markdownParser : Parser
        
        let sourcesURL     : URL
        let outputURL      : URL
        let themeURL       : URL
        let langExtension  : String
        
        let author         : Author
        
        public init(
            runner: Runner,
            syntaxParser: Parser,
            logsParser: Parser,
            markdownParser: Parser,
            sourcesURL: URL,
            outputURL: URL,
            themeURL: URL,
            langExtension: String,
            author: Author
        ) {
            self.runner = runner
            self.syntaxParser = syntaxParser
            self.logsParser = logsParser
            self.markdownParser = markdownParser
            self.sourcesURL = sourcesURL
            self.outputURL = outputURL
            self.themeURL = themeURL
            self.langExtension = langExtension
            self.author = author
        }
        
        public func build() throws {
            try FileManager.default.createDirectory(
                at: outputURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            try writeTemplateAssets()
            
            try getFileURLs().forEach {
                let rendered = try parse($0)
                let outputURL = outputURL.appendingPathComponent($0.lastPathComponent + ".html")
                try write(rendered, to: outputURL)
            }
        }
        
        func getFileURLs() throws -> [URL] {
            try getFileURLs(in: sourcesURL).filter { $0.lastPathComponent.contains(".\(langExtension)") }
        }
        
        // @nicetohave:
        // If I had a more sophisticated templating engine,
        // this wouldn't be render here...
        func renderFiles() throws -> String {
            let elements = try getFileURLs().reduce("") { current, next in
                let path = next.lastPathComponent
                return current + """
        <li>
        <a	href="#"
        onclick="loadContent('/\(path)', 'main'); return false;">
        \(path)
        </a>
        """
            }
            return "<ul>\(elements)</ul>"
        }
        
        public func parse(_ url: URL) throws -> String {
            let filename = url.lastPathComponent
            let contents = try String(contentsOf: url, encoding: .utf8)
            
            let logs = logsParser.parse(try runner.run(contents, with: filename, extension: nil))
            
            var parse: (String) -> String { syntaxParser.parse >>> markdownParser.parse }
            
            let data = [
                "$title": filename,
                "$content": parse(contents),
                "$author-name": author.name,
                "$author-website": author.website,
                "$logs": logs,
                "$files": try renderFiles()
            ]
            
            return try TemplateEngine(folder: themeURL, data: data).render()
        }
        
        func writeTemplateAssets() throws {
            try copyFiles(from: themeURL, to: outputURL, excluding: ["index.html"])
        }
    }

    infix operator >>> : AdditionPrecedence
    func >>><A>(first: @escaping (A) -> A, second: @escaping (A) -> A) -> (A) -> A {
        return { input in second(first(input)) }
    }

    extension Swiftdown {
        public struct Author {
            let name: String
            let website: String
            
            public init(name: String, website: String) {
                self.name = name
                self.website = website
            }
        }
    }

    extension SwiftSyntaxHighlighter: Parser {}
    extension MarkdownParser		 : Parser {}
    extension LogsParser			 : Parser {}
    extension CodeRunner			 : Runner {}
    
    
    // Sources/Core/App/TemplateEngine.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    
    public struct TemplateEngine {
        let folder: URL
        let data: [String: String]
        
        var index: URL {
            folder.appendingPathComponent("index.html")
        }
        
        public init(folder: URL, data: [String : String]) {
            self.folder = folder
            self.data = data
        }
        
        public func render() throws -> String {
            data.reduce(try String(contentsOf: index, encoding: .utf8)) { content, data in
                content.replacingOccurrences(of: data.key, with: data.value)
            }
        }
    }


    // Sources/Core/Domain/Parser.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    
    public protocol Parser {
        func parse(_ string: String) -> String
    }


    // Sources/Core/Domain/Runner.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    
    public protocol Runner {
        func run(_ code: String, with tmpFilename: String, extension ext: String?) throws -> String
    }


    // Sources/Core/Infra/Coderunner.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    
    public struct CodeRunner {
        let executablePath: String
        
        func run(_ code: String) throws -> String {
            try run(code, with: "temp", extension: nil)
        }
        
        public func run(_ code: String, with tmpFilename: String, extension ext: String?) throws -> String {
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(
                "\(tmpFilename).\(ext ?? "no-extension")")
            try write(code, to: tempFileURL)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = [tempFileURL.path]
            
            let outputPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = outputPipe
            
            try process.run()
            process.waitUntilExit()
            
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            guard let log = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "Unable to read output", code: 0)
            }
            return log
        }
        
        func write(_ string: String, to url: URL) throws {
            let folderURL = url.deletingLastPathComponent()
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: folderURL.path) {
                try fileManager.createDirectory(
                    at: folderURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            try string.write(to: url, atomically: true, encoding: .utf8)
        }
        
        nonisolated(unsafe) public static let swift = CodeRunner(executablePath: "/usr/bin/swift")
    }


    // Sources/Core/Infra/Parsing/LogsParser.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    import RegexBuilder
    
    public struct LogsParser {
        
        public init() {}
        public func parse(_ string: String) -> String {
            replaceLineNumberWithButton(in: string)
        }
        
        func replaceLineNumberWithButton(in text: String) -> String {
            let regex = Regex {
                Capture {
                    OneOrMore(.digit)
                }
                OneOrMore(.whitespace) 
                Capture {
                    ChoiceOf { 
                        "✅"
                        "❌"
                    }
                }
                OneOrMore(.whitespace) 
            }
            
            let result = text.replacing(regex) { match in
                let lineNumber = match.1
                let symbol = match.2
                return "<button onclick=\"gotomatchingline(\(lineNumber))\">\(lineNumber)</button> \(symbol) "
            }
            return result
        }
    }

    func test_logparser() {
        let sut = LogsParser()
        let output = sut.parse("207 ✅ test_login_success()")
        let expectedOutput = #"<button onclick="gotomatchingline(207)">207</button> ✅ test_login_success()"#
        print(output)
        assert(output == expectedOutput)
    }


    // Sources/Core/Infra/Parsing/MarkdownParser.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    
    public struct MarkdownParser {
        public init() {}
        public func parse(_ string: String) -> String {
            string.replacingOccurrences(of: #"^### (.*)$"#, with: "<h3>$1</h3>", options: .regularExpression)
            .replacingOccurrences(of: #"^## (.*)$"#, with: "<h2>$1</h2>", options: .regularExpression)
            .replacingOccurrences(of: #"^# (.*)$"#, with: "<h1>$1</h1>", options: .regularExpression)
            .replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "<strong>$1</strong>", options: .regularExpression)
            .replacingOccurrences(of: "\\*(.*?)\\*", with: "<em>$1</em>", options: .regularExpression)
            .replacingOccurrences(of: "__(.*?)__", with: "<u>$1</u>", options: .regularExpression)
            .replacingOccurrences(of: "~~(.*?)~~", with: "<del>$1</del>", options: .regularExpression)
            .replacingOccurrences(of: "!\\[(.*?)\\]\\((.*?)\\)", with: "<img src=\"$2\" alt=\"$1\" />", options: .regularExpression)
            .replacingOccurrences(of: "`(.*?)`", with: "<code>$1</code>")
        }
    }


    // Sources/Core/Infra/Parsing/SwiftSyntaxHighlighter.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    import Splash
    
    public struct SwiftSyntaxHighlighter {
        
        private let splash = SyntaxHighlighter(format: HTMLOutputFormat())
        private let lineInjector = LineInjector()
        private let defintionHighlighter = DefinitionsHighlighter()
        private let customTypeParser = CustomTypeHighlighter()
        
        
        public init() {}
        func run(_ string: String) -> String {
            let customTypes = customTypeParser.extractCustomTypes(from: string)
            let paserCustomTypes = { customTypeParser.run($0, from: customTypes) }
            return (
                splash.highlight >>>
                lineInjector.run >>>
                defintionHighlighter.run >>>
                parseKeywords >>>
                paserCustomTypes >>>
                parseComments >>>
                parseOperators
            )(string)
        }
        
        public func parse(_ string: String) -> String { run(string) }
        
        fileprivate func parseKeywords(on string: String) -> String {
            
            string.replacingOccurrences(
                of: #"<span class="call">throws</span>"#, 
                with: #"<span class="keyword">throws</span>"#
            )
            .replacingOccurrences(
                of: #"<span class="keyword">extension</span>"#,
                with: #"<span class="keyword-extension">extension</span>"#
            )
        }
        
        private func parseOperators(on string: String) -> String {
            string.replacingOccurrences(of: "infix operator", with: #"<span class="keyword">infix operator</span>"#)
            .replacingOccurrences(of: "prefix operator", with: #"<span class="keyword">prefix operator</span>"#)
            .replacingOccurrences(of: "postfix operator", with: #"<span class="keyword">postfix operator</span>"#)
        }
        
        private func parseComments(on string: String) -> String {
            string
            .replacingOccurrences(of: "/// ", with: "")
            .replacingOccurrences(of: "// ", with: "")
            .replacingOccurrences(of: "///", with: "")
            .replacingOccurrences(of: "//", with: "")
            .replacingOccurrences(of: "/*", with: "")
            .replacingOccurrences(of: "*/", with: "")
        }
    }


    fileprivate final class SwiftSyntaxHighlighterTests {
        func run() {
            test_keyword()
        }
        
        
        func test_keyword() {
            let sut = SwiftSyntaxHighlighter()
            let sourceCode = """
            <span class="call">throws</span>
            <span class="keyword">extension</span>
            """
            let result = sut.parseKeywords(on: sourceCode)
            let expectedResult = """
            <span class="keyword">throws</span>
            <span class="keyword-extension">extension</span>
            """
            
            assert(result == expectedResult)
        }
    }


    
    infix operator >>> : AdditionPrecedence
    fileprivate func >>>(first: @escaping (String) -> String, second: @escaping (String) -> String) -> (String) -> String {
        return { input in second(first(input)) }
    }

    // MARK: - Definitions
    extension SwiftSyntaxHighlighter {
        public struct DefinitionsHighlighter {
            public enum Definition: String, CaseIterable {
                case `class`
                case `enum` 
                case `struct`
                case `protocol`
                case `typealias`
                case `func`
                case `let`
                case `var`
                case `case`
                
                var cssClassName: String {
                    switch self {
                        case .func, .let, .var, .case: return "other-definition"
                        default: return "type-definition"
                    }
                }
            }
            
            public init() {}
            public func run(_ string: String) -> String {
                highlightDefinition(on: Definition.allCases.reduce(string) { current, keyword in
                    highlightDefinition(on: current, keyword)
                }, definition: "final class", cssClassName: "type-definition")
            }
            
            public func highlightDefinition(on string: String,_ definition: Definition) -> String {
                highlightDefinition(on: string, definition: definition.rawValue, cssClassName: definition.cssClassName)
            } 
            
            func highlightDefinition(on string: String, definition: String, cssClassName: String) -> String {
                let pattern = "(<span class=\"keyword\">\(definition)</span>)\\s+([A-Za-z][A-Za-z0-9_]*)"
                
                let template = "$1 <span class=\"\(cssClassName)\">$2</span>"
                
                do {
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    let range = NSRange(string.startIndex..<string.endIndex, in: string)
                    
                    let modifiedString = regex.stringByReplacingMatches(
                        in: string,
                        options: [],
                        range: range,
                        withTemplate: template
                    )
                    
                    return modifiedString
                } catch {
                    print("Error en la regex: \(error)")
                    return string
                }
            }
        }
    }


    
    // MARK: - LineInjector
    extension SwiftSyntaxHighlighter {
        public struct LineInjector {
            
            public init() {}
            // Injects lines as html `<span>`
            public func run(_ string: String) -> String {
                string.components(separatedBy: "\n").enumerated().reduce("") { (result, line) in
                    let (index, content) = line
                    return result + makeLine(index, content)
                }
            }
            
            private func makeLine(_ index: Int, _ content: String) -> String {
                "<span id=\"line-\(index + 1)\" class=\"line-number \(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "empty-line" : "")\">\(index + 1)</span>" + content + "\n"
            }
        }
    }

    // MARK: - CustopType 
    extension SwiftSyntaxHighlighter {
        
        fileprivate struct CustomTypeHighlighter {
            
            func run(_ string: String, from types: Set<String>) -> String {
    //			let types = extractCustomTypes(from: string)
                var result = string
                
                let pattern = #"<span class="type">([^<]+)</span>"#
                
                guard let regex = try? NSRegularExpression(pattern: pattern) else {
                    return string
                }
                
                let matches = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))
                
                for match in matches.reversed() {
                    guard let typeRange = Range(match.range(at: 1), in: string) else { continue }
                    let foundType = String(string[typeRange])
                    
                    if types.contains(foundType) {
                        if let matchRange = Range(match.range, in: string) {
                            let replacement = "<span class=\"custom-type\">\(foundType)</span>"
                            result = result.replacingCharacters(in: matchRange, with: replacement)
                        }
                    }
                }
                return result
            }
            
            /// Gets custom types (created by the developper) on a given swift sourceCode
            func extractCustomTypes(from sourceCode: String) -> Set<String> {
                let typeDeclarationPatterns = [
                            #"(?:class|struct|enum|protocol|typealias)\s+(\w+)"#
                        ]
                
                var customTypes = Set<String>()
                for pattern in typeDeclarationPatterns {
                    guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
                    let matches = regex.matches(
                        in: sourceCode,
                        range: NSRange(sourceCode.startIndex..., in: sourceCode)
                    )
                    for match in matches {
                        if let range = Range(match.range(at: 1), in: sourceCode) {
                            let typeName = String(sourceCode[range])
                            customTypes.insert(typeName)
                        }
                    }
                }
                return customTypes
            }
        }
    }


    // Sources/Core/Utilities/Filehandler.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    
    public struct TextFile {
        let name: String
        let content: String
    }

    protocol FileHandler: FileReader, FileWriter {}
    
    public protocol FileReader {}
    public extension FileReader {
        var fm: FileManager {.default}
        
        func getFileURLs(in folderURL: URL) throws -> [URL] {
            return try fm.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        }
        
        func readFile(at url: URL) throws -> String {
            try String(contentsOf: url, encoding: .utf8)
        }
        
        static func readFile(at url: URL) throws -> String {
            try String(contentsOf: url, encoding: .utf8)
        }
        
        func isFile(at url: URL) throws -> Bool {
            var isDirectory: ObjCBool = false
            fm.fileExists(atPath: url.path, isDirectory: &isDirectory) 
            return !isDirectory.boolValue
        }
        
        func isNotDStore(at url: URL) -> Bool {!url.lastPathComponent.contains(".DS_Store")}
        
        func readContentsOfAllFiles(in folderURL: URL) throws -> [TextFile] {
            return try getFileURLs(in: folderURL)
            .filter(isFile)
            .filter(isNotDStore)
            .map {
                TextFile(
                    name: $0.lastPathComponent, 
                    content: try readFile(at: $0) 
                )
            }
        }
        
        func copyFiles(from sourceURL: URL, to destinationURL: URL, excluding excludedFileNames: [String]) throws {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true)
            }
            
            let fileURLs = try fileManager.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                if excludedFileNames.contains(fileURL.lastPathComponent) { continue }
                let destinationFileURL = destinationURL.appendingPathComponent(fileURL.lastPathComponent)
                
                if fileManager.fileExists(atPath: destinationFileURL.path) {
                    try fileManager.removeItem(at: destinationFileURL)
                }
                
                try fileManager.copyItem(at: fileURL, to: destinationFileURL)
            }
        }
    }


    protocol FileWriter  {}
    extension FileWriter {
        func write(_ string: String, to url: URL) throws {
            let folderURL = url.deletingLastPathComponent()
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: folderURL.path) {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            try string.write(to: url, atomically: true, encoding: .utf8)
        }
    }


    
    
    // Sources/swiftdown/App.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    import ArgumentParser
    import Core
    
    @main
    struct SwiftDownCLI: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "swiftdown",
            abstract: "Static-site generator for Swift snippets.",
            subcommands: [Build.self, Serve.self]
        )
    }

    extension SwiftDownCLI {
        struct Build: ParsableCommand {
            @Argument(help: "Project folder's path")
                    var folder: String = "."
            
            func run() throws {
                let (ssg, _) = try Composer.compose(with: folder)
                try ssg.build()
            }
        }
        
        struct Serve: ParsableCommand {
            @Argument(help: "Project folder's path")
                    var folder: String = "."
            func run() throws {
                let (_, server) = try Composer.compose(with: folder)
                server.run()
            }
        }
    }


    
    
    // Sources/swiftdown/Composer.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    import ArgumentParser
    import Core
    import MiniSwiftServer
    
    enum Composer {
        static func compose(with pathURL: String) throws -> (Swiftdown, Server) {
            let folderURL   = URL(fileURLWithPath: pathURL).standardizedFileURL
            let sourcesURL  = folderURL.appendingPathComponent("sources")
            let themeURL    = folderURL.appendingPathComponent("theme")
            let outputURL   = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                                .appendingPathComponent("build")
            
            guard FileManager.default.fileExists(atPath: sourcesURL.path) else {
                throw ValidationError("Sources folder not found at: \(sourcesURL.path)")
            }
            guard FileManager.default.fileExists(atPath: themeURL.path) else {
                throw ValidationError("Sources folder not found at: \(themeURL.path)")
            }
            
            return make(sourcesURL: sourcesURL, themeURL: themeURL, outputURL: outputURL)
        }
        
        private static func make(
            sourcesURL: URL,
            themeURL: URL,
            outputURL: URL
        ) -> (Swiftdown, Server) {
            
            let ssg = Swiftdown(
                runner: CodeRunner.swift,
                syntaxParser: SwiftSyntaxHighlighter(),
                logsParser: LogsParser(),
                markdownParser: MarkdownParser(),
                sourcesURL: sourcesURL,
                outputURL: outputURL,
                themeURL: themeURL,
                langExtension: "swift",
                author: .init(name: "Cristian Felipe Patiño Rojas", website: "https://crisfe.me")
            )
            
            let requestHandler = RequestHandler(
                parser: ssg.parse,
                themeURL: themeURL,
                sourcesURL: sourcesURL,
                sourceExtension: "swift"
            )
            
            let server = Server(
                port: 4000,
                requestHandler: requestHandler.process
            )
            
            return (ssg, server)
        }
    }


    // Sources/swiftdown/RequestHandler.swift
    // Copyright © 2025 Cristian Felipe Patiño Rojas
    // Released under the MIT License
    
    import Foundation
    import MiniSwiftServer
    import Core
    
    public struct RequestHandler {
        let parser    : (URL) throws -> String
        let themeURL  : URL
        let sourcesURL: URL
        let sourceExtension: String
        
        public init(
            parser: @escaping (URL) throws -> String,
            themeURL: URL,
            sourcesURL: URL,
            sourceExtension: String
        ) {
            self.parser = parser
            self.themeURL = themeURL
            self.sourcesURL = sourcesURL
            self.sourceExtension = sourceExtension
        }
        
        public func process(_ request: Request) -> Response {
            if request.path == "/" || request.path.isEmpty {
                return handleIndex()
            }
            // if request has parameters, it's a resource
            guard !request.path.contains("?") else {
                return handleResourceFileWithParameters(request)
            }
            
            guard let ext = request.path.components(separatedBy: ".").last else {
                return Response(
                    statusCode: 400,
                    contentType: "text/html",
                    body: .text("Paths need to have an extension")
                )
            }
            
            if ext == sourceExtension {
                return handleSourceFile(request.path)
            } else if ext == "html" {
                return handleSourceFileWithHTMLExtension(request.path)
            } else {
                return handleResourceFile(request.path, ext: ext)
            }
        }
        
        private func handleIndex() -> Response {
            let fileURL = sourcesURL.appendingPathComponent("main.\(sourceExtension)")
            guard let parsed = try? parser(fileURL) else {
                return Response(statusCode: 400, contentType: "text/html", body: .text("Add your main.swift file!"))
            }
            
            return Response(statusCode: 200, contentType: "text/html", body: .text(parsed))
        }
        
        func handleSourceFileWithHTMLExtension(_ path: String) -> Response {
            handleSourceFile(path.replacingOccurrences(of: ".html", with: "") + ".swift")
        }
        
        func handleSourceFile(_ path: String) -> Response {
            let fileURL = sourcesURL.appendingPathComponent(path)
            guard let parsed = try? parser(fileURL) else {
                return Response(statusCode: 400, contentType: "text/html", body: .text("Unable to parse contents of \(path)"))
            }
            return Response(statusCode: 200, contentType: "text/html", body: .text(parsed))
        }
        
        // Ignore any param in the url, useful when using
        // livereloadx
        func handleResourceFileWithParameters(_ request: Request) -> Response {
            let cleanPath = request.path.components(separatedBy: "?").first ?? request.path
            guard let ext = cleanPath.components(separatedBy: ".").last else {
                return Response(statusCode: 400, contentType: "text/html", body: .text("Paths need to have an extension"))
            }
            return handleResourceFile(cleanPath, ext: ext)
        }
        
        func handleResourceFile(_ path: String, ext: String) -> Response {
            
            let fileURL = themeURL.appendingPathComponent(path)
            
            let data = try? Data(contentsOf: fileURL)
            let content = try? String(contentsOf: fileURL, encoding: .utf8)
            
            if ext == "woff2", let data = data {
                return Response(statusCode: 200, contentType: "font/woff2", body: .binary(data))
            }
            
            if ext == "woff", let data = data {
                return Response(statusCode: 200, contentType: "font/woff", body: .binary(data))
            }
            
            if ext == "jpg", let data = data {
                return Response(statusCode: 200, contentType: "image/jpeg", body: .binary(data))
            }
            
            if ext == "css", let content {
                return Response(statusCode: 200, contentType: "text/css", body: .text(content))
            }
            
            if ext == "js", let content {
                return Response(statusCode: 200, contentType: "application/javascript", body: .text(content))
            }
            
            return Response(statusCode: 400, contentType: "text/html", body: .text("Unable to handle extension on \(path)"))
        }
    }


    // Tests/CoreTests/RequestHandlerTests.swift
    // Created by Cristian Felipe Patiño Rojas on 7/5/25.
    
    import XCTest
    import MiniSwiftServer
    import swiftdown
    
    final class RequestHandlerTests: XCTestCase {
        
        func test_process_requestWithURLParametersIgnoresParametersAndCorrectlyReturnResourceContent() throws {
            let sut = makeSUT()
            let response = sut.process(anyRequestWithURLParameter(onPath: "css/styles.css"))
            let expectedResult = try readThemeResource("css/styles.css")
            XCTAssertEqual(response.contentType, "text/css")
            XCTAssertEqual(response.bodyAsText, expectedResult)
        }
        
        func test_process_swiftFileRequestReturnsSwiftFile() throws {
            let sut = makeSUT()
            let request = Request(method: .get, path: "example.swift.txt")
            let response = sut.process(request)
            let expectedResult = try readSwiftFile("example.swift.txt")
            XCTAssertEqual(response.bodyAsText, expectedResult)
        }
        
        func test_process_cssFileRequestReturnsCSSFile() throws {
            let sut = makeSUT()
            let request = Request(method: .get, body: nil, path: "css/styles.css")
            let response = sut.process(request)
            let expectedResult = try readThemeResource("css/styles.css")
            XCTAssertEqual(response.contentType , "text/css")
            XCTAssertEqual(response.bodyAsText , expectedResult)
        }
        
        func test_process_imageRequestsReturnsImage() throws {
            let sut = makeSUT()
            let response = sut.process(Request(method: .get, body: nil, path: "assets/author.jpg"))
            let expectedResult = try readThemeResourceAsData("assets/author.jpg")
            
            XCTAssertEqual(response.contentType , "image/jpeg")
            XCTAssertEqual(response.binaryData , expectedResult)
        }
        
        func makeSUT() -> RequestHandler {
            RequestHandler(
                parser: {try String(contentsOf: $0, encoding: .utf8)},
                themeURL: themeFolder(),
                sourcesURL: sourcesFolder(),
                sourceExtension: "txt"
            )
        }
    }

    extension RequestHandlerTests {
        
        private func anyRequestWithURLParameter(onPath path: String) -> Request {
            Request(method: .get, path: "\(path)?livereload=1729723229700")
        }
        
        private func readSwiftFile(_ path: String) throws -> String {
            try String(
                contentsOf: sourcesFolder().appendingPathComponent(path),
                encoding: .utf8
            )
        }
        
        private func readThemeResourceAsData(_ path: String) throws -> Data {
            try Data(contentsOf: themeFolder().appendingPathComponent(path))
        }
        
        private func readThemeResource(_ path: String) throws -> String {
            try String(
                contentsOf: themeFolder().appendingPathComponent(path),
                encoding: .utf8
            )
        }
        
        func testsResourceDirectory() -> URL {
            Bundle.module.bundleURL.appendingPathComponent("Contents/Resources")
        }
        
        func sourcesFolder() -> URL {
            inputFolder().appendingPathComponent("sources")
        }
        
        func inputFolder() -> URL {
            testsResourceDirectory().appendingPathComponent("input")
        }
        
        func themeFolder() -> URL {
            inputFolder().appendingPathComponent("theme")
        }
        
        func outputFolder() -> URL {
            testsResourceDirectory().appendingPathExtension("output")
        }
    }


    // Tests/CoreTests/SwiftDownTests.swift
    // Created by Cristian Felipe Patiño Rojas on 7/5/25.
    
    import XCTest
    import Core
    
    final class SwiftDownTests: XCTestCase, FileReader {
        
        override func setUp() {
            try? FileManager.default.removeItem(at: outputFolder())
        }
        
        override func tearDown() {
            try? FileManager.default.removeItem(at: outputFolder())
        }
        
        func test_theme_resources_are_coppied() throws {
            try makeSUT().build()
            
            let outputFiles = try fm.contentsOfDirectory(atPath: outputFolder().path)
            XCTAssert(outputFiles.contains("css"))
            XCTAssert(outputFiles.contains("js"))
            XCTAssert(outputFiles.contains("assets"))
            XCTAssert(!outputFiles.contains("index.html"))
        }
        
        func test_codesource_files_are_copied_as_html() throws {
            try makeSUT().build()
            let outputFiles = try fm.contentsOfDirectory(atPath: outputFolder().path)
            XCTAssert(outputFiles.contains("example.swift.txt.html"))
        }
        
        func getFileContents(fileName: String) throws -> String {
            let url = testsResourceDirectory().appendingPathComponent("example.swift")
            return try String(contentsOfFile: url.path, encoding: .utf8)
        }
        
        func makeSUT() -> Swiftdown {
            Swiftdown(
                runner: CodeRunner.swift,
                syntaxParser: SwiftSyntaxHighlighter(),
                logsParser: LogsParser(),
                markdownParser: MarkdownParser(),
                sourcesURL: sourcesFolder(),
                outputURL: outputFolder(),
                themeURL: themeFolder(),
                langExtension: "swift",
                author: .init(name: "Cristian Felipe Patiño Rojas", website: "https://cristian.lat")
            )
        }
        
        func testsResourceDirectory() -> URL {
            Bundle.module.bundleURL.appendingPathComponent("Contents/Resources")
        }
        
        func inputFolder() -> URL {
            testsResourceDirectory().appendingPathComponent("input")
        }
        
        func sourcesFolder() -> URL {
            inputFolder().appendingPathComponent("sources")
        }
        
        func themeFolder() -> URL {
            inputFolder().appendingPathComponent("theme")
        }
        
        private func cachesDirectory() -> URL {
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        }
        
        private func testSpecificURL() -> URL {
            return cachesDirectory().appendingPathComponent("\(type(of: self))")
        }
        
        func outputFolder() -> URL {
            testSpecificURL().appendingPathComponent("output")
        }
    }


    // Tests/CoreTests/SyntaxHighlighterTests.swift
    // Created by Cristian Felipe Patiño Rojas on 8/5/25.
    
    import XCTest
    import Core
    
    class DefinitionsHighlighterTests: XCTestCase {
        
        func test_class() {
            let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter()
            let input = #"<span class="keyword">class</span> MyType"#
            let expectedOutput = #"<span class="keyword">class</span> <span class="type-definition">MyType</span>"#
            let output = sut.highlightDefinition(on: input, .class)
            XCTAssertEqual(output, expectedOutput)
        }
        
        func test_enum() {
            let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter()
            let input = #"<span class="keyword">enum</span> MyType"#
            let expectedOutput = #"<span class="keyword">enum</span> <span class="type-definition">MyType</span>"#
            let output = sut.highlightDefinition(on: input, .enum)
            XCTAssertEqual(output, expectedOutput)
        }
        
        func test() {
            let sut = SwiftSyntaxHighlighter.DefinitionsHighlighter()
            let input = #"<span class="keyword">class</span> MyType"#
            let expectedOutput = #"<span class="keyword">class</span> <span class="type-definition">MyType</span>"#
            let output = sut.run(input)
            XCTAssertEqual(output, expectedOutput)
        }
    }


    class LineInjectorTests: XCTestCase {
        func testRunWithEmptyString() {
            let injector = SwiftSyntaxHighlighter.LineInjector()
            let input = ""
            let expectedOutput = "<span id=\"line-1\" class=\"line-number empty-line\">1</span>\n"
            let output = injector.run(input)
            XCTAssertEqual(output, expectedOutput)
        }
    }


    // Tests/CoreTests/TemplateEngineTests.swift
    // Created by Cristian Felipe Patiño Rojas on 7/5/25.
    import XCTest
    import Core
    
    final class TemplateEngineTests: XCTestCase {
        
        func test() throws {
            let themeFolder = try makeTemporaryFolder(name: "theme")
            
            try "$title\n$content".write(
                to: themeFolder.appendingPathComponent("index.html"),
                atomically: true,
                encoding: .utf8
            )
            
            let sut = TemplateEngine(
                folder: themeFolder,
                data: ["$title": "Hello world!", "$content": "Template rendered"]
            )
            let rendered = try sut.render()
            
            XCTAssertEqual(rendered, "Hello world!\nTemplate rendered")
        }
        
        @discardableResult
        func makeTemporaryFolder(name: String) throws -> URL {
            let tmpFolder  = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            try FileManager.default.createDirectory(at: tmpFolder, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: tmpFolder, withIntermediateDirectories: true, attributes: nil)
            return tmpFolder
        }
    }

// swift import:
    // Package.swift
    // swift-tools-version: 6.1
    import PackageDescription
    
    let package = Package(
        name: "swiftimport",
        platforms: [.macOS(.v13)],
        dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
            .package(url: "https://github.com/apple/swift-collections", from: "1.0.0")
        ],
        targets: [
            .executableTarget(
                name: "swiftimport",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                    .product(name: "Collections", package: "swift-collections")
                ]
            ),
            .testTarget(
                name: "swiftimportTests",
                dependencies: ["swiftimport"],
                resources: [.copy("files")]
            ),
        ]
    )


    // Sources/CLI.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 3/6/25.
    
    import ArgumentParser
    import Foundation
    
    @main
    struct CLI: ParsableCommand {
        @Option(name: .shortAndLong, help: "Input entry point swift file") var input: String
        @Option(name: .shortAndLong, help: "The extension of the file") var ext: String = "swift"
        mutating func run() throws {
            print(try execute())
        }
        
        func execute() throws -> String {
            return try FileImporter(keyword: "// import", ext: ext).makeExecutable(from: input)
        }
    }


    // Sources/FileHandler.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 3/6/25.
    
    import Foundation
    
    enum File {
        case directory
        case file(Data)
        
        struct Data {
            let url: URL
            let content: String
            let parentDir: URL
        }
    }

    protocol FileHandler {
        func getFile(_ url: URL) throws -> File?
        func getFileURLsOnDirectory(_ directoryURL: URL) throws -> [URL]
    }


    // Sources/FileImporter.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 2/6/25.
    
    
    import Foundation
    import RegexBuilder
    import Collections
    
    final class FileImporter {
        private let keyword: String
        private let ext: String
        private let fileHandler: FileHandler
        
        private var importedFilesByVisitOrder = OrderedSet<URL>()
        private var orderedFilesForConcatenation: OrderedSet<URL> {
            OrderedSet(importedFilesByVisitOrder.reversed())
        }
        
        init(keyword: String, ext: String, fileHandler: FileHandler = FileManager.default) {
            self.keyword = keyword
            self.ext = ext
            self.fileHandler = fileHandler
        }
        
        struct FileNotFoundError: Error {}
        
        func makeExecutable(from filePath: String) throws -> String {
            try scanImports( URL(fileURLWithPath: filePath))
                .map { try String(contentsOf: $0, encoding: .utf8) }
                .joined(separator: "\n")
        }
        
        func scanImports(_ fileURL: URL) throws -> OrderedSet<URL> {
            importedFilesByVisitOrder.removeAll()
            try scanFile(fileURL)
            return orderedFilesForConcatenation
        }
        
        func parseImports(_ content: String) -> OrderedSet<String> {
            let importPattern = Regex {
                Anchor.startOfLine
                "\(keyword) "
                Capture {
                    OneOrMore {
                        ChoiceOf {
                            .word
                            "/"
                            "."
                        }
                    }
                    ChoiceOf {
                        ".swift.txt"
                        "/"
                    }
                }
            }
            
            return OrderedSet(content
                .matches(of: importPattern)
                .map { String($0.output.1) })
        }
    }

    private extension FileImporter {
        
        func scanFile(_ fileURL: URL) throws {
            switch try fileHandler.getFile(fileURL) {
            case .directory: return try handleDirectory(fileURL)
            case .file(let data): return try handleFile(data)
            case .none: throw FileNotFoundError()
            }
        }
        
        func handleDirectory(_ directoryURL: URL) throws {
            try fileHandler.getFileURLsOnDirectory(directoryURL)
                .filter { $0.lastPathComponent.hasSuffix(ext) }
                .forEach { try scanFile($0) }
        }
        
        func handleFile(_ data: File.Data) throws {
            guard fileHasNotBeenAlreadyParsed(data.url) else { return }
            importedFilesByVisitOrder.append(data.url)
            
            try parseImports(data.content)
                .map { data.parentDir.appendingPathComponent($0, isDirectory: $0.hasSuffix("/")) }
                .forEach { try scanFile($0) }
        }
        
        func fileHasNotBeenAlreadyParsed(_ url: URL) -> Bool {
            !importedFilesByVisitOrder.contains(url)
        }
    }


    // Sources/FileManager.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 3/6/25.
    
    
    import Foundation
    
    extension FileManager: FileHandler {
        func getFile(_ url: URL) throws -> File? {
            var isDirectory: ObjCBool = false
            let fileExists = fileExists(atPath: url.path, isDirectory: &isDirectory)
            guard fileExists else { return nil }
            guard !isDirectory.boolValue else { return .directory }
            
            let content = try String(contentsOfFile: url.path, encoding: .utf8)
            let parentDir = url.deletingLastPathComponent()
            return .file(File.Data(url: url, content: content, parentDir: parentDir))
        }
        
        func getFileURLsOnDirectory(_ directoryURL: URL) throws -> [URL] {
            let resourceKeys: [URLResourceKey] = [.isDirectoryKey]
            
            guard let enumerator = FileManager.default.enumerator(
                at: directoryURL,
                includingPropertiesForKeys: resourceKeys,
                options: [.skipsHiddenFiles]
            ) else {
                throw NSError(domain: "Unable to read contents of directory", code: 0)
            }
            
            
            var files: [URL] = []
            
            for case let fileURL as URL in enumerator {
                files.append(fileURL)
            }
            
            return files
        }
    }


    // Tests/CLITests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 3/6/25.
    
    import XCTest
    @testable import swiftimport
    
    class CLITests: XCTestCase {
        
        func test() throws {
            let srcFolder = Bundle.module.testFilesDirectory.appendingPathComponent("integrationTests")
            let entryPointFileURL = srcFolder.appendingPathComponent("a.swift.txt")
            let sut = try CLI.parse([
                "--input", entryPointFileURL.path,
                "--ext", "swift.txt"
            ])
            
            let result = try sut.execute()
            
            let expectedResult = """
            c file
            
            // import nested/c.swift.txt
            b file
            
            // import b.swift.txt
            a file
            
            """
            
            XCTAssertEqual(result, expectedResult)
        }
    }


    // Tests/FileImporterTests.swift
    //
    //  Created by Cristian Felipe Patiño Rojas on 2/5/25.
    
    import XCTest
    import Collections
    @testable import swiftimport
    
    final class FileImporterTests: XCTestCase {
        
        lazy var testSources = Bundle.module.testFilesDirectory
        
        func test_file_parsing() throws {
            let sut = makeSUT()
            let fileURL = testSources.appendingPathComponent("b.swift.txt")
            let output = OrderedSet(try sut.scanImports(fileURL)
                .map { $0.lastPathComponent })
            let expectedOutput = ["a.swift.txt", "b.swift.txt"]
            
            XCTAssertEqual(output, OrderedSet(expectedOutput))
        }
        
        func test_cascade_parsing() throws {
            let sut = makeSUT()
            let fileURL = testSources.appendingPathComponent("cascade_a.swift.txt")
            let output = try sut.scanImports(fileURL)
                .map {$0.lastPathComponent}
            
            let expectedOutput = [
                "cascade_c.swift.txt",
                "cascade_b.swift.txt",
                "cascade_a.swift.txt"
            ]
            
            XCTAssertEqual(OrderedSet(output), OrderedSet(expectedOutput))
        }
        
        func test_infinite_recursion() throws {
            
            let sut = makeSUT()
            let fileURL = testSources.appendingPathComponent("cyclic_a.swift.txt")
            let output = try sut.scanImports(fileURL).map {$0.lastPathComponent}
            
            let expectedOutput = [
                "cyclic_b.swift.txt",
                "cyclic_a.swift.txt",
            ]
            
            XCTAssertEqual(OrderedSet(output), OrderedSet(expectedOutput))
        }
        
        func test_import_file_inside_folder() throws {
            let sut = makeSUT()
            let fileURL = testSources.appendingPathComponent("nested_import.swift.txt")
            let output = try sut.scanImports(fileURL)
            
            let expectedOutput = [
                "nested/a.swift.txt",
                "nested_import.swift.txt",
            ].map {
                testSources.appendingPathComponent($0)
            }
            
            XCTAssertEqual(output,  OrderedSet(expectedOutput))
        }
        
        func test_import_file_inside_folder_cascade() throws {
            let sut = makeSUT()
            let fileURL = testSources.appendingPathComponent("nested_import_b.swift.txt")
            let output = try sut.scanImports(fileURL)
            
            
            let expectedOutput = [
                "nested/a.swift.txt",
                "nested/b.swift.txt",
                "nested_import_b.swift.txt",
            ].map {
                testSources.appendingPathComponent($0)
            }
            
            XCTAssertEqual(output,  OrderedSet(expectedOutput))
        }
        
        func test_import_whole_folder() throws {
            let sut = makeSUT()
            let fileURL = testSources.appendingPathComponent("import_whole_folder.swift.txt")
            
            let output = try sut.scanImports(fileURL).map { url in
                url.path.components(separatedBy: "/files/").last!
            }
            
            let expectedOutput = [
                "nested/nested/a.swift.txt",
                "nested/b.swift.txt",
                "nested/a.swift.txt",
                "import_whole_folder.swift.txt",
            ]
            
            XCTAssertEqual(OrderedSet(output), OrderedSet(expectedOutput))
        }
    }


    // MARK: - Helpers
    extension FileImporterTests {
        func makeSUT(keyword: String = "import", extension: String = "swift.txt") -> FileImporter {
            FileImporter(keyword: keyword, ext: `extension`)
        }
    }


    // Tests/Helpers.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 2/6/25.
    
    import Foundation
    
    extension Bundle {
        var testFilesDirectory: URL {
            Bundle.module.resourceURL!.appendingPathComponent("files")
        }
    }


    
    
    // Tests/StringParsingTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 3/6/25.
    
    import XCTest
    import Collections
    @testable import swiftimport
    
    extension FileImporterTests {
        
        func test_parseImports_handlesStandaloneSwiftFilesImports() {
            let sut = makeSUT()
            let code = """
            import a.swift.txt
            import b.swift.txt
            import some_really_long_named_file.swift.txt
            import cascade_b.swift.txt
            
            let a = B()
            """
            
            let output = sut.parseImports(code)
            let expectedOutput = ["a.swift.txt", "b.swift.txt", "some_really_long_named_file.swift.txt", "cascade_b.swift.txt"]
            
            XCTAssertEqual(output, OrderedSet(expectedOutput))
        }
        
        
        func test_parseImports_handlesNestedSwiftFilesImports() {
            let sut = makeSUT()
            let code = """
            import nested/a.swift.txt
            import nested/b.swift.txt
            
            enum SomeEnum {}
            """
            
            let output = sut.parseImports(code)
            let expectedOutput = ["nested/a.swift.txt", "nested/b.swift.txt"]
            
            XCTAssertEqual(output, OrderedSet(expectedOutput))
        }
        
        func test_parseImports_handlesDirectories() {
            let sut = makeSUT()
            let code = """
            import nested/
            """
            
            let output = sut.parseImports(code)
            let expectedOutput = ["nested/"]
            
            XCTAssertEqual(output, OrderedSet(expectedOutput))
        }
    }

// server:
    // Package.swift
    // swift-tools-version: 6.1
    
    import PackageDescription
    
    let package = Package(
        name: "MiniSwiftServer",
        platforms: [.macOS(.v10_13)],
        products: [
            .library(
                name: "MiniSwiftServer",
                targets: ["MiniSwiftServer"]
            ),
        ],
        targets: [
            .target(
                name: "MiniSwiftServer"
            ),
        ]
    )


    // Request.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 16/6/25.
    
    import Foundation
    
    public struct Request  {
        public let method: Method
        public let body: Data?
        public let path: String
        
        public init(method: Method, body: Data? = nil, path: String) {
            self.method = method
            self.body = body
            self.path = path
        }
    }

    extension Request {
        public enum Method: String {
            case get
            case post
            case patch
            case put
            case delete
        }
        
        public enum Error: Swift.Error {
            case noMethodFound
            case invalidMethod(String)
            case noPathFound
        }
        
    }


    extension Request {
        init(_ request: String) throws {
            let components = request.components(separatedBy: "\n\n")
            let headers = components.first?.components(separatedBy: "\n") ?? []
            let payload = components.count > 1 ? components[1].trimmingCharacters(in: .whitespacesAndNewlines) : nil
            
            method = try Self.method(headers)
            body   = try Self.body  (payload)
            path   = try Self.path  (headers)
        }
        
        init(_ buffer: Array<UInt8>) throws {
            try self.init(String(bytes: buffer, encoding: .utf8) ?? "")
        }
    }

    extension Request {
        static func method(_ headers: [String]) throws -> Method {
            let firstLine = headers.first?.components(separatedBy: " ")
            
            guard let stringMethod = firstLine?.first?.lowercased() else {
                throw Error.noMethodFound
            }
            
            guard let method = Method.init(rawValue: stringMethod) else {
                throw Error.invalidMethod(stringMethod)
            }
            
            return method
        }
        
        static func body(_ payload: String?) throws -> Data? {
            guard let payload, let data = payload.data(using: .utf8) else { return nil }
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let normalizedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            
            return normalizedData
        }
        
        static func path(_ headers: [String]) throws -> String {
            let firstLine = headers.first?.components(separatedBy: " ")
            guard let path = firstLine?[idx: 1] else { throw Error.noPathFound }
            return path.first == "/" ? String(path.dropFirst()) : path
        }
    }

    fileprivate extension Array {
        subscript(idx idx: Int) -> Element? {
            indices.contains(idx) ? self[idx] : nil
        }
    }


    // Response.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 16/6/25.
    
    import Foundation
    
    public struct Response {
        public let statusCode: Int
        public let contentType: String
        public let body: Body
        
        public init(statusCode: Int, contentType: String, body: Body) {
            self.statusCode = statusCode
            self.contentType = contentType
            self.body = body
        }
    }

    extension Response {
        public enum Body {
            case text(String)
            case binary(Data)
        }
        
        func toHTTPResponse() -> String {
            var response = "HTTP/1.1 \(statusCode)\r\n"
            response += "Content-Type: \(contentType)\r\n"
            
            switch body {
            case .text(let textBody):
                response += "Content-Length: \(textBody.utf8.count)\r\n"
                response += "\r\n"
                response += textBody
            case .binary(let binaryBody):
                response += "Content-Length: \(binaryBody.count)\r\n"
                response += "\r\n"
            }
            
            return response
        }
        
        public var bodyAsText: String? {
            switch body {
                case .text(let text): return text
                default: return nil
            }
        }
        
        public var binaryData: Data? {
            switch body {
            case .binary(let binaryBody):
                return binaryBody
            case .text:
                return nil
            }
        }
    }


    // Server.swift
    //  © 2025  Cristian Felipe Patiño Rojas. Created on 16/6/25.
    
    import Foundation
    
    public struct Server {
        public typealias RequestHandler = (Request) -> Response
        let port: UInt16
        let requestHandler: RequestHandler
        
        public init(port: UInt16, requestHandler: @escaping RequestHandler) {
            self.port = port
            self.requestHandler = requestHandler
        }
        
        public func run() {
            
            let _socket = socket(AF_INET, SOCK_STREAM, 0)
            guard _socket >= 0 else {
                fatalError("Unable to create socket")
            }
            
            var value: Int32 = 1
            setsockopt(_socket, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size))
            
            var serverAddress = sockaddr_in()
            serverAddress.sin_family = sa_family_t(AF_INET)
            serverAddress.sin_port = in_port_t(port).bigEndian
            serverAddress.sin_addr = in_addr(s_addr: INADDR_ANY)
            
            let bindResult = withUnsafePointer(to: &serverAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    bind(_socket, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
            guard bindResult >= 0 else {
                fatalError("Error on socket launch.")
            }
            
            guard listen(_socket, 10) >= 0 else {
                fatalError("Error on socket listning.")
            }
            
            print("Server listening on port \(port)...")
            
            while true {
                var clientAddress = sockaddr_in()
                var clientAddressLength = socklen_t(MemoryLayout<sockaddr_in>.size)
                let clientSocket = withUnsafeMutablePointer(to: &clientAddress) {
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        accept(_socket, $0, &clientAddressLength)
                    }
                }
                
                guard clientSocket >= 0 else {
                    print("Error on connxion")
                    continue
                }
                
                var buffer = [UInt8](repeating: 0, count: 1024)
                let bytesRead = read(clientSocket, &buffer, 1024)
                
                guard bytesRead > 0 else {
                    print("Unable to read data")
                    close(clientSocket)
                    continue
                }
                
                do {
                    
                    let request = try Request(buffer)
                    let response = requestHandler(request)
                    
                    let headersAndBody = response.toHTTPResponse()
                    
                        write(clientSocket, headersAndBody, headersAndBody.utf8.count)
                    
                        if let binaryData = response.binaryData {
                            _ = binaryData.withUnsafeBytes { bytes in
                                write(clientSocket, bytes.baseAddress!, binaryData.count)
                            }
                        }
                    
                    
                    if response.statusCode != 200 {
                        print("Failed response at \(request.path):")
                        print(response)
                    }
                    
                    close(clientSocket)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        
        enum ServerError: Error {
            case noEndpointFound(String)
            
            var message: String {
                switch self {
                    case .noEndpointFound(let path): return "No endpoint found for \(path)"
                }
            }
        }
    }


    
// tddbuddy:
    // Package.swift
    // swift-tools-version: 6.1
    // The swift-tools-version declares the minimum version of Swift required to build this package.
    
    import PackageDescription
    
    let package = Package(
        name: "TddBuddy",
        platforms: [.macOS(.v12)],
        dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        ],
        targets: [
            .target(name: "Core"),
            
            .executableTarget(
                name: "tddbuddy",
                dependencies: [
                    "Core",
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                ]
            ),
            .testTarget(name: "CoreTests", dependencies: ["Core"]),
            .testTarget(name: "CoreE2ETests", dependencies: ["Core", "tddbuddy"], resources: [.copy("inputs")])
        ]
    )


    // Sources/Core/Infrastructure/FileManager+FileReader.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import Foundation
    
    extension FileManager: FileReader {
        public func read(_ url: URL) throws -> String {
            try String(contentsOf: url, encoding: .utf8)
        }
    }


    // Sources/Core/Infrastructure/FilePersistor.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    import Foundation
    
    public class FilePersistor: Persistor {
        public init() {}
        public func persist(_ string: String, outputURL: URL) throws {
            try string.write(to: outputURL, atomically: true, encoding: .utf8)
        }
    }


    // Sources/Core/Infrastructure/OllamaClient.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    
    import Foundation
    
    #if canImport(FoundationNetworking)
    import FoundationNetworking
    #endif
    
    public struct OllamaClient: Client {
        private let model = "llama3.2"
        private let url = "http://localhost:11434/api/chat"
        public init() {}
        public func send(messages: [Message]) async throws -> String {
            let url = URL(string: url)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try makeBody(messages)
            //request.timeoutInterval = 10
            
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = httpResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            return try JSONDecoder().decode(Response.self, from: data).message.content
        }
        
        private func makeBody(_ messages: [Message]) throws -> Data {
            try JSONSerialization.data(withJSONObject: [
                "model": model,
                "messages": messages,
                "stream": false
            ], options: [])
        }
        
        struct Response: Decodable {
            let message: Message
            // MARK: - Message
            struct Message: Decodable {
                let role: String
                let content: String
            }
        }
    }


    // Sources/Core/Infrastructure/SwiftRunner.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import Foundation
    
    public struct SwiftRunner: Runner {
        private let fm = FileManager.default
        public init() {}
        public typealias ProcessOutput = (stdout: String, stderr: String, exitCode: Int)
        public func run(_ code: String) throws -> ProcessOutput {
            let tmpURL = fm.temporaryDirectory.appendingPathComponent("generated.swift")
            try code.write(to: tmpURL, atomically: true, encoding: .utf8)
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["swift", tmpURL.path]
            
            let stdOutPipe = Pipe()
            let stdErrPipe = Pipe()
            process.standardOutput = stdOutPipe
            process.standardError = stdErrPipe
            
            try process.run()
            process.waitUntilExit()
            
            let stdOutData = stdOutPipe.fileHandleForReading.readDataToEndOfFile()
            let stdErrData = stdErrPipe.fileHandleForReading.readDataToEndOfFile()
            
            return (
                stdout: String(data: stdOutData, encoding: .utf8) ?? "",
                stderr: String(data: stdErrData, encoding: .utf8) ?? "",
                exitCode: Int(process.terminationStatus)
            )
        }
    }


    // Sources/Core/IO/FileReader.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    
    import Foundation
    
    public protocol FileReader {
        func read(_ url: URL) throws -> String
    }

    // Sources/Core/IO/Iterator.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    public class Iterator {
        public init() {}
        public func iterate<T>(nTimes n: Int, until condition: (T) -> Bool, action: () async throws -> T) async throws -> T {
            var results = [T]()
            while results.count < n {
                let result = try await action()
                if condition(result) { return result }
                results.append(result)
            }
            return results.first!
        }
    }


    // Sources/Core/IO/Persistor.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    
    import Foundation
    
    public protocol Persistor {
        func persist(_ string: String, outputURL: URL) throws
    }

    // Sources/Core/Main/Client.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    
    public protocol Client {
        typealias Message = [String: String]
        func send(messages: [Message]) async throws -> String
    }


    // Sources/Core/Main/Coordinator.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import Foundation
    
    public class Coordinator {
        
        public typealias Output = (generatedCode: String, procesOutput: Runner.ProcessOutput)
        
        private let reader: FileReader
        private let client: Client
        private let runner: Runner
        private let persistor: Persistor
        private let iterator = Iterator()
        public init(
            reader: FileReader,
            client: Client,
            runner: Runner,
            persistor: Persistor
        ) {
            self.reader = reader
            self.client = client
            self.runner = runner
            self.persistor = persistor
        }
        
        @discardableResult
        public func generateAndSaveCode(systemPrompt: String, specsFileURL: URL, outputFileURL: URL, maxIterationCount: Int = 1) async throws -> Output {
            let specs = try reader.read(specsFileURL)
            var previousOutput: Output?
            let output = try await iterator.iterate(
                nTimes: maxIterationCount,
                until: { previousOutput = $0 ; return isSuccess($0) }
            ) {
                try await self.generateCode(systemPrompt: systemPrompt, from: specs, previous: previousOutput)
            }
            
            try persistor.persist(output.generatedCode, outputURL: outputFileURL)
            return output
        }
        
        private func generateCode(systemPrompt: String, from specs: String, previous: Output?) async throws -> Output {
            var messages: [Client.Message] = [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": specs]
            ]
            
            if let previous {
                messages.append([
                    "role": "assistant",
                    "content": "failed attempt.\ncode:\(previous.generatedCode)\nerror:\(previous.procesOutput.stderr)"
                ])
            }
            let generated = try await client.send(messages: messages)
            let concatenated = generated + "\n" + specs
            let processOutput = try runner.run(concatenated)
            return (generated, processOutput)
        }
        
        private func isSuccess(_ o: Output) -> Bool { o.procesOutput.exitCode == 0 }
    }


    // Sources/Core/Main/Runner.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    
    public protocol Runner {
        typealias ProcessOutput = (stdout: String, stderr: String, exitCode: Int)
        func run(_ code: String) throws -> ProcessOutput
    }


    // Sources/tddbuddy/Logging.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    import Foundation
    import Core
    
    #if canImport(os)
    import os
    #endif
    
    enum Logger {
        #if canImport(os)
        static let logger = os.Logger(subsystem: "me.crisfe.tddbuddy.cli", category: "core")
        #endif
        static func info(_ message: String) {
            #if canImport(os)
            logger.info("\(message, privacy: .public)")
            #else
            print(message)
            #endif
        }
    }

    public final class LoggerDecorator<T> {
        let decoratee: T
        
        public init(_ decoratee: T) {
            self.decoratee = decoratee
        }
    }


    // MARK: - Runner
    extension LoggerDecorator: Runner where T: Runner {
        public func run(_ code: String) throws -> ProcessOutput {
            try decoratee.run(code)
        }
    }

    // MARK: - Persistor
    extension LoggerDecorator: Persistor where T: Persistor {
        public func persist(_ string: String, outputURL: URL) throws {
            try decoratee.persist(string, outputURL: outputURL)
            Logger.info("📍 Output saved to \(outputURL.path):")
        }
    }

    // MARK: - FileReader
    extension LoggerDecorator: FileReader where T: FileReader {
        public func read(_ url: URL) throws -> String {
            let contents = try decoratee.read(url)
            return contents
        }
    }


    // Sources/tddbuddy/TddBuddy.swift
    // main.swift
    import Foundation
    import ArgumentParser
    import Core
    
    @main
    struct TDDBuddy: AsyncParsableCommand {
        @Option(name: .shortAndLong, help: "Custom system prompt to use instead of the default.")
        var prompt: String?
        
        @Option(name: .shortAndLong, help: "The path to the specs file.")
        var input: String
        
        @Option(name: .shortAndLong, help: "The path where the generated code will be saved.")
        var output: String
        
        @Option(name: .shortAndLong, help: "Maximum number of iterations (default is 5).")
        var iterations: Int = 5
        
        func run() async throws {
            let client = OllamaClient()
            let runner = LoggerDecorator(SwiftRunner())
            let persistor = LoggerDecorator(FilePersistor())
            
            let coordinator = Coordinator(
                reader: FileManager.default,
                client: client,
                runner: runner,
                persistor: persistor
            )
            
            let inputURL = URL(fileURLWithPath: input)
            let outputURL = URL(fileURLWithPath: output)
            
            let result = try await coordinator.generateAndSaveCode(
                systemPrompt: prompt ?? TDDBuddy.systemPrompt,
                specsFileURL: inputURL,
                outputFileURL: outputURL,
                maxIterationCount: iterations
            )
            
            result.procesOutput.exitCode != 0
            ? Logger.info("❌ Code generated didn't meet the specs")
            : ()
            
        }
    }

    private extension TDDBuddy {
        static let systemPrompt = """
            Imagine that you are a programmer and the user's responses are feedback from compiling your code in your development environment. Your responses are the code you write, and the user's responses represent the feedback, including any errors.
            
            Implement the SUT's code in Swift based on the provided specs (unit tests).
            
            Follow these strict guidelines:
            
            1. Provide ONLY runnable Swift code. No explanations, comments, or formatting (no code blocks, markdown, symbols, or text).
            2. DO NOT include unit tests or any test-related code.
            3. ALWAYS IMPORT ONLY Foundation. No other imports are allowed.
            4. DO NOT use access control keywords (`public`, `private`, `internal`) or control flow keywords in your constructs.
            
            If your code fails to compile, the user will provide the error output for you to make adjustments.
            """
    }


    // Tests/CoreE2ETests/IntegrationTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import XCTest
    import Core
    import tddbuddy
    
    class IntegrationTests: XCTestCase {
        func test_adder_generation() async throws {
            let systemPrompt = """
                Imagine that you are a programmer and the user's responses are feedback from compiling your code in your development environment. Your responses are the code you write, and the user's responses represent the feedback, including any errors.
                
                Implement the SUT's code in Swift based on the provided specs (unit tests).
                
                Follow these strict guidelines:
                
                1. Provide ONLY runnable Swift code. No explanations, comments, or formatting (no code blocks, markdown, symbols, or text).
                2. DO NOT include unit tests or any test-related code.
                3. ALWAYS IMPORT ONLY Foundation. No other imports are allowed.
                4. DO NOT use access control keywords (`public`, `private`, `internal`) or control flow keywords in your constructs.
                
                If your code fails to compile, the user will provide the error output for you to make adjustments.
                """
            let reader = FileManager.default
            let client = OllamaClient()
            let runner = LoggerDecorator(SwiftRunner())
            let persistor = LoggerDecorator(FilePersistor())
            let sut = Coordinator(
                reader: reader,
                client: client,
                runner: runner,
                persistor: persistor
            )
            let adderSpecs = specsURL("adder.swift.txt")
            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("adder.swift.txt")
            let output = try await sut.generateAndSaveCode(systemPrompt: systemPrompt, specsFileURL: adderSpecs, outputFileURL: tmpURL, maxIterationCount: 5)
            
            XCTAssertFalse(output.generatedCode.isEmpty)
            XCTAssertEqual(output.procesOutput.exitCode, 0)
        }
        
        func specsURL(_ filename: String) -> URL {
            inputFolder().appendingPathComponent(filename)
        }
        
        func testsResourceDirectory() -> URL {
            Bundle.module.bundleURL.appendingPathComponent("Contents/Resources")
        }
        
        func inputFolder() -> URL {
            testsResourceDirectory().appendingPathComponent("inputs")
        }
    }


    // Tests/CoreE2ETests/OllamaClientTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import XCTest
    import Foundation
    import Core
    
    class OllamaClientTests: XCTestCase {
        
        func test_send_withRunningOllamaServer_returnsContent() async throws {
            let sut = OllamaClient()
            let response = try await sut.send(messages: [["role": "user", "content": "hello"]])
            XCTAssert(!response.isEmpty)
        }
    }


    // Tests/CoreTests/Infrastructure/FilePersistorTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import XCTest
    import Core
    
    class FilePersistorTests: XCTestCase {
        
        override func setUp() {
            setupEmptyState()
        }
        
        override func tearDown() {
            cleanTestsArtifacts()
        }
        
        func test_persist_savesStringToDisk() throws {
            let sut = FilePersistor()
            try sut.persist("any string", outputURL: temporaryFileURL())
            XCTAssertEqual(try String(contentsOf: temporaryFileURL(), encoding: .utf8), "any string")
        }
        
        func temporaryFileURL() -> URL {
            FileManager.default.temporaryDirectory.appendingPathComponent("output.txt")
        }
        
        func cleanTestsArtifacts() {
            try? removeTemporyFile()
        }
        
        func setupEmptyState() {
            try? removeTemporyFile()
        }
        
        func removeTemporyFile() throws {
            try FileManager.default.removeItem(at: temporaryFileURL())
        }
    }


    // Tests/CoreTests/Infrastructure/FileReaderTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import XCTest
    import Core
    
    class FileReaderTests: XCTestCase {
        override func setUp() {
            setupEmptyState()
        }
        
        override func tearDown() {
            cleanTestsArtifacts()
        }
        
        func test_read_readsFileWhenExists() throws {
            let sut = FileManager.default
            let stringToWrite = "Hello, world!"
            try stringToWrite.write(to: temporaryFileURL(), atomically: true, encoding: .utf8)
            let content = try sut.read(temporaryFileURL())
            XCTAssertEqual(stringToWrite, content)
        }
        
        func temporaryFileURL() -> URL {
            FileManager.default.temporaryDirectory.appendingPathComponent("output.txt")
        }
        
        func cleanTestsArtifacts() {
            try? removeTemporyFile()
        }
        
        func setupEmptyState() {
            try? removeTemporyFile()
        }
        
        func removeTemporyFile() throws {
            try FileManager.default.removeItem(at: temporaryFileURL())
        }
    }


    // Tests/CoreTests/Infrastructure/SwiftRunnerTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import XCTest
    import Core
    
    class SwiftRunnerTests: XCTestCase {
        
        func test_run_deliversRunsCode() throws {
            let sut = SwiftRunner()
            let swiftCode = #"print("hello world")"#
            let processOutput = try sut.run(swiftCode)
            let expectedStdout = "hello world\n"
            let expectedStderr = ""
            let expectedExitCode = 0
            
            XCTAssertEqual(processOutput.stdout, expectedStdout)
            XCTAssertEqual(processOutput.stderr, expectedStderr)
            XCTAssertEqual(processOutput.exitCode, expectedExitCode)
        }
    }


    // Tests/CoreTests/IO/IteratorTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    
    import XCTest
    import Core
    
    
    
    class IteratorTests: XCTestCase {
        
        func test_iterator_iteratesNtimes() async throws {
            let sut = Iterator()
            var iterationCount = 0
            try await sut.iterate(
                nTimes: 5,
                until: neverFullfillsCondition,
                action: { iterationCount += 1 }
            )
            XCTAssertEqual(iterationCount, 5)
        }
        
        func test_iterator_stopsWhenConditionIsMet() async throws {
            let sut = Iterator()
            var iterationCount = 0
            try await sut.iterate(
                nTimes: 5,
                until: { iterationCount == 1 },
                action: { iterationCount += 1 })
            XCTAssertEqual(iterationCount, 1)
        }
        
        private func neverFullfillsCondition() -> Bool { false }
    }


    // Tests/CoreTests/UseCases/CodeGenerationUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.
    
    import Core
    
    extension CoordinatorTests {
        func test_generateAndSaveCode_deliversErrorOnClientError() async throws {
            let client = ClientStub(result: .failure(anyError()))
            let coordinatior = makeSUT(client: client)
            
            await XCTAssertThrowsErrorAsync(
                try await coordinatior.generateAndSaveCode(
                    systemPrompt: anySystemPrompt(),
                    specsFileURL: anyURL(),
                    outputFileURL: anyURL()
                )
            )
        }
        
        func test_generateAndSaveCode_deliversNoErrorOnClientSuccess() async throws {
            let client = ClientStub(result: .success("any genereted code"))
            let sut = makeSUT(client: client)
            await XCTAssertNoThrowAsync(
                try await sut.generateAndSaveCode(
                    systemPrompt: anySystemPrompt(),
                    specsFileURL: anyURL(),
                    outputFileURL: anyURL()
                )
            )
        }
        
        private func makeSUT(client: Client) -> Coordinator {
            Coordinator(
                reader: FileReaderDummy(),
                client: client,
                runner: RunnerDummy(),
                persistor: PersistorDummy()
            )
        }
    }


    // Tests/CoreTests/UseCases/CoordinatorTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import XCTest
    import Core
    
    class CoordinatorTests: XCTestCase {    
        
        func test_generateAndSaveCode_usesConcatenatedCodeAsRunnerInputInTheRightOrder() async throws {
            class RunnerSpy: Runner {
                var code: String?
                func run(_ code: String) throws -> Runner.ProcessOutput {
                    self.code = code
                    return ("", "", 0)
                }
            }
            
            let readerStub = FileReaderStub(result: .success(anySpecs()))
            let clientStub = ClientStub(result: .success(anyGeneratedCode()))
            let runnerSpy = RunnerSpy()
            
            let sut = makeSUT(reader: readerStub, client: clientStub, runner: runnerSpy)
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
            
            XCTAssertEqual(runnerSpy.code, "\(anyGeneratedCode())\n\(anySpecs())")
        }
        
        func test_generateAndSaveCode_sendsContentsOfReadFileToClient() async throws {
            let reader = FileReaderStub(result: .success(anyString()))
            let clientSpy = ClientSpy()
            let sut = makeSUT(reader: reader, client: clientSpy)
            
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
            
            let expectedMessages = [
                ["role": "system", "content": anySystemPrompt()],
                ["role": "user", "content": anyString()]
            ]
            XCTAssertEqual(clientSpy.messages, [expectedMessages])
        }
        
        func test_generateAndSaveCode_persistsGeneratedCode() async throws {
            class PersistorSpy: Persistor {
                var persistedString: String?
                func persist(_ string: String, outputURL: URL) throws {
                    persistedString = string
                }
            }
            
            let clientStub = ClientStub(result: .success(anyGeneratedCode()))
            let persistorSpy = PersistorSpy()
            
            let sut = makeSUT(client: clientStub, persistor: persistorSpy)
            
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
            
            XCTAssertEqual(persistorSpy.persistedString, anyGeneratedCode())
        }
        
        func test_generateAndSaveCode_retriesUntilMaxIterationWhenProcessFails() async throws {
            let clientStub = ClientStub(result: .success(anyGeneratedCode()))
            let runnerStub = RunnerStubResults(results: [
                anyFailedProcessOutput(),
                anyFailedProcessOutput(),
                anyFailedProcessOutput()
            ])
            
            let sut = makeSUT(client: clientStub, runner: runnerStub)
            try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL(),
                maxIterationCount: 3
            )
            
            XCTAssertEqual(runnerStub.results.count, 0)
        }
        
        func test_generateAndSaveCode_retiresUntilSucessWhenProcessSucceedsAfterNRetries() async throws {
            let clientStub = ClientStub(result: .success(anyGeneratedCode()))
            let runnerStub = RunnerStubResults(results: [
                anyFailedProcessOutput(),
                anyFailedProcessOutput(),
                anyFailedProcessOutput(),
                anySuccessProcessOutput()
            ])
            
            try await makeSUT(client: clientStub, runner: runnerStub).generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL(),
                maxIterationCount: 5
            ) .* {
                XCTAssertEqual($0.generatedCode, anyGeneratedCode())
                XCTAssertEqual($0.procesOutput.stderr, anySuccessProcessOutput().stderr)
                XCTAssertEqual($0.procesOutput.stdout, anySuccessProcessOutput().stdout)
                XCTAssertEqual($0.procesOutput.exitCode, anySuccessProcessOutput().exitCode)
            }
            
            XCTAssertEqual(runnerStub.results.count, 0)
        }
        
        
        func test_generateAndSaveCode_buildsMessagesWithPreviousFeedbackWhenIterationFails() async throws {
            let reader = FileReaderStub(result: .success(anySpecs()))
            let client = ClientSpy()
            let runner = RunnerStub(result: .success(anyFailedProcessOutput()))
            let sut = makeSUT(reader: reader, client: client, runner: runner)
            
            let _ = try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL(),
                maxIterationCount: 2
            )
            
            let expectedMessages = [
                ["role": "system", "content": anySystemPrompt()],
                ["role": "user", "content": anySpecs()],
                ["role": "assistant", "content": "failed attempt.\ncode:\(anyGeneratedCode())\nerror:\(anyFailedProcessOutput().stderr)"]
            ]
            
            XCTAssertEqual(client.messages.last?.normalized(), expectedMessages.normalized())
            
        }
        private func makeSUT(
            reader: FileReader = FileReaderDummy(),
            client: Client = ClientDummy(),
            runner: Runner = RunnerDummy(),
            persistor: Persistor = PersistorDummy()
        ) -> Coordinator {
            Coordinator(
                reader: reader,
                client: client,
                runner: runner,
                persistor: persistor
            )
        }
    }

    private extension [[String: String]] {
        func normalized() -> [NSDictionary] {
            map { $0 as NSDictionary }
        }
    }


    // Tests/CoreTests/UseCases/Helpers/CoordinatorTests+Asserts.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.
    
    
    import XCTest
    
    extension CoordinatorTests {
        func XCTAssertNoThrowAsync<T>(
            _ expression: @autoclosure () async throws -> T,
            _ message: @autoclosure () -> String = "Expected no error, but error was thrown",
            file: StaticString = #filePath,
            line: UInt = #line
        ) async {
            do {
                _ = try await expression()
            } catch {
                XCTFail(message(), file: file, line: line)
            }
        }
        
        func XCTAssertThrowsErrorAsync<T>(
            _ expression: @autoclosure () async throws -> T,
            _ message: @autoclosure () -> String = "",
            file: StaticString = #filePath,
            line: UInt = #line,
            _ errorHandler: (Error) -> Void = { _ in }
        ) async {
            do {
                _ = try await expression()
                XCTFail("Expected error to be thrown, but no error was thrown", file: file, line: line)
            } catch {
                errorHandler(error)
            }
        }
    }


    // Tests/CoreTests/UseCases/Helpers/CoordinatorTests+Asterisk.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/5/25.
    
    infix operator .*: AdditionPrecedence
    
    @discardableResult
    func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
        var copy = lhs
        rhs(&copy)
        return copy
    }


    // Tests/CoreTests/UseCases/Helpers/CoordinatorTests+Helpers.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.
    
    import Foundation
    import Core
    
    extension CoordinatorTests {
        
        func anyURL() -> URL {
            URL(string: "http://any-url.com")!
        }
        
        func anyError() -> NSError {
            NSError(domain: "", code: 0)
        }
        
        func anyGeneratedCode() -> String {
            "any generated code"
        }
        
        func anyString() -> String {
            "any string"
        }
        
        func anySystemPrompt() -> String {
            "any system prompt"
        }
        
        func anySpecs() -> String {
            "any specs"
        }
        
        func anySuccessProcessOutput() -> Runner.ProcessOutput {
            ("", "", 0)
        }
        
        private static var failedExitCode: Int { 1 }
        func anyFailedProcessOutput() -> Runner.ProcessOutput {
            (stdout: "", stderr: "any stderr error", exitCode: Self.failedExitCode)
        }
    }


    // Tests/CoreTests/UseCases/Helpers/CoordinatorTests+Mocks.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.
    
    import Foundation
    import Core
    
    
    // Stubs
    extension CoordinatorTests {
        struct RunnerStub: Runner {
            let result: Result<ProcessOutput, Error>
            func run(_ code: String) throws -> ProcessOutput {
                try result.get()
            }
        }
        
        class RunnerStubResults: Runner {
            var results = [ProcessOutput]()
            
            init(results: [ProcessOutput]) {
                self.results = results
            }
            
            func run(_ code: String) throws -> ProcessOutput {
                results.removeFirst()
            }
        }
        
        struct FileReaderStub: FileReader {
            let result: Result<String, Error>
            func read(_: URL) throws -> String {
                try result.get()
            }
        }
        
        struct PersistorStub: Persistor {
            let result: Result<Void, Error>
            func persist(_ string: String, outputURL: URL) throws {
                try result.get()
            }
        }
        
        struct ClientStub: Client {
            let result: Result<String, Error>
            func send(messages: [Message]) async throws -> String {
                try result.get()
            }
        }
    }


    // Dummies
    extension CoordinatorTests {
        
        struct PersistorDummy: Persistor {
            func persist(_ string: String, outputURL: URL) throws {
            }
        }
        
        struct ClientDummy: Client {
            func send(messages: [Message]) async throws -> String {
                ""
            }
        }
        
        struct RunnerDummy: Runner {
            func run(_ code: String) throws -> ProcessOutput {
                (stdout: "", stderr: "", exitCode: 0)
            }
        }
        
        struct FileReaderDummy: FileReader {
            func read(_ url: URL) throws -> String {
                ""
            }
        }
    }

    // MARK: - Spies
    extension CoordinatorTests {
        class ClientSpy: Client {
            var messages = [[Message]]()
            func send(messages: [Message]) async throws -> String {
                self.messages.append(messages)
                return "any generated code"
            }
        }
    }


    // Tests/CoreTests/UseCases/PersistUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.
    
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import XCTest
    import Core
    
    extension CoordinatorTests {
        
        func test_generateAndSaveCode_deliversErrorOnPersistenceError() async throws {
            let persistor = PersistorStub(result: .failure(anyError()))
            let sut = makeSUT(persistor: persistor)
            await XCTAssertThrowsErrorAsync(
                try await sut.generateAndSaveCode(
                    systemPrompt: anySystemPrompt(),
                    specsFileURL: anyURL(),
                    outputFileURL: anyURL()
                )
            )
        }
        
        func test_generateAndSaveCode_deliversNoErrorOnPersistenceSuccess() async throws {
            let persistor = PersistorStub(result: .success(()))
            let sut = makeSUT(persistor: persistor)
            await XCTAssertNoThrowAsync(
                try await sut.generateAndSaveCode(
                    systemPrompt: anySystemPrompt(),
                    specsFileURL: anyURL(),
                    outputFileURL: anyURL()
                )
            )
        }
        
        private func makeSUT(persistor: Persistor) -> Coordinator {
            Coordinator(
                reader: FileReaderDummy(),
                client: ClientDummy(),
                runner: RunnerDummy(),
                persistor: persistor
            )
        }
    }


    // Tests/CoreTests/UseCases/ReadFileUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.
    
    import XCTest
    import Core
    
    extension CoordinatorTests {
        
        func test_generateAndSaveCode_deliversErrorOnReaderError() async throws {
            let reader = FileReaderStub(result: .failure(anyError()))
            let sut = makeSUT(reader: reader)
            
            await XCTAssertThrowsErrorAsync(
                try await sut.generateAndSaveCode(
                    systemPrompt: anySystemPrompt(),
                    specsFileURL: anyURL(),
                    outputFileURL: anyURL()
                )
            )
        }
        
        func test_generateAndSaveCode_deliversNoErrorOnReaderSuccess() async throws {
            let reader = FileReaderStub(result: .success(""))
            let sut = makeSUT(reader: reader)
            
            await XCTAssertNoThrowAsync(
                try await sut.generateAndSaveCode(
                    systemPrompt: anySystemPrompt(),
                    specsFileURL: anyURL(),
                    outputFileURL: anyURL()
                )
            )
        }
        
        // MARK: - Helpers
        private func makeSUT(reader: FileReader) -> Coordinator {
            Coordinator(
                reader: reader,
                client: ClientDummy(),
                runner: RunnerDummy(),
                persistor: PersistorDummy()
            )
        }
    }


    // Tests/CoreTests/UseCases/RunCodeUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.
    
    // © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.
    
    import XCTest
    import Core
    
    extension CoordinatorTests {
        
        func test_generateAndSaveCode_deliversErrorOnRunnerError() async throws {
            let runner = RunnerStub(result: .failure(anyError()))
            let sut = makeSUT(runner: runner)
            await XCTAssertThrowsErrorAsync(
                try await sut.generateAndSaveCode(
                    systemPrompt: anySystemPrompt(),
                    specsFileURL: anyURL(),
                    outputFileURL: anyURL()
                )
            )
        }
        
        func test_generateAndSaveCode_deliversOutputOnRunnerSuccess() async throws {
            let runner = RunnerStub(result: .success(anySuccessProcessOutput()))
            let sut = makeSUT(runner: runner)
            let result = try await sut.generateAndSaveCode(
                systemPrompt: anySystemPrompt(),
                specsFileURL: anyURL(),
                outputFileURL: anyURL()
            )
            
            let output = result.procesOutput
            anySuccessProcessOutput() .* { expected in
                XCTAssertEqual(output.stderr, expected.stderr)
                XCTAssertEqual(output.stdout, expected.stdout)
                XCTAssertEqual(output.exitCode, expected.exitCode)
            }
        }
        
        
        private func makeSUT(runner: Runner) -> Coordinator {
            Coordinator(
                reader: FileReaderDummy(),
                client: ClientDummy(),
                runner: runner,
                persistor: PersistorDummy()
            )
        }
    }

// chronolock:
    // Package.swift
    // swift-tools-version: 6.1
    // The swift-tools-version declares the minimum version of Swift required to build this package.
    
    import PackageDescription
    
    let package = Package(
        name: "ChronoLock",
        platforms: [.macOS(.v15)],
        dependencies: [
            .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        ],
        targets: [
            // Targets are the basic building blocks of a package, defining a module or a test suite.
            // Targets can depend on other targets in this package and products from dependencies.
            .executableTarget(
                name: "ChronoLock",
                dependencies: [
                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                ]
            ),
            .testTarget(name: "ChronoLockTests", dependencies: ["ChronoLock"])
        ]
    )


    // Sources/ChronoLock.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 31/5/25.
    
    import Foundation
    
    public struct ChronoLock {
        public protocol Encryptor {
            func encrypt<T: Codable>(_ codableObject: T) throws -> Data
        }
        
        public protocol Decryptor {
            func decrypt<T: Decodable>(_ data: Data) throws -> T
        }
        
        public protocol Reader {
            func read(_ fileURL: URL) throws -> Data
        }
        
        public protocol Persister {
            func save(_ data: Data, at outputURL: URL) throws
            func save(_ content: String, at outputURL: URL) throws
        }
        
        public enum Error: Swift.Error, Equatable {
            case alreadyEllapsedDate
            case nonEllapsedDate(TimeInterval)
            case invalidData
        }
        
        let encryptor: Encryptor
        let decryptor: Decryptor
        let reader: Reader
        let persister: Persister
        let currentDate: () -> Date
        
        public init(encryptor: Encryptor, decryptor: Decryptor, reader: Reader, persister: Persister, currentDate: @escaping () -> Date) {
            self.encryptor = encryptor
            self.decryptor = decryptor
            self.reader = reader
            self.persister = persister
            self.currentDate = currentDate
        }
        
        public func encrypt(_ content: String, until date: Date) throws -> Data {
            guard date > currentDate() else { throw Error.alreadyEllapsedDate }
            let item = Item(unlockDate: date, content: content)
            return try encryptor.encrypt(item)
        }
        
        public func decrypt(_ data: Data) throws -> String {
            let decrypted: Item = try decryptor.decrypt(data)
            let now = currentDate()
            guard decrypted.unlockDate <= now else {
                let remaining = decrypted.unlockDate.timeIntervalSince(now)
                throw Error.nonEllapsedDate(remaining)
            }
            return decrypted.content
        }
        
        public struct Item: Codable {
            let unlockDate: Date
            let content: String
            
            public init(unlockDate: Date, content: String) {
                self.unlockDate = unlockDate
                self.content = content
            }
        }
    }

    // MARK: - I/O
    // Infrastructure:
    extension Encryptor: ChronoLock.Decryptor {}
    extension Encryptor: ChronoLock.Encryptor {}
    
    extension FileManager: ChronoLock.Reader {
        public func read(_ fileURL: URL) throws -> Data {
            try Data(contentsOf: fileURL)
        }
    }

    extension FileManager: ChronoLock.Persister {
        public func save(_ data: Data, at outputURL: URL) throws {
            try data.write(to: outputURL, options: .atomic)
        }
        
        public func save(_ content: String, at outputURL: URL) throws {
            try content.write(to: outputURL, atomically: true, encoding: .utf8)
        }
    }

    // Coordinator logic:
    extension ChronoLock {
        public func encryptAndSave(file inputURL: URL, until date: Date, outputURL: URL) throws {
            let data = try reader.read(inputURL)
            guard let content = String(data: data, encoding: .utf8) else {
                throw Error.invalidData
            }
            let encrypted = try encrypt(content, until: date)
            try persister.save(encrypted, at: outputURL)
        }
    }

    extension ChronoLock {
        public func decryptAndSave(file fileURL: URL, at outputURL: URL) throws {
            let data = try reader.read(fileURL)
            let decrypted = try decrypt(data)
            try persister.save(decrypted, at: outputURL)
            
        }
    }


    
    // Sources/CLI.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 31/5/25.
    
    import ArgumentParser
    import Foundation
    
    
    @main
    public struct ChronoLockCLI: ParsableCommand {
        @Option(name: .shortAndLong, help: "Path to input file to encrypt")
        var input: String?
        
        @Option(name: .shortAndLong, help: "Path to output file")
        var output: String?
        
        @Option(name: .shortAndLong, help: "Unlock date (ISO8601)")
        var unlockDate: String?
        
        @Option(name: .shortAndLong, help: "Decrypt mode")
        var mode: Mode?
        
        public var config: Config?
        public init() {}
        
        public struct NonEllapsedDateError: Error {
            public let message: String
        }
        
        public mutating func run() throws {
            let system = Self.makeChronoLock(passphrase: "some really long passphrase", currentDate: config?.currentDate ?? Date.init)
            
            guard let output else {
                throw ValidationError("Missing output path")
            }
            
            guard let input else {
                throw ValidationError("Missing input file for decryption")
            }
            
            switch mode {
            case .decrypt:  try handleDecryption(with: system, i: input, o: output)
            case .encrypt:  try handleEncryption(with: system, i: input, o: output)
            case .none: throw ValidationError("Missing mode. Mode needs to be specified")
            }
        }
    }

    // MARK: - Helpers
    public enum DateParser {
        public static func parse(_ string: String) throws -> Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Europe/Madrid") ?? .current
            
            guard let date = formatter.date(from: string) else {
                throw ValidationError("Invalid date format. Use yyyy-MM-dd")
            }
            
            let calendar = Calendar(identifier: .gregorian)
            var components = calendar.dateComponents(in: formatter.timeZone!, from: date)
            components.hour = 12
            components.minute = 0
            components.second = 0
            
            return calendar.date(from: components)!
        }
        
        public static func timeIntervalAsString( _ timeInterval: TimeInterval) -> String {
            let totalSeconds = Int(timeInterval)
            
            let days = totalSeconds / 86400
            let hours = (totalSeconds % 86400) / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            
            return String(format: "%02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
        }
        
        private static func calendarMiddayReference() -> Date {
            var components = DateComponents()
            components.hour = 12
            components.minute = 0
            components.second = 0
            return Calendar(identifier: .gregorian).date(from: components) ?? Date()
        }
    }

    extension String {
        public static func unreachedDate(_ remaining: String) -> String {
            "Unlock date non reached. Remaining \(remaining)"
        }
    }
    private extension ChronoLockCLI {
        
        func handleDecryption(with system: ChronoLock, i inputPath: String, o outputPath: String) throws {
            do {
                try system.decryptAndSave(
                    file: URL(fileURLWithPath: inputPath),
                    at: URL(fileURLWithPath: outputPath)
                )
                print("🔓 Decrypted to \(outputPath)")
            } catch  {
                switch (error as? ChronoLock.Error) {
                case .nonEllapsedDate(let timeInterval):
                    let formatted = DateParser.timeIntervalAsString(timeInterval)
                    throw NonEllapsedDateError(message: formatted)
                default: throw ValidationError("Decryption error")
                }
            }
        }
        
        func handleEncryption(with system: ChronoLock, i inputPath: String, o outputPath: String) throws {
            guard let unlockDate else {
                throw ValidationError("Missing unlock date")
            }
            let date = try DateParser.parse(unlockDate)
            try system.encryptAndSave(
                file: URL(fileURLWithPath: inputPath),
                until: date,
                outputURL: URL(fileURLWithPath: outputPath)
            )
            print("🔒 Encrypted until \(date) at \(outputPath)")
        }
        
        static func makeChronoLock(passphrase: String, currentDate: @escaping () -> Date) -> ChronoLock {
            ChronoLock(
                encryptor: Encryptor(passphrase: passphrase),
                decryptor: Encryptor(passphrase: passphrase),
                reader: FileManager.default,
                persister: FileManager.default,
                currentDate: currentDate
            )
        }
    }

    extension ChronoLockCLI {
        enum Mode: String, ExpressibleByArgument, Decodable {
            case decrypt
            case encrypt
            init?(argument: String) {
                self.init(rawValue: argument)
            }
        }
        
        public struct Config {
            var currentDate: (() -> Date)?
            public init(currentDate: (() -> Date)? = nil) {self.currentDate = currentDate}
        }
    }


    extension ChronoLockCLI.Config: Decodable {
        public init(from decoder: any Decoder) throws {
            self = Self()
        }
        
    }


    // Sources/Encryptor.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.
    
    import CryptoKit
    import Foundation
    
    public struct Encryptor {
        private let passphrase: String
        
        public init(passphrase: String) {
            self.passphrase = passphrase
        }
        
        private var key: SymmetricKey {
            let keyData = SHA256.hash(data: Data(passphrase.utf8))
            return SymmetricKey(data: keyData)
        }
        
        public func encrypt<T: Encodable>(_ codableObject: T) throws -> Data {
            let encoded = try JSONEncoder().encode(codableObject)
            let sealedBox = try AES.GCM.seal(encoded, using: key)
            guard let combined = sealedBox.combined else {
                throw CombinedEncodingError()
            }
            return combined
        }
        
        struct CombinedEncodingError: Error {}
        
        public func decrypt<T: Decodable>(_ data: Data) throws -> T {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let data = try AES.GCM.open(sealedBox, using: key)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        }
    }


    // Tests/CLITests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 31/5/25.
    import XCTest
    import ChronoLock
    
    class CLITests: XCTestCase {
        func test_cliEncryptsAndDecryptsSucceeds_onEllapsedDate() throws {
            
            let inputURL = uniqueTemporaryURL()
            try "some secret content".write(to: inputURL, atomically: true, encoding: .utf8)
            
            let outputURL = uniqueTemporaryURL()
            let futureDate = "2025-06-01"
            
            var pastCLI = try ChronoLockCLI.parse([
                "--input", inputURL.path,
                "--output", outputURL.path,
                "--mode", "encrypt",
                "--unlock-date", futureDate
            ])
            
            pastCLI.config = ChronoLockCLI.Config(currentDate: { fixedNow() })
            try pastCLI.run()
            
            
            let decryptedURL = uniqueTemporaryURL()
            var futureCLI = try ChronoLockCLI.parse([
                "--input", outputURL.path,
                "--output", decryptedURL.path,
                "--mode", "decrypt"
            ])
            
            futureCLI.config = ChronoLockCLI.Config(currentDate: { try! DateParser.parse(futureDate) })
            try futureCLI.run()
            
            XCTAssertEqual(try String(data: Data(contentsOf: decryptedURL), encoding: .utf8), "some secret content")
        }
        
        func test_cliEncryptsAndDecryptsFailsReturningCorrectFormattedTimeInterval_onNonEllapsedUnlockDate() throws {
            
            let inputURL = uniqueTemporaryURL()
            try "some secret content".write(to: inputURL, atomically: true, encoding: .utf8)
            
            let outputURL = uniqueTemporaryURL()
            let futureDate = "2025-06-01"
            
            var sut = try ChronoLockCLI.parse([
                "--input", inputURL.path,
                "--output", outputURL.path,
                "--mode", "encrypt",
                "--unlock-date", futureDate
            ])
            
            sut.config = ChronoLockCLI.Config(currentDate: { fixedNow() })
            try sut.run()
            
            
            let decryptedURL = uniqueTemporaryURL()
            sut = try ChronoLockCLI.parse([
                "--input", outputURL.path,
                "--output", decryptedURL.path,
                "--mode", "decrypt"
            ])
            sut.config = ChronoLockCLI.Config(currentDate: { fixedNow() })
            
            XCTAssertThrowsError(try sut.run()) { error in
                
                XCTAssertEqual((error as? ChronoLockCLI.NonEllapsedDateError)?.message, "01d 00h 00m 00s")
            }
        }
        
        func uniqueTemporaryURL() -> URL {
            FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        }
    }

    private func fixedNow() -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(
            timeZone: TimeZone(identifier: "Europe/Madrid"),
            year: 2025,
            month: 5,
            day: 31,
            hour: 12,
            minute: 0
        ))!
    }

    private extension Date {
        private func adding(days: Int) -> Date {
            return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
        }
    }


    // Tests/EncryptorTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.
    
    import XCTest
    import ChronoLock
    
    class EncryptorTests: XCTestCase {
        
        
        func test_encryptAndDecrypt_withCodableObjectAndDifferentPassphrase_failsDecryption() throws {
            
            let itemToEncrypt = AnyCodableObject(message: "any message")
            
            let sut1 = Encryptor(passphrase: "passphrase 1")
            let sut2 = Encryptor(passphrase: "passphrase 2")
            
            let encrypted = try sut1.encrypt(itemToEncrypt)
            XCTAssertThrowsError(try {
                let d: AnyCodableObject = try sut2.decrypt(encrypted)
                return d
            }())
        }
        
        func test_encryptAndDecrypt_withCodableObjectAndSamePassphraseReturnsOriginalObject() throws {
            
            let itemToEncrypt = AnyCodableObject(message: "any message")
            let uniquePassPhraseAcrossInstances = "unique passphrase across instances"
            let sut1 = Encryptor(passphrase: uniquePassPhraseAcrossInstances)
            let sut2 = Encryptor(passphrase: uniquePassPhraseAcrossInstances)
            
            let encrypted = try sut1.encrypt(itemToEncrypt)
            let decrypted: AnyCodableObject = try sut2.decrypt(encrypted)
            
            XCTAssertEqual(decrypted, itemToEncrypt)
        }
    }

    private extension EncryptorTests {
        struct AnyCodableObject: Codable, Equatable {
            let message: String
        }
    }


    // Tests/IntegrationTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.
    
    import XCTest
    import ChronoLock
    
    
    
    class IntegrationTests: XCTestCase {
        func test_decrypt_deliversDecryptedMessageOnAlreadyEllapsedDate() throws {
            let timestamp = Date()
            let nonEllapsedDate = timestamp.adding(seconds: 10)
            let pastSUT = makeSUT(currentDate: {timestamp})
            let encrypted = try pastSUT.encrypt("any message to encrypt", until: nonEllapsedDate)
            
            let futureSUT = makeSUT(currentDate: {nonEllapsedDate})
            let decryptedMessage = try futureSUT.decrypt(encrypted)
            XCTAssertEqual(decryptedMessage, "any message to encrypt")
        }
        
        func test_decrypt_failsOnInvalidData() throws {
            let sut = makeSUT()
            let invalidData = Data()
            XCTAssertThrowsError(try sut.decrypt(invalidData))
        }
        
        func test_encryptAndSave_thenDecryptAndSave_restoresOriginalFileContent() throws {
            
            let inputURL = makeTemporaryAleatoryURL()
            let content = "some password"
            try content.write(to: inputURL, atomically: true, encoding: .utf8)
            
            let outputURL = makeTemporaryAleatoryURL()
            
            let timestamp = Date()
            let futureDate = timestamp.adding(seconds: 60)
            let pastSUT = makeSUT(currentDate: {timestamp})
            
            try pastSUT.encryptAndSave(
                file: inputURL,
                until: futureDate,
                outputURL: outputURL
            )
            
            let futureSUT = makeSUT(currentDate: {futureDate})
            
            let decryptedURL = makeTemporaryAleatoryURL()
            try futureSUT.decryptAndSave(file: outputURL, at: decryptedURL)
            let decrypted = try String(data: Data(contentsOf: decryptedURL), encoding: .utf8)
            XCTAssertEqual(decrypted, content)
        }
        
        func test_decrypt_deliversRemainingCountOnNonEllapsedDate() throws {
            let timestamp = Date()
            let nonEllapsedDate = timestamp.adding(seconds: 1)
            let sut = makeSUT(currentDate: { timestamp })
            let encrypted = try sut.encrypt("any message to encrypt", until: nonEllapsedDate)
            XCTAssertThrowsError(try sut.decrypt(encrypted)) { error in
                switch (error as? ChronoLock.Error) {
                case .nonEllapsedDate(let remainingTimeInterval):
                    let expectedTimeInterval = nonEllapsedDate.timeIntervalSince(timestamp)
                    XCTAssertEqual(remainingTimeInterval, expectedTimeInterval)
                default: XCTFail("Expected NonEllapsedDateError, got \(error) instead")
                }
            }
        }
    }

    private extension IntegrationTests {
        
        func makeSUT(currentDate: @escaping () -> Date = Date.init) -> ChronoLock {
            ChronoLock(
                encryptor: Encryptor(passphrase: "any passphrase"),
                decryptor: Encryptor(passphrase: "any passphrase"),
                reader: FileManager.default,
                persister: FileManager.default,
                currentDate: currentDate
            )
        }
        
        func makeTemporaryAleatoryURL() -> URL {
            FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        }
    }


    // Tests/UseCases/DecryptionUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.
    
    import ChronoLock
    import Foundation
    import XCTest
    
    
    extension ChronoLockTests {
        
        func test_decrypt_deliversErrorOnDecryptorError() throws {
            
            struct DecryptorStub: ChronoLock.Decryptor {
                let error: Error
                func decrypt<T: Decodable>(_ data: Data) throws -> T {
                    throw error
                }
            }
            
            let decryptor = DecryptorStub(error: anyError())
            
            let sut = makeSUT(decryptor: decryptor)
            let anyEncryptedData = Data()
            XCTAssertThrowsError(try sut.decrypt(anyEncryptedData))
        }
        
        
        func test_decrypt_deliversErrorOnNonEllapsedDate() throws {
            let timestamp = Date()
            let nonEllapsedDate = timestamp.adding(seconds: 1)
            let sut = makeSUT(currentDate: { timestamp })
            let encrypted = try sut.encrypt("any message to encrypt", until: nonEllapsedDate)
            XCTAssertThrowsError(try sut.decrypt(encrypted)) { error in
                switch (error as? ChronoLock.Error) {
                case .nonEllapsedDate: break
                default: XCTFail("Expected NonEllapsedDateError, got \(error) instead")
                }
            }
        }
    }


    // Tests/UseCases/EncryptionUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.
    
    import XCTest
    import ChronoLock
    
    class ChronoLockTests: XCTestCase {
        
        func test_encrypt_deliversErrorOnEncryptorError() throws {
            struct EncryptorStub: ChronoLock.Encryptor {
                let error: Error
                func encrypt<T>(_ codableObject: T) throws -> Data where T : Decodable, T : Encodable {
                    throw error
                }
            }
            let encryptor = EncryptorStub(error: anyError())
            let sut = makeSUT(encryptor: encryptor)
            
            XCTAssertThrowsError(try sut.encrypt("any message", until: anyDate()))
        }
        
        func test_encrypt_deliversErrorOnAlreadyEllapsedDate() throws {
            
            let timestamp = Date()
            let alreadyEllapsedDate = timestamp.adding(seconds: -1)
            
            let sut = makeSUT(currentDate: {timestamp})
            
            XCTAssertThrowsError(try sut.encrypt("any message", until: alreadyEllapsedDate)) { error in
                XCTAssertEqual(error as? ChronoLock.Error, .alreadyEllapsedDate)
            }
        }
        
        func test_encrypt_deliversNoErrorOnNonEllapsedDateAndEncryptorSuccess() throws {
            
            let timestamp = Date()
            let nonEllapsedDate = timestamp.adding(seconds: 1)
            
            let sut = makeSUT(currentDate: {timestamp})
            
            XCTAssertNoThrow(try sut.encrypt("any message", until: nonEllapsedDate))
        }
    }


    // Tests/UseCases/Helpers/ChronoLockTests+Helpers.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.
    
    import Foundation
    import ChronoLock
    
    // MARK: - Doubles
    // Dummies
    extension ChronoLockTests {
        struct EncryptorDummy: ChronoLock.Encryptor {
            func encrypt<T: Codable>(_ codableObject: T) throws -> Data {
                Data()
            }
        }
        
        
        struct DecryptorDummy: ChronoLock.Decryptor {
            func decrypt<T: Decodable>(_ data: Data) throws -> T {
                return ChronoLock.Item(unlockDate: Date(), content: "any content") as! T
            }
        }
        
        struct ReaderDummy: ChronoLock.Reader {
            func read(_ fileURL: URL) throws -> Data {Data()}
        }
        
        struct PersisterDummy: ChronoLock.Persister {
            func save(_ data: Data, at outputURL: URL) throws {}
            func save(_ content: String, at outputURL: URL) throws {}
        }
    }

    // MARK: - Factories
    extension ChronoLockTests {
        func makeSUT(
            encryptor: ChronoLock.Encryptor = EncryptorDummy(),
            decryptor: ChronoLock.Decryptor = DecryptorDummy(),
            reader: ChronoLock.Reader = ReaderDummy(),
            persister: ChronoLock.Persister = PersisterDummy(),
            currentDate: @escaping () -> Date = Date.init
        ) -> ChronoLock {
            ChronoLock(encryptor: encryptor, decryptor: decryptor, reader: reader, persister: persister, currentDate: currentDate)
        }
        
        func anyError() -> NSError {
            NSError(domain: "any error", code: 0)
        }
        
        func anyDate() -> Date {
            Date()
        } 
    }


    // Tests/UseCases/Helpers/Date+adding.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.
    
    import Foundation
    
    extension Date {
        func adding(seconds: TimeInterval) -> Date {
            return self + seconds
        }
    }


    // Tests/UseCases/IOUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 30/5/25.
    
    import XCTest
    import ChronoLock
    
    extension ChronoLockTests {
        func test_encryptAndSave_deliversErrorOnReadError() throws {
            struct ReaderStub: ChronoLock.Reader {
                let error: Error
                func read(_ fileURL: URL) throws -> Data {
                    throw error
                }
            }
            let reader = ReaderStub(error: anyError())
            let sut = ChronoLock(encryptor: EncryptorDummy(), decryptor: DecryptorDummy(), reader: reader, persister: PersisterDummy(), currentDate: Date.init)
            let anyInputURL = URL(string: "file:///anyinput-url.txt")!
            let anyOutputURL = URL(string: "file:///anyoutput-url.txt")!
            XCTAssertThrowsError(try sut.encryptAndSave(file: anyInputURL, until: anyDate(), outputURL: anyOutputURL))
        }
        
        func test_encryptAndSave_deliversErrorOnSaveError() throws {
            struct PersisterStub: ChronoLock.Persister {
                let error: Error
                func save(_ content: String, at outputURL: URL) throws {
                    throw error
                }
                func save(_ data: Data, at outputURL: URL) throws {
                    throw error
                }
            }
            
            let persister = PersisterStub(error: anyError())
            let sut = ChronoLock(
                encryptor: EncryptorDummy(),
                decryptor: DecryptorDummy(),
                reader: ReaderDummy(),
                persister: persister,
                currentDate: Date.init
            )
            let anyInputURL = URL(string: "file:///anyinput-url.txt")!
            let anyOutputURL = URL(string: "file:///anyoutput-url.txt")!
            XCTAssertThrowsError(try sut.encryptAndSave(file: anyInputURL, until: anyDate(), outputURL: anyOutputURL))
        }
    }

// hummingbird-auth:
    // Package.swift
    // swift-tools-version:6.0
    import PackageDescription
    
    let package = Package(
            name: "MinimalAuthExample",
            platforms: [
                    .macOS(.v14)
            ],
            dependencies: [
                    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
                    .package(url: "https://github.com/hummingbird-project/hummingbird-auth.git", from: "2.0.0"),
                    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
                    .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.0.0"),
            ],
            targets: [
                    .target(name: "GenericAuth", dependencies: [
                            .product(name: "Hummingbird", package: "hummingbird"),
                            .product(name: "HummingbirdBcrypt", package: "hummingbird-auth"),
                            .product(name: "JWTKit", package: "jwt-kit"),
                    ]),
                    .executableTarget(
                            name: "MinimalAuthExample",
                            dependencies: [
                                    "GenericAuth",
                                    .product(name: "ArgumentParser", package: "swift-argument-parser"),
                                    .product(name: "Hummingbird", package: "hummingbird"),
                                    .product(name: "HummingbirdBcrypt", package: "hummingbird-auth"),
                                    .product(name: "JWTKit", package: "jwt-kit"),
                            ],
                            swiftSettings: [
                                    // Enable better optimizations when building in Release configuration. Despite the use of
                                    // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                                    // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                                    .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
                            ]
                    ),
                    .testTarget(
                            name: "MinimalAuthExampleTests",
                            dependencies: [
                                    .target(name: "MinimalAuthExample"),
                                    .product(name: "Hummingbird", package: "hummingbird"),
                                    .product(name: "HummingbirdTesting", package: "hummingbird"),
                            ]
                    )
            ]
    )


    // Sources/GenericAuth/AuthRequest.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    
    public struct AuthRequest: Codable {
            public let email: String
            public let password: String
        
            public init(email: String, password: String) {
                    self.email = email
                    self.password = password
            }
    }


    // Sources/GenericAuth/Controllers/LoginController.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    public struct LoginController<UserId> {
        
            public typealias UserFinder = (_ email: String) throws -> User?
            public struct User {
                    fileprivate let id: UserId
                    fileprivate let hashedPassword: String
                
                    public init(id: UserId, hashedPassword: String) {
                            self.id = id
                            self.hashedPassword = hashedPassword
                    }
            }
        
            private let userFinder: UserFinder
            private let emailValidator: EmailValidator
            private let passwordValidator: PasswordValidator
            private let tokenProvider: AuthTokenProvider<UserId>
            private let passwordVerifier: PasswordVerifier
        
            public init(
                    userFinder: @escaping UserFinder,
                    emailValidator: @escaping EmailValidator,
                    passwordValidator: @escaping PasswordValidator,
                    tokenProvider: @escaping AuthTokenProvider<UserId>,
                    passwordVerifier: @escaping PasswordVerifier
            ) {
                    self.userFinder = userFinder
                    self.emailValidator = emailValidator
                    self.passwordValidator = passwordValidator
                    self.tokenProvider = tokenProvider
                    self.passwordVerifier = passwordVerifier
            }
        
            public func login(email: String, password: String) async throws -> String {
                    guard emailValidator(email) else {
                            throw InvalidEmailError()
                    }
                
                    guard passwordValidator(password) else {
                            throw InvalidPasswordError()
                    }
                
                    guard let user = try userFinder(email) else {
                            throw NotFoundUserError()
                    }
                
                    guard try await passwordVerifier(password, user.hashedPassword) else {
                            throw IncorrectPasswordError()
                    }
                
                    return try await tokenProvider(user.id, email)
            }
    }


    // Sources/GenericAuth/Controllers/RegisterController.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    import Foundation
    
    public typealias UserMaker<UserId> = (_ email: String, _ hashedPassword: String) throws -> UserId
    public typealias UserExists = (_ email: String) throws -> Bool
    
    public struct RegisterController<UserId> {
            private let userMaker: UserMaker<UserId>
            private let userExists: UserExists
            private let emailValidator: EmailValidator
            private let passwordValidator: PasswordValidator
            private let tokenProvider: AuthTokenProvider<UserId>
            private let passwordHasher: PasswordHasher
        
            public init(
                    userMaker: @escaping UserMaker<UserId>,
                    userExists: @escaping UserExists,
                    emailValidator: @escaping EmailValidator,
                    passwordValidator: @escaping PasswordValidator,
                    tokenProvider: @escaping AuthTokenProvider<UserId>,
                    passwordHasher: @escaping PasswordHasher
            ) {
                    self.userMaker = userMaker
                    self.userExists = userExists
                    self.emailValidator = emailValidator
                    self.passwordValidator = passwordValidator
                    self.tokenProvider = tokenProvider
                    self.passwordHasher = passwordHasher
            }
        
            public func register(email: String, password: String) async throws -> String {
                    guard try !userExists(email) else {
                            throw UserAlreadyExists()
                    }
                
                    guard emailValidator(email) else {
                            throw InvalidEmailError()
                    }
                
                    guard passwordValidator(password) else {
                            throw InvalidPasswordError()
                    }
                
                    let hashedPassword = try await passwordHasher(password)
                    let userID = try userMaker(email, hashedPassword)
                    return try await tokenProvider(userID, email)
            }
    }


    // Sources/GenericAuth/Errors.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    public struct InvalidEmailError: Error {}
    public struct InvalidPasswordError: Error {}
    public struct NotFoundUserError: Error {}
    public struct IncorrectPasswordError: Error {}
    public struct UserAlreadyExists: Error {}
    
    
    // Sources/GenericAuth/Hashing/BCryptPasswordHasher.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    
    import HummingbirdBcrypt
    import NIOPosix
    
    public struct BCryptPasswordHasher {
            public init() {}
            public func execute(_ password: String) async throws -> String {
                    return try await NIOThreadPool.singleton.runIfActive { Bcrypt.hash(password, cost: 12) }
            }
    }


    // Sources/GenericAuth/Hashing/BCryptPasswordVerifier.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import HummingbirdBcrypt
    import NIOPosix
    
    public struct BCryptPasswordVerifier {
            public init() {}
            public func execute(_ password: String, _ hash: String) async throws -> Bool {
                    try await NIOThreadPool.singleton.runIfActive {
                            Bcrypt.verify(password, hash: hash)
                    }
            }
    }


    // Sources/GenericAuth/Interactors.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    
    public typealias EmailValidator  = (_ email: String) -> Bool
    public typealias PasswordValidator = (_ password: String) -> Bool
    public typealias AuthTokenProvider<UserId> = (_ userId: UserId, _ email: String) async throws -> String
    public typealias AuthTokenVerifier = (_ token: String) async throws -> UUID
    public typealias PasswordHasher = (_ input: String) async throws -> String
    public typealias PasswordVerifier = (_ password: String, _ hash: String) async throws -> Bool
    
    
    // Sources/GenericAuth/JWT/JWTPayloadData.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    
    import JWTKit
    
    public struct JWTPayloadData: JWTPayload, Equatable {
            var subject: SubjectClaim
            private var expiration: ExpirationClaim
            private var email: String
        
            public init(subject: SubjectClaim, expiration: ExpirationClaim, email: String) {
                    self.subject = subject
                    self.expiration = expiration
                    self.email = email
            }
        
            public func verify(using algorithm: some JWTAlgorithm) async throws {
                    try self.expiration.verifyNotExpired()
            }
    }


    // Sources/GenericAuth/JWT/TokenProvider.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    import JWTKit
    
    public struct TokenProvider {
            private let kid: JWKIdentifier
            private let jwtKeyCollection: JWTKeyCollection
        
            public init(kid: JWKIdentifier, jwtKeyCollection: JWTKeyCollection) {
                    self.kid = kid
                    self.jwtKeyCollection = jwtKeyCollection
            }
        
            public func execute(userId: UUID, email: String) async throws -> String {
                    let payload = JWTPayloadData(
                            subject: .init(value: userId.uuidString),
                            expiration: .init(value: Date(timeIntervalSinceNow: 12 * 60 * 60)),
                            email: email
                    )
                    return try await self.jwtKeyCollection.sign(payload, kid: self.kid)
            }
    }


    // Sources/GenericAuth/JWT/TokenVerifier.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    import JWTKit
    
    public struct TokenVerifier {
            private let jwtKeyCollection: JWTKeyCollection
        
            public init(jwtKeyCollection: JWTKeyCollection) {
                    self.jwtKeyCollection = jwtKeyCollection
            }
        
            public func execute(_ token: String) async throws -> UUID {
                    let payload = try await jwtKeyCollection.verify(token, as: JWTPayloadData.self)
                
                    guard let uuid = UUID(uuidString: payload.subject.value) else {
                            throw InvalidSubjectError()
                    }
                    return uuid
            }
        
            struct InvalidSubjectError: Error {}
    }


    // Sources/MinimalAuthExample/AppComposer.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    import Hummingbird
    import JWTKit
    import GenericAuth
    
    public enum AppComposer {
            static public func execute(with configuration: ApplicationConfiguration, secretKey: HMACKey, userStore: UserStore, recipeStore: RecipeStore) async -> some ApplicationProtocol {
                
                    let jwtKeyCollection = JWTKeyCollection()
                    await jwtKeyCollection.add(
                            hmac: secretKey,
                            digestAlgorithm: .sha256,
                            kid: JWKIdentifier("auth-jwt")
                    )
                
                    let tokenProvider = TokenProvider(kid: JWKIdentifier("auth-jwt"), jwtKeyCollection: jwtKeyCollection)
                    let tokenVerifier = TokenVerifier(jwtKeyCollection: jwtKeyCollection)
                    let passwordHasher = BCryptPasswordHasher()
                    let passwordVerifier = BCryptPasswordVerifier()
                
                    let emailValidator: EmailValidator = { _ in true }
                    let passwordValidator: PasswordValidator = { _ in true }
                
                
                    let registerController = RegisterController<UUID>(
                            userMaker: userStore.createUser,
                            userExists: userStore.findUser |>> isNotNil,
                            emailValidator: emailValidator,
                            passwordValidator: passwordValidator,
                            tokenProvider: tokenProvider.execute,
                            passwordHasher: passwordHasher.execute
                    ) |> RegisterControllerAdapter.init
                
                    let loginController = LoginController<UUID>(
                            userFinder: userStore.findUser |>> UserMapper.map,
                            emailValidator: emailValidator,
                            passwordValidator: passwordValidator,
                            tokenProvider: tokenProvider.execute,
                            passwordVerifier: passwordVerifier.execute
                    ) |> LoginControllerAdapter.init
                
                    let recipesController = RecipesController(store: recipeStore, tokenVerifier: tokenVerifier.execute) |> RecipesControllerAdapter.init
                
                    return Application(router: Router() .* { router in
                            router.post("/register", use: registerController.handle)
                            router.post("/login", use: loginController.handle)
                            router.addRoutes(recipesController.endpoints, atPath: "/recipes")
                    }, configuration: configuration )
            }
    }


    enum UserMapper {
            static func map(_ user: User) -> LoginController<UUID>.User {
                    .init(id: user.id, hashedPassword: user.hashedPassword)
            }
    }

    // MARK:  Functional operators
    infix operator .*: AdditionPrecedence
    
    private func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
            var copy = lhs
            rhs(&copy)
            return copy
    }

    precedencegroup PipePrecedence {
            associativity: left
            lowerThan: LogicalDisjunctionPrecedence
    }

    infix operator |> : PipePrecedence
    func |><A, B>(lhs: A, rhs: (A) -> B) -> B {
            rhs(lhs)
    }

    typealias Throwing<A, B> = (A) throws -> B
    typealias Mapper<A, B> = (A) -> B
    
    infix operator |>>
    private func |>><A, B, C>(lhs:  @escaping Throwing<A, B?>, rhs: @escaping Mapper<B, C>) -> Throwing<A, C?> {
            return { a in
                    try lhs(a).map(rhs)
            }
    }

    private func |>><A, B, C>(lhs:  @escaping Throwing<A, B>, rhs: @escaping Mapper<B, C>) -> Throwing<A, C> {
            return { a in
                    let b = try lhs(a)
                    return rhs(b)
            }
    }

    private func isNotNil<T>(_ value: T?) -> Bool { value != nil }
    
    
    // Sources/MinimalAuthExample/CLI.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import ArgumentParser
    import Foundation
    import Hummingbird
    
    @main
    struct CLI: AsyncParsableCommand {
            @Option(name: .shortAndLong)
            var hostname: String = "127.0.0.1"
        
            @Option(name: .shortAndLong)
            var port: Int = 8080
        
            func run() async throws {
                    let userStoreURL = appDataURL().appendingPathComponent("users.json")
                    let recipeStoreURL = appDataURL().appendingPathComponent("recipes.json")
                
                    let userStore = CodableUserStore(storeURL: userStoreURL)
                    let recipeStore = CodableRecipeStore(storeURL: recipeStoreURL)
                
                    let config = ApplicationConfiguration(address: .hostname(self.hostname, port: self.port), serverName: "Hummingbird")
                
                    return try await AppComposer.execute(
                            with: config,
                            secretKey: "my secret key that should come from deployment environment",
                            userStore: userStore,
                            recipeStore: recipeStore
                    ).runService()
            }
        
            private func cachesDirectory() -> URL {
                    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            }
        
            private func appDataURL() -> URL {
                    cachesDirectory().appendingPathComponent("\(type(of: self))")
            }
    }


    // Sources/MinimalAuthExample/CodableStore.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    
    final class CodableStore<T: Codable> {
            let storeURL: URL
        
            init(storeURL: URL) {
                    self.storeURL = storeURL
            }
        
            func save(_ object: T) throws {
                    var objects = try get()
                    objects.append(object)
                    let data = try JSONEncoder().encode(objects)
                    try data.write(to: storeURL)
            }
        
            func get() throws -> [T] {
                    guard FileManager.default.fileExists(atPath: storeURL.path) else {
                            let directory = storeURL.deletingLastPathComponent()
                            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                            return []
                    }
                    let data = try Data(contentsOf: storeURL)
                    return try JSONDecoder().decode([T].self, from: data)
            }
    }


    // Sources/MinimalAuthExample/Helpers/ResponseGeneratorEncoder.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    
    import Foundation
    import Hummingbird
    
    enum ResponseGeneratorEncoder {
            static func execute<T: Encodable>(_ encodable: T, from request: Request, context: some RequestContext) throws -> Response {
                    let data = try JSONEncoder().encode(encodable)
                    var buffer = ByteBufferAllocator().buffer(capacity: data.count)
                    buffer.writeBytes(data)
                
                    var headers = HTTPFields()
                    headers.reserveCapacity(4)
                    headers.append(.init(name: .contentType, value: "application/json"))
                    headers.append(.init(name: .contentLength, value: buffer.readableBytes.description))
                
                    return Response(
                            status: .ok,
                            headers: headers,
                            body: .init(byteBuffer: buffer)
                    )
            }
    }


    // Sources/MinimalAuthExample/Modules/Auth/Adapters/LoginControllerAdapter.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    import Foundation
    import Hummingbird
    import GenericAuth
    
    struct LoginControllerAdapter: @unchecked Sendable   {
            let controller: LoginController<UUID>
        
            init(_ controller: LoginController<UUID>) {
                    self.controller = controller
            }
        
            func handle(request: Request, context: BasicRequestContext) async throws  -> Response {
                    let registerRequest = try await request.decode(as: AuthRequest.self, context: context)
                    let token = try await controller.login(
                            email: registerRequest.email,
                            password: registerRequest.password
                    )
                    return try ResponseGeneratorEncoder.execute(
                            TokenResponse(token: token),
                            from: request,
                            context: context
                    )
            }
    }


    // Sources/MinimalAuthExample/Modules/Auth/Adapters/RegisterControllerAdapter.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    import Foundation
    import Hummingbird
    import GenericAuth
    
    struct RegisterControllerAdapter: @unchecked Sendable {
            let controller: RegisterController<UUID>
        
            init(_ controller: RegisterController<UUID>) {
                    self.controller = controller
            }
        
            func handle(request: Request, context: BasicRequestContext) async throws  -> Response {
                    let registerRequest = try await request.decode(as: AuthRequest.self, context: context)
                    let token = try await controller.register(email: registerRequest.email, password: registerRequest.password)
                
                    return try ResponseGeneratorEncoder.execute(
                            TokenResponse(token: token),
                            from: request,
                            context: context
                    )
            }
    }


    // Sources/MinimalAuthExample/Modules/Auth/Domain/User.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    import Foundation
    
    public struct User: Equatable {
            public let id: UUID
            public let email: String
            public let hashedPassword: String
        
            public init(id: UUID, email: String, hashedPassword: String) {
                    self.id = id
                    self.email = email
                    self.hashedPassword = hashedPassword
            }
    }


    // Sources/MinimalAuthExample/Modules/Auth/Infrastructure/CodableUserStore.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    
    public class CodableUserStore: UserStore {
            private let store: CodableStore<CodableUser>
            public init(storeURL: URL) {
                    self.store = .init(storeURL: storeURL)
            }
        
            public func getUsers() throws -> [User] {
                    try store.get().map(CodableUserMapper.map)
            }
        
            @discardableResult
            public func createUser(email: String, hashedPassword: String) throws -> UUID {
                    let id = UUID()
                    try store.save(CodableUser(id: id, email: email, hashedPassword: hashedPassword))
                    return id
            }
        
            public func findUser(byEmail email: String) throws -> User? {
                    return try store.get().first { $0.email == email }.map(CodableUserMapper.map)
            }
    }


    private struct CodableUser: Codable {
            let id: UUID
            let email: String
            let hashedPassword: String
    }

    private enum CodableUserMapper {
            static func map(_ user: CodableUser) -> User {
                    User(id: user.id, email: user.email, hashedPassword: user.hashedPassword)
            }
        
            static func map(_ user: User) -> CodableUser {
                    CodableUser(id: user.id, email: user.email, hashedPassword: user.hashedPassword)
            }
    }


    // Sources/MinimalAuthExample/Modules/Auth/Responses/TokenResponse.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    public struct TokenResponse: Codable, Equatable {
            public let token: String
    }


    // Sources/MinimalAuthExample/Modules/Auth/UserStore.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    
    public protocol UserStore {
            func createUser(email: String, hashedPassword: String) throws -> UUID
            func findUser(byEmail email: String) throws -> User?
    }


    // Sources/MinimalAuthExample/Modules/Recipes/Adapters/RecipesControllerAdapter.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    import Hummingbird
    
    struct RecipesControllerAdapter: @unchecked Sendable {
            let controller: RecipesController
        
            init(_ controller: RecipesController) {
                    self.controller = controller
            }
        
            var endpoints: RouteCollection<BasicRequestContext> {
                    return RouteCollection(context: BasicRequestContext.self)
                            .get(use: get)
                            .post(use: post)
            }
        
            func post(request: Request, context: BasicRequestContext) async throws -> Response {
                    guard let authHeader = request.headers[values: .init("Authorization")!].first,
                                authHeader.starts(with: "Bearer "),
                                let token = authHeader.split(separator: " ").last.map(String.init)
                    else {
                            return Response(status: .unauthorized)
                    }
                
                    let recipeRequest = try await request.decode(as: CreateRecipeRequest.self, context: context)
                    let recipe = try await controller.postRecipe(accessToken: token, title: recipeRequest.title)
                    return try ResponseGeneratorEncoder.execute(recipe, from: request, context: context)
            }
        
            func get(request: Request, context: BasicRequestContext) async throws -> Response {
                    guard let authHeader = request.headers[values: .init("Authorization")!].first,
                                authHeader.starts(with: "Bearer "),
                                let token = authHeader.split(separator: " ").last.map(String.init)
                    else {
                            return Response(status: .unauthorized)
                    }
                    let recipes = try await controller.getRecipes(accessToken: token)
                    return try ResponseGeneratorEncoder.execute(recipes, from: request, context: context)
            }
    }


    // Sources/MinimalAuthExample/Modules/Recipes/Controllers/RecipesController.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    import Foundation
    import GenericAuth
    
    public struct RecipesController {
            private let store: RecipeStore
            private let tokenVerifier: AuthTokenVerifier
        
            struct UnauthorizedError: Error {}
            private let jsonDecoder = JSONDecoder()
        
            public init(store: RecipeStore, tokenVerifier: @escaping AuthTokenVerifier) {
                    self.store = store
                    self.tokenVerifier = tokenVerifier
            }
        
            public func postRecipe(accessToken: String, title: String) async throws -> Recipe {
                    let userId = try await tokenVerifier(accessToken)
                    return try store.createRecipe(userId: userId, title: title)
            }
        
            public func getRecipes(accessToken: String) async throws -> [Recipe] {
                    let userId = try await tokenVerifier(accessToken)
                    let recipes = try store.getRecipes()
                
                    return recipes.filter { $0.userId == userId }
            }
    }


    // Sources/MinimalAuthExample/Modules/Recipes/Domain/Recipe.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    import Foundation
    
    public struct Recipe: Equatable, Codable {
            let id: UUID
            public let userId: UUID
            public let title: String
        
            public init(id: UUID, userId: UUID, title: String) {
                    self.id = id
                    self.userId = userId
                    self.title = title
            }
    }


    // Sources/MinimalAuthExample/Modules/Recipes/Infrastructure/CodableRecipeStore.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    
    public class CodableRecipeStore: RecipeStore {
            private let store: CodableStore<CodableRecipe>
        
            public init(storeURL: URL) {
                    self.store = .init(storeURL: storeURL)
            }
        
            public func getRecipes() throws -> [Recipe] {
                    try store.get().map(RecipeMapper.map)
            }
        
            public func createRecipe(userId: UUID, title: String) throws -> Recipe {
                    let recipe = CodableRecipe(id: UUID(), userId: userId, title: title)
                    try store.save(recipe)
                    return RecipeMapper.map(recipe)
            }
    }

    private struct CodableRecipe: Codable {
            let id: UUID
            let userId: UUID
            let title: String
    }

    private enum RecipeMapper {
            static func map(_ recipe: Recipe) -> CodableRecipe {
                    CodableRecipe(
                            id: recipe.id,
                            userId: recipe.userId,
                            title: recipe.title
                    )
            }
        
            static func map(_ recipe: CodableRecipe) -> Recipe {
                    Recipe(
                            id: recipe.id,
                            userId: recipe.userId,
                            title: recipe.title
                    )
            }
    }


    // Sources/MinimalAuthExample/Modules/Recipes/RecipeStore.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    
    import Foundation
    
    public protocol RecipeStore {
            func getRecipes() throws -> [Recipe]
            func createRecipe(userId: UUID, title: String) throws -> Recipe
    }

    // Sources/MinimalAuthExample/Modules/Recipes/Requests/CreateRecipeRequest.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    public struct CreateRecipeRequest: Codable {
            let title: String
            public init(title: String) {
                    self.title = title
            }
    }


    // Tests/Infrastructure/CodableRecipeStoreTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import XCTest
    import MinimalAuthExample
    
    class CodableRecipeStoreTests: XCTestCase {
        
        
        
            override func setUp() {
                    try? FileManager.default.removeItem(at: testSpecificURL())
            }
        
            override func tearDown() {
                    try? FileManager.default.removeItem(at: testSpecificURL())
            }
        
            func test_getRecipes_deliversNoRecipesOnEmptyStore() throws {
                    let sut = CodableRecipeStore(storeURL: testSpecificURL())
                    let recipes = try sut.getRecipes()
                    XCTAssertEqual(recipes, [])
            }
        
            func test_createRecipe_createsRecipe() throws {
                    let sut = CodableRecipeStore(storeURL: testSpecificURL())
                    let recipe = try sut.createRecipe(userId: anyUUID(), title: "any recipe title")
                    XCTAssertTrue(try sut.getRecipes().contains(recipe))
            }
        
            private func anyUUID() -> UUID { UUID() }
        
            private func cachesDirectory() -> URL {
                    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            }
        
            private func testSpecificURL() -> URL {
                    cachesDirectory().appendingPathComponent("\(type(of: self))")
            }
    }


    // Tests/Infrastructure/CodableUserStoreTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import XCTest
    import MinimalAuthExample
    
    class CodableUserStoreTests: XCTestCase {
            override func setUp() {
                    try? FileManager.default.removeItem(at: testSpecificURL())
            }
        
            override func tearDown() {
                    try? FileManager.default.removeItem(at: testSpecificURL())
            }
        
            func test_getUsers_deliversNoUsersOnEmptyStore() throws {
                    let sut = CodableUserStore(storeURL: testSpecificURL())
                    let users = try sut.getUsers()
                    XCTAssertEqual(users, [])
            }
        
            func test_saveUser_savesUser() throws {
                    let sut = CodableUserStore(storeURL: testSpecificURL())
                    let user = anyUser()
                    try sut.createUser(email: user.email, hashedPassword: user.hashedPassword)
                    let users = try sut.getUsers()
                    XCTAssertEqual(users.count, 1)
                    XCTAssertEqual(users.first?.email, user.email)
                    XCTAssertEqual(users.first?.hashedPassword, user.hashedPassword)
            }
        
            func test_findUserByEmail_returnsUserIfExists() throws {
                    let sut = CodableUserStore(storeURL: testSpecificURL())
                    try sut.createUser(email: "hi@crisfe.im", hashedPassword: "any password")
                    let foundUser = try sut.findUser(byEmail: "hi@crisfe.im")
                    XCTAssertEqual(foundUser?.email, "hi@crisfe.im")
                    XCTAssertEqual(foundUser?.hashedPassword, "any password")
            }
        
            private func cachesDirectory() -> URL {
                    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            }
        
            private func testSpecificURL() -> URL {
                    cachesDirectory().appendingPathComponent("\(type(of: self)).json")
            }
    }


    // Tests/Integration/AppTests.swift
    import MinimalAuthExample
    import Hummingbird
    import HummingbirdTesting
    import XCTest
    import GenericAuth
    
    final class AppTests: XCTestCase, @unchecked Sendable {
        
            override func setUp() {
                    try? FileManager.default.removeItem(at: testSpecificURL())
            }
        
            override func tearDown() {
                    try? FileManager.default.removeItem(at: testSpecificURL())
            }
        
            func testApp() async throws {
                    let userStoreURL = testSpecificURL().appendingPathComponent("users.json")
                    let recipeStoreURL = testSpecificURL().appendingPathComponent("recipes.json")
                
                    let userStore = CodableUserStore(storeURL: userStoreURL)
                    let recipeStore = CodableRecipeStore(storeURL: recipeStoreURL)
                
                    let app = await AppComposer.execute(
                            with: .init(),
                            secretKey: "my secret key that should come from deployment environment",
                            userStore: userStore,
                            recipeStore: recipeStore
                    )
                
                    try await app.test(.router) { client in
                            try await assertPostRegisterSucceeds(client, email: "hi@crisfe.im", password: "123456")
                        
                            let token = try await assertPostLoginSucceeds(client, email: "hi@crisfe.im", password: "123456")
                        
                            let recipesState0 = try await assertGetRecipesSucceeds(client, accessToken: token)
                            XCTAssertEqual(recipesState0, [])
                        
                            let recipe = try await assertPostRecipeSucceeds(client, accessToken: token, request: CreateRecipeRequest(title: "Test recipe"))
                        
                            let recipesState1 = try await assertGetRecipesSucceeds(client, accessToken: token)
                            XCTAssertEqual(recipesState1, [recipe])
                    }
            }
    }

    private extension AppTests {
            func assertPostRegisterSucceeds(_ client: TestClientProtocol, email: String, password: String, file: StaticString = #filePath, line: UInt = #line) async throws {
                
                    try await client.execute(
                            uri: "/register",
                            method: .post,
                            headers: [.init("Content-Type")!: "application/json"],
                            body: try bufferFrom(AuthRequest(email: email, password: password))
                    ) { response in
                            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: response.body)
                            XCTAssertFalse(tokenResponse.token.isEmpty, file: file, line: line)
                            XCTAssertEqual(response.status, .ok, file: file, line: line)
                    }
            }
        
            func assertPostLoginSucceeds(_ client: TestClientProtocol, email: String, password: String, file: StaticString = #filePath, line: UInt = #line) async throws -> String {
                    try await client.execute(
                            uri: "/login",
                            method: .post,
                            headers: [.init("Content-Type")!: "application/json"],
                            body: try bufferFrom(AuthRequest(email: email, password: password))
                    ) { response in
                            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: response.body)
                            XCTAssertFalse(tokenResponse.token.isEmpty, file: file, line: line)
                            XCTAssertEqual(response.status, .ok, file: file, line: line)
                            return tokenResponse.token
                    }
            }
        
            func assertPostRecipeSucceeds(_ client: TestClientProtocol, accessToken: String, request: CreateRecipeRequest, file: StaticString = #filePath, line: UInt = #line) async throws -> Recipe {
                    try await client.execute(
                            uri: "/recipes",
                            method: .post,
                            headers: [
                                    .init("Content-Type")!: "application/json",
                                    .init("Authorization")!: "Bearer \(accessToken)"
                            ],
                            body: try bufferFrom(request)
                    ) { response in
                            try JSONDecoder().decode(Recipe.self, from: response.body)
                    }
            }
        
            func assertGetRecipesSucceeds(_ client: TestClientProtocol, accessToken: String, file: StaticString = #filePath, line: UInt = #line) async throws -> [Recipe] {
                    try await client.execute(
                            uri: "/recipes",
                            method: .get,
                            headers: [
                                    .init("Content-Type")!: "application/json",
                                    .init("Authorization")!: "Bearer \(accessToken)"
                            ]
                    ) { response in
                            return try JSONDecoder().decode([Recipe].self, from: response.body)
                    }
            }
    }

    extension AppTests {
        
            private func cachesDirectory() -> URL {
                    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            }
        
            private func testSpecificURL() -> URL {
                    cachesDirectory().appendingPathComponent("\(type(of: self))")
            }
    }

    private func bufferFrom<T: Encodable>(_ payload: T) throws -> ByteBuffer {
            let data = try JSONEncoder().encode(payload)
            var buffer = ByteBufferAllocator().buffer(capacity: data.count)
            buffer.writeBytes(data)
            return buffer
    }


    // Tests/UseCases/Auth/AuthTestCaseDoubles.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    
    import XCTest
    import MinimalAuthExample
    
    class UserStoreSpy: UserStore {
            private(set) var messages = [Message]()
        
            enum Message: Equatable {
                    case findUser(byEmail: String)
                    case saveUser(email: String, hashedPassword: String)
            }
        
            func createUser(email: String, hashedPassword: String) throws -> UUID {
                    messages.append(.saveUser(email: email, hashedPassword: hashedPassword))
                    return UUID()
            }
        
            func findUser(byEmail email: String) throws -> User? {
                    messages.append(.findUser(byEmail: email))
                    return nil
            }
    }

    struct UserStoreStub: UserStore {
            let findUserResult: Result<User?, Error>
            let saveResult: Result<Void, Error>
            func findUser(byEmail email: String) throws -> User? {
                    try findUserResult.get()
            }
        
            func createUser(email: String, hashedPassword: String) throws -> UUID {
                    try saveResult.get()
                    return UUID()
            }
    }


    // Tests/UseCases/Auth/LoginControllerTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    import XCTest
    import GenericAuth
    
    class LoginControllerTests: XCTestCase {
        
            func test_login_deliversErrorOnUserFinder() async throws {
                    let sut = makeSUT(userFinder: { _ in throw self.anyError() })
                    await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password"))
            }
        
            func test_login_deliversErrorOnNotFoundUser() async throws {
                    let sut = makeSUT(userFinder: { _ in return nil })
                    await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
                            XCTAssertTrue(error is NotFoundUserError)
                    }
            }
        
            func test_login_deliversErrorOnInvalidEmail() async throws {
                    let sut = makeSUT(userFinder: { _ in self.anyUser() }, emailValidator: { _ in false })
                    await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
                            XCTAssertTrue(error is InvalidEmailError)
                    }
            }
        
            func test_login_deliversErrorOnInvalidPassword() async throws {
                    let sut = makeSUT(userFinder: { _ in self.anyUser() }, passwordValidator: { _ in false })
                    await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
                            XCTAssertTrue(error is InvalidPasswordError)
                    }
            }
        
            func test_login_deliversErrorOnPasswordVerifierError() async throws {
                    let sut = makeSUT(userFinder: { _ in self.anyUser() }, passwordVerifier: { _, _ in throw self.anyError() })
                    await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password"))
            }
        
            func test_login_deliversErrorOnIncorrectPassword() async throws {
                    let sut = makeSUT(userFinder: { _ in self.anyUser() }, passwordVerifier: { _, _ in false })
                    await XCTAssertThrowsErrorAsync(try await sut.login(email: "any-email", password: "any-password")) { error in
                            XCTAssertTrue(error is IncorrectPasswordError)
                    }
            }
        
            func test_login_deliversProvidedTokenOnCorrectCredentialsAndFoundUser() async throws {
                    let sut = makeSUT(userFinder: { _ in self.anyUser() }, tokenProvider: { _,_ in "any-provided-token" })
                    let token = try await sut.login(email: "any-email", password: "any-password")
                    XCTAssertEqual(token, "any-provided-token")
            }
        
            func test_login_passwordIsValidatedWithPasswordValidator() async throws {
                    var password: String?
                    let sut = makeSUT(passwordValidator: {
                            password = $0
                            return true
                    })
                
                    _ = try? await sut.login(email: "any email", password: "any password")
                    XCTAssertEqual(password, "any password")
            }
        
            func test_login_emailIsValidatedWithEmailValidator() async throws {
                    var email: String?
                    let sut = makeSUT(emailValidator: {
                            email = $0
                            return true
                    })
                
                    _ = try? await sut.login(email: "any email", password: "any password")
                    XCTAssertEqual(email, "any email")
            }
        
            func makeSUT(
                    userFinder: @escaping LoginController<UUID>.UserFinder = { _ in nil },
                    emailValidator: @escaping EmailValidator = { _ in true },
                    passwordValidator: @escaping PasswordValidator = { _ in true },
                    tokenProvider: @escaping AuthTokenProvider<UUID> = { _,_ in "any-token" },
                    passwordVerifier: @escaping PasswordVerifier = { _,_ in true }
            ) -> LoginController<UUID> {
                    return LoginController<UUID>(
                            userFinder: userFinder,
                            emailValidator: emailValidator,
                            passwordValidator: passwordValidator,
                            tokenProvider: tokenProvider,
                            passwordVerifier: passwordVerifier
                    )
            }
        
        
            func anyUser() -> LoginController<UUID>.User {
                    .init(id: UUID(), hashedPassword: "any hashed password")
            }
    }


    // Tests/UseCases/Auth/RegisterControllerTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.
    
    import XCTest
    import GenericAuth
    
    class RegisterControllerTests: XCTestCase {
        
            func test_register_deliversErrorOnStoreSaveError() async throws {
                    let sut = makeSUT(userMaker: { _,_ in throw self.anyError() }, userExists: { _ in true })
                    await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password"))
            }
        
            func test_register_deliversErrorOnAlreadyExistingUser() async throws {
                    let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in true })
                    await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
                            XCTAssertTrue(error is UserAlreadyExists)
                    }
            }
        
            func test_register_deliversErrorOnInvalidEmail() async throws {
                    let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in false }, emailValidator: { _ in false })
                    await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
                        
                            XCTAssertTrue(error is InvalidEmailError)
                    }
            }
        
            func test_register_deliversErrorOnInvalidPassword() async throws {
                    let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in false }, passwordValidator: { _ in false })
                    await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password")) { error in
                            XCTAssertTrue(error is InvalidPasswordError)
                    }
            }
        
            func test_register_deliversProvidedTokenOnNewUserValidCredentialsAndUserStoreSuccess() async throws {
                    let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in false }, tokenProvider: { _,_ in "any-provided-token" })
                    let token = try await sut.register(email: "any-email", password: "any-password")
                    XCTAssertEqual(token, "any-provided-token")
            }
        
            func test_register_deliversErrorOnHasherError() async throws {
                    let sut = makeSUT(userMaker: { _,_ in self.anyUser().id }, userExists: { _ in true }, hasher: { _ in throw self.anyError() })
                    await XCTAssertThrowsErrorAsync(try await sut.register(email: "any-email", password: "any-password"))
            }
        
        
            func makeSUT(
                    userMaker: @escaping UserMaker<UUID>,
                    userExists: @escaping UserExists,
                    emailValidator: @escaping EmailValidator = { _ in true },
                    passwordValidator: @escaping PasswordValidator = { _ in true },
                    tokenProvider: @escaping AuthTokenProvider<UUID> = { _,_ in "any" },
                    hasher: @escaping PasswordHasher = { $0 }
            ) -> RegisterController<UUID> {
                    return RegisterController<UUID>(
                            userMaker: userMaker,
                            userExists: userExists,
                            emailValidator: emailValidator,
                            passwordValidator: passwordValidator,
                            tokenProvider: tokenProvider,
                            passwordHasher: hasher,
                    )
            }
    }


    // Tests/UseCases/Helpers/XCTAssertThrowsErrorAsync.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    
    import XCTest
    import MinimalAuthExample
    
    func XCTAssertThrowsErrorAsync<T>(
            _ expression: @autoclosure () async throws -> T,
            _ message: @autoclosure () -> String = "",
            file: StaticString = #filePath,
            line: UInt = #line,
            _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
            do {
                    _ = try await expression()
                    XCTFail("Expected error to be thrown, but no error was thrown. \(message())", file: file, line: line)
            } catch {
                    errorHandler(error)
            }
    }


    // Tests/UseCases/Helpers/XCTestCaseHelpers.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import XCTest
    import MinimalAuthExample
    
    extension XCTestCase {
        
            func anyError() -> NSError {
                    NSError(domain: "any error", code: 0)
            }
        
            func anyRecipe() -> Recipe {
                    Recipe(id: UUID(), userId: UUID(), title: "any-title")
            }
        
            func anyUser() -> User {
                    User(id: UUID(), email: "any-user@email.com", hashedPassword: "any-hashed-password")
            }
    }


    // Tests/UseCases/Recipes/CreateRecipesUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import XCTest
    import MinimalAuthExample
    import GenericAuth
    
    class CreateRecipesUseCaseTests: XCTestCase {
            func test_postRecipe_deliversErrorOnStoreError() async throws {
                    let store = RecipeStoreStub(result: .failure(anyError()))
                    let sut = makeSUT(store: store)
                    await XCTAssertThrowsErrorAsync(try await sut.postRecipe(accessToken: "any valid access token", title: "Fried chicken")) { error in
                            XCTAssertEqual(error as NSError, anyError())
                    }
            }
        
            func test_postRecipe_deliversErrorOnInvalidAccessToken() async throws {
                    let store = RecipeStoreStub(result: .success(anyRecipe()))
                    let sut = makeSUT(store: store, tokenVerifier: { _ in throw self.anyError() })
                
                    await XCTAssertThrowsErrorAsync(try await sut.postRecipe(accessToken: "any valid access token", title: "Fried chicken")) { error in
                            XCTAssertEqual(error as NSError, anyError())
                    }
            }
        
            func test_postRecipe_deliversRecipeOnSuccess() async throws {
                    let stubbedRecipe = anyRecipe()
                    let store = RecipeStoreStub(result: .success(stubbedRecipe))
                    let sut = makeSUT(store: store)
                
                    let recipe = try await sut.postRecipe(accessToken: "any valid access token", title: "Fried chicken")
                
                    XCTAssertEqual(recipe, stubbedRecipe)
            }
        
            func test_postRecipe_createsRecipeWithUserIdFromToken() async throws {
                    let stubbedUserId = UUID()
                    let store = RecipeStoreSpy(result: .success(anyRecipe()))
                    let sut = makeSUT(store: store, tokenVerifier: { _ in stubbedUserId })
                
                    let _ = try await sut.postRecipe(accessToken: "any valid access token", title: "Fried chicken")
                
                    XCTAssertEqual(store.capturedMessages, [
                            .init(userId: stubbedUserId, title: "Fried chicken")
                    ])
            }
        
            func makeSUT(
                    store: RecipeStore,
                    tokenVerifier: @escaping AuthTokenVerifier = { _ in UUID() },
            ) -> RecipesController {
                    RecipesController(store: store, tokenVerifier: tokenVerifier)
            }
        
            struct RecipeStoreStub: RecipeStore {
                    let result: Result<Recipe, Error>
                
                    func getRecipes() throws -> [Recipe] {
                            fatalError("should never be called within test case context")
                    }
                
                    func createRecipe(userId: UUID, title: String) throws -> Recipe {
                            try result.get()
                    }
            }
    }


    // Tests/UseCases/Recipes/GetRecipesUseCaseTests.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import XCTest
    import MinimalAuthExample
    import GenericAuth
    
    class GetRecipesUseCaseTests: XCTestCase {
        
            func test_getRecipes_deliversErrorOnStoreError() async throws {
                    let store = RecipeStoreStub(result: .failure(anyError()))
                    let sut = makeSUT(store: store)
                    await XCTAssertThrowsErrorAsync(try await sut.getRecipes(accessToken: "any valid access token"))
            }
        
            func test_getRecipes_deliversErrorOnTokenVerifierError() async throws {
                    let store = RecipeStoreStub(result: .success([]))
                    let sut = makeSUT(store: store, tokenVerifier: { _ in throw self.anyError() })
                    await XCTAssertThrowsErrorAsync(try await sut.getRecipes(accessToken: "any invalid access token"))
            }
        
            func test_getRecipes_deliversErrorOnInvalidAccessToken() async throws {
                    let store = RecipeStoreStub(result: .success([]))
                    let sut = makeSUT(store: store, tokenVerifier: { _ in throw self.anyError() })
                    await XCTAssertThrowsErrorAsync(try await sut.getRecipes(accessToken: "any invalid access token"))
            }
        
            func test_getRecipes_deliversUserRecipesOnCorrectAccessToken() async throws {
                    let user = User(id: UUID(), email: "any@email.com", hashedPassword: "1234")
                    let otherUserRecipes = [anyRecipe(), anyRecipe(), anyRecipe()]
                    let userRecipes = [Recipe(id: UUID(), userId: user.id, title: "any-title")]
                    let store = RecipeStoreStub(result: .success(otherUserRecipes + userRecipes))
                    let sut = makeSUT(store: store, tokenVerifier: { _ in user.id })
                    let recipes = try await sut.getRecipes(accessToken: "anyvalidtoken")
                    XCTAssertEqual(userRecipes, recipes)
            }
        
            func makeSUT(
                    store: RecipeStore,
                    tokenVerifier: @escaping AuthTokenVerifier = { _ in UUID() },
            ) -> RecipesController {
                    return RecipesController(
                            store: store,
                            tokenVerifier: tokenVerifier,
                    )
            }
        
            struct RecipeStoreStub: RecipeStore {
                    let result: Result<[Recipe], Error>
                
                    func getRecipes() throws -> [Recipe] {
                            try result.get()
                    }
                
                    func createRecipe(userId: UUID, title: String) throws -> Recipe {
                            fatalError("should not be called in current test context")
                    }
            }
    }


    // Tests/UseCases/Recipes/RecipesTestCaseDoubles.swift
    // © 2025  Cristian Felipe Patiño Rojas. Created on 21/6/25.
    
    import Foundation
    import MinimalAuthExample
    
    class RecipeStoreSpy: RecipeStore {
            let result: Result<Recipe, Error>
            struct CreateRecipeCommand: Equatable {
                    let userId: UUID
                    let title: String
            }
        
            var capturedMessages = [CreateRecipeCommand]()
        
            init(result: Result<Recipe, Error>) {
                    self.result = result
            }
        
            func getRecipes() throws -> [Recipe] {
                    fatalError("should never be called within test case context")
            }
        
            func createRecipe(userId: UUID, title: String) throws -> Recipe {
                    capturedMessages.append(.init(userId: userId, title: title))
                    return try result.get()
            }
    }

