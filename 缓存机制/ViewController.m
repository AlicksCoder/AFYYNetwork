//
//  ViewController.m
//  缓存机制
//
//  Created by Mac on 16/11/10.
//  Copyright © 2016年 Zhu. All rights reserved.
//

#import "ViewController.h"

#import "HCNetwork.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btn:(id)sender {
    
    NSDictionary *dict = @{@"shop_id":@"189"}; //请求参数
    
    [HCNetwork WEBGET:@"http://siteinterface.360manager.cn/index.php/Content/getshopdetail" parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        
    } showHUD:YES];
}
- (IBAction)json:(id)sender {
    
    [HCNetwork GET:@"http://jrapi.86tudi.com/Account/login" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    } showHUD:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
