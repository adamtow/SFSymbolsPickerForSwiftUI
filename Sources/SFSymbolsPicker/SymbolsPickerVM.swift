//
//  SymbolsPickerViewModel.swift
//
//
//  Created by Alessio Rubicini on 25/02/24.
//

import Foundation
import SwiftUI
import SFSafeSymbols

public class SymbolsPickerViewModel: ObservableObject {

    let title: Text
    let searchbarLabel: Text
    let autoDismiss: Bool
    let animate: Bool
    private let symbolLoader: SymbolLoader = SymbolLoader()
    private var searchTask: Task<Void, Never>?
    private let customSymbols: [String]
    private let useCustomSymbols: Bool

    @Published var symbols: [String] = []
    @Published var isLoading: Bool = true
    @Published var isLoadingMore: Bool = false
    private var isSearching: Bool = false

    init(
        title: Text,
        searchbarLabel: Text,
        autoDismiss: Bool,
        symbols: [SFSymbol] = [],
        animate: Bool = true
    ) {
        self.title = title
        self.searchbarLabel = searchbarLabel
        self.autoDismiss = autoDismiss
        self.animate = animate

        if !symbols.isEmpty {
            self.customSymbols = symbols.map { $0.rawValue }
            self.useCustomSymbols = true
            DispatchQueue.main.async {
                self.updatePublishedSymbols {
                    self.symbols = self.customSymbols
                    self.isLoading = false
                }
            }
        } else {
            self.customSymbols = []
            self.useCustomSymbols = false
            NotificationCenter.default.addObserver(self, selector: #selector(updateSymbols), name: .symbolsLoaded, object: nil)
            self.loadSymbols()
        }
    }

    deinit {
        searchTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func updateSymbols() {
        DispatchQueue.main.async {
            self.updatePublishedSymbols {
                self.symbols = self.symbolLoader.getSymbols()
                self.isLoading = false
            }
        }
    }

    public var hasMoreSymbols: Bool {
        guard !useCustomSymbols else { return false }
        return !isSearching && symbolLoader.hasMoreSymbols()
    }

    public func loadSymbols() {
        DispatchQueue.main.async {
            self.updatePublishedSymbols {
                self.symbols = self.symbolLoader.getSymbols()
                self.isLoading = false
            }
        }
    }

    public func loadMoreSymbols() {
        guard !useCustomSymbols && !isLoadingMore && hasMoreSymbols else { return }
        isLoadingMore = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let newSymbols = self.symbolLoader.loadNextPage()

            DispatchQueue.main.async {
                if !newSymbols.isEmpty {
                    self.updatePublishedSymbols {
                        self.symbols = self.symbolLoader.getSymbols()
                    }
                }
                self.isLoadingMore = false
            }
        }
    }

    public func searchSymbols(with name: String) {
        searchTask?.cancel()
        isSearching = true

        searchTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            guard !Task.isCancelled else { return }
            guard let self else { return }

            let matchingSymbols: [String]
            if self.useCustomSymbols {
                matchingSymbols = self.customSymbols.filter { symbol in
                    symbol.lowercased().contains(name.lowercased())
                }
            } else {
                matchingSymbols = self.symbolLoader.getSymbols(named: name)
            }

            self.updatePublishedSymbols {
                self.symbols = matchingSymbols
                self.isLoading = false
            }
        }
    }

    public func reset() {
        searchTask?.cancel()

        if useCustomSymbols {
            updatePublishedSymbols {
                symbols = customSymbols
                isSearching = false
                isLoading = false
            }
        } else {
            symbolLoader.resetPagination()
            updatePublishedSymbols {
                symbols.removeAll()
                isLoading = true
            }
            isSearching = false
            isLoadingMore = false
            loadSymbols()
        }
    }

    private func updatePublishedSymbols(_ updates: () -> Void) {
        if animate {
            withAnimation {
                updates()
            }
        } else {
            updates()
        }
    }
}
