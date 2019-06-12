#  Runtime

### `常用场景`
```
    1.拦截系统自带的方法调用(Method Swizzling 黑魔法)
    2.给分类增加属性
    3.字典和p模型的相互转换
    4.JSPath替换已有的OC方法实现等
```

### `简介`
```
**
    Objective-C 语言 将编译和链接的时间推迟到运行时。
    动态加载（类） 动态消息（方法） 动态属性
**
```
### `常见的相关的专业术语`
```
    1.id
    2.isa
    3.SEL
    4.imp
    
    
    
    struct objc_class {
        Class isa  OBJC_ISA_AVAILABILITY;
        
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
        
    struct method_t {
        SEL name;
        const char *types;
        IMP imp;
        
        struct SortBySELAddress :
        public std::binary_function<const method_t&,
        const method_t&, bool>
        {
        bool operator() (const method_t& lhs,
        const method_t& rhs)
        { return lhs.name < rhs.name; }
        };
    };
        
    struct objc_object 
    
    typedef struct objc_class *Class;
    typedef struct objc_object *id;
    
    
    Class 
    
```

### `消息`

### `动态方法`

### `消息转发`

### `键入编码`


### `常见的方法`
```
    objc_msgSend   
    
```



