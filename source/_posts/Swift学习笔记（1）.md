---
title: Swift学习笔记（1）
date: 2017-10-16 14:35:53
categories:
- 技术
tags:
- iOS
- Swift
---

# 1. Swift 语法

## 1.1 可选类型

1.可选类型解析

```
var errorCode: Int? = 404              // 在类型后面添加一个?，表示是可选类型
print(errorCode)                       // Optional(404)
if errorCode != nil {                  // 确定可选类型包含值后可以在变量名后加!强制解析
  print(errorCode!)                    // 404
}
```

## 1.2 基本运算符

1.空合运算符: a ?? b	

```
let optionalE: Int? = 4     // ?? 前面那个值要为可选类型
let d = optionalE ?? b      // 4, 如果optionalE为空,d为b的值，如果不为空就是optionalE解包后的值
```

2.区间运算符: 表示一个区间的值	

```
1...5                       // 定义1到5,5个数,包含1和5
1..<5                       // 定义1到5,4个数,不包含5
```

## 1.3 字符串

1.初始化

```
var emptyString1 = ""                  // 空字符串,""内为空
let emptyString2 = String()            // 空字符串,通过String()初始化方法置为空
```

字符串的值传递方式是通过值传递的,传递的时候是对已有的字符串创建副本再进行传递或赋值操作.

2.字符的操作

```
var string1 = "Not Empty"
let char: Character = "a"             // a, 字符的类型为Character
for char in string1.characters {      // for循环后面会详述
    print(char)                       // 依次输出emptyString1中所有字符
}
string1.characters.count              // 9, 获取字符串中字符个数包括空格
```

3.字符串拼接

```
var string1 = "Hello"
var string2 = " World"

var string3 = string1 + string2        // Hello World, 通过"+"将两个字符串相连

string1 += string2                     // Hello World, 等价于string1 = string1+string2
string1.append(" !")                   // Hello World !, 通过append()方法拼接

let messages = "Hello \(string2) !"    // Hello World !, 通过将常量或变量放入\()中
```

    注意：print(string1.append(string2))    //() 因为append没有返回值，是直接改变sting1的值

4.字符串索引

```
let messages = "Hello World !"   
             
let messChar = messages[messages.startIndex]  // H,通过第一个字符的索引获取字符

let firstIndex = messages.index(after: messages.startIndex)  // 1, 第一个字符的索引
let lastIndex = messages.index(before: messages.endIndex)    // 13, 最后一个字符的索引

let index = messages.index(messages.startIndex, offsetBy: 4) // 4, 初始位置偏移4
let indexChar = messages[index]                              // o, 通过索引获得的字符为o
```

    注意:索引不能越界

5.字符串的插入和删除	

```
var welcome = "Hello"

welcome.insert("!", at: welcome.endIndex)  
print(welcome)                             // Hello!, 将!插入welcome的末尾

welcome.insert(contentsOf: "world".characters, at: welcome.index(before: welcome.endIndex))
print(welcome)                             // Helloworld!, 注意:插入的内容是:"world".characters

welcome.remove(at: welcome.index(before: welcome.endIndex)) 
print(welcome)                             // Helloworld, 删除最后一位

let range = welcome.index(welcome.endIndex, offsetBy: -5)..< welcome.endIndex // 后5位的范围
welcome.removeSubrange(range)              // 删除"world"
print(welcome)                             // Hello
```

6.字符串的比较操作	

```
var welcome = "Hello"
welcome == "Hello"                     // true, 字符串可以用==, !=进行比较操作
```

## 1.4 数组

有序的,同一类型的多个元素的集合

1.定义

```
var arrInts = [Int]()                  // [], 定义一个元素类型为Int的可变空数组
arrInts = []                           // [], 空数组的简单定义方式
arrInts = [1, 4]                       // [1, 4], 数组的简单构造方法
var twoDouble = [Double](repeating: 2.0, count: 2)  // [2.0, 2.0] 相同元素数组的创建
```

