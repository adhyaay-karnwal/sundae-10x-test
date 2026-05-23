import Foundation

enum SeedData {
    static let ingredients: [Ingredient] = [
        // Produce
        Ingredient(id: "spinach",     name: "Baby spinach",     aisle: .produce, unit: "g"),
        Ingredient(id: "broccoli",    name: "Broccoli florets", aisle: .produce, unit: "g"),
        Ingredient(id: "sweetpotato", name: "Sweet potato",     aisle: .produce, unit: "g"),
        Ingredient(id: "onion",       name: "Yellow onion",     aisle: .produce, unit: "ea"),
        Ingredient(id: "garlic",      name: "Garlic clove",     aisle: .produce, unit: "ea"),
        Ingredient(id: "bellpepper",  name: "Bell pepper",      aisle: .produce, unit: "ea"),
        Ingredient(id: "tomato",      name: "Tomato",           aisle: .produce, unit: "ea"),
        Ingredient(id: "cucumber",    name: "Cucumber",         aisle: .produce, unit: "ea"),
        Ingredient(id: "avocado",     name: "Avocado",          aisle: .produce, unit: "ea"),
        Ingredient(id: "lemon",       name: "Lemon",            aisle: .produce, unit: "ea"),
        Ingredient(id: "lime",        name: "Lime",             aisle: .produce, unit: "ea"),
        Ingredient(id: "carrot",      name: "Carrot",           aisle: .produce, unit: "ea"),
        Ingredient(id: "cilantro",    name: "Cilantro",         aisle: .produce, unit: "bunch"),
        Ingredient(id: "kale",        name: "Kale",             aisle: .produce, unit: "g"),
        Ingredient(id: "mushroom",    name: "Cremini mushroom", aisle: .produce, unit: "g"),
        Ingredient(id: "banana",      name: "Banana",           aisle: .produce, unit: "ea"),
        Ingredient(id: "berries",     name: "Mixed berries",    aisle: .produce, unit: "g"),
        Ingredient(id: "zucchini",    name: "Zucchini",         aisle: .produce, unit: "ea"),

        // Protein
        Ingredient(id: "chicken",     name: "Chicken breast",   aisle: .protein, unit: "g"),
        Ingredient(id: "groundbeef",  name: "Lean ground beef", aisle: .protein, unit: "g"),
        Ingredient(id: "salmon",      name: "Salmon fillet",    aisle: .protein, unit: "g"),
        Ingredient(id: "shrimp",      name: "Shrimp",           aisle: .protein, unit: "g"),
        Ingredient(id: "groundturkey",name: "Ground turkey",    aisle: .protein, unit: "g"),
        Ingredient(id: "tofu",        name: "Firm tofu",        aisle: .protein, unit: "g"),
        Ingredient(id: "eggs",        name: "Egg",              aisle: .protein, unit: "ea"),
        Ingredient(id: "tuna",        name: "Canned tuna",      aisle: .protein, unit: "can"),

        // Dairy
        Ingredient(id: "greekyog",    name: "Greek yogurt",     aisle: .dairy, unit: "g"),
        Ingredient(id: "cheddar",     name: "Cheddar",          aisle: .dairy, unit: "g"),
        Ingredient(id: "feta",        name: "Feta",             aisle: .dairy, unit: "g"),
        Ingredient(id: "milk",        name: "Whole milk",       aisle: .dairy, unit: "ml"),
        Ingredient(id: "parmesan",    name: "Parmesan",         aisle: .dairy, unit: "g"),
        Ingredient(id: "cottage",     name: "Cottage cheese",   aisle: .dairy, unit: "g"),

        // Pantry
        Ingredient(id: "rice",        name: "Jasmine rice",     aisle: .pantry, unit: "g"),
        Ingredient(id: "brownrice",   name: "Brown rice",       aisle: .pantry, unit: "g"),
        Ingredient(id: "quinoa",      name: "Quinoa",           aisle: .pantry, unit: "g"),
        Ingredient(id: "oats",        name: "Rolled oats",      aisle: .pantry, unit: "g"),
        Ingredient(id: "pasta",       name: "Pasta",            aisle: .pantry, unit: "g"),
        Ingredient(id: "lentils",     name: "Red lentils",      aisle: .pantry, unit: "g"),
        Ingredient(id: "chickpeas",   name: "Chickpeas",        aisle: .pantry, unit: "can"),
        Ingredient(id: "blackbeans",  name: "Black beans",      aisle: .pantry, unit: "can"),
        Ingredient(id: "oliveoil",    name: "Olive oil",        aisle: .pantry, unit: "tbsp"),
        Ingredient(id: "soysauce",    name: "Soy sauce",        aisle: .pantry, unit: "tbsp"),
        Ingredient(id: "honey",       name: "Honey",            aisle: .pantry, unit: "tbsp"),
        Ingredient(id: "peanutbutter",name: "Peanut butter",    aisle: .pantry, unit: "tbsp"),
        Ingredient(id: "tortilla",    name: "Whole-wheat tortilla", aisle: .pantry, unit: "ea"),
        Ingredient(id: "almonds",     name: "Almonds",          aisle: .pantry, unit: "g"),
        Ingredient(id: "proteinpwd",  name: "Whey protein",     aisle: .pantry, unit: "scoop"),

        // Bakery
        Ingredient(id: "sourdough",   name: "Sourdough bread",  aisle: .bakery, unit: "slice"),

        // Frozen
        Ingredient(id: "edamame",     name: "Edamame",          aisle: .frozen, unit: "g"),
        Ingredient(id: "frozenberry", name: "Frozen berries",   aisle: .frozen, unit: "g"),

        // Spices
        Ingredient(id: "salt",        name: "Salt",             aisle: .spices, unit: "tsp"),
        Ingredient(id: "pepper",      name: "Black pepper",     aisle: .spices, unit: "tsp"),
        Ingredient(id: "paprika",     name: "Paprika",          aisle: .spices, unit: "tsp"),
        Ingredient(id: "cumin",       name: "Cumin",            aisle: .spices, unit: "tsp"),
        Ingredient(id: "chili",       name: "Chili flakes",     aisle: .spices, unit: "tsp"),
    ]

