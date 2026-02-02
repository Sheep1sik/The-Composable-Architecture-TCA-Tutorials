//
//  firstfeatureApp.swift
//  firstfeature
//
//  Created by wonsik on 2/2/26.
//

import ComposableArchitecture
import SwiftUI


@main
struct firstfeatureApp: App {
  static let store = Store(initialState: CounterFeature.State()) {
      CounterFeature()
          ._printChanges()
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView(store: firstfeatureApp.store)
    }
  }
}
