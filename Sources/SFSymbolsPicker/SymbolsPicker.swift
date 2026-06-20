//
//  SwiftUIView.swift
//
//
//  Created by Alessio Rubicini on 22/10/23.
//

import SwiftUI
import SFSafeSymbols

public struct SymbolsPicker<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selection: String
    @ObservedObject var vm: SymbolsPickerViewModel

    let closeButtonView: Content

    @State private var searchText = ""
    @State private var isSearchPresented = false

    /// Initialize the SymbolsPicker view
    /// - Parameters:
    ///   - selection: binding to the selected icon name.
    ///   - title: navigation title for the view.
    ///   - searchLabel: label for the search bar.
    ///   - autoDismiss: if true the view automatically dismisses itself when the symbol is selected.
    ///   - animate: if true symbol loading and search updates are animated.
    ///   - symbols: an array of SFSymbols to display. If empty, all symbols will be shown.
    ///   - closeButton: a custom view for the picker close button.
    public init(
        selection: Binding<String>,
        title: Text,
        searchLabel: Text,
        autoDismiss: Bool = false,
        animate: Bool = true,
        symbols: [SFSymbol] = [],
        @ViewBuilder closeButton: () -> Content = {
            #if os(iOS)
            if #available(iOS 26, *) {
                Image(systemName: "xmark")
            } else {
                Image(systemName: "xmark.circle")
            }
            #else
            Image(systemName: "xmark.circle")
            #endif
        }
    ) {
        self._selection = selection
        self.vm = SymbolsPickerViewModel(
            title: title,
            searchbarLabel: searchLabel,
            autoDismiss: autoDismiss,
            symbols: symbols,
            animate: animate
        )
        self.closeButtonView = closeButton()
    }

    public var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    if vm.isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if vm.symbols.isEmpty && !searchText.isEmpty {
                        ContentUnavailableView {
                            Label {
                                Text("No Symbols Found", bundle: Bundle.module)
                            } icon: {
                                Image(systemName: "magnifyingglass")
                            }
                        } description: {
                            Text("Try searching for something else", bundle: Bundle.module)
                        }
                    } else {
                        ScrollView(.vertical) {
                            LazyVGrid(
                                columns: [
                                    GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 8)
                                ],
                                spacing: 8
                            ) {
                                ForEach(vm.symbols, id: \.self) { icon in
                                    SymbolIcon(symbolName: icon, selection: $selection)
                                }

                                if vm.hasMoreSymbols && searchText.isEmpty {
                                    if vm.isLoadingMore {
                                        ProgressView()
                                            .padding()
                                    } else {
                                        Color.clear
                                            .frame(height: 1)
                                            .onAppear {
                                                vm.loadMoreSymbols()
                                            }
                                    }
                                }
                            }
                            .padding(8)
                        }
                        .scrollIndicators(.hidden)
                        .scrollDisabled(false)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged { _ in }
                        )
                        #if !os(visionOS)
                        .scrollDismissesKeyboard(.immediately)
                        #endif
                    }
                }
                .navigationTitle(vm.title)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            closeButtonView
                        }
                    }
                }
            }
            .searchable(
                text: $searchText,
                isPresented: $isSearchPresented,
                placement: .automatic,
                prompt: vm.searchbarLabel
            )
            .onAppear(perform: presentSearch)
        }
        .onChange(of: selection) { _, _ in
            if vm.autoDismiss {
                dismiss()
            }
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
                vm.reset()
            } else {
                vm.searchSymbols(with: newValue)
            }
        }
    }

    private func presentSearch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isSearchPresented = true
        }
    }
}