    static let ingredientById: [String: Ingredient] = {
        Dictionary(uniqueKeysWithValues: ingredients.map { ($0.id, $0) })
    }()

    // MARK: - Recipes

    static let recipes: [Recipe] = [
        Recipe(
            id: "chicken-rice-bowl",
            title: "Lime-Cilantro Chicken Bowl",
            blurb: "Charred chicken, jasmine rice, black beans, avocado.",
            timeMinutes: 25, baseServings: 2,
            macrosPerServing: Macros(kcal: 580, protein: 48, carbs: 62, fat: 14),
            ingredients: [
                .init(ingredientId: "chicken", qty: 300),
                .init(ingredientId: "rice", qty: 160),
                .init(ingredientId: "blackbeans", qty: 1),
                .init(ingredientId: "avocado", qty: 1),
                .init(ingredientId: "lime", qty: 1),
                .init(ingredientId: "cilantro", qty: 1),
                .init(ingredientId: "oliveoil", qty: 1),
                .init(ingredientId: "cumin", qty: 1),
            ],
            steps: [
                "Rub chicken with cumin, salt, and a squeeze of lime.",
                "Sear chicken 4 min per side until 165°F. Rest, then slice.",
                "Cook jasmine rice (1:1.5 water) for 12 min.",
                "Warm black beans with cumin and a pinch of salt.",
                "Layer rice, beans, chicken, avocado, cilantro, lime."
            ],
            tags: [.highProtein, .glutenFree, .dairyFree],
            suitableMeals: [.lunch, .dinner], accentHue: 0.25, glyph: "leaf.fill"
        ),
        Recipe(
            id: "salmon-quinoa",
            title: "Honey-Soy Salmon + Quinoa",
            blurb: "Glazed salmon, fluffy quinoa, charred broccoli.",
            timeMinutes: 30, baseServings: 2,
            macrosPerServing: Macros(kcal: 620, protein: 42, carbs: 55, fat: 24),
            ingredients: [
                .init(ingredientId: "salmon", qty: 300),
                .init(ingredientId: "quinoa", qty: 150),
                .init(ingredientId: "broccoli", qty: 300),
                .init(ingredientId: "soysauce", qty: 2),
                .init(ingredientId: "honey", qty: 1),
                .init(ingredientId: "garlic", qty: 2),
                .init(ingredientId: "oliveoil", qty: 1),
            ],
            steps: [
                "Whisk soy, honey, and minced garlic. Marinate salmon 10 min.",
                "Roast broccoli with olive oil at 220°C for 18 min.",
                "Cook quinoa 1:2 in water for 15 min, then fluff.",
                "Sear salmon skin-down 4 min, flip 2 min, glaze."
            ],
            tags: [.highProtein, .pescatarian, .dairyFree],
            suitableMeals: [.dinner], accentHue: 0.05, glyph: "fish.fill"
        ),
        Recipe(
            id: "beef-sweet-potato",
            title: "Ground Beef + Sweet Potato Hash",
            blurb: "Crispy sweet potato, lean beef, paprika, peppers.",
            timeMinutes: 25, baseServings: 2,
            macrosPerServing: Macros(kcal: 540, protein: 38, carbs: 48, fat: 20),
            ingredients: [
                .init(ingredientId: "groundbeef", qty: 300),
                .init(ingredientId: "sweetpotato", qty: 400),
                .init(ingredientId: "bellpepper", qty: 1),
                .init(ingredientId: "onion", qty: 1),
                .init(ingredientId: "paprika", qty: 1),
                .init(ingredientId: "oliveoil", qty: 1),
            ],
            steps: [
                "Dice sweet potato; roast 20 min at 220°C.",
                "Brown beef with onion and pepper, season with paprika.",
                "Toss everything together off heat."
            ],
            tags: [.highProtein, .glutenFree, .dairyFree],
            suitableMeals: [.lunch, .dinner], accentHue: 0.08, glyph: "flame.fill"
        ),
        Recipe(
            id: "overnight-oats",
            title: "Protein Overnight Oats",
            blurb: "Oats, whey, berries, peanut butter. Make once, eat thrice.",
            timeMinutes: 5, baseServings: 1,
            macrosPerServing: Macros(kcal: 460, protein: 35, carbs: 52, fat: 12),
            ingredients: [
                .init(ingredientId: "oats", qty: 60),
                .init(ingredientId: "milk", qty: 250),
                .init(ingredientId: "proteinpwd", qty: 1),
                .init(ingredientId: "frozenberry", qty: 80),
                .init(ingredientId: "peanutbutter", qty: 1),
            ],
            steps: [
                "Stir oats, milk, and whey in a jar.",
                "Top with berries and peanut butter.",
                "Refrigerate overnight."
            ],
            tags: [.highProtein, .vegetarian],
            suitableMeals: [.breakfast, .snack], accentHue: 0.55, glyph: "bowl.fill"
        ),
        Recipe(
            id: "greek-yogurt-parfait",
            title: "Greek Yogurt + Almond Parfait",
            blurb: "Thick Greek yogurt, honey, toasted almonds, berries.",
            timeMinutes: 5, baseServings: 1,
            macrosPerServing: Macros(kcal: 380, protein: 28, carbs: 38, fat: 12),
            ingredients: [
                .init(ingredientId: "greekyog", qty: 250),
                .init(ingredientId: "berries", qty: 100),
                .init(ingredientId: "almonds", qty: 20),
                .init(ingredientId: "honey", qty: 1),
            ],
            steps: ["Layer yogurt, berries, almonds.", "Drizzle honey."],
            tags: [.highProtein, .vegetarian, .glutenFree],
            suitableMeals: [.breakfast, .snack], accentHue: 0.62, glyph: "drop.fill"
        ),
        Recipe(
            id: "turkey-meatballs",
            title: "Turkey Meatballs + Pasta",
            blurb: "Lean turkey meatballs in tomato sauce over pasta.",
            timeMinutes: 35, baseServings: 3,
            macrosPerServing: Macros(kcal: 590, protein: 44, carbs: 60, fat: 18),
            ingredients: [
                .init(ingredientId: "groundturkey", qty: 500),
                .init(ingredientId: "pasta", qty: 240),
                .init(ingredientId: "tomato", qty: 4),
                .init(ingredientId: "onion", qty: 1),
                .init(ingredientId: "garlic", qty: 3),
                .init(ingredientId: "parmesan", qty: 40),
                .init(ingredientId: "oliveoil", qty: 2),
            ],
            steps: [
                "Mix turkey with grated onion, garlic, salt. Roll meatballs.",
                "Brown meatballs 6 min in olive oil.",
                "Add chopped tomato; simmer 15 min.",
                "Cook pasta al dente. Plate and top with parmesan."
            ],
            tags: [.highProtein],
            suitableMeals: [.dinner], accentHue: 0.02, glyph: "circle.grid.3x3.fill"
        ),
        Recipe(
            id: "shrimp-stirfry",
            title: "Garlic Shrimp Stir-Fry",
            blurb: "Quick shrimp with peppers, soy, and brown rice.",
            timeMinutes: 20, baseServings: 2,
            macrosPerServing: Macros(kcal: 520, protein: 40, carbs: 58, fat: 12),
            ingredients: [
                .init(ingredientId: "shrimp", qty: 300),
                .init(ingredientId: "brownrice", qty: 150),
                .init(ingredientId: "bellpepper", qty: 2),
                .init(ingredientId: "garlic", qty: 3),
                .init(ingredientId: "soysauce", qty: 2),
                .init(ingredientId: "oliveoil", qty: 1),
                .init(ingredientId: "chili", qty: 1),
            ],
            steps: [
                "Cook brown rice 25 min.",
                "Sear shrimp with garlic 2 min per side.",
                "Toss in peppers, soy, chili flakes. 2 more min."
            ],
            tags: [.highProtein, .pescatarian, .dairyFree],
            suitableMeals: [.lunch, .dinner], accentHue: 0.95, glyph: "flame.fill"
        ),
        Recipe(
            id: "tofu-bowl",
            title: "Crispy Tofu + Edamame Bowl",
            blurb: "Pan-crisped tofu, edamame, soy-honey glaze.",
            timeMinutes: 25, baseServings: 2,
            macrosPerServing: Macros(kcal: 510, protein: 32, carbs: 55, fat: 18),
            ingredients: [
                .init(ingredientId: "tofu", qty: 400),
                .init(ingredientId: "edamame", qty: 200),
                .init(ingredientId: "rice", qty: 150),
                .init(ingredientId: "soysauce", qty: 2),
                .init(ingredientId: "honey", qty: 1),
                .init(ingredientId: "oliveoil", qty: 1),
            ],
            steps: [
                "Press and cube tofu. Crisp in oil 8 min.",
                "Cook rice and steam edamame.",
                "Glaze tofu with soy + honey off heat."
            ],
            tags: [.highProtein, .vegan, .vegetarian, .dairyFree],
            suitableMeals: [.lunch, .dinner], accentHue: 0.18, glyph: "square.stack.3d.up.fill"
        ),
        Recipe(
            id: "egg-scramble",
            title: "3-Egg Veggie Scramble",
            blurb: "Eggs, spinach, mushrooms, sourdough.",
            timeMinutes: 12, baseServings: 1,
            macrosPerServing: Macros(kcal: 440, protein: 28, carbs: 32, fat: 22),
            ingredients: [
                .init(ingredientId: "eggs", qty: 3),
                .init(ingredientId: "spinach", qty: 60),
                .init(ingredientId: "mushroom", qty: 80),
                .init(ingredientId: "sourdough", qty: 2),
                .init(ingredientId: "oliveoil", qty: 1),
            ],
            steps: [
                "Sauté mushrooms 4 min, add spinach 1 min.",
                "Pour in beaten eggs, fold until just set.",
                "Toast sourdough."
            ],
            tags: [.highProtein, .vegetarian],
            suitableMeals: [.breakfast], accentHue: 0.13, glyph: "sun.max.fill"
        ),
        Recipe(
            id: "tuna-wrap",
            title: "Tuna Salad Wrap",
            blurb: "Tuna, Greek yogurt, cucumber, tortilla.",
            timeMinutes: 10, baseServings: 1,
            macrosPerServing: Macros(kcal: 420, protein: 36, carbs: 38, fat: 12),
            ingredients: [
                .init(ingredientId: "tuna", qty: 1),
                .init(ingredientId: "greekyog", qty: 60),
                .init(ingredientId: "cucumber", qty: 1),
                .init(ingredientId: "tortilla", qty: 1),
                .init(ingredientId: "lemon", qty: 1),
            ],
            steps: [
                "Mix tuna, yogurt, lemon, pepper.",
                "Add diced cucumber.",
                "Wrap in tortilla."
            ],
            tags: [.highProtein, .pescatarian],
            suitableMeals: [.lunch, .snack], accentHue: 0.5, glyph: "scroll.fill"
        ),
        Recipe(
            id: "lentil-stew",
            title: "Red Lentil + Carrot Stew",
            blurb: "Hearty lentils, carrots, cumin, lemon finish.",
            timeMinutes: 35, baseServings: 3,
            macrosPerServing: Macros(kcal: 460, protein: 24, carbs: 70, fat: 8),
            ingredients: [
                .init(ingredientId: "lentils", qty: 300),
                .init(ingredientId: "carrot", qty: 3),
                .init(ingredientId: "onion", qty: 1),
                .init(ingredientId: "garlic", qty: 2),
                .init(ingredientId: "cumin", qty: 2),
                .init(ingredientId: "lemon", qty: 1),
                .init(ingredientId: "oliveoil", qty: 1),
            ],
            steps: [
                "Sweat onion and carrot 8 min.",
                "Add garlic and cumin, 30 sec.",
                "Add lentils + 900 ml water; simmer 25 min.",
                "Finish with lemon juice."
            ],
            tags: [.vegan, .vegetarian, .dairyFree, .glutenFree],
            suitableMeals: [.lunch, .dinner], accentHue: 0.07, glyph: "circle.dashed"
        ),
        Recipe(
            id: "chicken-quinoa-salad",
            title: "Chicken + Quinoa Greek Salad",
            blurb: "Cold quinoa, chicken, feta, cucumber, tomato.",
            timeMinutes: 20, baseServings: 2,
            macrosPerServing: Macros(kcal: 540, protein: 44, carbs: 50, fat: 16),
            ingredients: [
                .init(ingredientId: "chicken", qty: 300),
                .init(ingredientId: "quinoa", qty: 150),
                .init(ingredientId: "cucumber", qty: 1),
                .init(ingredientId: "tomato", qty: 2),
                .init(ingredientId: "feta", qty: 60),
                .init(ingredientId: "lemon", qty: 1),
                .init(ingredientId: "oliveoil", qty: 2),
            ],
            steps: [
                "Cook quinoa, cool.",
                "Grill chicken, slice.",
                "Toss everything with lemon, olive oil, feta."
            ],
            tags: [.highProtein, .glutenFree],
            suitableMeals: [.lunch], accentHue: 0.3, glyph: "leaf.circle.fill"
        ),
        Recipe(
            id: "chickpea-curry",
            title: "Coconut Chickpea Curry",
            blurb: "Chickpeas, tomato, warming spices, rice.",
            timeMinutes: 25, baseServings: 3,
            macrosPerServing: Macros(kcal: 500, protein: 18, carbs: 78, fat: 14),
            ingredients: [
                .init(ingredientId: "chickpeas", qty: 2),
                .init(ingredientId: "tomato", qty: 3),
                .init(ingredientId: "onion", qty: 1),
                .init(ingredientId: "garlic", qty: 2),
                .init(ingredientId: "cumin", qty: 1),
                .init(ingredientId: "rice", qty: 200),
                .init(ingredientId: "oliveoil", qty: 1),
            ],
            steps: [
                "Sauté onion + garlic 5 min.",
                "Add spices and tomato, cook 5 min.",
                "Add chickpeas, simmer 10 min.",
                "Serve over rice."
            ],
            tags: [.vegan, .vegetarian, .dairyFree],
            suitableMeals: [.dinner], accentHue: 0.1, glyph: "circle.grid.2x2.fill"
        ),
        Recipe(
            id: "cottage-banana",
            title: "Cottage Cheese + Banana Bowl",
            blurb: "Cottage cheese, banana, almonds, honey.",
            timeMinutes: 3, baseServings: 1,
            macrosPerServing: Macros(kcal: 340, protein: 28, carbs: 36, fat: 9),
            ingredients: [
                .init(ingredientId: "cottage", qty: 200),
                .init(ingredientId: "banana", qty: 1),
                .init(ingredientId: "almonds", qty: 15),
                .init(ingredientId: "honey", qty: 1),
            ],
            steps: ["Spoon, slice, sprinkle, drizzle. Done."],
            tags: [.highProtein, .vegetarian, .glutenFree],
            suitableMeals: [.snack, .breakfast], accentHue: 0.18, glyph: "circle.fill"
        ),
        Recipe(
            id: "chicken-zucchini-bake",
            title: "Sheet-Pan Chicken + Zucchini",
            blurb: "One tray. Chicken, zucchini, lemon, herbs.",
            timeMinutes: 30, baseServings: 3,
            macrosPerServing: Macros(kcal: 460, protein: 46, carbs: 18, fat: 22),
            ingredients: [
                .init(ingredientId: "chicken", qty: 600),
                .init(ingredientId: "zucchini", qty: 3),
                .init(ingredientId: "lemon", qty: 1),
                .init(ingredientId: "garlic", qty: 3),
                .init(ingredientId: "oliveoil", qty: 2),
                .init(ingredientId: "paprika", qty: 1),
            ],
            steps: [
                "Toss everything with oil, lemon, garlic, paprika.",
                "Roast at 220°C for 22 min."
            ],
            tags: [.highProtein, .lowCarb, .glutenFree, .dairyFree],
            suitableMeals: [.dinner], accentHue: 0.28, glyph: "rectangle.grid.1x2.fill"
        ),
        Recipe(
            id: "beef-tacos",
            title: "Lean Beef Tacos",
            blurb: "Spiced beef, tortillas, avocado, cilantro.",
            timeMinutes: 20, baseServings: 2,
            macrosPerServing: Macros(kcal: 560, protein: 38, carbs: 42, fat: 24),
            ingredients: [
                .init(ingredientId: "groundbeef", qty: 300),
                .init(ingredientId: "tortilla", qty: 4),
                .init(ingredientId: "avocado", qty: 1),
                .init(ingredientId: "onion", qty: 1),
                .init(ingredientId: "lime", qty: 1),
                .init(ingredientId: "cumin", qty: 1),
                .init(ingredientId: "cilantro", qty: 1),
            ],
            steps: [
                "Brown beef with onion, cumin, salt.",
                "Warm tortillas.",
                "Fill with beef, avocado, lime, cilantro."
            ],
            tags: [.highProtein],
            suitableMeals: [.dinner, .lunch], accentHue: 0.06, glyph: "triangle.fill"
        ),
        Recipe(
            id: "kale-salmon-bowl",
            title: "Massaged Kale + Salmon Bowl",
            blurb: "Kale, flaked salmon, quinoa, lemon dressing.",
            timeMinutes: 25, baseServings: 2,
            macrosPerServing: Macros(kcal: 580, protein: 40, carbs: 42, fat: 26),
            ingredients: [
                .init(ingredientId: "salmon", qty: 280),
                .init(ingredientId: "kale", qty: 200),
                .init(ingredientId: "quinoa", qty: 120),
                .init(ingredientId: "lemon", qty: 1),
                .init(ingredientId: "oliveoil", qty: 2),
                .init(ingredientId: "almonds", qty: 20),
            ],
            steps: [
                "Massage kale with olive oil + lemon + salt.",
                "Roast salmon 12 min at 200°C, flake.",
                "Toss with cooked quinoa and almonds."
            ],
            tags: [.highProtein, .pescatarian, .glutenFree, .dairyFree],
            suitableMeals: [.lunch, .dinner], accentHue: 0.32, glyph: "leaf.fill"
        ),
        Recipe(
            id: "pb-banana-toast",
            title: "PB-Banana Sourdough",
            blurb: "Sourdough, peanut butter, banana, honey.",
            timeMinutes: 5, baseServings: 1,
            macrosPerServing: Macros(kcal: 420, protein: 16, carbs: 58, fat: 14),
            ingredients: [
                .init(ingredientId: "sourdough", qty: 2),
                .init(ingredientId: "peanutbutter", qty: 2),
                .init(ingredientId: "banana", qty: 1),
                .init(ingredientId: "honey", qty: 1),
            ],
            steps: ["Toast. Spread. Slice banana. Drizzle honey."],
            tags: [.vegetarian],
            suitableMeals: [.breakfast, .snack], accentHue: 0.12, glyph: "square.fill"
        ),
        Recipe(
            id: "egg-veggie-burrito",
            title: "Breakfast Egg Burrito",
            blurb: "Eggs, peppers, cheddar, wrapped tight.",
            timeMinutes: 12, baseServings: 1,
            macrosPerServing: Macros(kcal: 480, protein: 32, carbs: 36, fat: 22),
            ingredients: [
                .init(ingredientId: "eggs", qty: 3),
                .init(ingredientId: "bellpepper", qty: 1),
                .init(ingredientId: "cheddar", qty: 30),
                .init(ingredientId: "tortilla", qty: 1),
                .init(ingredientId: "oliveoil", qty: 1),
            ],
            steps: [
                "Sauté peppers 4 min.",
                "Scramble eggs in pan, fold in cheese.",
                "Wrap in tortilla."
            ],
            tags: [.highProtein, .vegetarian],
            suitableMeals: [.breakfast], accentHue: 0.08, glyph: "sun.max.fill"
        ),
        Recipe(
            id: "shrimp-tacos",
            title: "Chili-Lime Shrimp Tacos",
            blurb: "Quick shrimp tacos with slaw and lime.",
            timeMinutes: 18, baseServings: 2,
            macrosPerServing: Macros(kcal: 510, protein: 36, carbs: 50, fat: 16),
            ingredients: [
                .init(ingredientId: "shrimp", qty: 300),
                .init(ingredientId: "tortilla", qty: 4),
                .init(ingredientId: "lime", qty: 1),
                .init(ingredientId: "avocado", qty: 1),
                .init(ingredientId: "chili", qty: 1),
                .init(ingredientId: "oliveoil", qty: 1),
            ],
            steps: [
                "Toss shrimp with chili + lime.",
                "Sear 2 min per side.",
                "Fill warm tortillas with shrimp + avocado."
            ],
            tags: [.pescatarian, .highProtein, .dairyFree],
            suitableMeals: [.dinner, .lunch], accentHue: 0.96, glyph: "triangle.fill"
        ),
        Recipe(
            id: "yogurt-bowl-banana",
            title: "Yogurt + Oats + Banana",
            blurb: "Cold yogurt over toasted oats and banana.",
            timeMinutes: 5, baseServings: 1,
            macrosPerServing: Macros(kcal: 410, protein: 28, carbs: 48, fat: 10),
            ingredients: [
                .init(ingredientId: "greekyog", qty: 200),
                .init(ingredientId: "oats", qty: 40),
                .init(ingredientId: "banana", qty: 1),
                .init(ingredientId: "honey", qty: 1),
            ],
            steps: ["Layer yogurt, oats, banana.", "Drizzle honey."],
            tags: [.highProtein, .vegetarian],
            suitableMeals: [.breakfast, .snack], accentHue: 0.5, glyph: "bowl.fill"
        ),
        Recipe(
            id: "chicken-pasta",
            title: "Chicken + Tomato Pasta",
            blurb: "Pasta in light tomato sauce with seared chicken.",
            timeMinutes: 25, baseServings: 2,
            macrosPerServing: Macros(kcal: 620, protein: 46, carbs: 70, fat: 14),
            ingredients: [
                .init(ingredientId: "chicken", qty: 300),
                .init(ingredientId: "pasta", qty: 180),
                .init(ingredientId: "tomato", qty: 3),
                .init(ingredientId: "garlic", qty: 2),
                .init(ingredientId: "parmesan", qty: 30),
                .init(ingredientId: "oliveoil", qty: 2),
            ],
            steps: [
                "Cook pasta al dente.",
                "Sear chicken, slice.",
                "Sauté garlic + tomato 8 min, toss with pasta + chicken."
            ],
            tags: [.highProtein],
            suitableMeals: [.dinner, .lunch], accentHue: 0.0, glyph: "fork.knife"
        ),
        Recipe(
            id: "turkey-lettuce",
            title: "Turkey + Avocado Lettuce Cups",
            blurb: "Light, fast, low-carb. High protein punch.",
            timeMinutes: 15, baseServings: 2,
            macrosPerServing: Macros(kcal: 420, protein: 36, carbs: 18, fat: 22),
            ingredients: [
                .init(ingredientId: "groundturkey", qty: 300),
                .init(ingredientId: "avocado", qty: 1),
                .init(ingredientId: "lime", qty: 1),
                .init(ingredientId: "garlic", qty: 2),
                .init(ingredientId: "soysauce", qty: 1),
                .init(ingredientId: "chili", qty: 1),
                .init(ingredientId: "kale", qty: 100),
            ],
            steps: [
                "Sauté garlic, add turkey, brown 6 min.",
                "Add soy + chili.",
                "Spoon into kale leaves with avocado + lime."
            ],
            tags: [.highProtein, .lowCarb, .dairyFree],
            suitableMeals: [.lunch, .dinner], accentHue: 0.28, glyph: "leaf.arrow.circlepath"
        ),
        Recipe(
            id: "quinoa-bowl-veg",
            title: "Roasted Veg Quinoa Bowl",
            blurb: "Quinoa, roasted veg, feta, lemon.",
            timeMinutes: 30, baseServings: 2,
            macrosPerServing: Macros(kcal: 520, protein: 18, carbs: 70, fat: 18),
            ingredients: [
                .init(ingredientId: "quinoa", qty: 150),
                .init(ingredientId: "zucchini", qty: 2),
                .init(ingredientId: "bellpepper", qty: 1),
                .init(ingredientId: "feta", qty: 60),
                .init(ingredientId: "oliveoil", qty: 2),
                .init(ingredientId: "lemon", qty: 1),
            ],
            steps: [
                "Roast veg with oil + salt at 220°C, 22 min.",
                "Cook quinoa.",
                "Combine, finish with feta + lemon."
            ],
            tags: [.vegetarian],
            suitableMeals: [.lunch, .dinner], accentHue: 0.35, glyph: "square.grid.2x2.fill"
        ),
    ]

    static let recipeById: [String: Recipe] = {
        Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })
    }()
}
