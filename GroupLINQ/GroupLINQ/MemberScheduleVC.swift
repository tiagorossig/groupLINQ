//
//  MemberScheduleVC.swift
//  GroupLINQ
//
//  Created by Bagaria on 8/9/21.
//

import UIKit
import Firebase
import JZCalendarWeekView

class MemberScheduleVC: UIViewController {
    
    let db = Firestore.firestore()
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var calendarWeekView: JZLongPressWeekView!
    var delegate : UIViewController!
    var mName : String!
    let viewModel = AllDayViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberName.text = "Member Name: \(mName ?? "")"
        self.db.collection("users").whereField("name", isEqualTo: mName)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.email.text = "Email: \(document.get("email") as! String)"
                    self.phoneNumber.text = "Phone Number: \(document.get("phoneNumber") as! String)"
                    if let availableTimes = document["availableTimes"] as? [Timestamp] {
                        for t in availableTimes {
                            let date = t.dateValue()
                            self.viewModel.events.append(AllDayEvent(id: UUID().uuidString, title: "", startDate: date, endDate: date.add(component: .hour, value: 1),
                                                                     location: "", isAllDay: false))
                        }
                        self.setupCalendarView()
                    }
                }
            }
        }
        self.setupBasic()
        self.setupCalendarView()
        self.setupNaviBar()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "darkModeEnabled") {
            overrideUserInterfaceStyle = .dark
        }
        else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    private func setupCalendarView() {
        calendarWeekView.baseDelegate = self

        if viewModel.currentSelectedData != nil {
            // For example only
            setupCalendarViewWithSelectedData()
        } else {
            calendarWeekView.setupCalendar(numOfDays: 7,
                                           setDate: Date(timeIntervalSinceReferenceDate: 0),
                                           allEvents: JZWeekViewHelper.getIntraEventsByDate(originalEvents: self.viewModel.events),
                                           scrollType: .pageScroll,
                                           scrollableRange: (Date(timeIntervalSinceReferenceDate: 0), Date(timeIntervalSinceReferenceDate: 60 * 60 * 24 * 3)))
        }

        // LongPress delegate, datasorce and type setup
        calendarWeekView.longPressDelegate = self
        calendarWeekView.longPressDataSource = self
        calendarWeekView.longPressTypes = [.addNew, .move]

        // Optional
        calendarWeekView.addNewDurationMins = 60
        calendarWeekView.moveTimeMinInterval = 30
    }

    /// For example only
    private func setupCalendarViewWithSelectedData() {
        guard let selectedData = viewModel.currentSelectedData else { return }
        calendarWeekView.setupCalendar(numOfDays: selectedData.numOfDays,
                                       setDate: selectedData.date,
                                       allEvents: viewModel.eventsByDate,
                                       scrollType: selectedData.scrollType,
                                       firstDayOfWeek: selectedData.firstDayOfWeek)
        calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: selectedData.hourGridDivision))
    }
}

extension MemberScheduleVC: JZBaseViewDelegate {
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
        updateNaviBarTitle()
    }
}

// LongPress core
extension MemberScheduleVC: JZLongPressViewDelegate, JZLongPressViewDataSource {

    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        // don't let them edit another person's calendar
    }

    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
        // don't let them edit another person's calendar
    }

    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        // don't let them edit another person's calendar
        return UIView()
    }
}

// For example only
extension MemberScheduleVC: OptionsViewDelegate {

    func setupBasic() {
        // Add this to fix lower than iOS11 problems
        self.automaticallyAdjustsScrollViewInsets = false
    }

    private func setupNaviBar() {
        updateNaviBarTitle()
    }

    private func getSelectedData() -> OptionsSelectedData {
        let numOfDays = calendarWeekView.numOfDays!
        let firstDayOfWeek = numOfDays == 7 ? calendarWeekView.firstDayOfWeek : nil
        viewModel.currentSelectedData = OptionsSelectedData(viewType: .longPressView,
                                                            date: calendarWeekView.initDate.add(component: .day, value: numOfDays),
                                                            numOfDays: numOfDays,
                                                            scrollType: calendarWeekView.scrollType,
                                                            firstDayOfWeek: firstDayOfWeek,
                                                            hourGridDivision: calendarWeekView.flowLayout.hourGridDivision,
                                                            scrollableRange: calendarWeekView.scrollableRange)
        return viewModel.currentSelectedData
    }

    func finishUpdate(selectedData: OptionsSelectedData) {

        // Update numOfDays
        if selectedData.numOfDays != viewModel.currentSelectedData.numOfDays {
            calendarWeekView.numOfDays = selectedData.numOfDays
            calendarWeekView.refreshWeekView()
        }
        // Update Date
        if selectedData.date != viewModel.currentSelectedData.date {
            calendarWeekView.updateWeekView(to: selectedData.date)
        }
        // Update Scroll Type
        if selectedData.scrollType != viewModel.currentSelectedData.scrollType {
            calendarWeekView.scrollType = selectedData.scrollType
            // If you want to change the scrollType without forceReload, you should call setHorizontalEdgesOffsetX
            calendarWeekView.setHorizontalEdgesOffsetX()
        }
        // Update FirstDayOfWeek
        if selectedData.firstDayOfWeek != viewModel.currentSelectedData.firstDayOfWeek {
            calendarWeekView.updateFirstDayOfWeek(setDate: selectedData.date, firstDayOfWeek: selectedData.firstDayOfWeek)
        }
        // Update hourGridDivision
        if selectedData.hourGridDivision != viewModel.currentSelectedData.hourGridDivision {
            calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: selectedData.hourGridDivision))
        }
        // Update scrollableRange
        if selectedData.scrollableRange != viewModel.currentSelectedData.scrollableRange {
            calendarWeekView.scrollableRange = selectedData.scrollableRange
        }
    }
    
    private func updateNaviBarTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        self.navigationItem.title = "Select Available Times"
    }
}
