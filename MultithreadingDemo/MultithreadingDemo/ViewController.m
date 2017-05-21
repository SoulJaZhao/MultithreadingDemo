//
//  ViewController.m
//  MultithreadingDemo
//
//  Created by SoulJa on 2017/5/21.
//  Copyright © 2017年 com.soulja. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()
- (IBAction)clickPThread;

- (IBAction)clickNSThread;

- (IBAction)clickGCD;

- (IBAction)clickNSOperation;

@property (nonatomic,strong) NSOperationQueue *operQueue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickPThread {
    /**
     参数：
     1> 指向线程标识符的指针，C 语言中类型的结尾通常 _t/Ref，而且不需要使用 *
     2> 用来设置线程属性
     3> 线程运行函数的起始地址
     4> 运行函数的参数
     
     返回值：
     - 若线程创建成功，则返回0
     - 若线程创建失败，则返回出错编号
     */
    pthread_t threadId = NULL;
    NSString *str = @"Hello Pthread";
    // 这边的demo函数名作为第三个参数写在这里可以在其前面加一个&，也可以不加，因为函数名就代表了函数的地址。
    int result = pthread_create(&threadId, NULL, demo, (__bridge void *)(str));
    
    if (result == 0) {
        NSLog(@"创建线程 OK");
    } else {
        NSLog(@"创建线程失败 %d", result);
    }
    // pthread_detach:设置子线程的状态设置为detached,则该线程运行结束后会自动释放所有资源。
    pthread_detach(threadId);
    
}

- (IBAction)clickNSThread {
    //1.通过alloc init方式创建并执行线程
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(runThread) object:nil];
    [thread1 setName:@"thread1"];
    [thread1 setThreadPriority:0.5];
    [thread1 start];
    
    //2.通过detachMewThreadSelector
    [NSThread detachNewThreadSelector:@selector(runThread) toTarget:self withObject:nil];
    
    //3.通过performSelectorInBackground 方式创建
    [self performSelectorInBackground:@selector(runThread) withObject:nil];
}

- (IBAction)clickGCD {
      //并行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //执行耗时任务
        [NSThread sleepForTimeInterval:3.0];
        dispatch_async(dispatch_get_main_queue(), ^{
            //回到主线程刷新UI
            NSLog(@"刷新UI");
        });
    });
    
    //串行
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(myQueue, ^{
        //执行耗时任务
        NSLog(@"start task 1");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"end task 1");
    });
    
    dispatch_async(myQueue, ^{
        //执行耗时任务
        NSLog(@"start task 2");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"end task 2");
    });
    
    dispatch_async(myQueue, ^{
        //执行耗时任务
        NSLog(@"start task 3");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"end task 3");
    });
    
    //线程组
    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"start task 1");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"end task 1");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"start task 2");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"end task 2");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"start task 3");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"end task 3");
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"All tasks over");
    });
}

- (IBAction)clickNSOperation {
    NSInvocationOperation *invocationOper = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationAction) object:nil];
    [invocationOper start];
    
    NSBlockOperation *blockOper = [NSBlockOperation blockOperationWithBlock:^{
        [self invocationAction];
    }];
    [blockOper start];
    
    if (self.operQueue) {
        self.operQueue = [[NSOperationQueue alloc] init];
        self.operQueue.maxConcurrentOperationCount = 10;
    }
    
    [self.operQueue addOperation:blockOper];
    [self.operQueue addOperation:invocationOper];
    
    [blockOper addDependency:invocationOper];
    NSLog(@"end");
}

- (void)invocationAction {
    for (int i = 0;i<3;i++) {
        NSLog(@"invocation %d",i);
        [NSThread sleepForTimeInterval:1.0];
    }
}

- (void)runThread {
    //锁机制
    @synchronized (self) {
        for (int i = 0; i<=10; i++) {
            NSLog(@"%d",i);
            sleep(1);
        }
    }
}

// 后台线程调用函数
void *demo(void *params) {
    NSString *str = (__bridge NSString *)(params);
    
    NSLog(@"%@ - %@", [NSThread currentThread], str);
    
    return NULL;
}
@end
