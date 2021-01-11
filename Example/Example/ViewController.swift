import UIKit
import Dreams

//
// This ViewController is initialized and presented by InterfaceBuilder (Main.storyboard)
//
class ViewController: UIViewController {
    @IBAction func presentDreams() {
        let vc = DreamsViewController()
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .fullScreen
        present(nvc, animated: true)
        vc.open(credentials: DreamsCredentials(idToken: "idToken"), locale: Locale.current)
    }
}

//
// Example implementation of DreamsDelegate
//
extension ViewController: DreamsDelegate {
    func handleDreamsCredentialsExpired(completion: (DreamsCredentials) -> Void) {
        print("IdToken expired event received")
        
        completion(DreamsCredentials(idToken: "newtoken"))
    }
    
    func handleDreamsTelemetryEvent(name: String, payload: [String : Any]) {
        print("Telemetry event received: \(name) with payload: \(payload)")
    }
    
    func handleDreamsAccountProvisioning(completion: () -> Void) {
        print("Account Provisioning event received")

        completion()
    }
    
    func handleExitRequest() {
        // For example:
        presentedViewController?.dismiss(animated: true, completion: nil)
        print("Exit requested event received")
    }
}
