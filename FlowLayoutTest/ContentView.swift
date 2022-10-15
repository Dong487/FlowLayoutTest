//
//  ContentView.swift
//  FlowLayoutTest
//
//  Created by Dong on 2022/10/14.
//

import SwiftUI

struct FlowLayout: Layout {
   
    
    var vSpacing: CGFloat = 10
    var alignment: TextAlignment = .leading
    
    struct Row{
        var viewRects: [CGRect] = []
        
        // 最後一個 view 的 maxX
        var width: CGFloat { viewRects.last?.maxX ?? 0 }
        // 所有 view 中 最高的 height
        var height: CGFloat { viewRects.map(\.height).max() ?? 0 }
        
        // 給 alignment 使用
        func getStart(in bounds: CGRect ,alignment: TextAlignment) -> CGFloat {
            switch alignment{
                
            case .leading:
                return bounds.minX
            case .center:
                return bounds.minX + (bounds.width - width) / 2 // 123123
            case .trailing:
                return bounds.maxX - width
            }
        }
    }
    
    
    private func getRows(subviews: Subviews ,totalWidth: CGFloat?) -> [Row]{
        
        // 如果 proposal 沒有寬度 回傳一個空的  Array
        guard let totalWidth , !subviews.isEmpty else { return [] }
        
        var rows = [Row()]
        let proposal = ProposedViewSize(width: totalWidth, height: nil)
        
        // 找出相加最寬的那一橫排 : 為了找到 return 的 寬、高
        // 用 indices 是為了 取得前一個 view的位置 -> previousView(subviews[index - 1])
        // 取得前一個 view的位置 是為了 利用 .distance  來計算 2個view 中間的spacing ->let spacing
        subviews.indices.forEach { index in
            let view = subviews[index]
            
            let size = view.sizeThatFits(proposal)
            let previousRect = rows.last!.viewRects.last ?? .zero // 有可能沒有值
            let previousView = rows.last!.viewRects.isEmpty ? nil : subviews[index - 1] // 前一個 View(第一個前面 則為 nil)
            let spacing = previousView?.spacing.distance(to: view.spacing, along: .horizontal) ?? 0
            
            // 檢查是否還可以放下 view
            // 現在這一排的寬度 + spacing + 下一個的寬度 (size.width) 是否超過螢幕寬度
            // 超過: true  -> 換下一橫排
            // 沒超過: false  -> 繼續放這橫排
            // previousRect.maxX: 前一個Rect 的 x最後位置
            switch previousRect.maxX + spacing + size.width > totalWidth {
                case true:
                    // 換 下一排 的情況
                    // rect: 要放的位置 (view左上角的座標)
                    let rect = CGRect(origin: .init(x: 0,
                                                    y: previousRect.minY + rows.last!.height + vSpacing),
                                      size: size)
                    rows.append(Row(viewRects: [rect]))
                    
                case false:
                    // 加在 同橫排
                    // rect: 要放的位置 (view左上角的座標)
                    let rect = CGRect(origin: .init(x: previousRect.maxX + spacing,
                                                    y: previousRect.minY),
                                      size: size)
                rows[rows.count - 1].viewRects.append(rect)
            }
        }
        return rows
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        
        let rows = getRows(subviews: subviews, totalWidth: proposal.width)
        
        
        // width :最寬的那一橫排
        // height: 每一排高度
        return .init(width: rows.map(\.width).max() ?? 0,
                     height: rows.last?.viewRects.map(\.maxY).max() ?? 0)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = getRows(subviews: subviews, totalWidth: bounds.width)
        
        var index = 0
        rows.forEach { row in
            let minX = row.getStart(in: bounds, alignment: alignment)
            
            row.viewRects.forEach { rect in
                let view = subviews[index]
                defer{ index += 1 }
                
                view.place(at: .init(x: rect.minX + minX,
                                     y: rect.minY + bounds.minY),
                           proposal: .init(rect.size))
            }
        }
    }
}
struct FlowLayOutView: View{
    
    @State var alignment: TextAlignment = .leading
    let tags: [String] = [ "WWDC222" , "勇士總冠軍" , "中信兄弟" ,"滷肉飯" ,"義大利肉醬麵" ,"野原新之助" ,"UIKit" ,"APPLE" ,"iOS" ,"MAc pro" ,"7777"]
    
    var body: some View{
        
        ScrollView{
            Picker("",selection: $alignment) {
                Text("向前").tag(TextAlignment.leading)
                Text("置中").tag(TextAlignment.center)
                Text("向後").tag(TextAlignment.trailing)
            }
            .pickerStyle(.segmented)
            
            FlowLayout(vSpacing: 8, alignment: alignment)(){
                ForEach(tags ,id: \.self) { tag in
                    Button(tag){ }
                        .buttonStyle(.bordered)
                }
                
                Group{
                    
                    Rectangle()
                        .frame(width: 300)
                        .frame(height: 110)
                    ForEach(1..<10 ,id: \.self){ _ in
                        Rectangle()
                            .frame(width: CGFloat.random(in: 20...150))
                            .frame(height: 110)
                    }
                }.clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            .background(.yellow)
            .animation(.easeInOut, value: alignment)
          
        }
        
        .padding(.horizontal)
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FlowLayOutView()
    }
}
