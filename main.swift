import UIKit

// 入口：以 AppDelegate 作为 UIApplication 的代理类。
// 不使用 Storyboard / Scene，全部用代码构建 UI。
let argv = UnsafeMutableRawPointer(CommandLine.unsafeArgv)
    .bindMemory(to: UnsafeMutablePointer<CChar>?.self, capacity: Int(CommandLine.argc))
_ = UIApplicationMain(
    CommandLine.argc,
    argv,
    nil,
    NSStringFromClass(AppDelegate.self)
)
