//
//  RealmTableViewCell.swift
//  Realm_Tutorial
//
//  Created by yc on 2023/02/22.
//

import UIKit
import SnapKit
import Then

final class RealmTableViewCell: UITableViewCell {
    static let identifier = "RealmTableViewCell"
    
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
    }
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(todoItem: TodoItem) {
        titleLabel.text = todoItem.title
    }
    
    private func configureUI() {
        [
            titleLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview().inset(16.0)
        }
    }
}
