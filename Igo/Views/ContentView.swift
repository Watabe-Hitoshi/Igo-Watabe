//
//  ContentView.swift
//  Igo
//
//  Created by hitoshi on 2025/02/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("囲碁対局プラットフォーム")
                    .font(.largeTitle)
                    .bold()
                
                VStack(spacing: 10) {
                    Text("ランク: 初段")
                    Text("勝敗: 10勝 5敗")
                }
                .font(.title2)
                
//                NavigationLink(destination: MatchView()) {
//                    Text("対局を開始")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .frame(width: 200, height: 50)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//                
//                NavigationLink(destination: AnalysisView()) {
//                    Text("棋譜解析")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .frame(width: 200, height: 50)
//                        .background(Color.green)
//                        .cornerRadius(10)
//                }
//                
//                NavigationLink(destination: GachaView()) {
//                    Text("ガチャ")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .frame(width: 200, height: 50)
//                        .background(Color.orange)
//                        .cornerRadius(10)
//                }
                
                NavigationLink(destination: GameBoardView()) {
                    Text("対局画面へ")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct GameBoardView: View {
    let boardSize = 19
    let gridSpacing: CGFloat = 20
    @State private var stones: [[Int]] = Array(repeating: Array(repeating: 0, count: 19), count: 19)
    @State private var currentPlayer = 1
    @State private var koPosition: (Int, Int)? = nil
    @State private var passCount = 0
    
    var body: some View {
        VStack {
            Text("対局画面")
                .font(.largeTitle)
                .bold()
                .padding()
            
            ZStack {
                Rectangle()
                    .fill(Color.brown)
                    .frame(width: gridSpacing * CGFloat(boardSize), height: gridSpacing * CGFloat(boardSize))
                    .cornerRadius(10)
                    .overlay(
                        GridView(boardSize: boardSize, gridSpacing: gridSpacing, stones: $stones, currentPlayer: $currentPlayer, koPosition: $koPosition, passCount: $passCount)
                    )
            }
            .padding()
            
            Button("パス") {
                passTurn()
            }
            .font(.title2)
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
    }
    
    private func passTurn() {
        passCount += 1
        if passCount >= 2 {
            endGame()
        }
        currentPlayer = currentPlayer == 1 ? 2 : 1
    }
    
    private func endGame() {
        print("対局終了: 2回連続パス")
        let score = calculateScore()
        print("黒の地: \(score.blackScore), 白の地: \(score.whiteScore)")
    }
    
    private func calculateScore() -> (blackScore: Int, whiteScore: Int) {
        var blackScore = 0
        var whiteScore = 0
        
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                if stones[row][col] == 0 {
                    let territory = countTerritory(row: row, col: col)
                    if territory.owner == 1 {
                        blackScore += territory.size
                    } else if territory.owner == 2 {
                        whiteScore += territory.size
                    }
                }
            }
        }
        return (blackScore, whiteScore)
    }
    
    private func countTerritory(row: Int, col: Int) -> (size: Int, owner: Int) {
        var visited = Set<[Int]>()
        var queue = [[row, col]]
        var size = 0
        var owner = 0
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let r = current[0], c = current[1]
            if visited.contains([r, c]) || r < 0 || r >= boardSize || c < 0 || c >= boardSize {
                continue
            }
            visited.insert([r, c])
            size += 1
            
            for dir in [(0,1), (1,0), (0,-1), (-1,0)] {
                let newRow = r + dir.0
                let newCol = c + dir.1
                if newRow >= 0 && newRow < boardSize && newCol >= 0 && newCol < boardSize {
                    let stone = stones[newRow][newCol]
                    if stone == 0 {
                        queue.append([newRow, newCol])
                    } else if owner == 0 {
                        owner = stone
                    } else if owner != stone {
                        return (size, 0)
                    }
                }
            }
        }
        return (size, owner)
    }
}

#Preview {
    ContentView()
}

#Preview {
    GameBoardView()
}
