//
//  LongPressViewController.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 30/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView
import Firebase

class SurveyVC: UIViewController {

    @IBOutlet weak var calendarWeekView: JZLongPressWeekView!
    let viewModel = AllDayViewModel()
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBasic()
        setupCalendarView()
        setupNaviBar()
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

    // Support device orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }

    @IBAction func submitPressed(_ sender: Any) {
        var timestamps: [Timestamp] = []
        for event in viewModel.events {
            timestamps.append(Timestamp(date: event.startDate))
        }
        self.db.collection("users").document(Auth.auth().currentUser!.uid).updateData([
            "availableTimes": timestamps
        ])
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")

        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    private func setupCalendarView() {
        calendarWeekView.baseDelegate = self

        if viewModel.currentSelectedData != nil {
            // For example only
            setupCalendarViewWithSelectedData()
        } else {
            calendarWeekView.setupCalendar(numOfDays: 7,
                                           setDate: Date(timeIntervalSinceReferenceDate: 0),
                                           allEvents: viewModel.eventsByDate,
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

extension SurveyVC: JZBaseViewDelegate {
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
        updateNaviBarTitle()
    }
}

// LongPress core
extension SurveyVC: JZLongPressViewDelegate, JZLongPressViewDataSource {

    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        let newEvent = AllDayEvent(id: UUID().uuidString, title: "", startDate: startDate, endDate: startDate.add(component: .hour, value: weekView.addNewDurationMins/60),
                             location: "", isAllDay: false)

        if viewModel.eventsByDate[startDate.startOfDay] == nil {
            viewModel.eventsByDate[startDate.startOfDay] = [AllDayEvent]()
        }
        viewModel.events.append(newEvent)
        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }

    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
        guard let event = editingEvent as? AllDayEvent else { return }
        let duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
        let selectedIndex = viewModel.events.firstIndex(where: { $0.id == event.id })!
        viewModel.events[selectedIndex].startDate = startDate
        viewModel.events[selectedIndex].endDate = startDate.add(component: .minute, value: duration)

        viewModel.eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: viewModel.events)
        weekView.forceReload(reloadEvents: viewModel.eventsByDate)
    }

    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        if let view = UINib(nibName: EventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? EventCell {
            view.titleLabel.text = ""
            return view
        }
        return UIView()
    }
}

// For example only
extension SurveyVC: OptionsViewDelegate {

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

