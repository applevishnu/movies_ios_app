import UIKit
import Flutter

class MovieFlutterViewController: FlutterViewController {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || isMovingFromParent {
            engine.viewController = nil
        }
    }
}

class MainViewController: UIViewController {

    private var flutterChannel: FlutterMethodChannel?
    private weak var currentFlutterVC: FlutterViewController?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Cinema Hub"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Native iOS host application embedding the Flutter movie module via CocoaPods."
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 72, weight: .regular)
        iv.image = UIImage(systemName: "film.stack.fill", withConfiguration: config)
        iv.tintColor = .systemRed
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let showMoviesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show List of Movies", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.systemRed.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Native Host"
        setupUI()
        setupMethodChannel()
    }

    private func setupUI() {
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(showMoviesButton)

        showMoviesButton.addTarget(self, action: #selector(didTapShowMovies), for: .touchUpInside)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -90),
            iconImageView.widthAnchor.constraint(equalToConstant: 90),
            iconImageView.heightAnchor.constraint(equalToConstant: 90),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),

            showMoviesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            showMoviesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            showMoviesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            showMoviesButton.heightAnchor.constraint(equalToConstant: 54),
        ])
    }

    private func setupMethodChannel() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let engine = appDelegate.flutterEngine

        flutterChannel = FlutterMethodChannel(
            name: "com.example.movies/bridge",
            binaryMessenger: engine.binaryMessenger
        )

        flutterChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }

            switch call.method {
            case "openTrailer":
                guard let args = call.arguments as? [String: Any],
                      let movieId = args["movieId"] as? Int,
                      let title = args["title"] as? String,
                      let overview = args["overview"] as? String,
                      let posterUrl = args["posterUrl"] as? String,
                      let trailerKey = args["trailerKey"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing expected movie payload", details: nil))
                    return
                }

                result(nil)
                self.handleOpenTrailer(
                    movieId: movieId,
                    title: title,
                    overview: overview,
                    posterUrl: posterUrl,
                    trailerKey: trailerKey
                )

            case "closeModule":
                result(nil)
                DispatchQueue.main.async { [weak self] in
                    self?.dismissFlutterModule()
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @objc private func didTapShowMovies() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // Detach previous view controller from FlutterEngine if still attached
        appDelegate.flutterEngine.viewController = nil

        let flutterViewController = MovieFlutterViewController(
            engine: appDelegate.flutterEngine,
            nibName: nil,
            bundle: nil
        )
        flutterViewController.modalPresentationStyle = .fullScreen
        self.currentFlutterVC = flutterViewController
        present(flutterViewController, animated: true)
    }

    private func dismissFlutterModule(completion: (() -> Void)? = nil) {
        guard let flutterVC = currentFlutterVC else {
            completion?()
            return
        }
        if flutterVC.isBeingDismissed {
            completion?()
            return
        }
        flutterVC.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.flutterEngine.viewController = nil
            }
            self.currentFlutterVC = nil
            completion?()
        }
    }

    private func handleOpenTrailer(
        movieId: Int,
        title: String,
        overview: String,
        posterUrl: String,
        trailerKey: String
    ) {
        // Dismiss the Flutter module view controller safely before presenting native trailer
        dismissFlutterModule { [weak self] in
            guard let self = self else { return }

            // Present the native trailer view controller
            let trailerVC = TrailerViewController(
                movieId: movieId,
                title: title,
                overview: overview,
                posterUrl: posterUrl,
                trailerKey: trailerKey
            )
            let navController = UINavigationController(rootViewController: trailerVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
}
