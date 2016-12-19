//
//  FliterViewController.swift
//  MEAPhotoEditor
//
//  Created by Pranavi Adusumilli  on 10/24/16.
//  Copyright © 2016 MeaMobile. All rights reserved.
//

import UIKit
import SystemConfiguration
import Firebase
import AdobeCreativeSDKImage
import AdobeCreativeSDKCore



class FilterViewController:UIViewController, AdobeUXImageEditorViewControllerDelegate,UITextFieldDelegate{

    
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var filteredImage: UIImageView!
    @IBOutlet weak var animatingView: UIImageView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var masterpieceLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var meme: Masterpiece!
    var data: NSData?
    var pickedImageView: UIImageView!
    var modelId: String!
    var memeToShare: UIImage!
    
    var detailText:String!
    var searchURL: NSURL?
    var activityViewController:UIActivityViewController?
    var photoEditor: AdobeUXImageEditorViewController?
    
    
    
    var documentInteractionController:UIDocumentInteractionController!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.filteredImage.image =
        shareButton.isEnabled = false
        printButton.isEnabled = false
        editButton.isEnabled = false
        masterpieceLabel.numberOfLines = 4
        masterpieceLabel.text = "Creating Masterpiece using Artificial Intelligence. Our robots can be slow, this may take a minute or two."
        
        bannerView.adUnitID = "ca-app-pub-8189404576936801/8112454707"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        var loadingImages = ["0%Loading","20%Loading","40%Loading","60%Loading","80%Loading","100%Loading"]
        var images = [UIImage]()
        
        for i in 0..<loadingImages.count{
            images.append(UIImage(named: loadingImages[i])!)
        }
        animatingView.animationImages = images
        animatingView.animationDuration = 2.0
        animatingView.startAnimating()
        
        FIRAnalytics.logEvent(withName: "Filtering", parameters: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true{
            uploadImage()
        }
        else{
            animatingView.stopAnimating()
            displayAlert(message: "Please check the Internet Connection")
        }
    }
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
            print("Download Started")
            getDataFromUrl(url: url) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                
                DispatchQueue.main.async() { () -> Void in
                    self.animatingView.stopAnimating()
                    self.masterpieceLabel.text = ""
                    self.shareButton.isEnabled = true
                    self.printButton.isEnabled = true
                    self.editButton.isEnabled = true
                    self.filteredImage.image = UIImage(data: data)
                }
            }
    }
    
    func handleAuth(){
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error != nil{
                return
            }
        })
    }
    
    public func uploadImage(){
        handleAuth()
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference(forURL: "gs://meaphotoeditor.appspot.com").child("images").child(imageName)
        let uploadData = UIImagePNGRepresentation(pickedImageView.image!)
        storageRef.put(uploadData!, metadata: nil) { (metadata, error) in
            if error != nil{
                print(error!)
                return
            }
            
            if let imageUrl = metadata?.downloadURL()?.absoluteString {
                let imageurlStr = imageUrl.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
               
                let url:NSString = "http://convert.somatic.io/api/v1.2/cdn-query?id=\(self.modelId!)&api_key=H3w8a7tsv5g9csc4nf2efs5zxrvb5K&--input=\(imageurlStr)" as NSString
                self.searchURL = NSURL(string: url as String)!
                self.downloadImage(url: self.searchURL as! URL)
                self.pickedImageView.animationDuration = 0.5
                
            }
        }
    }
    
    @IBAction func shareImage(_ sender: Any) {
        
        memeToShare = generateMemedImage()
        
        activityViewController = UIActivityViewController(activityItems: [memeToShare as UIImage!], applicationActivities: nil)
        
        self.present(activityViewController!, animated: true, completion: nil)
        FIRAnalytics.logEvent(withName: "Sharing_Image", parameters: nil)
    }
    
    
    @IBAction func printButton(_ sender: Any) {
        memeToShare = generateMemedImage()
        let ourApplication = UIApplication.shared
        let ourPath = "printicularMEA://"
        let ourURL = URL(string: ourPath)!
        UIImageWriteToSavedPhotosAlbum(memeToShare, nil, nil, nil)
        ourApplication.open(ourURL, options: [:], completionHandler: nil)
        FIRAnalytics.logEvent(withName: "Print", parameters: nil)
    }
    func displayEditor(for imageToEdit: UIImage) {
        let editorController = AdobeUXImageEditorViewController(image: imageToEdit)
        editorController.delegate = self
        self.present(editorController, animated: true, completion: { _ in })
    }
    @IBAction func editButton(_ sender: Any) {
        memeToShare = generateMemedImage()
        FIRAnalytics.logEvent(withName: "Adobe_Editor", parameters: nil)
        AdobeUXAuthManager.shared().setAuthenticationParametersWithClientID("07105f82869d4609893cd5ab4da2b22a", withClientSecret:"670e173c-077f-4c73-9c98-e70d717b21f5" )
        displayEditor(for: memeToShare)

    }
   
    public func photoEditorCanceled(_ editor: AdobeUXImageEditorViewController) {
        editor.dismiss(animated: true, completion: nil)
    }
    
    func photoEditor(_ editor: AdobeUXImageEditorViewController, finishedWith image: UIImage?) {
        self.filteredImage.image = image
        editor.dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(message: String!){
        let alertController = UIAlertController(title: "Alert", message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true) { 
            let vc = (self.storyboard?.instantiateViewController(withIdentifier: "MPKItemDisplayViewControllerStoryboardIdentifier"))! as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func save(newMemedImage : UIImage){
        
        // Creating Meme
        meme = Masterpiece(captionField: captionField.text, filteredImage: newMemedImage)
    }
    
    func generateMemedImage() -> UIImage{
        editButton.isHidden = true
        shareButton.isHidden = true
        printButton.isHidden = true
        bannerView.isHidden = true
        navBar.isAccessibilityElement = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        editButton.isHidden = false
        shareButton.isHidden = false
        printButton.isHidden = false
        bannerView.isHidden = false
        navBar.isAccessibilityElement = false
        
        return memedImage
        
    }
}

