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
    case orderFetchingFailed(Error)
    case transformingToGoal(Error)
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
    
    private func getGoalOrder(for lifeArea: String) throws -> Int16 {
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = .init(format: "lifeArea == %@", lifeArea)
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let lastGoal = try context.fetch(fetchRequest).first
            return (lastGoal?.order ?? 0) + 1
        } catch {
            throw SubgoalError.orderFetchingFailed(error)
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
            completion(subgoalToSave)
            return
        }
        try saveContext {
            .savingFailed($0)
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
        _ subgoal: Subgoal?,
        lifeArea: Constants.LifeAreas,
        title: String,
        notes: String
    ) throws {
        guard let subgoal else { return }
        let goal = Goal(context: context)
        goal.lifeArea = lifeArea.rawValue
        goal.title = title.trimmingCharacters(
            in: .whitespacesAndNewlines)
        goal.notes = notes.trimmingCharacters(
            in: .whitespacesAndNewlines)
        goal.order = try getGoalOrder(for: lifeArea.rawValue)
        context.delete(subgoal)
        try saveContext {
            .transformingToGoal($0)
        }
    }
}