2.数组操作

```
var arr1 = [1, 2, 3]
var arr2 = [4, 5]

var array = arr1 + arr2                 // 数组也能用"+"拼接
arr1 += arr2                            // 等价于arr1 = arr1 + arr2
                    
let secondNum = arr1[2]                 // 3, 通过下标访问元素,数组中第一个元素的下标是0
arr1[0] = 10                            // 将arr1的第一个元素改为 10

arr1[1...2] = [11, 12]                  // 将数组中的[1...2]区间改为[11, 12]中的元素
print(arr1)                             // [10, 11, 12, 4, 5]

arr1.append(6)                          // arr1 中插入一个元素6
arr1.insert(1, at: 0)                   // 将1插入到数组第一个元素
arr1.remove(at: 0)                      // 移除0位置的元素,之前后面的元素会自动往前一位
arr1.removeLast()                       // 移除最后一个元素
```

3.遍历

```
for (index, value) in arr1.enumerated() {  // 使用迭代器获取数组元素以及索引号
    print("索引:\(index), 元素:\(value)")   // 依次打印索引号及元素 索引号:0, 元素:10 ...
} 
```

## 1.5 集合

存储相同类型没有确定顺序的元素,相同元素只能出现一次

1.定义

```
var char1 = Set< Character >()          // 创建一个Character类型的空集合
let char2:Set< Character > = []         // 定义空集合的简便方法.类型:Set< Character >

var letter1: Set = ["a", "b", "c"]      // 集合类型可以写成Set,但必须显示声明,不能省略
var letter2 = ["a", "b", "c"]           // Set省略后,根据自动类型推断,letter2就是数组类型
```

2.操作

```
letter1.insert("a")                    // 如果插入的元素如果已经在集合中,那么会被忽略
letter1.remove("c")                    // c, 要删除的元素在集合中,则返回元素,否则返回nil
letter1.contains("a")                  // true, 是否包含某个元素
	
var num1: Set = ["3", "2", "1", "5", "7"]
let num2: Set = ["3", "2", "5", "7"]
let num3: Set = ["1", "6", "5"]

num1.intersection(num3)              // ["1", "5"], 两个集合的交集
num1.union(num3)                     // ["5", "2", "1", "7", "6", "3"], 两个集合的并集
num1.subtracting(num3)               // ["2", "7", "3"], 只在集合1不在集合2的部分
num1.symmetricDifference(num3)       // ["2", "7", "6", "3"], 两个集合的并集中非交集部分

num1 == num2                         // false, 判断两个集合包含的元素是否都相同
num2.isSubset(of: num1)              // true, num2是num1的子集
num1.isSuperset(of: num2)            // true, num1是num2的超集合
num1.isDisjoint(with: num2)          // false, 判断两个集合中的元素是否都不相同
```

3.遍历

```
for char in letter1 {
    print(char)                      // 不按顺序的输出集合中每个元素
}

for char in letter1.sorted() {
    print(char)                      // 按特定顺序的输出集合中每个元素
}
```

## 1.6 字典

字典中的每个元素都是一个键值对,每个键值对有一个对应的key和value

1.定义

```
var chars: [String: String] = ["char1":"A", "char2":"B"]  // 键和值都是String类型
var charDict = ["char1":"A", "char2":"B"]  // 系统会作自动类型推断,类型也可以省略
```

2.操作

```
chars["char2"]                             // b, 通过字典的key访问value
let arrKeys = [String](charDict.keys)      // ["char1", "char2"], 获取字典中所有key的数组
let arrValues = [String](charDict.values)  // ["A", "B"], 获取字典中所有value的数组

chars["char3"] = "C"                       // chars中新增一个键值对
chars["char1"] = "a"                       // chars中修改key对应的value
chars["char3"] = nil                       // 将key对应的value设置为nil,移除键值对

chars.updateValue("b", forKey: "char2")    // 更新键值对,要是这个键不存在则会添加一个
chars.removeValue(forKey: "char2")         // 移除键值对
```

