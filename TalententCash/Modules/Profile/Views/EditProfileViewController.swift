//
//  EditProfileViewController.swift
//  Loadxuser
//
//  Created by Zohaib Baig on 26/11/2021.
//

import UIKit
import Alamofire
import SDWebImage

class EditProfileViewController: StatusBarController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var fullNameView: PrimaryTextFieldView!
    @IBOutlet weak var userNameView: PrimaryTextFieldView!
    @IBOutlet weak var profileBioView: PrimaryTextFieldView!
    
    @IBOutlet weak var profileImagePhoto: UIImageView!
    @IBOutlet weak var profileImageTapped: UIButton!

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var coverImageTapped: UIButton!
    
    var name:String = ""
    var userName:String = ""
    var bio:String = ""
    var profileImage:String = ""
    var coverImageURL:String = ""
    
    var isProfile:Bool = true
    
    var window: UIWindow?
    var editProfileDataSource : QuickLoginModel!
    var imagePicker:UIImagePickerController!
    
//    var profileImage: ProfileImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        selectProfileImage()
        setupUI()
        
       // editProfile()
                profileImagePhoto.isUserInteractionEnabled = true
                profileImagePhoto.layer.cornerRadius = profileImagePhoto.bounds.height / 2
                profileImagePhoto.clipsToBounds = true
                profileImageTapped.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
       // coverImage.isUserInteractionEnabled = true
        //coverImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCoverImagePicker)))
       // coverImage.layer.cornerRadius = coverImage.bounds.height / 4
        
                imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
        

        let userImgUrl = URL(string: profileImage)
        self.profileImagePhoto.sd_setImage(with: userImgUrl, placeholderImage: UIImage(named: "placeholder.user"))
        
        let coverImageURL1 = URL(string: coverImageURL)
        self.coverImage.sd_setImage(with: coverImageURL1, placeholderImage: UIImage(named: "CoverImage"))
       
    }
