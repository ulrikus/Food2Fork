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
        
        self.collectionView?.registerNib(CustomCollectionViewRecipeCell.self)
                
        self.collectionView?.backgroundColor = .foodBlack
        definesPresentationContext = true
        
        self.searchController.searchBar.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.reloadData()
    }
    
    // MARK: Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        
        if searchBarText.isEmpty {
            RecipesProvider.sharedProvider.listRecipes = []
            collectionView?.backgroundView?.isHidden = false
            collectionView?.reloadData()
        } else {
            perform(#selector(getRecipeFromFood2ForkBySearch), with: nil, afterDelay: 1.0)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = RecipesProvider.sharedProvider.lastSearchString   // Keep text from former search
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        RecipesProvider.sharedProvider.lastSearchString = searchBar.text!  // Store searchPhrase
    }
    
    // MARK: Collection View
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if RecipesProvider.sharedProvider.listRecipes.count == 0 {
            self.collectionView?.backgroundView?.isHidden = false
        } else {
            self.collectionView?.backgroundView?.isHidden = true
        }
        
        return RecipesProvider.sharedProvider.listRecipes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CustomCollectionViewRecipeCell.self, for: indexPath)
        
        let recipeImage = RecipesProvider.sharedProvider.listRecipes[indexPath.row]
        let imageURL = URL(string: recipeImage.imageUrlString)
        
        cell.recipeImage?.image = UIImage()
        cell.recipeTitleLabel?.text = recipeImage.title
        
        performTaskInBackground() {
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    cell.recipeImage?.image = UIImage(data: imageData)
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let recipe = RecipesProvider.sharedProvider.listRecipes[indexPath.row]
        recipeToPass = recipe
        
        performSegue(withIdentifier: Constants.StringLiterals.SegueIdentifier, sender: self)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constants.StringLiterals.SegueIdentifier)
        {
            let viewController = segue.destination as! DetailViewController
            viewController.recipe = recipeToPass
        }
    }
    
    // MARK: Network request
    @objc fileprivate func getRecipeFromFood2ForkBySearch() {
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        
        RecipesProvider.sharedProvider.getRecipeFromFood2ForkBySearch(searchPhrase: searchBarText) {
            if RecipesProvider.sharedProvider.listRecipes.count == 0 {
                print("No recipes found. Search again.")
                self.presentNoSearchResultAlert()
                return
            } else {
                self.collectionView?.reloadData()
            }
        }
    }
    
    func presentNoSearchResultAlert() {
        // Create the alert controller
        let alertController = UIAlertController(title: "No search result for:", message: "\(RecipesProvider.sharedProvider.lastSearchString ?? "")", preferredStyle: .alert)
        
        alertController.view.tintColor = .foodGreen
        alertController.view.backgroundColor = .foodDarkBlack
        alertController.view.layer.cornerRadius = 30
        
        // Create the actions
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel) { alert in
            
        }
        
        // Add the actions
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow = CGFloat(3)
        let screenSize = UIScreen.main.bounds
        let itemSize = CGSize(width: (screenSize.width/numberOfItemsPerRow - numberOfItemsPerRow*2), height: 150)
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = CGFloat(4)
        return UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
