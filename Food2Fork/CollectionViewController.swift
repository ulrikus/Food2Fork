//
//  CollectionViewController.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 23.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {
    
    var searchController: UISearchController!
    var recipeToPass: Recipe?
    var flowLayout = ColumnFlowLayout()
    var recipesList = ListRecipe.init(count: 0, recipes: [])
    private var lastSearchString = ""
    
    private let recipesCoordinator = RecipesCoordinator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let emptySearchView = UIView.instanceFromNib() as EmptyView
        collectionView?.backgroundView = emptySearchView
        collectionView?.registerNib(CustomRecipeCell.self)
        collectionView?.backgroundColor = .foodBlack
        collectionView?.collectionViewLayout = flowLayout
        collectionView?.delegate = self

        searchController = UISearchController(searchResultsController: nil)
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.keyboardAppearance = .alert
        searchController.dimsBackgroundDuringPresentation = false

        navigationController?.navigationBar.barTintColor = .foodBlack
        navigationController?.navigationBar.tintColor = .foodGreen
        
        definesPresentationContext = true

        searchController.searchBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        collectionView?.reloadData()
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constants.StringLiterals.SegueIdentifier) {
            let viewController = segue.destination as! DetailViewController
            viewController.passedRecipe = recipeToPass
        }
    }
    
    // MARK: Network request
    
    @objc fileprivate func getRecipeFromFood2ForkBySearch() {
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        
        recipesCoordinator.performSearch(with: searchBarText) { [weak self] (recipesList, error) in
            guard let recipesList = recipesList, error == nil else {
                return
            }
            if recipesList.count == 0 {
                self?.presentNoSearchResultAlert(with: searchBarText)
            } else {
                self?.recipesList = recipesList
                self?.collectionView?.reloadData()
            }
        }
    }
    
    func presentNoSearchResultAlert(with searchPhrase: String) {
        // Create the alert controller
        let alertController = UIAlertController(title: "No search result for:", message: "\(searchPhrase)", preferredStyle: .alert)
        
        alertController.view.tintColor = .foodGreen
        alertController.view.backgroundColor = .foodDarkBlack
        alertController.view.layer.cornerRadius = 20
        
        // Create the actions
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { [weak self] alert in
            self?.searchController.searchBar.becomeFirstResponder()
        }
        
        // Add the actions
        alertController.addAction(okAction)
        
        // Present the controller
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - CollectionView delegate and data source

extension CollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if recipesList.count == 0 {
            collectionView.backgroundView?.isHidden = false
        } else {
            collectionView.backgroundView?.isHidden = true
        }
        
        return recipesList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CustomRecipeCell.self, for: indexPath)
        
        let recipe = recipesList.recipes[indexPath.row]
        
        cell.recipeImage?.image = UIImage()
        cell.recipeTitleLabel?.text = recipe.title
        
        performTaskInBackground() {
            if let imageData = try? Data(contentsOf: recipe.imageUrl) {
                performUIUpdatesOnMain {
                    cell.recipeImage?.image = UIImage(data: imageData)
                }
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let recipe = recipesList.recipes[indexPath.row]
        recipeToPass = recipe
        
        performSegue(withIdentifier: Constants.StringLiterals.SegueIdentifier, sender: self)
    }
}

// MARK: UISearchBarDelegate

extension CollectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        
        if searchBarText.isEmpty {
            recipesList = ListRecipe(count: 0, recipes: [])
            collectionView?.backgroundView?.isHidden = false
            collectionView?.reloadData()
        } else {
            perform(#selector(getRecipeFromFood2ForkBySearch), with: nil, afterDelay: 1.0)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = lastSearchString   // Keep text from former search
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        lastSearchString = searchBar.text!  // Store searchPhrase
        if searchBar.text == "" {
            searchBar.placeholder = "Search"
        } else {
            searchBar.placeholder = lastSearchString
        }
    }
}
