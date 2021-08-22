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

    private var lastSequence: UInt = 0
    private var scheduled: [(sequence: UInt, action: () -> Void, date: SchedulerTimeType)] = []

    func schedule(
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        scheduled.append((nextSequence(), action, now))
    }
    
    func schedule(
        after date: SchedulerTimeType,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        scheduled.append((nextSequence(), action, date))
    }
    
    func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        let sequence = nextSequence()

        func scheduleAction(for date: SchedulerTimeType) -> () -> Void {
          return { [weak self] in
            let nextDate = date.advanced(by: interval)
            self?.scheduled.append((sequence, scheduleAction(for: nextDate), nextDate))
            action()
          }
        }

        self.scheduled.append((sequence, scheduleAction(for: date), date))
        
        return AnyCancellable {
            self.scheduled.removeAll(where: { $0.sequence == sequence })
        }
    }

    func advance(by stride: SchedulerTimeType.Stride = .zero) {
        let finalDate = now.advanced(by: stride)
        
        while now <= finalDate {
            scheduled.sort { ($0.date, $0.sequence) < ($1.date, $1.sequence) }
            
            guard let nextDate = scheduled.first?.date,
                  finalDate >= nextDate
            else {
                now = finalDate
                return
            }

            now = nextDate

            while let (_, action, date) = scheduled.first, date == nextDate {
                scheduled.removeFirst()
                action()
            }
        }
    }
    
    private func nextSequence() -> UInt {
        lastSequence += 1
        return lastSequence
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
