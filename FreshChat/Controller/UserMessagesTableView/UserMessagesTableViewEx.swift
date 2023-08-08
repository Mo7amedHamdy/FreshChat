//
//  UserMessagesTableViewEx.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 25/10/2022.
//

import UIKit
import FirebaseAuth

//table view data source and delegate
extension UserMessagesViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionsCount = groupedMessages.count
        return sectionsCount
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    //view for footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! CustomHeader
        //to remove the visual effect of footer
        var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
        backgroundConfig.visualEffect = nil //coooooool🥳🥳
        footer.backgroundConfiguration = backgroundConfig
        let messageTime = groupedMessages[section].messages[0].sendTime
        let headerDateString = configureDateFormatForHeader(messageTime)
        footer.dateLabel.text = headerDateString
        //for reversed table
        footer.transform = CGAffineTransform(scaleX: 1, y: -1)
       return footer
    }
    
    //hide pinned header
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showPinnedHeadersDuringScroll()
        hideFooter = false
        isFetching = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let work = DispatchWorkItem {
            if self.hideFooter == false {
                self.removePinnedHeadersAfterScroll2()
                print("removed Pinned header 3434343434")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: work)
    }
    
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //this activate end dragging in case of scrollView.isDecelerating = false
        hideFooter = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if chatTable.contentOffset.y < chatTable.contentSize.height - chatTable.frame.height {
            removePinnedHeadersAfterScroll2()  //was scroll not 2
        }
        let indexPath = IndexPath(row: (groupedMessages.last?.messages.count)! - 1, section: groupedMessages.count - 1)
        if !isFetching && chatTable.indexPathsForVisibleRows?.last == indexPath {
            loadNextBatch()
        }
    }

    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexP in indexPaths {
            let indexPath = IndexPath(row: (groupedMessages.last?.messages.count)! - 3, section: groupedMessages.count - 1)
            if indexP >= indexPath && !isFetching {
                loadNextBatch()
                print("xxxxxxxxxxxxx")
                break
            }
        }
    }
    
    //to start animating activity indicator
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.section == groupedMessages.count - 1 && indexPath.row == (groupedMessages.last?.messages.count)! - 9 && !isFetching {
////            chatTable.tableFooterView = configureActivityIndicator()
////            chatTable.tableFooterView?.alpha = 0  //TODO study this
//            self.loadNextBatch()
//        }
//    }
    
    //todo check this..... when tap on hour 
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        let offsetY = chatTable.contentSize.height - chatTable.frame.height
        chatTable.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        return false
    }
    
    //configure activity indicator
    func configureActivityIndicator() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 35))
        let activity = UIActivityIndicatorView()
        activity.center = view.center
        view.addSubview(activity)
        activity.startAnimating()
        return view
    }

    //show pinned header during scroll
    func showPinnedHeadersDuringScroll() {
        for section in 0..<groupedMessages.count {
            let header = chatTable.footerView(forSection: section)
            header?.alpha = 1.0
        }
    }

    //hide pinned header after scroll
