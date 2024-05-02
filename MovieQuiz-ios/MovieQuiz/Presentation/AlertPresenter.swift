//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Maksim  on 27.03.2024.
//

import UIKit

final class AlertPresenter {
    static func presentAlert(from viewController: UIViewController, with model: AlertModel) {
        let alertController = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
      
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
    
        alertController.addAction(action)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
