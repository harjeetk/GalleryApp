//
//  GalleryViewModel.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import Foundation

class GalleryViewModel{
    
    private var arrayPhotos = [PhotoModel]()
    private var arraySearchedPhotos = [PhotoModel]()
    private var isSearchActive = false
    
    var alertMessage: Dynamic<AlertMessage> = Dynamic(AlertMessage())
    var isDataFetched: Dynamic<Bool> = Dynamic(false)
    
    init(){
        
    }
    
    func fetchPhotos(){
        let requestManager = RequestManager()
        let queryParameters: [String:Any] = ["page": 1,
                               "client_id": "jvpdmE4hTVPAX5aRxMjB9m-pQyNbj2rCawlbzJ_O3CI"]
        requestManager.call(type: .fetchPhotos, queryParameter: queryParameters) { (response :Result<[PhotoModel], AlertMessage>) in
            switch response{
                
            case .success(let data):
                self.arrayPhotos = data
                self.isDataFetched.value = true
            case .failure(let alert):
                self.alertMessage.value = alert
            }
        }
    }
}

extension GalleryViewModel{
    
    func getCountOfPhotos() -> Int{
        return isSearchActive ? self.arraySearchedPhotos.count : self.arrayPhotos.count
    }
    
    func getPhoto(at index: Int) -> PhotoModel?{
        return isSearchActive ? self.arraySearchedPhotos[index] : self.arrayPhotos[index]
    }
    
    func enableSearch(_ value: Bool){
        self.isSearchActive = value
    }
    
    func searchPhotoViaName(text: String){
        self.arraySearchedPhotos = self.arrayPhotos.filter({ model in
            return model.user?.name?.lowercased().contains(text.lowercased()) ?? false
        })
    }
}
