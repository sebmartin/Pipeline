//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import Pipeline

PlaygroundPage.current.needsIndefiniteExecution = true

let view = UIView()
view.backgroundColor = .white
view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
PlaygroundPage.current.liveView = view

var textField1 = UITextField()
textField1.frame = CGRect(x: 10, y: 10, width: 400, height: 44)
textField1.backgroundColor = .lightGray
view.addSubview(textField1)

var textField2 = UITextField()
textField2.frame = CGRect(x: 10, y: 80, width: 400, height: 44)
textField2.backgroundColor = .red
view.addSubview(textField2)

var prop1 = ViewProperty(value: "hello1", view: textField1)
var prop2 = ViewProperty(value: "hello2", view: textField2)

prop2.value
