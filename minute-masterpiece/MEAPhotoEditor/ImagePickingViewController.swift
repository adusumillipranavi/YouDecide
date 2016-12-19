//
//  ViewController.swift
//  MEAPhotoEditor
//
//  Created by Pranavi Adusumilli  on 10/19/16.
//  Copyright © 2016 MeaMobile. All rights reserved.
//

import UIKit
import mea_photokit
import Firebase

class ImagePickingViewController: MPKItemDisplayViewController, UICollectionViewDataSource, UICollectionViewDelegate{

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    var imagesArray = [#imageLiteral(resourceName: "Mosaic"),#imageLiteral(resourceName: "Engarving"),#imageLiteral(resourceName: "Purely Abstract"),#imageLiteral(resourceName: "Oil Painting"),#imageLiteral(resourceName: "Impressionist"),#imageLiteral(resourceName: "NaturePatterns"),#imageLiteral(resourceName: "Campaign Style"),#imageLiteral(resourceName: "Red and Black"),]
    
    var Model = ["Mosaic","Engraving","Purely Abstract","OilPainting","Impressionist","NaturePatterns","Campaign Style","Black And Red"]
    
    var text = ["9kgYo1Zp","zZP0evZ0","LnL71DkK","DkMl3OEg","MkeLoMEg","lEVv8vEB","8k8aLmnM","oEG3P0ER"]


    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.frame = view.frame
        // Do any additional setup after loading the view.
        flowLayout.scrollDirection = .horizontal
        FIRAnalytics.logEvent(withName: "Image-Picking", parameters: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.myLabel.text = self.Model[indexPath.item]
        cell.imageView.image = self.imagesArray[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "FilterVC") as! FilterViewController
        
        detailVC.pickedImageView = self.imageView
        detailVC.modelId = self.text[indexPath.item]

        FIRAnalytics.logEvent(withName: "Model-Selected", parameters: nil)
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }

}