extension SymbolsPicker {
    /// Initialize the SymbolsPicker view
    /// - Parameters:
    ///   - selection: binding to the selected icon name.
    ///   - titleKey: navigation title for the view.
    ///   - searchLabel: label for the search bar.
    ///   - autoDismiss: if true the view automatically dismisses itself when the symbol is selected.
    ///   - animate: if true symbol loading and search updates are animated.
    ///   - symbols: an array of SFSymbols to display. If empty, all symbols will be shown.
    ///   - closeButton: a custom view for the picker close button.
    public init(
        selection: Binding<String>,
        titleKey: LocalizedStringKey,
        searchLabel: LocalizedStringKey,
        bundle: Bundle = #bundle,
        autoDismiss: Bool = false,
        animate: Bool = true,
        symbols: [SFSymbol] = [],
        @ViewBuilder closeButton: () -> Content = {
            #if os(iOS)
            if #available(iOS 26, *) {
                Image(systemName: "xmark")
            } else {
                Image(systemName: "xmark.circle")
            }
            #else
            Image(systemName: "xmark.circle")
            #endif
        }
    ) {
        self._selection = selection
        self.vm = SymbolsPickerViewModel(
            title: Text(titleKey, bundle: bundle),
            searchbarLabel: Text(searchLabel, bundle: bundle),
            autoDismiss: autoDismiss,
            symbols: symbols,
            animate: animate
        )
        self.closeButtonView = closeButton()
    }

    /// Initialize the SymbolsPicker view
    /// - Parameters:
    ///   - selection: binding to the selected icon name.
    ///   - titleKey: navigation title for the view.
    ///   - autoDismiss: if true the view automatically dismisses itself when the symbol is selected.
    ///   - animate: if true symbol loading and search updates are animated.
    ///   - symbols: an array of SFSymbols to display. If empty, all symbols will be shown.
    ///   - closeButton: a custom view for the picker close button.
    public init(
        selection: Binding<String>,
        titleKey: LocalizedStringKey,
        bundle: Bundle = #bundle,
        autoDismiss: Bool = false,
        animate: Bool = true,
        symbols: [SFSymbol] = [],
        @ViewBuilder closeButton: () -> Content = {
            #if os(iOS)
            if #available(iOS 26, *) {
                Image(systemName: "xmark")
            } else {
                Image(systemName: "xmark.circle")
            }
            #else
            Image(systemName: "xmark.circle")
            #endif
        }
    ) {
        self._selection = selection
        self.vm = SymbolsPickerViewModel(
            title: Text(titleKey, bundle: bundle),
            searchbarLabel: Text("Search...", bundle: Bundle.module),
            autoDismiss: autoDismiss,
            symbols: symbols,
            animate: animate
        )
        self.closeButtonView = closeButton()
    }

    /// Initialize the SymbolsPicker view
    /// - Parameters:
    ///   - selection: binding to the selected icon name.
    ///   - title: navigation title for the view.
    ///   - searchLabel: label for the search bar. Set to 'Search...' by default.
    ///   - autoDismiss: if true the view automatically dismisses itself when the symbol is selected.
    ///   - animate: if true symbol loading and search updates are animated.
    ///   - symbols: an array of SFSymbols to display. If empty, all symbols will be shown.
    ///   - closeButton: a custom view for the picker close button.
    public init(
        selection: Binding<String>,
        title: String,
        searchLabel: String = "Search...",
        autoDismiss: Bool = false,
        animate: Bool = true,
        symbols: [SFSymbol] = [],
        @ViewBuilder closeButton: () -> Content = {
            #if os(iOS)
            if #available(iOS 26, *) {
                Image(systemName: "xmark")
            } else {
                Image(systemName: "xmark.circle")
            }
            #else
            Image(systemName: "xmark.circle")
            #endif
        }
    ) {
        self._selection = selection
        self.vm = SymbolsPickerViewModel(
            title: Text(title),
            searchbarLabel: Text(searchLabel),
            autoDismiss: autoDismiss,
            symbols: symbols,
            animate: animate
        )
        self.closeButtonView = closeButton()
    }
}

#Preview {
    SymbolsPicker(selection: .constant("beats.powerbeatspro"), title: "Pick a symbol", autoDismiss: true)
}