//
    func setupUI() {
        fullNameView.isUserInteractionEnabled = true
        userNameView.isUserInteractionEnabled = true
        profileBioView.isUserInteractionEnabled = true
        fullNameView.setTitle = "Name"
        fullNameView.textInput.text = name

        userNameView.setTitle = "Username"
        userNameView.textInput.text = userName

        profileBioView.setTitle = "Profile Bio"
        profileBioView.textInput.text = bio
    }
    
    
    
    @objc func openImagePicker(_ sender:Any) {
            //Open Image Picker
        if self.profileImage == "https://www.talentcash.pk/storage/female.png"{
            self.openCameraIntent()
        }else{
            let alert = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
               alert.addAction(UIAlertAction(title: "Upload Photo", style: .default, handler: { _ in
                   self.openCameraIntent()
               }))
               
               alert.addAction(UIAlertAction(title: "View Photo", style: .default, handler: { _ in
                   let vc = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
                   vc.imgUrl = self.profileImage
                   vc.modalPresentationStyle = .fullScreen
                   self.present(vc, animated: true, completion: nil)
               }))
            
            alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
                let myWebsite = NSURL(string:self.profileImage)
                let shareAll = [myWebsite]
                let activityViewController = UIActivityViewController(activityItems: shareAll as [Any], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }))
               
               alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
               
               /*If you want work actionsheet on ipad
               then you have to use popoverPresentationController to present the actionsheet,
               otherwise app will crash on iPad */
               switch UIDevice.current.userInterfaceIdiom {
               case .pad:
                   alert.popoverPresentationController?.sourceView = self.view
                   alert.popoverPresentationController?.sourceRect = (self.view as AnyObject).bounds
                   alert.popoverPresentationController?.permittedArrowDirections = .up
               default:
                   break
               }
               self.isProfile = true
               self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCameraIntent(){
        
        
        let alert = UIAlertController(title: "Choose Profile Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = (self.view as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.isProfile = true
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func openCoverIntent(){
        
        let alert = UIAlertController(title: "Choose Cover Image", message: nil, preferredStyle: .actionSheet)
           alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
               self.openCamera()
           }))
           
           alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
               self.openGallary()
           }))
           
           alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
           
           /*If you want work actionsheet on ipad
           then you have to use popoverPresentationController to present the actionsheet,
           otherwise app will crash on iPad */
           switch UIDevice.current.userInterfaceIdiom {
           case .pad:
               alert.popoverPresentationController?.sourceView = self.view
               alert.popoverPresentationController?.sourceRect = (self.view as AnyObject).bounds
               alert.popoverPresentationController?.permittedArrowDirections = .up
           default:
               break
           }
        self.isProfile = false
        self.present(alert, animated: true, completion: nil)
        
    }
  
    @IBAction func openCoverImage(_ sender: Any) {
        
        if self.coverImageURL == "https://www.talentcash.pk/storage/female.png"{
            self.openCoverIntent()
        }else{
            let alert = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
               alert.addAction(UIAlertAction(title: "Upload Photo", style: .default, handler: { _ in
                   self.openCoverIntent()
               }))
               
               alert.addAction(UIAlertAction(title: "View Photo", style: .default, handler: { _ in
                   let vc = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
                   vc.imgUrl = self.coverImageURL
                   vc.modalPresentationStyle = .fullScreen
                   self.present(vc, animated: true, completion: nil)
               }))
            
            alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
                let myWebsite = NSURL(string:self.coverImageURL)
                let shareAll = [myWebsite]
                let activityViewController = UIActivityViewController(activityItems: shareAll as [Any], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }))
               
               alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
               
               /*If you want work actionsheet on ipad
               then you have to use popoverPresentationController to present the actionsheet,
               otherwise app will crash on iPad */
               switch UIDevice.current.userInterfaceIdiom {
               case .pad:
                   alert.popoverPresentationController?.sourceView = self.view
                   alert.popoverPresentationController?.sourceRect = (self.view as AnyObject).bounds
                   alert.popoverPresentationController?.permittedArrowDirections = .up
               default:
                   break
               }
               self.isProfile = false
               self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func openCamera()
        {
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
            {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            else
            {
                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

        func openGallary()
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       if let pickedImage = info[.originalImage] as? UIImage {
           // imageViewPic.contentMode = .scaleToFill
           
           if isProfile == true{
               self.profileImagePhoto.image = pickedImage
           }else{
//               let myImageWidth = pickedImage.size.width
//               let myImageHeight = pickedImage.size.height
//               let myViewWidth = self.coverImage.frame.size.width
//
//               let ratio = myViewWidth/myImageWidth
//               let scaledHeight = myImageHeight * ratio
//               self.coverImage.image = pickedImage.sd_croppedImage(with: .init(origin: .zero, size: CGSize(width: myViewWidth, height: scaledHeight)))
               self.coverImage.image = pickedImage
                                                                }
       }
       picker.dismiss(animated: true, completion: nil)
   }
    
    @IBAction func save(_ sender: Any) {
        
        self.editProfile()
    }

    public func showProfileVc(){
   
      
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }

    
    func editProfile() {
        
        self.startPulseAnimation()
        
        let images = [self.profileImagePhoto.image,self.coverImage.image] as? [UIImage] ?? [UIImage]()
        NetworkUtil.mulitiparts(apiMethod:  Constants.URL.editProfile , ServerImage:images, parameters: ["userId":UserDefaultManager.instance.userID,"name":self.fullNameView.textInput.text ?? "","username":self.userNameView.textInput.text ?? "","bio":self.profileBioView.textInput.text ?? "","gender":"Male"],requestType: .patch, onSuccess: { data in
            self.stopPulseAnimation()
            guard let data = data as? Data else {
                print("cast error")
                return
            }
            print("data = ",String(data: data, encoding: .utf8) ?? "no")
            
            self.dismiss(animated: true)
        }, onFailure: {msg in
            self.stopPulseAnimation()
            print("onFailure  =  ",msg)
        })
    }

    
}



