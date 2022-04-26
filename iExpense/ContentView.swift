//
//  ContentView.swift
//  iExpense
//
//  Created by Peter Hartnett on 1/21/22.
//

import SwiftUI



struct ExpenseItem: Identifiable, Codable{ //making it conform to identifiable lets me remove the need for the id: in foreach lines, these are now understood to be identifiable to swift, requires the ID on the next line.
    var id = UUID() //this will make a new UUID for each item, and there is almost no chance of a dupe
    let name: String
    let type: String
    let amount: Double
}

class Expenses: ObservableObject{
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") { //check for our "Items" key in userdefaults
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {// make a decoder and have it do decoding
                items = decodedItems //assign that array to items
                return
            }
        }

        items = [] // if fails, then just make items [] empty
    }
    @Published var items = [ExpenseItem]() {
        didSet { //note, xcode seems to not want to auto complete didSet at all, watch out for that
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
}


struct ContentView: View {
    //********** properties ***********
   @StateObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    //This does not currently work because when you delete an item from the filtered personalExpenses or bussinessExpenses it is simply using the index and knocking that index off of the full list.
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
        
    }
    
    //TODO 0000000 This function needs to work by getting some id reference from the filtered calculated expenseitem arrays and delete that id in the base array. just not sure how to do that at this moment.
    
    func removeItemsB(id: UUID){
        //expenses.items.remove(at: <#T##Int#>)
        expenses.items.removeAll{
            $0.id == id
        }
    }
    
    let currencyCodeU : FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currencyCode ?? "USD")

    var personalExpenses: [ExpenseItem] {
        var returnArray = [ExpenseItem]()
        for item in expenses.items{
            if item.type == "Personal"{
                returnArray.append(item)
            }
        }
        return returnArray
    }
    
    var bussinessExpenses: [ExpenseItem] {
        var returnArray = [ExpenseItem]()
        for item in expenses.items{
            if item.type == "Bussiness"{
                returnArray.append(item)
            }
        }
        return returnArray
    }
    
    //****** Body *************
    var body: some View {
        NavigationView{
            List{
                //Challenge, split the output here into two sections, one for bussiness and one for personal. s
                //So making some calculated properties works to split up the views, trying to put if structures down here made xcode unhappy, the next bit is to make sure that the delete item references are actually pointed at the right thing.
                
                Section{
                ForEach(expenses.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        
                        Spacer()
                        VStack{
                            Text(item.amount, format: currencyCodeU)
                                .font(.body)
                                .foregroundColor(item.amount < 10.0 ? .primary : (item.amount < 100.00 ? .orange : .red))
                            Text("\(item.id)")
                        }
                        
                    }
                }//end foreach
                .onDelete(perform: removeItems)
                }
                
                Section{
                    ForEach(personalExpenses) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }
                            
                            Spacer()
                            VStack{
                                Text(item.amount, format: currencyCodeU)
                                    .font(.body)
                                    .foregroundColor(item.amount < 10.0 ? .primary : (item.amount < 100.00 ? .orange : .red))
                                Text("\(item.id)")
                            }
                            
                        }
                    }//end foreach
                    .onDelete{thingy in
                        for index in thingy{
                           // print(expenses.items[index].id)
                            removeItemsB(id: personalExpenses[index].id)
                        }
                    }//end onDelete
                }//end section 2
                
                
                Section{
                    ForEach(bussinessExpenses) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }
                            
                            Spacer()
                            VStack{
                                Text(item.amount, format: currencyCodeU)
                                    .font(.body)
                                    .foregroundColor(item.amount < 10.0 ? .primary : (item.amount < 100.00 ? .orange : .red))
                                Text("\(item.id)")
                            }
                            
                        }
                    }//end foreach
                    .onDelete{thingy in
                        for index in thingy{
//                            print(bussinessExpenses[index].id)
//                            print(expenses.items[index].id)
                            removeItemsB(id: bussinessExpenses[index].id)
                        }
                    }//end onDelete
                }//end section 3
                
                
                
                
                
            }//end list
            .toolbar{
                //test button added to list to add dummy info
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }//End navigation view
        .sheet(isPresented: $showingAddExpense){
            AddView(expenses: expenses)
            //show an addview here
        }
    }//end var body
}//end content view struct



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
        ContentView()
        }
    }
}
