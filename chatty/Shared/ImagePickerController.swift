//
//  ImagePickerController.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 04.02.23.
//

import UIKit

class ImagePickerController: UIViewController {

    var onImagePicked: (UIImage) -> Void

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(AppColor.gray)
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init(onImagePicked: @escaping (UIImage) -> Void = { _ in }) {
        self.onImagePicked = onImagePicked

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        setupConstraints()

        addTapGesture()
    }

    private func setupView() {
        view.addSubview(imageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onImageTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }

    @objc func onImageTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        present(imagePickerController, animated: true)
    }

    public func resetImage() {
        imageView.image = UIImage(named: "placeholder")?.withRenderingMode(.alwaysTemplate)
    }
}

extension ImagePickerController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        else {
            dismiss(animated: true)

            return
        }

        imageView.image = pickedImage
        onImagePicked(pickedImage)

        dismiss(animated: true)
    }
}
