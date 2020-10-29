//
//  ViewController.swift
//  taskapp
//
//  Created by 家城苑佳 on 2020/10/23.
//  Copyright © 2020 sonoka.yashiro. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    //検索バーを押した時に呼ぶメソッド
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        //条件として検索文字がcategoryと一致するものを検索
        let result = realm.objects(Task.self).filter("category == %@", searchBar.text!)

        //検索結果の件数を取得
        let count = result.count
        print(count)
        if count == 0{//検索結果が0の場合
            taskArray = realm.objects(Task.self)//Task.selfはTask自身
        } else {//検索結果がある場合
            taskArray = result
            tableView.reloadData()
        }
  
    }
    
    @IBOutlet weak var tableView: UITableView!
    // Realmインスタンスを取得する
    let realm = try! Realm()
    // DB内のタスクが格納されるリスト
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self//L6課題
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
 
    //データの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
   // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // 再利用可能な cell を得る
       let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
       // Cellに値を設定する.
       let task = taskArray[indexPath.row]
       cell.textLabel?.text = task.title

       let formatter = DateFormatter()
       formatter.dateFormat = "yyyy-MM-dd HH:mm"

       let dateString:String = formatter.string(from: task.date)
       cell.detailTextLabel?.text = dateString

       return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //削除するタスクを取得
            let task = taskArray[indexPath.row]
            //ローカル通知をキャンセル
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
                }
            }
       }
    }
    //cellSegueで画面遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
   
    //入力画面から戻ってきたときにTabelViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    


}

