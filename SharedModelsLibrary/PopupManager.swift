import Observation
import Foundation

@Observable
class PopupManager {
    static let shared = PopupManager()
    
    var isPopupVisible: Bool = false
    
    func showPopup() {
        isPopupVisible = true
    }
    
    func hidePopup() {
        isPopupVisible = false
    }
}
