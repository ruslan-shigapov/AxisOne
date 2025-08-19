//
//  GoalService.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import CoreData

enum GoalError: Error {
    case movingFailed(Error)
    case orderFetchingFailed(Error)
    case completionTogglingFailed(Error)
    case activationTogglingFailed(Error)
    case deletingFailed(Error)
    case duplicateFetchingFailed(Error)
    case savingFailed(Error)
}

final class GoalService {
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func saveContext(goalError: (Error) -> GoalError) throws {
        do {
            try context.save()
        } catch {
            throw goalError(error)
        }
    }
    
    private func getOrder(in lifeArea: String?) throws -> Int16 {
        let areaPredicate: NSPredicate
        if let lifeArea {
            areaPredicate = .init(format: "lifeArea == %@", lifeArea)
        } else {
            areaPredicate = .init(format: "lifeArea == nil")
        }
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = areaPredicate
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let lastGoal = try context.fetch(fetchRequest).first
            return (lastGoal?.order ?? 0) + 1
        } catch {
            throw GoalError.orderFetchingFailed(error)
        }
    }
    
    func saveOrders() throws {
        try saveContext {
            .movingFailed($0)
        }
    }
    
    func toggleComplete(of goal: Goal) throws {
        goal.isCompleted.toggle()
        if goal.isCompleted {
            goal.isActive = false
            goal.subgoals?.forEach {
                ($0 as? Subgoal)?.isActive = false
            }
            goal.order = try getOrder(in: goal.lifeArea)
        }
        try saveContext {
            .completionTogglingFailed($0)
        }
    }
    
    func toggleActive(of goal: Goal) throws {
        goal.isActive.toggle()
        goal.subgoals?.forEach {
            ($0 as? Subgoal)?.isActive.toggle()
        }
        try saveContext {
            .activationTogglingFailed($0)
        }
    }
    
    func delete(_ goal: Goal) throws {
        context.delete(goal)
        try saveContext {
            .deletingFailed($0)
        }
    }
    
    func rollback() {
        context.rollback()
    }
    
    func hasDuplicate(by title: String, excludingGoal: Goal?) throws -> Bool {
        let fetchRequest = Goal.fetchRequest()
        var predicates: [NSPredicate] = [
            .init(
                format: "title ==[c] %@",
                title.trimmingCharacters(in: .whitespacesAndNewlines))
        ]
        if let excludingGoal {
            predicates.append(.init(format: "SELF != %@", excludingGoal))
        }
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: predicates)
        fetchRequest.fetchLimit = 1
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            throw GoalError.duplicateFetchingFailed(error)
        }
    }
    
    func save(
        _ goal: Goal?,
        lifeArea: String,
        title: String,
        notes: String,
        isActive: Bool,
        subgoals: [Subgoal]
    ) throws {
        let goalToSave = goal ?? Goal(context: context)
        goalToSave.lifeArea = lifeArea
        goalToSave.title = title
        goalToSave.notes = notes
        goalToSave.isActive = isActive
        goalToSave.isCompleted = goal?.isCompleted ?? false
        if goal == nil {
            goalToSave.order = try getOrder(in: lifeArea)
        }
        let oldSubgoals = goalToSave.subgoals as? Set<Subgoal> ?? []
        for subgoal in oldSubgoals.subtracting(subgoals) {
            context.delete(subgoal)
        }
        for (index, subgoal) in subgoals.enumerated() {
            subgoal.order = Int16(index)
            subgoal.isActive = isActive
            goalToSave.addToSubgoals(subgoal)
        }
        try saveContext {
            .savingFailed($0)
        }
    }
}
