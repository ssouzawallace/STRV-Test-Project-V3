import Foundation
import Firebase
import FirebaseFirestore

class FirebaseUtils {
    
    private init() { /* do nothing */ }
    
    // MARK: Public API
    
    static let sharedInstance = FirebaseUtils()
    
    func configure() {
        FirebaseApp.configure()
    }
    
    func log(userEmail: String, temperature: Double, latitude: Double, longitude: Double) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("weather").addDocument(data: [
            "email": userEmail,
            "temperature": temperature,
            "latitude": latitude,
            "longitude": longitude
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}
