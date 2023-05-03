//
//  ViewController.swift
//  TableViewWithActivityIndicator
//
//  Created by Apex on 3/5/2566 BE.
//

import UIKit
final class DataFatcher {
    private(set) var isBeingLoaded = false
    private var iteration = 1
    
    func fetchData(completionHandler: @escaping ([String]) -> Void) {
        isBeingLoaded = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            let array = Array(1...10).map { cellNum in
                "iteration: \(self!.iteration): cell: \(cellNum)"
            }
            
            completionHandler(array)
            self?.isBeingLoaded = false
            self?.iteration += 1
        }
    }
}
final class Cell: UITableViewCell {
    static let reusableCell = "Cell"
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.frame = contentView.frame
        contentView.backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ text: String) {
        self.label.text = text
    }
}

class ViewController: UIViewController {
    private let fetcher = DataFatcher()
    private let tableView = UITableView()
    private let footer: UIView = {
        let footerRect = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 50
        )
        let footer = UIView(frame: footerRect)
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        footer.addSubview(activityIndicator)
        activityIndicator.center = footer.center
        footer.backgroundColor = .green
        return footer
    }()
    
    private var arrayOfSections = [["Initial"]] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTV()
    }
    
    private func setUpTV() {
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.reusableCell)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayOfSections[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Section number: \(section)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reusableCell, for: indexPath) as! Cell
        cell.setText(arrayOfSections[indexPath.section][indexPath.row])
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        arrayOfSections.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomPosition = scrollView.contentSize.height - scrollView.bounds.size.height
        
        if scrollView.contentOffset.y > bottomPosition {
            if fetcher.isBeingLoaded == true {
                tableView.tableFooterView = footer
            } else {
                fetcher.fetchData { [weak self] newArrayOfTitles in
                    self?.arrayOfSections.append(newArrayOfTitles)
                    self?.tableView.tableFooterView = nil
                }
            }
        }
    }
}
