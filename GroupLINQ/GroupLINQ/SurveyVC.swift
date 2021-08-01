//
//  SurveyVC.swift
//  GroupLINQ
//
//  Created by Erika Tan on 7/30/21.
//

import UIKit

class SurveyVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarWeekView.setupCalendar(numOfDays: 7,
                                       setDate: Date(),
                                       allEvents: JZWeekViewHelper.getIntraEventsByDate(originalEvents: events),
                                       scrollType: .pageScroll,
                                       firstDayOfWeek: .Monday)
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }
    
    override func registerViewClasses() {
        super.registerViewClasses()

        // Register CollectionViewCell
        self.collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: "EventCell")

        // Register DecorationView: must provide corresponding JZDecorationViewKinds
        self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
        self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)

        // Register SupplementrayView: must override collectionView viewForSupplementaryElementOfKind
        collectionView.register(RowHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.rowHeader, withReuseIdentifier: "RowHeader")
    }
    
    
}