3.遍历

```	
for (key, value) in charDict {             // 遍历字典中的所有key value
    print("\(key): \(value)")              // char2: B, char1: A
}
for key in charDict.keys {                 // 遍历字典中的所有key
    print(key)                             // char2, char1
}

for value in charDict.values {             // 遍历字典中的所有value
    print(value)                           // B, A
}
```

## 1.7 控制流

1.for循环	

```
for num in 1...5 {                     // 依次把闭区间[1, 5]中的值赋值给num
    print(num)                         // 依次输出5个数字
}

for _ in 1...5 {                       // _ 替代变量名
    print("A")                         // 依次输出5个字符串"A"
}
```
                    
2.repeat-while循环

```	
var num = 3
repeat {                               // 第一次即使条件不满足也会进入{}
    print(num)                         // 3
    num = num - 1                      // 每次循环 num - 1
} while num > 0
```

3.switch语句

```	
var num = 12
switch num {
case 2:
    print("num等于2")                  // 每个case分支至少需要包含一条语句
case 3, 4, 5:                         // case语句可以匹配多个值,之间用(,)隔开
    print("num == 3 or 4 or 5")       // case分支末尾不需要写break,不会发生贯穿
case 6..<10:                          // case语句也支持区间
    print("num大于等于6,且小于10")
case 10..<19 where num % 3 == 0:      // 使用where语句来增加额外判断条件
    print("num大于等于10,且小于19,且能被3整除")
default:
    print("上面的情况都不满足")
}
```

4.控制转移语句	

```
var num = 2
switch num {
case 2:
    print("Hello")                     // Hello
    fallthrough                        // 贯穿,使用fallthrough可以连续到下一个case中
default:
    print("World")                     // World
}
```

5.循环语句的标签设置	

```
var num1 = 6
var num2 = 4
num1Loop: while num1 > 0 {
    num2Loop: while num2 > 0 {
        print(num2)                    // 4
        num2 = num2 - 1
        break num1Loop                 // 终止第一个循环
    }
    print(num1)                        // 已经在num2Loop中执行了退出num1Loop循环，所以不会执行此语句
    num1 = num1 - 1
}
```

6.guard语句

```	
var num = 4
func guardTest() {
    guard num == 5 else {             // 如果guard条件不满足,则会执行else后面的{}
        print(num)                    // 4
        return                        // 由于有return, guard语句必需要在函数中
    }
}
guardTest()
```

7.版本适配

```	
if #available(iOS 11, *) { // 平台还可以是: iOS macOS watchOS tvOS
    // 使用iOS11及以上的API
} else {
    // 使用iOS11以下的API
}
```

## 1.8 函数

1.参数的标签

```
func sum(_ name1: String, label2 name2: String) {  // 下划线(_)来代替标签
    print(name1 + name2)                           // KobeBryant
}
sum("Kobe", label2: "Bryant")                      // 忽略的参数标签此处不会显示
```

2.参数的默认值

```
func defaultLabel(label1 name1: String, label2 name2: String = "Bryant") {
    print(name1 + name2)
}
defaultLabel(label1: "Kobe", label2: "Lee")  // KobeLee
defaultLabel(label1: "Kobe")                 // KobeBryant, 有默认参数可以省略
```

3.可变参数

```
func avarageNum(_ num: Double...) -> Double { // 参数后面加...表示有多个参数
    var total: Double = 0
    for number in num {
        total += number
    }
    return total/Double(num.count)
}

avarageNum(2, 6, 4, 8, 7)                     // 5.4, 参数个数不限
```

    注意: 一个函数只能有一个可变参数

4.inout改变输入参数

```
func swapTwoInts(_ a: inout Int, _ b: inout Int) {  //  加inout可以传指针
    let temp = a
    a = b
    b = temp
}
var a = 2
var b = 3
swapTwoInts(&a, &b)                     // 此处传进去的是a,b两个变量的地址
print("a=\(a), b=\(b)")                 // a=3, b=2, swapTwoInts后a,b的值改变了
```

