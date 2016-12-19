//
//  ViewController.swift
//  CollectionView
//
//  Created by Pranavi Adusumilli  on 11/4/16.
//  Copyright © 2016 MeaMobile. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pickedImageView: UIImageView!
    var imagesArray = [#imageLiteral(resourceName: "Mosaic"),#imageLiteral(resourceName: "Engarving"),#imageLiteral(resourceName: "Circuit"),#imageLiteral(resourceName: "Purely Abstract"),#imageLiteral(resourceName: "Oil Painting"),#imageLiteral(resourceName: "Impressionist"),#imageLiteral(resourceName: "NaturePatterns"),#imageLiteral(resourceName: "Campaign Style"),#imageLiteral(resourceName: "Red and Black"),#imageLiteral(resourceName: "PSEUDODIAGRAPHIC"),#imageLiteral(resourceName: "Many Colors"),#imageLiteral(resourceName: "Modern Colors"),#imageLiteral(resourceName: "snowflake"),#imageLiteral(resourceName: "Modern Colors2"),#imageLiteral(resourceName: "Neon"),#imageLiteral(resourceName: "AbnormalExpressionist"),#imageLiteral(resourceName: "Lava")]
    var Model = ["Mosaic","Engraving","Circuit","Purely Abstract","OilPainting","Impressionist","NaturePatterns","Campaign Style","Black And Red", "Pseudodiagraphic","ManyColors","Modern Colors","SnowFlake","Modern Colors2","Neon","Abnormal Expressionist","Lava"]
    var text = ["9kgYo1Zp","zZP0evZ0","MZJN75ZY","LnL71DkK","DkMl3OEg","MkeLoMEg","lEVv8vEB","8k8aLmnM","oEG3P0ER","gZDA63Ex","VEqz4xkx","Bka9oBkM","Kkb1r4EO","zZP0RvZ0","VEqzYpkx","2kRl49ZW","7E9r2WkR"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
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
        
        detailVC.pickedImageView = self.pickedImageView
        detailVC.modelId = self.text[indexPath.item]


        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