//    func removePinnedHeadersAfterScroll() {
//        if let indexPathsForVisibleRows = chatTable.indexPathsForVisibleRows {
//            if indexPathsForVisibleRows.count > 0 {
//                for indexPathForVisibleRow in indexPathsForVisibleRows {
//                    if let header = chatTable.footerView(forSection: indexPathForVisibleRow.section) {
//                        if let cell = chatTable.cellForRow(at: indexPathForVisibleRow) {
//                            if header.frame.intersects(cell.frame) {
//                                let seconds = 0.3
//                                let delay = seconds * Double(NSEC_PER_SEC)
//                                let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
//                                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
//                                    if header.frame.intersects(cell.frame) {
//                                        UIView.animate(withDuration: 0.3, delay: 0.0) {
//                                            header.alpha = 0.0
//
//                                        }
//                                    }
//                                })
//                                break
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    //hide pinned footer after scroll
    func removePinnedHeadersAfterScroll2() {
        if let indexPathsForVisibleRows = chatTable.indexPathsForVisibleRows {
            if indexPathsForVisibleRows.count > 0 {
//                for indexPathForVisibleRow in indexPathsForVisibleRows {
                if let header = chatTable.footerView(forSection: (indexPathsForVisibleRows.last?.section)!) as? CustomHeader {
                    if let cell = chatTable.cellForRow(at: (indexPathsForVisibleRows.last)!) as? MessageCell {
//                        if header.dateLabel.frame.intersects(cell.messageBubbleStack.frame) {
                        let frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.width, height: cell.frame.height - 5)
                        if header.frame.intersects(frame) {
//                                let seconds = 0.3
//                                let delay = seconds * Double(NSEC_PER_SEC)
//                                let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
//                                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
//                                    if header.frame.intersects(cell.frame) {
                                        UIView.animate(withDuration: 0.6) {
                                            header.alpha = 0.0
                                            
                                        }
//                                    }
//                                })
                            }
                        }
                    }
//                }
            }
        }
    }

    
    //hide pinned header when start messages view controller
    func removePinnedHeadersAtStart() {
        if let indexPathsForVisibleRows = chatTable.indexPathsForVisibleRows {
            if indexPathsForVisibleRows.count > 0 {
//                for indexPathForVisibleRow in indexPathsForVisibleRows {
                if let footer = chatTable.footerView(forSection: indexPathsForVisibleRows.last!.section) {
                    if let cell = chatTable.cellForRow(at: indexPathsForVisibleRows.last!) {
                        let frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.width, height: cell.frame.height - 5)
                        if footer.frame.intersects(frame) {
                            footer.alpha = 0.0
                        }
                    }
                }
//                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let messagesCount = groupedMessages[section].messages.count
        return messagesCount
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let index = indexForEdit {
            return indexPath != index
        }
        return true
    }
    
    //configure cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //cell for unread messages
        if indexPath.row == indexForEdit?.row && indexPath.section == indexForEdit?.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: "unread", for: indexPath) as! UnReadMessageTextTableViewCell
            cell.transform = CGAffineTransform(scaleX: 1, y: -1)
            let message = groupedMessages[indexPath.section].messages[indexPath.row]
            cell.unReadTextLabel.text = message.body
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        
        let cellWithCheckMark = tableView.dequeueReusableCell(withIdentifier: "messageCellWithCheckMark", for: indexPath) as! MessageCell
        cellWithCheckMark.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        let cell2WithCheckMark = tableView.dequeueReusableCell(withIdentifier: "messageCell2WithCheckMark", for: indexPath) as! MessageCell
        cell2WithCheckMark.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "messageCell2", for: indexPath) as! MessageCell
        cell2.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        let cellForUnReadMessage = tableView.dequeueReusableCell(withIdentifier: "unread", for: indexPath) as! UnReadMessageTextTableViewCell
        cellForUnReadMessage.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        let sectionMessages = groupedMessages[indexPath.section].messages
        let message = sectionMessages[indexPath.row]
        
        //for current user
        cellWithCheckMark.messageLabel.text = message.body
        cellWithCheckMark.messageLabel.decideTextDirection()  //cool func
        cellWithCheckMark.messageTimeLabel.text = configureDateFormatForMessage(message.sendTime)
        if let checkmark = message.messageState {
            if checkmark == "sent" { //TODO this with enum and switch cases
                cellWithCheckMark.imageViewCheckMark.alpha = 1
                cellWithCheckMark.imageViewCheckMark.tintColor = .systemGray4
            }
            else if checkmark == "delivered" {
                cellWithCheckMark.imageViewCheckMark.alpha = 1
                cellWithCheckMark.imageViewCheckMark2.alpha = 1
                cellWithCheckMark.imageViewCheckMark.tintColor = .systemGray4
                cellWithCheckMark.imageViewCheckMark2.tintColor = .systemGray4
            }
            else if checkmark == "seen" {
                cellWithCheckMark.imageViewCheckMark.alpha = 1
                cellWithCheckMark.imageViewCheckMark2.alpha = 1
                cellWithCheckMark.imageViewCheckMark.tintColor = .green
                cellWithCheckMark.imageViewCheckMark2.tintColor = .green
            }
        }
        
        cell2WithCheckMark.messageLabel.text = message.body
        cell2WithCheckMark.messageLabel.decideTextDirection()  //cool func
        cell2WithCheckMark.messageTimeLabel.text = configureDateFormatForMessage(message.sendTime)
        if let checkmark = message.messageState {
            if checkmark == "sent" { //TODO this with enum and switch cases
                cell2WithCheckMark.imageViewCheckMark.alpha = 1
                cell2WithCheckMark.imageViewCheckMark.tintColor = .systemGray4
            }
            else if checkmark == "delivered" {
                cell2WithCheckMark.imageViewCheckMark.alpha = 1
                cell2WithCheckMark.imageViewCheckMark2.alpha = 1
                cell2WithCheckMark.imageViewCheckMark.tintColor = .systemGray4
                cell2WithCheckMark.imageViewCheckMark2.tintColor = .systemGray4
            }
            else if checkmark == "seen" {
                cell2WithCheckMark.imageViewCheckMark.alpha = 1
                cell2WithCheckMark.imageViewCheckMark2.alpha = 1
                cell2WithCheckMark.imageViewCheckMark.tintColor = .green
                cell2WithCheckMark.imageViewCheckMark2.tintColor = .green
            }
        }
        
        //for other user
        cell.messageLabel.text = message.body
        cell.messageLabel.decideTextDirection()  //cool func
        cell.messageTimeLabel.text = configureDateFormatForMessage(message.sendTime)
        
        cell2.messageLabel.text = message.body
        cell2.messageLabel.decideTextDirection()  //cool func
        cell2.messageTimeLabel.text = configureDateFormatForMessage(message.sendTime)
        
        //Mark:- add cell for unread messages that coming from notifications
        if isPushingBackgroundNotificationToApp == true && message.roomId == "unreadmessages9999" {
            cellForUnReadMessage.unReadTextLabel.text = message.body
            return cellForUnReadMessage
        }
        
        //leading and trailing messages
        if message.sender == Auth.auth().currentUser?.email {
            //cell1
            cellWithCheckMark.messageBubbleStack.alignment = .trailing
            cellWithCheckMark.messageBubbleView.backgroundColor = .link
            cellWithCheckMark.messageLabel.textColor = .white
            cellWithCheckMark.messageTimeLabel.textColor = .systemGray4
            
            //cell2
            cell2WithCheckMark.messageBubbleStack.alignment = .trailing
            cell2WithCheckMark.messageBubbleView.backgroundColor = .link
            cell2WithCheckMark.messageLabel.textColor = .white
            cell2WithCheckMark.messageTimeLabel.textColor = .systemGray4
        }
        else {
            //cell1 for other user
            cell.messageBubbleStack.alignment = .leading
            cell.messageBubbleView.backgroundColor = .systemGray5
            cell.messageLabel.textColor = .black
            cell.messageTimeLabel.textColor = .link
            
            //cell2
            cell2.messageBubbleStack.alignment = .leading
            cell2.messageBubbleView.backgroundColor = .systemGray5
            cell2.messageLabel.textColor = .black
            cell2.messageTimeLabel.textColor = .link
        }
        
        //draw chat bubble with tail or not
        if sectionMessages.count == 1 {
            //draw with tail - section contains one message
            if indexPath.section == 0 {
                if message.sender == Auth.auth().currentUser?.email {
                    cellWithCheckMark.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                }
                else {
                    cell.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                    return cell
                }
            }
            else {
                if message.sender == Auth.auth().currentUser?.email {
                    cell2WithCheckMark.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                    return cell2WithCheckMark
                }
                else {
                    cell2.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                    return cell2
                }
            }
        }
        else { //section contains more than one mesage
            let messageToCompare = sectionMessages.first  //first message in array is the last message in transform table
            if message.messageId == messageToCompare?.messageId && message.sender == messageToCompare?.sender {
                //draw with tail
                if indexPath.section == 0 {
                    if message.sender == Auth.auth().currentUser?.email {
                        cellWithCheckMark.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                    }
                    else {
                        cell.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                        return cell
                    }
                }
                else {
                    if message.sender == Auth.auth().currentUser?.email {
                        cell2WithCheckMark.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                        return cell2WithCheckMark
                    }
                    else {
                        cell2.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                        return cell2
                    }
                }
            }
            else {
                //draw without tail
                let PreviousMessage = sectionMessages[indexPath.row - 1]
                if message.sender == PreviousMessage.sender {
                    if message.sender == Auth.auth().currentUser?.email {
                        cellWithCheckMark.messageBubbleView.checkMessageSender(message: message, drawWithTail: false)
                    }
                    else {
                        cell.messageBubbleView.checkMessageSender(message: message, drawWithTail: false)
                        return cell
                    }
                }
                else {
//                    draw with tail and use of cell2
                    if message.sender == Auth.auth().currentUser?.email {
                        cell2WithCheckMark.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                        return cell2WithCheckMark
                    }
                    else {
                        cell2.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                        return cell2
                    }
                }
            }
        }
        return cellWithCheckMark
    }
    
    //time interval into date
    func configureDateFormatForMessage(_ time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let timeText = date.formatted(date: .omitted, time: .shortened)
        return String(format: "%@", timeText)
    }
    
    func configureDateFormatForHeader(_ time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dayText = date.formatted(.dateTime.month(.abbreviated).day())
        let dayTextOfWeek = date.formatted(.dateTime.weekday(.abbreviated))
        let dayText2 = date.formatted(.dateTime.weekday(.wide))
        if Locale.current.calendar.isDateInToday(date) {
            return String(format: "%@", "Today")
        }
        else if let lastWeekDate = Locale.current.calendar.date(byAdding: .weekOfMonth, value: -1, to: Date()), lastWeekDate > date {
            return String(format: "%@, %@", dayTextOfWeek, dayText)
        }
        
        else {
            return String(format: "%@", dayText2)
        }
    }
    
}

//MARK: - text direction
extension UILabel { //TODO need to study this func
    func decideTextDirection () {
        if self.text != "" {
            let tagScheme = [NSLinguisticTagScheme.language]
            let tagger = NSLinguisticTagger(tagSchemes: tagScheme, options: 0)
            tagger.string = self.text
            let lang = tagger.tag(at: 0, scheme: NSLinguisticTagScheme.language, tokenRange: nil, sentenceRange: nil)
            let langDir = NSLocale.characterDirection(forLanguage: lang?.rawValue ?? "en")
            if langDir == .rightToLeft { self.textAlignment = NSTextAlignment.right }
            else { self.textAlignment = NSTextAlignment.left }
        }
    }
}

