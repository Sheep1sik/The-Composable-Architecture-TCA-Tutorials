//
//  CounterFeature.swift
//  firstfeature
//
//  Created by wonsik on 2/2/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CounterFeature {
    
    @ObservableState
    struct State {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }
    
    enum Action {
        case decrementButtonTapped
        case factButtonTapped
        case factResponse(Result<String, Error>)
        case incrementButtonTapped
        case timerTick
        case toggleTimerButtonTapped
    }
    
    nonisolated enum CancelID {
        case timer
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none
                
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                return .run { [count = state.count] send in

                    do {
                        let (data, _) = try await URLSession.shared
                            .data(from: URL(string: "https://numbersapi.com/\(count)")!)
                        let fact = String(decoding: data, as: UTF8.self)
                        await send(.factResponse(.success(fact)))
                    } catch {
                        await send(.factResponse(.failure(error)))
                    }
                }
                
            case let .factResponse(.success(fact)):
                state.fact = fact
                state.isLoading = false
                return .none
                
            case .factResponse(.failure):
                state.isLoading = false
                state.fact = "에러가 발생했습니다. 다시 시도해주세요."
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        while true {
                            try await Task.sleep(for: .seconds(1))
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
                
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
            }
        }
    }
}