5.函数类型

可以把一个函数当作常量或变量赋值给一个常量或者变量

```
var swap = swapTwoInts                  // swap的类型为(inout Int, inout Int) -> ()
swap(&a, &b)
print("a=\(a), b=\(b)")                 // a=2, b=3, 函数swap等价于swapTwoInts
```

6.函数参数

可以把一个函数当做参数传入另一个函数

```
func sum(num1: Int, num2: Int) -> Int { // 和
    return num1 + num2
}
func sub(num1: Int, num2: Int) -> Int { // 差
    return num1 - num2
}

func mathNumber(_ mathFunc: (Int, Int) -> Int, _ a: Int, _ b: Int) -> Int {
    return (mathFunc(a, b))
}

mathNumber(sum, 4, 2)                   // 6, 将函数作为参数传进去
mathNumber(sub, 4, 2)                   // 2
```

7.函数返回值

可以把一个函数作为另一个函数的返回值

```
func mathSumOrSub(_ isSum: Bool) -> (Int, Int) -> Int {
    return isSum ? sum : sub
}
mathSumOrSub(true)(2, 4)              // 6, mathSumOrSub(true) 等于 sum
```

8.函数嵌套

```
func mathSumOrSub(isSum: Bool, _ a: Int, _ b: Int) -> Int {
    func sum(num1: Int, num2: Int) -> Int { return num1 + num2 }
    func sub(num1: Int, num2: Int) -> Int { return num1 - num2 }

    return isSum ? sum(num1: a, num2: b) : sub(num1: a, num2: b)
}

mathSumOrSub(isSum: true, 4, 4)       // 8
```

## 1.9 闭包

闭包: 用来捕获,存储传递代码块以及常量和变量的引用

1.闭包表达语法

利用闭包去实现,闭包表达语法:
{ (参数名1: 参数类型, 参数名2: 参数类型) -> 返回类型 in
    代码块
    return 返回值
}

```	
let nums = [4, 6, 2, 9, 5]
let sortNums = nums.sorted(by: { (n1: Int, n2: Int) -> Bool in
    return n1 > n2
})
print(sortNums)                        // [9, 6, 5, 4, 2]
```
                    
2.闭包的简化	

```
let sortNums2 = nums.sorted(by: { n1, n2 in return n1 < n2}) // 根据上下文推断类型
print(sortNums2)                        // [2, 4, 5, 6, 9]

let sortNums3 = nums.sorted(by: { n1, n2 in n1 < n2}) // 隐式返回返回单行表达式
print(sortNums3)                        // [2, 4, 5, 6, 9]

let sortNums4 = nums.sorted(by: {$0 > $1})  // 内联闭包可以进行参数名缩写,in也可以省略
print(sortNums4)                        // [9, 6, 5, 4, 2], $0 $1为两个Int类型的参数

let sortNums5 = nums.sorted(by: >)      // 返回类型正好匹配
print(sortNums5)                        // [9, 6, 5, 4, 2]
```

    注意：在开发中为了代码的可读性,刻意简化的代码不提倡

3.尾随闭包:调用函数时,要将闭包作为函数的参数传递,如果太长可以写在函数括号之后

```	
let sortNums7 = nums.sorted() { $0 > $1 } // 使用尾随闭包调用函数
let sortNums8 = nums.sorted { $0 > $1 } // 这个函数只有一个参数,且是闭包表达式,还可以省略()
```

4.值捕获: 捕获变量或常量
	
