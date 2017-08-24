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
        
        self.collectionView?.registerNib(CustomCollectionViewRecipeCell.self)
                
        self.collectionView?.backgroundColor = .foodBlack
        definesPresentationContext = true
        
        self.searchController.searchBar.delegate = self
    }
    
    // MARK: Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        searchPhrase = searchBar.text!
        if searchPhrase.isEmpty {
            food2ForkImagesResult = []
            collectionView?.backgroundView?.isHidden = false
            collectionView?.reloadData()
        } else {
            perform(#selector(getRecipeFromFood2ForkBySearch), with: nil, afterDelay: 1.0)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchPhrase   // Keep text from former search
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchPhrase = searchBar.text!  // Store searchPhrase
    }
    
    // MARK: Collection View
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return food2ForkImagesResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CustomCollectionViewRecipeCell.self, for: indexPath)
        
        let recipeImage = food2ForkImagesResult[indexPath.row]
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
        
        let recipe = food2ForkImagesResult[indexPath.row]
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
        let parameters = [Constants.Food2ForkParameterKeys.SearchQuery: searchController.searchBar.text as AnyObject]
        let method = Constants.Food2ForkMethods.Search
        
        let netwotkClient = NetworkClient()
        
        netwotkClient.taskForSEARCHMethod(method: method, parameters: parameters) { (result, error) in
            guard let result = result else {
                print("\(String(describing: error))")
                return
            }
            
            let listRecipes = ListRecipe.createListReicpes(recipeDictionary: result)
            
            performUIUpdatesOnMain {
                if listRecipes.count == 0 {
                    self.collectionView?.backgroundView?.isHidden = false
                    print("No recipes found. Search again.")
                    return
                } else {
                    self.food2ForkImagesResult = listRecipes
                    self.collectionView?.backgroundView?.isHidden = true
                    self.collectionView?.reloadData()
                }
            }
        }
    }

}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow = CGFloat(3.0)
        let screenSize = UIScreen.main.bounds
        let itemSize = CGSize(width: (screenSize.width/numberOfItemsPerRow - numberOfItemsPerRow*3), height: 150)
        
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
