//
//  CollectionViewController.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 23.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UISearchBarDelegate {
    
    var searchController: UISearchController!
    var searchPhrase = String()
    var food2ForkImagesResult = [ListRecipe]()    // For storing image titles and URLs
    var recipeToPass: ListRecipe?
    
    private var emptySearchView: EmptySearchView {
        return self.view as! EmptySearchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emptySearchView = UIView.instanceFromNib() as EmptySearchView
        self.collectionView?.backgroundView = emptySearchView
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.titleView = self.searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.keyboardAppearance = .alert
        self.searchController.dimsBackgroundDuringPresentation = false
        
        navigationController?.navigationBar.barTintColor = .foodBlack
        navigationController?.navigationBar.tintColor = .foodGreen
        
        let nib = UINib(nibName: Constants.StringLiterals.ReuseCollectionCellIdentifier, bundle: nil)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: Constants.StringLiterals.ReuseCollectionCellIdentifier)
        self.collectionView?.backgroundColor = .foodBlack
        definesPresentationContext = true
        
        self.searchController.searchBar.delegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.StringLiterals.ReuseCollectionCellIdentifier, for: indexPath)
        
        
        
        return cell
    }
}
