//
//  MyTestScheduler.swift
//  iOSDC2021SampleApp
//
//  Created by Kenta Aikawa on 2021/08/11.
//

import Combine
import Foundation

final class MyTestScheduler<SchedulerTimeType, SchedulerOptions>: Scheduler where SchedulerTimeType: Strideable, SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    var now: SchedulerTimeType
    var minimumTolerance: SchedulerTimeType.Stride = 0
    
    init(now: SchedulerTimeType) {
        self.now = now
    }

    private var scheduled: [(action: () -> Void, date: SchedulerTimeType)] = []

    func schedule(
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        scheduled.append((action, now))
    }
    
    func schedule(
        after date: SchedulerTimeType,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        scheduled.append((action, date))
    }
    
    func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        func scheduleAction(for date: SchedulerTimeType) -> () -> Void {
          return { [weak self] in
            let nextDate = date.advanced(by: interval)
            self?.scheduled.append((scheduleAction(for: nextDate), nextDate))
            action()
          }
        }

        self.scheduled.append((scheduleAction(for: date), date))
        
        return AnyCancellable {}
    }

    func advance(by stride: SchedulerTimeType.Stride = .zero) {
        let finalDate = now.advanced(by: stride)
        
        while now <= finalDate {
            scheduled.sort { $0.date < $1.date }
            
            guard let nextDate = scheduled.first?.date,
                  finalDate >= nextDate
            else {
                now = finalDate
                return
            }

            now = nextDate

            while let (action, date) = scheduled.first, date == nextDate {
                scheduled.removeFirst()
                action()
            }
        }
    }
}

extension DispatchQueue {
    static var myTest: MyTestSchedulerOf<DispatchQueue> {
        .init(now: .init(.init(uptimeNanoseconds: 1)))
    }
}

typealias MyTestSchedulerOf<Scheduler> = MyTestScheduler<
    Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions
> where Scheduler: Combine.Scheduler
