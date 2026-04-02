import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard
      let window,
      let flutterViewController = window.rootViewController as? FlutterViewController,
      !(window.rootViewController is NativeBackNavigationController)
    else {
      return
    }

    let navigationController = NativeBackNavigationController(
      flutterViewController: flutterViewController
    )
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
  }
}

final class NativeBackNavigationController: UINavigationController {
  private let rootFlutterViewController: FlutterViewController
  private lazy var bridge = NativeBackButtonChannelBridge(
    messenger: flutterBinaryMessenger,
    onVisibilityChanged: { [weak self] visible in
      self?.setBackButtonVisible(visible)
    }
  )

  private var flutterBinaryMessenger: FlutterBinaryMessenger {
    rootFlutterViewController.binaryMessenger
  }

  init(flutterViewController: FlutterViewController) {
    self.rootFlutterViewController = flutterViewController
    super.init(rootViewController: flutterViewController)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    _ = bridge
    navigationBar.prefersLargeTitles = false
    navigationBar.tintColor = .label
    topViewController?.navigationItem.leftBarButtonItem = makeBackBarButtonItem()
    setNavigationBarHidden(true, animated: false)
  }

  private func setBackButtonVisible(_ visible: Bool) {
    UIView.performWithoutAnimation {
      topViewController?.navigationItem.leftBarButtonItem = visible
        ? makeBackBarButtonItem()
        : nil
      setNavigationBarHidden(!visible, animated: false)
      navigationBar.layoutIfNeeded()
    }
  }

  private func makeBackBarButtonItem() -> UIBarButtonItem {
    let configuration = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    let image = UIImage(systemName: "chevron.backward", withConfiguration: configuration)
    return UIBarButtonItem(
      image: image,
      style: .plain,
      target: self,
      action: #selector(handleBackButtonTap)
    )
  }

  @objc
  private func handleBackButtonTap() {
    bridge.sendBackPressed()
  }
}

private final class NativeBackButtonChannelBridge: NSObject {
  private let channel: FlutterMethodChannel
  private let onVisibilityChanged: (Bool) -> Void

  init(
    messenger: FlutterBinaryMessenger,
    onVisibilityChanged: @escaping (Bool) -> Void
  ) {
    self.channel = FlutterMethodChannel(
      name: "accord/native_back_button",
      binaryMessenger: messenger
    )
    self.onVisibilityChanged = onVisibilityChanged
    super.init()
    channel.setMethodCallHandler(handleMethodCall)
    channel.invokeMethod("nativeBackButtonReady", arguments: nil)
  }

  func sendBackPressed() {
    channel.invokeMethod("nativeBackPressed", arguments: nil)
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setBackButtonVisible":
      let visible = (call.arguments as? Bool) ?? false
      DispatchQueue.main.async {
        self.onVisibilityChanged(visible)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
