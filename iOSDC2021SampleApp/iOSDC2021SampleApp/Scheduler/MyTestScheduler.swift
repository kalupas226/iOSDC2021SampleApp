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

    private var scheduled: [() -> Void] = []

    func schedule(options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        scheduled.append(action)
    }
    
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        return
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        return AnyCancellable{}
    }
    
    func advance() {
        for action in scheduled {
            action()
        }
        scheduled.removeAll()
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
