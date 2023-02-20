//
//  RealmViewController.swift
//  Realm_Tutorial
//
//  Created by yc on 2023/02/21.
//

import UIKit
import SnapKit
import Then
import RealmSwift

class TodoItem: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    
    convenience init(id: String, title: String) {
        self.init()
        self.id = id
        self.title = title
    }
}

final class RealmViewController: UIViewController {
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    private lazy var db = try! Realm(configuration: configuration)
    
    private lazy var keyTextField = UITextField().then {
        $0.font = .systemFont(ofSize: 24.0, weight: .semibold)
        $0.borderStyle = .roundedRect
        $0.placeholder = "키 값을 입력하세요..."
    }
    private lazy var titleTextField = UITextField().then {
        $0.font = .systemFont(ofSize: 24.0, weight: .semibold)
        $0.borderStyle = .roundedRect
        $0.placeholder = "타이틀 값을 입력하세요..."
    }
    private lazy var updateButton = MyButton().then {
        $0.setTitle("UPDATE", for: .normal)
        $0.style = .fill(backgroundColor: .systemYellow)
        $0.addTarget(
            self,
            action: #selector(didTapUpdateButton),
            for: .touchUpInside
        )
    }
    private lazy var deleteButton = MyButton().then {
        $0.setTitle("DELETE", for: .normal)
        $0.style = .fill(backgroundColor: .systemPurple)
        $0.addTarget(
            self,
            action: #selector(didTapDeleteButton),
            for: .touchUpInside
        )
    }
    private lazy var deleteAllButton = MyButton().then {
        $0.setTitle("DELETE ALL", for: .normal)
        $0.style = .fill(backgroundColor: .systemRed)
        $0.addTarget(
            self,
            action: #selector(didTapDeleteAllButton),
            for: .touchUpInside
        )
    }
    private lazy var readAllButton = MyButton().then {
        $0.setTitle("READ ALL", for: .normal)
        $0.style = .fill(backgroundColor: .systemBlue)
        $0.addTarget(
            self,
            action: #selector(didTapReadAllButton),
            for: .touchUpInside
        )
    }
    private lazy var readButton = MyButton().then {
        $0.setTitle("READ", for: .normal)
        $0.style = .fill(backgroundColor: .systemCyan)
        $0.addTarget(
            self,
            action: #selector(didTapReadButton),
            for: .touchUpInside
        )
    }
    private lazy var saveButton = MyButton().then {
        $0.setTitle("SAVE", for: .normal)
        $0.style = .fill(backgroundColor: .systemPink)
        $0.addTarget(
            self,
            action: #selector(didTapSaveButton),
            for: .touchUpInside
        )
    }
    