```
func makeAdd(forAdd amount: Int) -> () -> Int {
    var total = 0
    func add() -> Int {
        total += amount                // 在函数体内捕获了total和amount两个变量的引用
        return total                   // 捕获保证了两个变量在makeAdd调用完并不会消失
    }
    return add                         // 并且保证在下次调用makeAdd时候total依然存在
}

let addTen = makeAdd(forAdd: 10)       // 定义了一个常量,相当于持续持有add()函数
addTen()                               // 10, 每一次调用都会将total增加10
addTen()                               // 20

let addSeven = makeAdd(forAdd: 7)      // 开辟持有了一块新的内存
addSeven()                             // 7

addTen()                               // 30,addTen和addSeven相互独立,互不影响

```

5.逃逸闭包: 当一个闭包作为参数传到一个函数中,这个闭包会在函数返回后被执行

```
var handlers: [() -> Void] = []
func funcWithEscaping(handler: @escaping () -> Void) { // 外部定义的闭包需要添加标记@escaping
    handlers.append(handler)
}

class tempClass {
    var x = 10
    func  doSomething() {
        funcWithEscaping { self.x = 100 } // 加了@escaping标记,需要显式引用self
    }
}

let instance = tempClass()

handlers.first?()
print(instance.x)                      // 100
```

## 1.10 枚举

1.定义
将一组相关的值定义成共同的类型	

```
enum compassPoint {                    // 用枚举表示指南针的四个方向
    case North                         // 枚举成员不会像OC进行隐式赋值
    case South
    case East
    case West
}
enum compassPoint2 {
    case North, South, East, West      // 成员值也可以横着写
}
```

2.使用switch语句匹配枚举值，如果省略default, 就必须穷举所有情况

3.关联值: 枚举可以存储和修改不同类型的关联值

```	
enum Person {
    case Location(Double, Double)
    case Name(String)
}
var p1 = Person.Location(87.21, 90.123)
p1 = .Name("Alex")                      // 同一时间只能存储一个值
p1 = .Name("Joan")

switch p1 {
case .Location(let x, let y):
    print("X:\(x),Y:\(y)")
case .Name(let name):
    print(name)                         // Joan
}
```

4.原始值:可以给枚举成员设置默认填充值,但类型必须一致

```	
// 原始值的隐藏赋值,当使用整数作为原始值时,隐式赋值依次递增1
enum Mouth: Int {                       // 枚举成员类型: Int
    case January = 1, February, March, April, May
}
// 在定义枚举类型的时候使用了原始值,会自动获得一个初始化方法
let secondMonth = Mouth(rawValue: 2)   // 获得的是一个可选类型
print(secondMonth)                     // Optional(Mouth.February)
```

5.递归枚举

```
enum Arth {
    case Number(Int)
    indirect case Add(Arth, Arth)      // indirect表示枚举成员可递归
    indirect case Mul(Arth, Arth)
}

let five = Arth.Number(5)
let four = Arth.Number(4)
let sum = Arth.Add(five, four)
let result = Arth.Mul(sum, Arth.Number(2))

func evaluate(express: Arth) -> Int {
    switch express {
    case .Number(let value):
        return value
    case .Add(let left, let right):
        return evaluate(express: left) + evaluate(express: right)
    case .Mul(let left, let right):
        return evaluate(express: left) * evaluate(express: right)
    }
}
print(result)   // Mul(Arth.Add(Arth.Number(5), Arth.Number(4)), Arth.Number(2))
print(evaluate(express: result))       // 18
```

## 1.11 类和结构体

1.类和结构体的值传递

结构体和枚举的值传递都是通过值拷贝
类是引用拷贝,拷贝后的值的改变会影响原来的
                    
2.类和结构体的选择

结构体: 只是用来封装少量简单的数据值;实例被赋值或传递存储的时候需要进行值拷贝,不需要用到继承
类: 需要包含复杂的属性方法,能形成一个抽象的事物描述;需要用到继承;需要用到引用拷贝

字符串,数组,字典的底层都是通过结构体实现的,所以它们在被赋值的时候都是通过值拷贝,
当然了swift在内部会做性能优化,不会是只要赋值就拷贝,只有在必要的时候才会进行值拷贝.



