//
//  TodoItemBuilder.swift
//  Realm_Tutorial
//
//  Created by yc on 2023/02/25.
//

import Foundation

class TodoItemBuilder {
    private var todoItem = TodoItem(id: "", title: "")
    
    func withID(_ id: String) -> Self {
        todoItem.id = id
        return self
    }
    
    func withTitle(_ title: String) -> Self {
        todoItem.title = title
        return self
    }
    
    func build() -> TodoItem {
        return todoItem
    }
}
