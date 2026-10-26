import UIKit
import WebKit

class TrailerViewController: UIViewController {

    private let movieId: Int
    private let movieTitle: String
    private let overviewText: String
    private let posterUrl: String
    private let trailerKey: String

    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.backgroundColor = .black
        wv.isOpaque = false
        wv.scrollView.isScrollEnabled = false
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let overviewHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Overview"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(movieId: Int, title: String, overview: String, posterUrl: String, trailerKey: String) {
        self.movieId = movieId
        self.movieTitle = title
        self.overviewText = overview
        self.posterUrl = posterUrl
        self.trailerKey = trailerKey
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Trailer"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(didTapClose)
        )

        setupLayout()
        populateData()
        loadTrailer()
    }

    private func setupLayout() {
        view.addSubview(webView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(badgeLabel)
        contentView.addSubview(overviewHeaderLabel)
        contentView.addSubview(overviewLabel)

        let webViewHeight = view.bounds.width * (9.0 / 16.0)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: webViewHeight),

            scrollView.topAnchor.constraint(equalTo: webView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            badgeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            badgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            badgeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            overviewHeaderLabel.topAnchor.constraint(equalTo: badgeLabel.bottomAnchor, constant: 24),
            overviewHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overviewHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            overviewLabel.topAnchor.constraint(equalTo: overviewHeaderLabel.bottomAnchor, constant: 8),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
        ])
    }

    private func populateData() {
        titleLabel.text = movieTitle
        badgeLabel.text = "YouTube Key: \(trailerKey) • Movie ID: \(movieId)"
        overviewLabel.text = overviewText.isEmpty ? "No overview provided." : overviewText
    }

    private func loadTrailer() {
        let embedHtml = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body { margin: 0; background-color: #000; display: flex; justify-content: center; align-items: center; height: 100vh; }
                iframe { width: 100%; height: 100%; border: none; }
            </style>
        </head>
        <body>
            <iframe src="https://www.youtube.com/embed/\(trailerKey)?autoplay=1&playsinline=1"
                    allow="autoplay; encrypted-media"
                    allowfullscreen>
            </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(embedHtml, baseURL: URL(string: "https://www.youtube.com"))
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}
