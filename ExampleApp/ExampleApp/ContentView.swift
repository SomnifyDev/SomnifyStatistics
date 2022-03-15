//
//  ContentView.swift
//  ExampleApp
//
//  Created by Анас Бен Мустафа on 3/12/22.
//

import SwiftUI
import SleepStatistics

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                Task {
                    await self.retrieveLastSleepInterval()
                }
            }
    }

    private func retrieveLastSleepInterval() async {
        do {
            let sleepStatisticsProvider = SleepStatisticsProvider()
            let res = try await sleepStatisticsProvider.getLastSleepDateInterval(type: .asleep)
            print(res)
        } catch {}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
