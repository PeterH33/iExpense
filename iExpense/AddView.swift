//
//  AddView.swift
//  iExpense
//
//  Created by Peter Hartnett on 1/23/22.
//

import SwiftUI

struct AddView: View {
    @ObservedObject var expenses: Expenses
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0
    
    @Environment(\.dismiss) var dismiss
    
    let types = ["Bussiness", "Personal"]
    
    
    var body: some View {
        NavigationView{
            Form{
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type){
                    ForEach(types, id: \.self){
                        Text($0)
                    }//end foreach
                }//end picker
                
                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
            }//end form
            .navigationTitle("Add new Expense")
            .toolbar{
                Button("Save"){
                    let item = ExpenseItem(name: name, type: type, amount: amount)
                    expenses.items.append(item)
                    dismiss()
                }
            }
        }//end navigation view
        
        
    }//end body
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
