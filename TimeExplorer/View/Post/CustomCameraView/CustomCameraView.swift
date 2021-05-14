import SwiftUI
import AVFoundation

enum CameraMode:String{
    case photo = "Photo"
    case video = "Video"
}

enum TypeCamera:String{
    case front = "front"
    case back = "back"
}

enum CaptureMode:String{
    case photo = "Photo"
    case video = "Video"
}

struct CustomCameraRepresentable: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var didTapCapture: Bool
    @Binding var swapCamera:TypeCamera
    @Binding var captureMode:CameraMode
    @Binding var videoURL:URL?
    
    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.photodelegate = context.coordinator
        controller.videodelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        
        if(self.didTapCapture) {
            if self.captureMode == .photo{
                cameraViewController.capturePhoto()
            }else if self.captureMode == .video{
                cameraViewController.startVideoCapture()
            }
        }else{
            if self.captureMode == .video{
                cameraViewController.stopVideoCapture()
            }
        }
        
        
        
        if(self.swapCamera != cameraViewController.type){
            cameraViewController.swapCamera(type: self.swapCamera)
        }
        
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
//    AVCaptureVideoDataOutputSampleBufferDelegate
    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
        
        let parent: CustomCameraRepresentable
//        let videoConverter:VideoWriter = .init()
        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
            super.init()
//            self.videoConverter.onRecordingEnded = self.updateURL
            
        }
        
        var mode:CameraMode{
            get{
                return self.parent.captureMode
            }
            set{
                self.parent.captureMode = newValue
            }
        }
        
        var capture:Bool{
            get{
                return self.parent.didTapCapture
            }
            set{
                self.parent.didTapCapture = newValue
            }
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            self.capture = false
            if let photo = photo.fileDataRepresentation(){
                self.parent.image = UIImage(data: photo)
            }
        }
        
        func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
//            output.maxRecordedDuration = CMTimeMake(value: 60000, timescale: 600)
            print("\(output.recordedDuration)")
            print("Video is starting to record to location :\(fileURL)")
        }
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
            if error == nil{
                print("\(output.recordedDuration)")
                self.updateURL(outputFileURL)
//                self.capture = false
            }else{
                print("error : \(error!.localizedDescription)")
            }
        }
        
//        func capturePhoto(_ sampleBuffer:CMSampleBuffer){
//            if self.capture{
//                self.capture = false
//                guard let image = sampleBuffer.getImageFromBuffer() else {return}
//                self.parent.image = image
//            }
//
//        }
//
//        func captureVideo(_ sampleBuffer:CMSampleBuffer){
//            if capture{
//                if self.videoConverter.captureMode == .idle{
//                    self.videoConverter.captureMode = .starting
//                }
//                switch(self.videoConverter.captureMode){
//                    case .starting:
//                        self.videoConverter.videoBuffer = sampleBuffer
//                        self.videoConverter.setupVideoConverter()
//                        break
//                    case .capturing:
//                        self.videoConverter.videoBuffer = sampleBuffer
//                        self.videoConverter.captureVideo()
//                        break
//                    default:
//                        break
//                }
//
//            }else{
//                if self.videoConverter.captureMode != .ending && self.videoConverter.captureMode != .idle{
//                    self.videoConverter.endCapturingVideo()
//                }
//            }
//        }
//
//        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//            switch(self.mode){
//                case .photo:
//                    self.capturePhoto(sampleBuffer)
//                    break
//                case .video:
//                    self.captureVideo(sampleBuffer)
//                    break
//                default:
//                    break
//            }
//        }
        
        func updateURL(_ url:URL){
            self.parent.videoURL = url
        }

    }
}

class CustomCameraController: UIViewController {

    var image: UIImage?
    
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var videoOutput : AVCaptureMovieFileOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var type:TypeCamera = .back
    
    //DELEGATE
    var photodelegate: AVCapturePhotoCaptureDelegate?
    var videodelegate : AVCaptureFileOutputRecordingDelegate?
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setup()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopRunning()
    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.stopRunning()
//    }
    
    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInput()
        setupOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
    }
    
    func capturePhoto(){
        if let photo = self.photoOutput{
            photo.capturePhoto(with: .init(), delegate: photodelegate!)
        }
    }
    
    func startVideoCapture(){
        guard let video = self.videoOutput, !video.isRecording else {return}
        var filename = UUID().uuidString
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(filename).mov")
        video.startRecording(to: url, recordingDelegate: videodelegate!)
    }
    
    func stopVideoCapture(){
        guard let video = self.videoOutput else {return}
        if video.isRecording{
            video.stopRecording()
        }
    }
    
    
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: AVCaptureDevice.Position.unspecified)
        for device in deviceDiscoverySession.devices {
            
            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
                
            case AVCaptureDevice.Position.back:
                self.backCamera = device
                
            default:
                break
            }
        }
        
        self.currentCamera = self.type == .back ? self.backCamera : self.frontCamera
    }
    
    func swapCamera(type:TypeCamera){
        if(type != self.type){
            self.type = type
            print("Change Cam on CVC \(self.type)")
            if type == .back{
                self.currentCamera = self.backCamera
                print("Swapping to back")
            }else if type == .front{
                self.currentCamera = self.frontCamera
                print("Swapping to front")
            }
            self.changeCamera()
        }
    }
    
    func setupInput(){
        
        do{
            // Adding Video Input
            if let currentCamera = currentCamera{
                let videoInput = try AVCaptureDeviceInput(device: currentCamera)
                self.captureSession.addInput(videoInput)
            }
            
            if let audioDevice = AVCaptureDevice.default(for: .audio){
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                self.captureSession.addInput(audioInput)
            }
            
        }catch{
            print(error)
        }
        
    }
    
    
    func setupOutput(){
        
        // Adding Video+Audio Output
        self.videoOutput = .init()
        videoOutput?.maxRecordedDuration = CMTime(value: 60000, timescale: 600)
        if self.captureSession.canAddOutput(self.videoOutput!){
            self.captureSession.addOutput(self.videoOutput!)
        }
        
        // Adding Photo Output
        self.photoOutput = .init()
        if self.captureSession.canAddOutput(self.photoOutput!){
            self.captureSession.addOutput(self.photoOutput!)
        }
        self.captureSession.commitConfiguration()
    
    }
        
    func changeCamera(){
        do{
            self.captureSession.removeInput(self.captureSession.inputs.first!)
            let captureDeviceInput = try AVCaptureDeviceInput(device: self.currentCamera!)
            self.captureSession.addInput(captureDeviceInput)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func setupPreviewLayer()
    {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }
    
    func stopRunning(){
        self.captureSession.stopRunning()
        self.captureSession.inputs.forEach { (input) in
            self.captureSession.removeInput(input)
        }
    }
        
}


struct CaptureButtonView: View {
    @State private var animationAmount: CGFloat = 1
    var v1:some View{
        Image(systemName: "video").font(.largeTitle)
            .padding(30)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.red)
                    .scaleEffect(animationAmount)
                    .opacity(Double(2 - animationAmount))
                    .animation(Animation.easeOut(duration: 1)
                                .repeatForever(autoreverses: false))
            )
            .onAppear
            {
                self.animationAmount = 2
            }
    }
    
    var v2:some View{
        Circle()
            .fill(Color.white)
            .frame(width: 55, height: 55, alignment: .center)
            .padding(.vertical)
//            .onAppear
//            {
//                self.animationAmount = 2
//            }
    }
    
    var body: some View {
        self.v2
    }
}

