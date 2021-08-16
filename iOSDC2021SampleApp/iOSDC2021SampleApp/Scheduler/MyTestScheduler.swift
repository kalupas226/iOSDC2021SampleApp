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
        return AnyCancellable{}
    }

    func advance(by stride: SchedulerTimeType.Stride = .zero) {
        now = now.advanced(by: stride)

        for (action, date) in scheduled {
            if date <= now {
                action()
            }
        }
        scheduled.removeAll(where: { $0.date <= now })
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
