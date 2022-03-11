//
//  ViewController.swift
//  
//
//  Created by Harjeet on 11/03/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionViewGallery: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var viewModel = GalleryViewModel()
    var dataSource: GalleryDataSource? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gallery"
        bindViewModel()
        setupDataSource()
        searchBar.showsCancelButton = false
        searchBar.delegate = self
    }
    
    func bindViewModel(){
        viewModel.fetchPhotos()
        viewModel.isDataFetched.bind { success in
            if success{
                self.collectionViewGallery.reloadData()
            }
        }
        viewModel.alertMessage.bind { alert in
            alert.showAlert(controller: self)
        }
    }

    fileprivate func setupDataSource(){
        dataSource = GalleryDataSource(self.viewModel, collectionView: collectionViewGallery, controller: self)
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0://list
            self.dataSource?.changeViewStyle(false)
        case 1://Grid
            self.dataSource?.changeViewStyle(true)
        default:
            break;
        }
    }
}

extension ViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.viewModel.enableSearch(true)
        self.collectionViewGallery.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.viewModel.enableSearch(false)
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        self.collectionViewGallery.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.enableSearch(false)
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        self.collectionViewGallery.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.enableSearch(true)
        self.searchBar.showsCancelButton = true
        self.viewModel.searchPhotoViaName(text: searchText)
        self.collectionViewGallery.reloadData()
        
    }
}
