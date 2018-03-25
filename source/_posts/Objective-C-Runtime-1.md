---
title: Objective-C Runtime - 基础结构
date: 2015-08-01 22:12:18
categories:
- 技术
tags:
- iOS
- Runtime
---

## 概述

Objective-C 在 C 语言的基础上，借鉴了 Smalltalk 的面向对象与消息机制，扩展了 C 语言，这个扩展的核心是一个用 C 和 编译语言 写的 Runtime 库，它是 Objective-C 面向对象和动态机制的基石。Objective-C Runtime 使得 C 具有了面向对象能力，在程序运行时创建，检查，修改类、对象和它们的方法。理解 Objective-C 的 Runtime 机制可以帮我们更好的了解这个语言，适当的时候还能对语言进行扩展，从系统层面解决项目中的一些设计或技术问题。了解 Runtime ，要先了解它的基础 - 基础结构。[这里](https://opensource.apple.com/tarballs/objc4/) 可以下载到 Runtime 的源码来研究。

<!--more-->

## 基础结构

### Class

#### objc_class

在 Objective-C 中的类在 Runtime 中是用 `Class` 来表示的，`Class`  是一个 `struct objc_class` 类型的指针，`struct objc_class` 才是保存真正数据的地方，也就是说任何一个类都是用 `objc_class` 这样一个结构体来描述的，其定义为：

```C
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;

struct objc_class {
    Class isa;

#if !__OBJC2__
    Class super_class                                        OBJC2_UNAVAILABLE;
    const char *name                                         OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;
    struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache *cache                                 OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
/* Use `Class` instead of `struct objc_class *` */
```

> 具体解释一下：

> **isa**：对象的 isa 指针指向它的类，而在 OC 中，类本身也是一个对象，这个对象的 Class 里面也有一个 isa 指针，指向 `Meta Class` （元类，这个后面再具体介绍）

> **super_class**：指向该类的父类，如果该类已经是最顶层的根类 (如 NSObject 或 NSProxy)，则 super_class 为 NULL

> **name**：类名

> **version**：类的版本信息，默认为 0，这对于对象的序列化非常有用，它可是让我们识别出不同类定义版本中实例变量布局的改变

> **info**：类信息，运行时使用的一些位标识。

> **instance_size**：该类的实例变量大小

> **ivars**：该类的成员变量链表，NULL代表没有实例变量，不包括父类的变量

> **methodLists**：该类的方法定义的链表

> **cache**：该类的方法缓存，后面具体讲 cache 的作用。

> **protocols**：该类的协议链表


可见，我们平常调用的 `[NSObject class]` 方法就是返回这样一个指向其类结构的指针。

### id & Object

#### id

在 Objective-C 中 id 表示通用对象类型，可以转换为任何数据类型，即 id类型的变量可以存放任何数据类型的对象。id 的定义为：

```C
/// A pointer to an instance of a class.
typedef struct objc_object *id;
```

id，是一个 `objc_object` 结构类型的指针，它的存在可以让我们实现类似于C++ 中泛型的一些操作。该类型的对象可以转换为任何一种对象，有点类似于C语言中void *指针类型的作用。

#### objc_object

`struct objc_object` 的声明如下：

```C
/// Represents an instance of a class.
struct objc_object {
    Class isa  OBJC_ISA_AVAILABILITY;
};
```

可以看到，`struct objc_object` 中有一个指向其类的 isa 指针。向一个对象发送消息时，Runtime 库会根据对象 object 的 isa 指针找到 object 所属于的类，然后在类的方法列表以及父类方法列表寻找对应的方法运行。

#### id 与 NSObject

`NSObject` 的定义：

```C
@interface NSObject <NSObject> {
    Class    isa;
}
```

可以看出 NSObject 的第一个成员实例是 Class 类型的 isa 指针，而 id 是一个指向 objc_object 结构体的指针，该结构体只有一个成员 isa，所以任何继承自 NSObject 的类对象都可以用id 来指代，因为第一个元素相同，也就意味着可以互相 cast 而不损失信息。

可见，每一个基于 NSObject 的类的实例对象都有一个指向该对象的类结构的指针，叫做 isa，通过该指针，对象可以访问它对应的类以及相应的父类。

### Ivar

#### objc_ivar

在 Objective-C 中的实例变量在 Runtime 中是用 `Ivar` 来表示的，其定义为：

```C
/// An opaque type that represents an instance variable.
typedef struct objc_ivar *Ivar;

struct objc_ivar {
    char *ivar_name                                          OBJC2_UNAVAILABLE;
    char *ivar_type                                          OBJC2_UNAVAILABLE;
    int ivar_offset                                          OBJC2_UNAVAILABLE;
#ifdef __LP64__
    int space                                                OBJC2_UNAVAILABLE;
#endif
}                                                            OBJC2_UNAVAILABLE;
```

> **ivar_name**：变量名
> **ivar_type**：变量类型
> **ivar_offset**：实例结构的基地址偏移字节

可以看出 `Ivar` 是一个指向 `struct objc_ivar` 类型的指针，`Ivar` 指针地址是根据 class 结构体的地址加上基地址偏移字节 `ivar_offset` 得到的。

#### objc_ivar_list

在 `objc_class` 中，所有的实例变量（成员变量、属性）的信息是放在链表 ivars 中的，ivars 是一个指向 `struct objc_ivar_list` 类型的指针，`objc_ivar_list` 结构体存储了 `objc_ivar` 的数组列表，`struct objc_ivar_list` 的声明如下：

```C
struct objc_ivar_list {
    int ivar_count                                           OBJC2_UNAVAILABLE;
#ifdef __LP64__
    int space                                                OBJC2_UNAVAILABLE;
#endif
    /* variable length structure */
    struct objc_ivar ivar_list[1]                            OBJC2_UNAVAILABLE;
} 
```

### Method

#### objc_method

Objective-C 中的方法在 Runtime 中是用 `Method` 来表示的，其定义为：

```C
/// An opaque type that represents a method in a class definition.
typedef struct objc_method *Method;

struct objc_method {
    SEL method_name                                          OBJC2_UNAVAILABLE;
    char *method_types                                       OBJC2_UNAVAILABLE;
    IMP method_imp                                           OBJC2_UNAVAILABLE;
}
```

> **method_name**：表示方法名称
> **method_types**：方法的参数类型
> **method_imp**：指向该方法的具体实现的函数指针

#### SEL

`SEL` 表示该方法的名字/签名，定义如下：

```C
/// An opaque type that represents a method selector.
typedef struct objc_selector     *SEL;
```

没有找到 `struct objc_selector` 的定义，从一些博客文章上看到过可以将 `SEL` 理解为一个 `char*` 指针，可以猜测到 `struct objc_selector` 的定义为：

```C
struct objc_selector  {
    char name[64 or ...];

    ...
};
```

只要遵循如上原型，就可以将 `SEL` 理解为一个 `char*`。

#### IMP

`IMP` 是一个函数指针，定义如下：

```C
/// A pointer to the function of a method implementation. 
typedef id (*IMP)(id, SEL, ...); 
```

这个被指向的函数包含一个接收消息的对象（id 类型）, 一个调用方法的名称（SEL 类型），以及不定个数的方法参数，并返回一个 id。也就是说 IMP 是消息最终调用的执行代码，是方法真正的实现代码。我们可以像在Ｃ语言里面一样使用这个函数指针。

NSObject 类中的方法 `- (IMP)methodForSelector:(SEL)aSelector` 的作用就是可以获取指向方法实现 IMP 的指针，返回的指针和赋值的变量类型必须完全一致，包括方法参数类型和返回值类型。

#### objc_method_list

`objc_class` 中的方法列表 `methodLists` 是一个二级指针，一个指向结构体 `objc_method_list` 的二级指针，指针变量当中存的是一个地址，你可以改变这个地址的值从而改变最终指向的变量。动态的修改 `*methodLists` 的值来添加方法，这也是实现 category 的原理。

`struct objc_method_list` 的声明如下：

```C
struct objc_method_list {
    struct objc_method_list *obsolete                        OBJC2_UNAVAILABLE;

    int method_count                                         OBJC2_UNAVAILABLE;
#ifdef __LP64__
    int space                                                OBJC2_UNAVAILABLE;
#endif
    /* variable length structure */
    struct objc_method method_list[1]                        OBJC2_UNAVAILABLE;
}
```

### Category

#### objc_category

Runtime 中 `Category` 是一个指向分类的结构体的指针，定义如下：

```C
/// An opaque type that represents a category.
typedef struct objc_category *Category;

struct objc_category {
    char *category_name                                      OBJC2_UNAVAILABLE;
    char *class_name                                         OBJC2_UNAVAILABLE;
    struct objc_method_list *instance_methods                OBJC2_UNAVAILABLE;
    struct objc_method_list *class_methods                   OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
}
```

> **category_name**：分类名
> **class_name**：分类所属的类名
> **instance_methods**：实例方法列表
> **class_methods**：类方法列表，Meta Class方法列表的子集
> **protocols**：分类所遵循的协议列表

可以看出，`Catagory` 可以动态地为已经存在的类添加新的实例方法，类方法，协议。后面再单独介绍 `Category` 里面的方法加载过程。

### Protocol

#### Protocol

Runtime 中 `Protocol` 其实就是一个对象结构体，定义如下：

``` C
typedef struct objc_object Protocol
```

#### objc_protocol_list

在 `objc_class` 中，所有实现的协议是放在链表 protocols 中的，protocols 是一个指向 `struct objc_protocol_list` 类型的指针，`objc_protocol_list` 结构体存储了 `Protocol` 的数组列表，`struct objc_protocol_list` 的声明如下：

```C
struct objc_protocol_list {
    struct objc_protocol_list *next;
    long count;
    Protocol *list[1];
};
```

### objc_property_t

```C
/// An opaque type that represents an Objective-C declared property.
typedef struct objc_property *objc_property_t;
```

没有找到 `struct objc_property` 的定义，但看了下 `objc_runtime-new`
 中有个 `struct property_t` 的定义：

```C
struct property_t {
    const char *name;
    const char *attributes;
};
```

### Cache

#### objc_cache

Runtime 中的 `Cache` 定义为：

```C
typedef struct objc_cache *Cache                             OBJC2_UNAVAILABLE;

struct objc_cache {
    unsigned int mask /* total = mask + 1 */                 OBJC2_UNAVAILABLE;
    unsigned int occupied                                    OBJC2_UNAVAILABLE;
    Method buckets[1]                                        OBJC2_UNAVAILABLE;
};
```

`objc_class` 结构体中的 cache 字段用于缓存调用过的 method，cache 指针指向 `objc_cache` 结构体。

当对象接到一个消息时，会根据 isa 指针查找能够响应这个消息的对象，这时会在 methodLists 中遍历，在实际使用中，这个对象只有一部分方法是常用的，很多方法其实很少用或者根本用不上，如果每次消息来时，我们都是在 methodLists 中遍历一遍，性能会很差。cache 的作用就是在每次调用过一个方法后，把这个方法缓存到 cache 列表中，下次调用的时候 Runtime 就会优先去 cache 中查找，如果 cache 没有，才去methodLists 中查找方法，找到后再放到 cache 中，下次使用时就会直接在 cache 中找到，这样，对于那些经常用到的方法的调用，提高了调用的效率。

## 总结

本文主要从 `objc_class` 开始，围绕 `objc_class` 介绍了 Runtime 运行时中的一些最基本的数据结构，通过这些数据结构，我们可以大概了解 Objective-C 底层面向对象实现的一些信息。下文继续讲 Runtime 中的类与对象，MetaClass 等相关的内容。

## 参考

http://www.cnblogs.com/whyandinside/archive/2013/02/26/2933552.html

https://ming1016.github.io/2015/04/01/objc-runtime/

