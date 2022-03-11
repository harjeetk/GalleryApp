//
//  GalleryDataSource.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import UIKit
import Foundation

class GalleryDataSource: NSObject{
    
    var viewModel = GalleryViewModel()
    var collectionView: UICollectionView?
    var viewController: UIViewController?
    var isGrid = false
    
    init(_ viewModel: GalleryViewModel,collectionView: UICollectionView?,controller: UIViewController) {
        self.viewModel = viewModel
        self.collectionView = collectionView
        self.viewController = controller
        super.init()
        self.setupCollectionView()
    }
    
    fileprivate func setupCollectionView(){
        ["GridPhotoCollectionViewCell",
        "ListPhotoCollectionViewCell"].forEach { identifier in
            self.collectionView?.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        }
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.reloadData()
    }
    
    func changeViewStyle(_ isGrid: Bool){
        self.isGrid = isGrid
        self.collectionView?.reloadData()
    }
}

extension GalleryDataSource: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = self.viewModel.getPhoto(at: indexPath.item){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
            controller.modalTransitionStyle = .crossDissolve
            controller.objectPhoto = data
            self.viewController?.present(controller, animated: true, completion: nil)
        }
    }
}

extension GalleryDataSource: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getCountOfPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGrid{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridPhotoCollectionViewCell", for: indexPath) as! GridPhotoCollectionViewCell
            if let data = self.viewModel.getPhoto(at: indexPath.item){
                cell.loadData(data)
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListPhotoCollectionViewCell", for: indexPath) as! ListPhotoCollectionViewCell
            if let data = self.viewModel.getPhoto(at: indexPath.item){
                cell.loadData(data)
            }
            return cell
        }
    }
}

extension GalleryDataSource: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGrid{
            let width = UIScreen.main.bounds.width/2
            return CGSize(width: width, height: width)
        }else{
            let width = UIScreen.main.bounds.width
            return CGSize(width: width, height: 100)
        }
    }
}
