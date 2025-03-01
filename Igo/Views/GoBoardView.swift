//
//  GoBoardView.swift
//  Igo
//
//  Created by hitoshi on 2025/02/28.
//

import SwiftUI

import SwiftUI

struct GoBoardView: View {
    let boardSize: Int
    let gridSpacing: CGFloat
    @Binding var stones: [[Int]]
    @Binding var currentPlayer: Int
    @Binding var koPosition: (Int, Int)?
    @Binding var passCount: Int  // パス回数
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<boardSize ,id: \.self) { row in
                GridRow {
                    ForEach(0..<boardSize ,id: \.self) { col in
                        ZStack {
                            Color.brown
                            
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.black)
                                .padding(-2)
                            
                            if row == 4 && col == 4 {
                                Circle()
                                    .foregroundStyle(Color.black)
                                    .frame(width: 15, height: 15)
                            }
                            stoneView(for: stones[row][col])
                            //.position(x: gridSpacing * CGFloat(col + 1), y: gridSpacing * CGFloat(row + 1))
                        }
                        
                        .onTapGesture {
                            print("row: \(row), col: \(col)")
                            if isLegalMove(row: row, col: col) {
                                stones[row][col] = currentPlayer
                                captureStones(row: row, col: col)
                                koPosition = checkKo(row: row, col: col) ? (row, col) : nil
                                passCount = 0  // パス回数リセット
                                currentPlayer = currentPlayer == 1 ? 2 : 1
                            }
                        }
                    }
                }
                //.frame(width: 40, height: 40)
            }
            
        }
        //        .overlay {
        //            Circle()
        //                .foregroundStyle(Color.black)
        //                .frame(width: 15, height: 15)
        //        }
        
        //        ZStack {
        //            ForEach(0..<boardSize, id: \.self) { row in
        //                ForEach(0..<boardSize, id: \.self) { col in
        //                    Circle()
        //                        .stroke(Color.black, lineWidth: 0)
        //                        .background(.brown) // grayだった
        ////                        .frame(width: 5, height: 5)
        ////                        .frame(width: 15, height: 15)
        //                        .frame(width: 40, height: 40)
        //                        .position(x: gridSpacing * CGFloat(col + 1), y: gridSpacing * CGFloat(row + 1))
        //                        .onTapGesture {
        //                            //print("row: \(row), col: \(col)")
        //                            if isLegalMove(row: row, col: col) {
        //                                stones[row][col] = currentPlayer
        //                                captureStones(row: row, col: col)
        //                                koPosition = checkKo(row: row, col: col) ? (row, col) : nil
        //                                passCount = 0  // パス回数リセット
        //                                currentPlayer = currentPlayer == 1 ? 2 : 1
        //                            }
        //                        }
        //                        .overlay(
        //                            stoneView(for: stones[row][col])
        //                                .position(x: gridSpacing * CGFloat(col + 1), y: gridSpacing * CGFloat(row + 1))
        //                        )
        //                }
        //            }
        //        }
    }
    
    @ViewBuilder
    private func stoneView(for player: Int) -> some View {
        if player == 1 {
            Circle()
                .fill(Color.black)
                .frame(width: 40, height: 40)
        } else if player == 2 {
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
        }
        
//        let nowPlayer = Player(number: 1)// 1: 黒, 2: 白
        
//        if nowPlayer.number == 1 {
//            Circle()
//                .fill(Color.black)
//                .frame(width: 40, height: 40)
//        } else if nowPlayer.number == 2 {
//            Circle()
//                .fill(Color.white)
//                .frame(width: 40, height: 40)
//        }
    }
    
    
    struct Player {
        let number: Int // 1: 黒, 2: 白
        var gotStones: Int = 0
    }
    
    
    private func isLegalMove(row: Int, col: Int) -> Bool {
        if stones[row][col] != 0 {
            return false
        }
        if let ko = koPosition, ko == (row, col) {
            return false
        }
        return true
    }
    
    private func checkKo(row: Int, col: Int) -> Bool {
        return false // 簡易実装: 実際のコウ判定は石の取り合いを考慮する必要あり
    }
    
    private func captureStones(row: Int, col: Int) {
        let directions = [(0,1), (1,0), (0,-1), (-1,0)]
        for dir in directions {
            let newRow = row + dir.0
            let newCol = col + dir.1
            if newRow >= 0 && newRow < boardSize && newCol >= 0 && newCol < boardSize {
                if stones[newRow][newCol] != 0 && !hasLiberty(row: newRow, col: newCol) {
                    removeGroup(row: newRow, col: newCol)
                }
            }
        }
    }
    
    private func hasLiberty(row: Int, col: Int) -> Bool {
        let player = stones[row][col]
        if player == 0 { return false }
        
        var visited = Set<[Int]>()
        var queue = [[row, col]]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let r = current[0], c = current[1]
            
            if visited.contains([r, c]) {
                continue
            }
            visited.insert([r, c])
            
            let directions = [(0,1), (1,0), (0,-1), (-1,0)]
            for dir in directions {
                let newRow = r + dir.0
                let newCol = c + dir.1
                if newRow >= 0 && newRow < boardSize && newCol >= 0 && newCol < boardSize {
                    if stones[newRow][newCol] == 0 {
                        return true  // 空きがあるなら生きている
                    } else if stones[newRow][newCol] == player {
                        queue.append([newRow, newCol])
                    }
                }
            }
        }
        return false
    }
    
    private func removeGroup(row: Int, col: Int) {
        let player = stones[row][col]
        if player == 0 { return }
        
        var visited = Set<[Int]>()
        var queue = [[row, col]]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            let r = current[0], c = current[1]
            
            if visited.contains([r, c]) {
                continue
            }
            visited.insert([r, c])
            stones[r][c] = 0  // 石を削除
            
            let directions = [(0,1), (1,0), (0,-1), (-1,0)]
            for dir in directions {
                let newRow = r + dir.0
                let newCol = c + dir.1
                if newRow >= 0 && newRow < boardSize && newCol >= 0 && newCol < boardSize {
                    if stones[newRow][newCol] == player {
                        queue.append([newRow, newCol])
                    }
                }
            }
        }
    }
}

//#Preview {
//    GoBoardView()
//}
