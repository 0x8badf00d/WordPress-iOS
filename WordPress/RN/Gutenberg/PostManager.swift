
import Foundation

protocol GBPostManagerDelegate: class {
    func saveButtonPressed(with content: String)
    func closeButtonPressed()
}

@objc (GBPostManager)
public class GBPostManager: NSObject, RCTBridgeModule {
    public static func moduleName() -> String! {
        return "GBPostManager"
    }

    var delegate: GBPostManagerDelegate?

    @objc(savePost:)
    func savePost(with content: String) {
        delegate?.saveButtonPressed(with: content)
    }

    public static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
