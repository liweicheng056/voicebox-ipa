import UIKit
import WebKit

/// 老牧师语音盒 —— iOS WKWebView 壳 App
/// 原版安卓包是一个 WebView 壳，加载 H5 地址：https://apps.125ks.cn/qwyy/lms2
/// 这里用原生 WKWebView 1:1 还原同一套 H5 内容（语音库 / 实时变声 / 音效区）。
final class ViewController: UIViewController {

    private var webView: WKWebView!
    private let targetURL = URL(string: "https://apps.125ks.cn/qwyy/lms2")!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        // 允许网页内媒体无需点击直接播放（变声回放）
        cfg.mediaTypesRequiringUserActionForPlayback = []
        if #available(iOS 14.0, *) {
            let prefs = WKWebpagePreferences()
            prefs.allowsContentJavaScript = true
            cfg.defaultWebpagePreferences = prefs
        }

        webView = WKWebView(frame: .zero, configuration: cfg)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsBackForwardNavigationGestures = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loadTarget()
    }

    private func loadTarget() {
        var req = URLRequest(url: targetURL)
        req.cachePolicy = .reloadIgnoringLocalCacheData
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) "
                     + "AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
                     forHTTPHeaderField: "User-Agent")
        webView.load(req)
    }

    override var prefersStatusBarHidden: Bool { false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        // 网络不佳时自动重试
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.loadTarget()
        }
    }

    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.loadTarget()
        }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

extension ViewController: WKUIDelegate {
    // 网页内 target=_blank 的新窗口，直接在同一个 WebView 里打开
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    // iOS 15+：授权网页使用麦克风（实时变声需要）
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
}