    private lazy var typeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
        $0.text = "type : "
    }
    private lazy var idLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20.0, weight: .semibold)
        $0.numberOfLines = 0
        $0.text = "id : "
    }
    private lazy var titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20.0, weight: .semibold)
        $0.numberOfLines = 0
        $0.text = "title : "
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        navigationItem.title = "Realm"
        [
            saveButton,
            readButton,
            updateButton,
            deleteButton,
            deleteAllButton,
            readAllButton,
            keyTextField,
            titleTextField,
            typeLabel,
            idLabel,
            titleLabel
        ].forEach {
            view.addSubview($0)
        }
        keyTextField.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.height.equalTo(48.0)
        }
        titleTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.top.equalTo(keyTextField.snp.bottom).offset(16.0)
            $0.height.equalTo(48.0)
        }
        typeLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.top.equalTo(titleTextField.snp.bottom).offset(16.0)
        }
        idLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.top.equalTo(typeLabel.snp.bottom).offset(8.0)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.top.equalTo(idLabel.snp.bottom).offset(8.0)
        }
        saveButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.height.equalTo(48.0)
        }
        readButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.bottom.equalTo(saveButton.snp.top).inset(-16.0)
            $0.height.equalTo(48.0)
        }
        readAllButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.bottom.equalTo(readButton.snp.top).inset(-16.0)
            $0.height.equalTo(48.0)
        }
        updateButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.bottom.equalTo(readAllButton.snp.top).inset(-16.0)
            $0.height.equalTo(48.0)
        }
        deleteButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.bottom.equalTo(updateButton.snp.top).inset(-16.0)
            $0.height.equalTo(48.0)
        }
        deleteAllButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.bottom.equalTo(deleteButton.snp.top).inset(-16.0)
            $0.height.equalTo(48.0)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    enum DBType {
        case create
        case read
        case update
        case delete
        case deleteAll
        case error
        
        var str: String {
            switch self {
            case .create: return "CREATE"
            case .read:  return "READ"
            case .update: return "UPDATE"
            case .delete: return "DELETE"
            case .deleteAll: return "DELETE ALL"
            case .error: return "ERROR"
            }
        }
    }
    
    private func updateLabel(todoItem: TodoItem? = nil, type: DBType) {
        if type == .error {
            typeLabel.text = type.str
            idLabel.text = "id : "
            titleLabel.text = "title : "
            return
        }
        guard let todoItem = todoItem else { return }
        typeLabel.text = "type : \(type.str)"
        idLabel.text = "id : \(todoItem.id)"
        titleLabel.text = "title : \(todoItem.title)"
    }
    
    @objc func didTapUpdateButton() {
        print(#function)
        
        let id = keyTextField.text ?? ""
        let title = titleTextField.text ?? ""
        
        guard id != "", title != "" else {
            updateLabel(type: .error)
            return
        }
        
        let todoItem = TodoItem(id: id, title: title)
        
        do {
            try db.write {
                db.add(todoItem, update: .modified)
                updateLabel(todoItem: todoItem, type: .update)
            }
        } catch {
            print(error.localizedDescription)
            updateLabel(type: .error)
        }
        
    }
    
    @objc func didTapDeleteAllButton() {
        print(#function)
        
        do {
            try db.write {
                db.deleteAll()
                updateLabel(type: .deleteAll)
            }
        } catch {
            print(error.localizedDescription)
            updateLabel(type: .error)
        }
    }
    @objc func didTapDeleteButton() {
        print(#function)
        let id = keyTextField.text ?? ""
        
        guard id != "" else {
            updateLabel(type: .error)
            return
        }
        
        if let todoItem = db.object(ofType: TodoItem.self, forPrimaryKey: id) {
            do {
                try db.write {
                    updateLabel(todoItem: todoItem, type: .delete)
                    db.delete(todoItem)
                }
            } catch {
                print(error.localizedDescription)
                updateLabel(type: .error)
            }
        } else {
            print("없음")
            updateLabel(type: .error)
        }
    }
    @objc func didTapReadAllButton() {
        print(#function)
        let todoItems = db.objects(TodoItem.self)
        print(todoItems)
        
        var ids = todoItems.reduce("") { partialResult, item in
            return partialResult + item.id + " "
        }
        var titles = todoItems.reduce("") { partialResult, item in
            return partialResult + item.title + " "
        }
        
        if ids == "" { ids = "없음" }
        if titles == "" { titles = "없음" }
        
        let tempTodoItem = TodoItem(id: ids, title: titles)
        updateLabel(todoItem: tempTodoItem, type: .read)
    }
    @objc func didTapSaveButton() {
        print(#function)
        
        let id = keyTextField.text ?? ""
        let title = titleTextField.text ?? ""
        
        guard id != "", title != "" else {
            updateLabel(type: .error)
            return
        }
        
        let todoItem = TodoItem(
            id: id,
            title: title
        )
        do {
            try db.write {
                db.add(todoItem)
                updateLabel(todoItem: todoItem, type: .create)
            }
        } catch {
            print(error.localizedDescription)
            updateLabel(type: .error)
        }
    }
    @objc func didTapReadButton() {
        print(#function)
        let id = keyTextField.text ?? ""
        
        guard id != "" else {
            updateLabel(type: .error)
            return
        }
        
        guard let todoItem = db.object(ofType: TodoItem.self, forPrimaryKey: id) else {
            print("없음")
            updateLabel(type: .error)
            return
        }
        print(todoItem)
        updateLabel(todoItem: todoItem, type: .read)
    }
}
