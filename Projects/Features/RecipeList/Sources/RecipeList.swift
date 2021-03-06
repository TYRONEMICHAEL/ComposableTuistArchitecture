import CasePaths
import Combine
import ComposableArchitecture
import SwiftUI
import ComposableTuistArchitectureSupport
import AddRecipe
import RecipeDetail

public func makeRecipeListView(store: Store<RecipeListFeatureState, RecipeListFeatureAction>) -> some View {
    RecipeListView(store: store)
}

struct RecipeListView: View {
    struct State: Equatable {
        var recipes: IdentifiedArrayOf<Recipe>
        var isActivityIndicatorHidden: Bool
        var isAddRecipeNavigationLinkActive: Bool
        var selectionRecipe: Identified<Recipe.ID, RecipeDetailState>?
    }
    
    enum Action {
        case recipes
        case deleteRecipes(IndexSet)
        case tappedOnAddRecipe
        case isAddRecipeNavigationLinkActiveChanged(Bool)
        case selectedRecipeDetail(Recipe.ID?)
    }
    
    let store: Store<RecipeListFeatureState, RecipeListFeatureAction>
    
    var body: some View {
        WithViewStore(
            self.store
                .scope(state: \.recipeList, action: RecipeListFeatureAction.recipeList)
                .scope(state: State.init, action: RecipeListAction.init)
        ) { viewStore in
            NavigationView {
                VStack {
                    List {
                        ForEach(viewStore.recipes) { recipe in
                            NavigationLink(
                                destination: IfLetStore(
                                    self.store.scope(state: { $0.selectionRecipe?.value }, action: RecipeListFeatureAction.recipeDetail),
                                    then: RecipeDetailView.init
//                                    then: UIKit_RecipeDetailView.init
                                ),
                                tag: recipe.id,
                                selection: viewStore.binding(
                                    get: { $0.selectionRecipe?.id },
                                    send: Action.selectedRecipeDetail
                                )
                            ) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(recipe.name)
                                    Text("Duration: " + String(recipe.duration))
                                }
                            }
                        }
                        .onDelete {
                            viewStore.send(.deleteRecipes($0))
                        }
                    }
                    NavigationLink(
                        destination: AddRecipeView(store: self.store.scope(state: \.addRecipeState, action: RecipeListFeatureAction.addRecipe)),
                        isActive: viewStore.binding(get: \.isAddRecipeNavigationLinkActive, send: Action.isAddRecipeNavigationLinkActiveChanged)
                    ) {
                        EmptyView()
                    }
                }
                .onAppear { viewStore.send(.recipes) }
                .navigationBarTitle("Recipes")
                .navigationBarItems(
                    trailing: Button(action: { viewStore.send(.tappedOnAddRecipe) }) {
                        Image(uiImage: Asset.icAdd.image)
                    }
                )
            }
            if viewStore.isActivityIndicatorHidden {
                ActivityIndicator()
            }
        }
    }
}

extension RecipeListView.State {
    init(recipeListState: RecipeListState) {
        recipes = recipeListState.recipes
        isActivityIndicatorHidden = recipeListState.isLoadingRecipes
        isAddRecipeNavigationLinkActive = recipeListState.isShowingAddRecipe
        selectionRecipe = recipeListState.selectionRecipe
    }
}

extension RecipeListAction {
    init(action: RecipeListView.Action) {
        switch action {
        case .recipes:
            self = .recipes
        case let .deleteRecipes(indexSet):
            self = .deleteRecipes(indexSet)
        case .tappedOnAddRecipe:
            self = .isShowingAddRecipeChanged(true)
        case let .isAddRecipeNavigationLinkActiveChanged(value):
            self = .isShowingAddRecipeChanged(value)
        case let .selectedRecipeDetail(recipeID):
            self = .selectedRecipeDetail(recipeID)
        }
    }
}

struct RecipeList_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView(
            store: Store<RecipeListFeatureState, RecipeListFeatureAction>(
                initialState: RecipeListFeatureState(
                    recipes: [
                        Recipe(id: "a", name: "Spaghetti", description: "", ingredients: [], duration: 20, score: 2, info: "")
                    ],
                    isLoadingRecipes: false
                ),
                reducer: recipeListFeatureReducer,
                environment: RecipeListFeatureEnvironment(
                    cookbookClient: .mock(
                        recipes: {
                            Effect(
                                value: [
                                    Recipe(id: "a", name: "Spaghetti", description: "", ingredients: ["Banana"], duration: 20, score: 2, info: "")
                                ]
                            )
                        }
                    ),
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            )
        )
    }
}
