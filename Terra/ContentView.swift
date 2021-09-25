//
//  ContentView.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import SwiftUI
import CoreData
import HealthKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    private var healthStore: HealthStore?
    
    @State private var steps: [Step] = [Step]()
    
    let user_id = UUID().uuidString
    var TerraClient: Terra?

    init() {
        TerraClient = Terra(user_id: user_id, dev_id: "testing")
    }
    
    private func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection){
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let endDate = Date()
        statisticsCollection.enumerateStatistics(from: startDate, to: endDate){
            (statistics, stop) in
            let count = statistics.sumQuantity()?.doubleValue(for:.count())
            let step = Step(count: Int(count ?? 0), timestamp: statistics.startDate)
            steps.append(step)
        }
    }
    var body: some View {
        Text("Hello")
        TerraConnectUI(dev_id: "testing")
        Button("Test Athlete") {
            TerraClient?.getAthleteJson()
        }
        Button("Test Daily"){
            TerraClient?.getDaily()
        }

    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
