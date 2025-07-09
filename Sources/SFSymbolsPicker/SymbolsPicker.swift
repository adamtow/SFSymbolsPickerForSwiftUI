//
//  SwiftUIView.swift
//  
//
//  Created by Alessio Rubicini on 22/10/23.
//

import SwiftUI

public struct SymbolsPicker<Content: View>: View {
	@Environment(\.presentationMode) var presentationMode
	
    @Binding var selection: String
    @ObservedObject var vm: SymbolsPickerViewModel
	
    let closeButtonView: Content
	
	@State private var searchText = ""
	@State private var isPresented: Bool = false
	
    /// Initialize the SymbolsPicker view
    /// - Parameters:
    ///   - selection: binding to the selected icon name.
    ///   - title: navigation title for the view.
    ///   - searchLabel: label for the search bar. Set to 'Search...' by default.
    ///   - autoDismiss: if true the view automatically dismisses itself when the symbols is selected.
    ///   - closeButton: a custom view for the picker close button. Set to 'Image(systemName: "xmark.circle")' by default.
    
	public init(selection: Binding<String>, title: String, searchLabel: String = "Search...", autoDismiss: Bool = false, animate: Bool = true, @ViewBuilder closeButton: () -> Content = { Image(systemName: "xmark.circle") }) {
        self._selection = selection
		self.vm = SymbolsPickerViewModel(title: title, searchbarLabel: searchLabel, autoDismiss: autoDismiss, animate: animate)
        self.closeButtonView = closeButton()
    }
    
    @ViewBuilder
    public var body: some View {
        NavigationView {
			VStack {
				ScrollView(.vertical) {
					LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 20) {
						ForEach(vm.symbols, id: \.hash) { icon in
							Button {
								withAnimation {
									self.selection = icon
								}
							} label: {
								SymbolIcon(symbolName: icon, selection: $selection)
							}
							
						}.padding(.top, 5)
					}
					
					if(vm.hasMoreSymbols && searchText.isEmpty) {
						Button(action: {
							vm.loadSymbols()
						}, label: {
							Label("Load More", systemImage: "square.and.arrow.down")
						}).padding()
					}
				}
				.navigationTitle(vm.title)
#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
#endif
				.toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            closeButtonView
                        }
                    }
                }
                .padding(.vertical, 5)
                
            }
			.padding(.horizontal, 5)
			.searchable(text: $searchText, isPresented: $isPresented, placement: .automatic, prompt: vm.searchbarLabel)
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
					isPresented = true
				}
			}
        }
        
        .onChange(of: selection) { newValue in
            if(vm.autoDismiss) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        .onChange(of: searchText) { newValue in
            if(newValue.isEmpty || searchText.isEmpty) {
                vm.reset()
            } else {
                vm.searchSymbols(with: newValue)
            }
        }
    }

}

#Preview {
    SymbolsPicker(selection: .constant("beats.powerbeatspro"), title: "Pick a symbol", autoDismiss: true)
}
