//
//  SubgoalService.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import CoreData

enum SubgoalError: Error {
    case savingFailed(Error)
    case updatingFailed(Error)
    case deletingFailed(Error)
    case goalOrderFetchingFailed(Error)
    case transformingToGoalFailed(Error)
    case transformingToTaskFailed(Error)
    case rescheduleFailed(Error)
    case subgoalOrderFetchingFailed(Error)
    case completionTogglingFailed(Error)
    case completingNowFailed(Error)
    case fetchingFailed(Error)
    case dailyResetingFailed(Error)
    case inboxTriageFetchingFailed(Error)
    case inboxTriageSavingFailed(Error)
}

final class SubgoalService {
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func saveContext(subgoalError: (Error) -> SubgoalError) throws {
        do {
            try context.save()
        } catch {
            throw subgoalError(error)
        }
    }
    
    private func getGoalOrder(in lifeArea: String) throws -> Int16 {
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = .init(format: "lifeArea == %@", lifeArea)
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let lastGoal = try context.fetch(fetchRequest).first
            return (lastGoal?.order ?? 0) + 1
        } catch {
            throw SubgoalError.goalOrderFetchingFailed(error)
        }
    }
    
    private func getSubgoalOrder(_ subgoal: Subgoal) throws -> Int16 {
        let fetchRequest = Subgoal.fetchRequest()
        let goalTitle = subgoal.goal?.title ?? ""
        fetchRequest.predicate = .init(format: "goal.title == %@", goalTitle)
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let lastGoal = try context.fetch(fetchRequest).first
            return (lastGoal?.order ?? 0) + 1
        } catch {
            throw SubgoalError.subgoalOrderFetchingFailed(error)
        }
    }
    
    private func getSubgoals() throws -> [Subgoal] {
        let fetchRequest = Subgoal.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            throw SubgoalError.fetchingFailed(error)
        }
    }
    
    func save(
        _ subgoal: Subgoal?,
        type: Constants.SubgoalTypes,
        title: String,
        notes: String,
        isUrgent: Bool,
        deadline: Date,
        isExactly: Bool,
        time: Date,
        timeOfDay: Constants.TimesOfDay,
        partCompletion: Double,
        startDate: Date,
        habitFrequency: Constants.Frequencies,
        lifeArea: Constants.LifeAreas?,
        completion: (Subgoal) -> Void
    ) throws {
        let subgoalToSave = subgoal ?? Subgoal(context: context)
        subgoalToSave.type = type.rawValue
        subgoalToSave.title = title
        subgoalToSave.notes = notes
        subgoalToSave.isCompleted = subgoal?.isCompleted ?? false
        if type != .habit, type != .focus {
            subgoalToSave.deadline = isUrgent ? deadline : nil
        }
        if type != .focus {
            subgoalToSave.time = isExactly ? time : nil
            let convertedTimeOfDay = Constants.TimesOfDay.getTimeOfDay(
                from: subgoalToSave.time)
            subgoalToSave.timeOfDay = isExactly
            ? convertedTimeOfDay.rawValue
            : timeOfDay.rawValue
            if !isUrgent, type != .habit {
                subgoalToSave.timeOfDay = nil
            }
        }
        if type == .milestone {
            subgoalToSave.completion = partCompletion
        }
        if type == .habit {
            subgoalToSave.startDate = startDate
            subgoalToSave.frequency = habitFrequency.rawValue
        }
        if lifeArea == nil {
            try saveContext {
                .savingFailed($0)
            }
        } else {
            completion(subgoalToSave)
        }
    }
    
    func update(
        _ subgoal: Subgoal?,
        type: Constants.SubgoalTypes,
        title: String,
        notes: String,
        isUrgent: Bool,
        deadline: Date,
        isExactly: Bool,
        time: Date,
        timeOfDay: Constants.TimesOfDay,
        partCompletion: Double,
        startDate: Date,
        habitFrequency: Constants.Frequencies,
    ) throws {
        guard let subgoal else { return }
        subgoal.title = title
        subgoal.notes = notes
        if type != .habit, type != .focus {
            if !Calendar.current.isDateInToday(deadline) {
                subgoal.isCompleted = false
            }
            subgoal.deadline = isUrgent ? deadline : nil
        }
        if type != .focus {
            subgoal.time = isExactly ? time : nil
            subgoal.timeOfDay = isExactly
            ? Constants.TimesOfDay.getTimeOfDay(from: subgoal.time).rawValue
            : timeOfDay.rawValue
            if !isUrgent, type != .habit {
                subgoal.timeOfDay = nil
            }
        }
        if type == .milestone {
            subgoal.completion = partCompletion
        }
        if type == .habit {
            subgoal.startDate = startDate
            subgoal.frequency = habitFrequency.rawValue
        }
        try saveContext {
            .updatingFailed($0)
        }
    }
    
    func delete(_ subgoal: Subgoal) throws {
        context.delete(subgoal)
        try saveContext {
            .deletingFailed($0)
        }
    }
    
    func transformToGoal(
        _ subgoal: Subgoal,
        lifeArea: Constants.LifeAreas,
        title: String,
        notes: String
    ) throws {
        let goal = Goal(context: context)
        goal.lifeArea = lifeArea.rawValue
        goal.title = title.trimmingCharacters(
            in: .whitespacesAndNewlines)
        goal.notes = notes.trimmingCharacters(
            in: .whitespacesAndNewlines)
        goal.order = try getGoalOrder(in: lifeArea.rawValue)
        context.delete(subgoal)
        try saveContext {
            .transformingToGoalFailed($0)
        }
    }
    
    func transformToTask(_ subgoal: Subgoal, for goal: Goal?) throws {
        guard let goal else { return }
        subgoal.type = Constants.SubgoalTypes.task.rawValue
        subgoal.goal = goal
        try saveContext {
            .transformingToTaskFailed($0)
        }
    }
    
    func reschedule(
        _ subgoal: Subgoal,
        to timeOfDay: Constants.TimesOfDay,
        isToday: Bool
    ) throws {
        if subgoal.type == Constants.SubgoalTypes.habit.rawValue {
            if isToday {
                subgoal.todayMoved = timeOfDay.rawValue
            } else {
                subgoal.yesterdayMoved = timeOfDay.rawValue
            }
        } else {
            subgoal.timeOfDay = timeOfDay.rawValue
            subgoal.time = nil
        }
        try saveContext {
            .rescheduleFailed($0)
        }
    }
    
    func toggleComplete(of subgoal: Subgoal, isYesterday: Bool) throws {
        isYesterday
        ? subgoal.wasCompleted.toggle()
        : subgoal.isCompleted.toggle()
        subgoal.order = try getSubgoalOrder(subgoal)
        try saveContext {
            .completionTogglingFailed($0)
        }
    }
    
    func completeNow(_ subgoal: Subgoal) throws {
        subgoal.deadline = .now
        subgoal.timeOfDay = Constants.TimesOfDay.getTimeOfDay(
            from: .now).rawValue
        subgoal.time = nil
        subgoal.isCompleted = true
        subgoal.order = try getSubgoalOrder(subgoal)
        try saveContext {
            .completingNowFailed($0)
        }
    }
    
    func resetDailyValues() throws {
        let today = Calendar.current.startOfDay(for: .now)
        let subgoals = try getSubgoals()
        subgoals.forEach {
            guard let lastReset = $0.lastReset else {
                $0.lastReset = today
                return
            }
            if !Calendar.current.isDate(lastReset, inSameDayAs: today) {
                if $0.type == Constants.SubgoalTypes.habit.rawValue {
                    $0.wasCompleted = $0.isCompleted
                    $0.isCompleted = false
                }
                $0.yesterdayMoved = $0.todayMoved
                $0.todayMoved = nil
                $0.lastReset = today
            }
        }
        try saveContext {
            .dailyResetingFailed($0)
        }
    }
    
    func getInboxTriage() throws -> Subgoal? {
        let fetchRequest = Subgoal.fetchRequest()
        fetchRequest.predicate = .init(
            format: "title == %@",
            "Сортировка Входящих")
        fetchRequest.fetchLimit = 1
        do {
            let inboxTriage = try context.fetch(fetchRequest).first
            return inboxTriage
        } catch {
            throw SubgoalError.inboxTriageFetchingFailed(error)
        }
    }
    
    func saveInboxTriage(
        _ subgoal: Subgoal?,
        timeOfDay: Constants.TimesOfDay,
        time: Date?
    ) throws {
        guard subgoal == nil else { return }
        let inboxTriage = Subgoal(context: context)
        inboxTriage.type = Constants.SubgoalTypes.habit.rawValue
        inboxTriage.title = "Сортировка Входящих"
        inboxTriage.startDate = Date()
        if let time {
            inboxTriage.time = time
        } else {
            inboxTriage.timeOfDay = timeOfDay.rawValue
        }
        inboxTriage.frequency = Constants.Frequencies.daily.rawValue
        try saveContext {
            .inboxTriageSavingFailed($0)
        }
    }
}
