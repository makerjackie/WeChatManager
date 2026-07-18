import Foundation
import Security

struct CodeSignatureInspector {
    func teamIdentifier(for applicationURL: URL) -> String? {
        var staticCode: SecStaticCode?
        let creationStatus = SecStaticCodeCreateWithPath(
            applicationURL as CFURL,
            SecCSFlags(),
            &staticCode
        )
        guard creationStatus == errSecSuccess, let staticCode else { return nil }

        var signingInformation: CFDictionary?
        let informationStatus = SecCodeCopySigningInformation(
            staticCode,
            SecCSFlags(rawValue: kSecCSSigningInformation),
            &signingInformation
        )
        guard informationStatus == errSecSuccess,
              let dictionary = signingInformation as? [CFString: Any] else {
            return nil
        }

        return dictionary[kSecCodeInfoTeamIdentifier] as? String
    }
}
