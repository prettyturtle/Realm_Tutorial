//
//  RealmTableViewController.swift
//  Realm_Tutorial
//
//  Created by yc on 2023/02/21.
//

import UIKit
import SnapKit
import Then
import RealmSwift

final class RealmTableViewController: UIViewController {
    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(beginRefresh), for: .valueChanged)
    }
    private lazy var tableView = UITableView().then {
        $0.refreshControl = refreshControl
        $0.backgroundColor = .systemBackground
        $0.keyboardDismissMode = .onDrag
        $0.dataSource = self
        $0.delegate = self
        $0.register(
            RealmTableViewCell.self,
            forCellReuseIdentifier: RealmTableViewCell.identifier
        )
    }
    private lazy var textField = UITextField().then {
        $0.font = .systemFont(ofSize: 16.0, weight: .medium)
        $0.placeholder = "할 일을 입력하세요..."
        $0.borderStyle = .roundedRect
    }
    private lazy var saveButton = MyButton().then {
        $0.setTitle("저장", for: .normal)
        $0.style = .fill(backgroundColor: .systemPink)
        $0.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }
    
    private let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    private lazy var db = try! Realm(configuration: configuration)
    
    private var todoList = [TodoItem]()
    
    private var bottomConstraint: [NSLayoutConstraint]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        let safeArea = view.safeAreaLayoutGuide
        
        self.bottomConstraint = [
            NSLayoutConstraint(
                item: textField,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0
            ),
            NSLayoutConstraint(
                item: saveButton,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0
            )
        ]
        (bottomConstraint ?? []).forEach {
            $0.isActive = true
        }
        
        readAllTodoItemsAndTableViewReload()
    }
}

private extension RealmTableViewController {
    func readAllTodoItemsAndTableViewReload() {
        let todoItems = Array(db.objects(TodoItem.self))
        todoList = todoItems
        tableView.reloadData()
    }
    func createTodoItem(todoItem: TodoItem) {
        do {
            try db.write {
                db.add(todoItem)
            }
        } catch {
            return
        }
    }
    func deleteTodoItem(todoItem: TodoItem) {
        do {
            try db.write {
                db.delete(todoItem)
            }
        } catch {
            return
        }
    }
}

// MARK: - @objc Methods
private extension RealmTableViewController {
    @objc func didTapSaveButton() {
        print(#function)
        guard textField.text != "" else { return }
        let title = textField.text ?? ""
        let todoItem = TodoItem(id: UUID().uuidString, title: title)
        
        createTodoItem(todoItem: todoItem)
        readAllTodoItemsAndTableViewReload()
        textField.text = ""
    }
    
    @objc func beginRefresh() {
        readAllTodoItemsAndTableViewReload()
        refreshControl.endRefreshing()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight: CGFloat
            keyboardHeight = keyboardSize.height - view.safeAreaInsets.bottom
            (bottomConstraint ?? []).forEach {
                $0.constant = -1 * keyboardHeight - 16.0
            }
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        (bottomConstraint ?? []).forEach { $0.constant = 0 }
        view.layoutIfNeeded()
    }
}

// MARK: - Configure UI
private extension RealmTableViewController {
    func configureUI() {
        navigationItem.title = "Realm Todo"
        view.backgroundColor = .systemBackground
        [tableView, textField, saveButton].forEach {
            view.addSubview($0)
        }
        
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        textField.snp.makeConstraints {
            $0.height.equalTo(48.0)
            $0.leading.bottom.equalTo(view.safeAreaLayoutGuide).inset(16.0)
            $0.top.equalTo(tableView.snp.bottom).offset(16.0)
        }
        saveButton.snp.makeConstraints {
            $0.height.equalTo(48.0)
            $0.width.equalTo(48.0 * 2)
            $0.leading.equalTo(textField.snp.trailing).offset(8.0)
            $0.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16.0)
        }
    }
}

extension RealmTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return todoList.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RealmTableViewCell.identifier,
            for: indexPath
        ) as? RealmTableViewCell else {
            return UITableViewCell()
        }
        
        if !todoList.isEmpty {
            cell.setupView(todoItem: todoList[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            tableView.deselectRow(at: indexPath, animated: true)
            self.deleteTodoItem(todoItem: self.todoList[indexPath.row])
            self.readAllTodoItemsAndTableViewReload()
            completion(true)
        }
        let updateAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            //TODO: - UPDATE
            tableView.deselectRow(at: indexPath, animated: true)
            completion(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        updateAction.backgroundColor = .systemBlue
        updateAction.image = UIImage(systemName: "pencil.and.outline")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
