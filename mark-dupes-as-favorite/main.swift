import Foundation
import Photos


func fetchPhotos() {
    let group = DispatchGroup()
    
    group.enter()
    // Request the user's authorization to access photos
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        if status == .authorized {
            // The user has authorized access to photos
            
            // Fetch all photos in the library
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            var dupes: [TimeInterval: Bool] = [:]
            
            
            // Iterate over each photo
            fetchResult.enumerateObjects { asset, _, _ in
                // Handle each photo asset here
                // asset.localIdentifier can be used to uniquely identify the photo
                
                // Example: Retrieve the image data for the photo
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                
                guard let t  = asset.creationDate?.timeIntervalSince1970 else {
                    print("creationDate not found")
                    return
                }
                
                if let _ = dupes[t] {
                    group.enter()
                    PHPhotoLibrary.shared().performChanges({
                        // Create a change request
                        let changeRequest = PHAssetChangeRequest(for: asset)
                        changeRequest.isFavorite = true
                    })   { success, error in
                        group.leave()
                        if success {
                            print("Photo favorited successfully.")
                        } else {
                            print("Error favoriting the photo: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                } else {
                    dupes[t] = true
                }
            }
        } else {
            // The user has denied access to photos or has not yet responded
            // Handle this scenario gracefully
            print(status)
        }
        group.leave()
    }

    group.wait()
}

fetchPhotos()
