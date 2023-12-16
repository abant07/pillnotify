import UIKit
import SwiftUI

public class MedsView: UIView {
    private let contentView = UIView()
    private let cardView = UIView()
    private let stackView = UIStackView()
    private let medView = UIView()
    private let medLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    public func update(meds: String) {
        self.layoutIfNeeded()
        
        
        // Set the maximum number of lines for the label to 0 (unlimited) for dynamic height
        medLabel.numberOfLines = 0
        
        // Update the text of the medLabel
        medLabel.text = "Medications:\n\(meds)"
        
        // Adjust the label's size to fit its content
        medLabel.sizeToFit()
        
        // Calculate the desired height for the medView based on the label's height
        let medViewHeight = medLabel.frame.height + 16 // Add vertical padding of 16 points
        
        // Update the height constraint of the medView
        medView.translatesAutoresizingMaskIntoConstraints = false
        medView.heightAnchor.constraint(equalToConstant: medViewHeight).isActive = true
        
        // Update the layout of the view hierarchy
        self.layoutIfNeeded()
    }
}

private extension MedsView {
    func setUpSubViews() {
        contentView.backgroundColor = UIColor(red:  129/255, green: 159/255, blue: 247/255, alpha: 1)
        addSubview(contentView)
        
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 4
        
        cardView.layer.masksToBounds = false
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowRadius = 3
        cardView.layer.shadowOpacity = 0.12
        contentView.addSubview(cardView)
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        cardView.addSubview(stackView)
        
        
        medLabel.text = "Medications:\nno meds"
        medLabel.lineBreakMode = .byWordWrapping
        medLabel.numberOfLines = 0 // Allow multiple lines for the label
        medLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        medLabel.textColor = UIColor(red:  69/255, green: 80/255, blue: 81/255, alpha: 1)
        medView.addSubview(medLabel)
        
        medLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            medLabel.leadingAnchor.constraint(equalTo: medView.leadingAnchor),
            medLabel.trailingAnchor.constraint(equalTo: medView.trailingAnchor),
            medLabel.topAnchor.constraint(equalTo: medView.topAnchor, constant: 8),
            medView.bottomAnchor.constraint(equalTo: medLabel.bottomAnchor, constant: 8),
        ])
        stackView.addArrangedSubview(medView)
        
        addConstraints()
    }

    
    func addConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        medLabel.translatesAutoresizingMaskIntoConstraints = false // Add this line to disable autoresizing mask translation for the label

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 8),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),

            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),

            medLabel.leadingAnchor.constraint(equalTo: medView.leadingAnchor),
            medLabel.topAnchor.constraint(equalTo: medView.topAnchor, constant: 8),
            medView.bottomAnchor.constraint(equalTo: medLabel.bottomAnchor, constant: 8),
        ])
    }
}


