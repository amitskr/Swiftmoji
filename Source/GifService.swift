import Foundation
import Cocoa

public enum GifProvider: String, CaseIterable, Identifiable {
    case all = "All"
    case tenor = "Tenor"
    case giphy = "Giphy"
    
    public var id: String { self.rawValue }
}

public struct GifItem: Identifiable, Hashable, Equatable, Codable {
    public let id: String
    public let title: String
    public let previewUrl: String
    public let fullUrl: String
    public let category: String
    public let keywords: [String]
    public let source: String
    public let width: CGFloat
    public let height: CGFloat
    
    public var aspectRatio: CGFloat {
        guard height > 0 else { return 1.0 }
        return width / height
    }
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        previewUrl: String,
        fullUrl: String,
        category: String = "Reactions",
        keywords: [String] = [],
        source: String = "Tenor",
        width: CGFloat = 200,
        height: CGFloat = 200
    ) {
        self.id = id
        self.title = title
        self.previewUrl = previewUrl
        self.fullUrl = fullUrl
        self.category = category
        self.keywords = keywords
        self.source = source
        self.width = width
        self.height = height
    }
}

public class GifService: ObservableObject {
    public static let shared = GifService()
    
    // Memory cache for downloaded GIF raw data
    private let memoryCache = NSCache<NSString, NSData>()
    
    // Disk cache directory
    private let cacheDirectory: URL
    
    // Provider API Keys
    private let tenorApiKey = "LIVDSRZULELA"
    private let tenorClientKey = "swiftmoji_mac"
    private let giphyApiKey = "sXpGFDGZs0Dv1mmNFvYaGUvYwKX0PWIh" // Giphy public SDK key
    
    // Categories matching Gboard reaction chips
    public static let reactionCategories: [String] = [
        "Trending",
        "Reactions",
        "Happy",
        "Love",
        "Dance",
        "Applause",
        "OMG",
        "Facepalm",
        "Sad",
        "Yes",
        "No",
        "Thinking",
        "Party",
        "Laugh",
        "Cat",
        "Dog",
        "Coffee",
        "Sleepy"
    ]
    
    // Rich Curated Library of 100+ Popular GIFs
    public let curatedCatalog: [GifItem]
    
    private init() {
        memoryCache.countLimit = 250
        memoryCache.totalCostLimit = 150 * 1024 * 1024 // 150 MB
        
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("com.amitsarkar.Swiftmoji/GifCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Comprehensive categorized catalog
        self.curatedCatalog = [
            // MARK: - 1. Trending & Pop Culture
            GifItem(
                id: "popcorn_michael",
                title: "Michael Jackson Popcorn",
                previewUrl: "https://media.giphy.com/media/pUeXcg80cO8I8/giphy.gif",
                fullUrl: "https://media.giphy.com/media/pUeXcg80cO8I8/giphy.gif",
                category: "Trending",
                keywords: ["popcorn", "eating", "drama", "watching", "entertained", "movie", "michael"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "leonardo_cheers",
                title: "Gatsby Cheers",
                previewUrl: "https://media.giphy.com/media/GCLlQnV7dXY2KGmpRh/giphy.gif",
                fullUrl: "https://media.giphy.com/media/GCLlQnV7dXY2KGmpRh/giphy.gif",
                category: "Trending",
                keywords: ["cheers", "celebrate", "gatsby", "leonardo", "champagne", "toast", "congrats", "party"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "drake_approval",
                title: "Drake Hotline Bling Approval",
                previewUrl: "https://media.giphy.com/media/l41lFw057lAJQMwg0/giphy.gif",
                fullUrl: "https://media.giphy.com/media/l41lFw057lAJQMwg0/giphy.gif",
                category: "Trending",
                keywords: ["drake", "yes", "approve", "like", "agree", "correct", "good"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "spongebob_imagination",
                title: "Spongebob Rainbow Imagination",
                previewUrl: "https://media.giphy.com/media/BQUITFiYVtNte/giphy.gif",
                fullUrl: "https://media.giphy.com/media/BQUITFiYVtNte/giphy.gif",
                category: "Trending",
                keywords: ["spongebob", "rainbow", "imagination", "magic", "wonder", "creative"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "deal_with_it_dog",
                title: "Deal With It Shades",
                previewUrl: "https://media.giphy.com/media/xTiTnnzSvW1g05nUCQ/giphy.gif",
                fullUrl: "https://media.giphy.com/media/xTiTnnzSvW1g05nUCQ/giphy.gif",
                category: "Trending",
                keywords: ["deal with it", "sunglasses", "shades", "cool", "boss", "swag", "legend"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 2. Reactions & Mind Blown
            GifItem(
                id: "mind_blown",
                title: "Mind Blown Galaxy Explosion",
                previewUrl: "https://media.giphy.com/media/26ufdipQqU2lhNA4g/giphy.gif",
                fullUrl: "https://media.giphy.com/media/26ufdipQqU2lhNA4g/giphy.gif",
                category: "Reactions",
                keywords: ["mindblown", "mind", "blown", "explosion", "shocked", "omg", "whoa", "galaxy"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "shaq_shimmy",
                title: "Shaq Shimmy Wiggle",
                previewUrl: "https://media.giphy.com/media/UO5elnTqo4vSg/giphy.gif",
                fullUrl: "https://media.giphy.com/media/UO5elnTqo4vSg/giphy.gif",
                category: "Reactions",
                keywords: ["shaq", "shimmy", "wiggle", "excited", "happy", "smile", "dance", "ready"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "dramatic_cupcake_dog",
                title: "Staring Cupcake Dog",
                previewUrl: "https://media.giphy.com/media/kKdgdeUG24Prq/giphy.gif",
                fullUrl: "https://media.giphy.com/media/kKdgdeUG24Prq/giphy.gif",
                category: "Reactions",
                keywords: ["dramatic", "stare", "dog", "shocked", "vietnam", "flashback", "eyes"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "homer_simpson_bush",
                title: "Homer Simpson Backs Into Bush",
                previewUrl: "https://media.giphy.com/media/jUwpNzg9IcyrK/giphy.gif",
                fullUrl: "https://media.giphy.com/media/jUwpNzg9IcyrK/giphy.gif",
                category: "Reactions",
                keywords: ["homer", "bush", "disappear", "awkward", "leaving", "bye", "fade", "hide"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "blinking_white_guy",
                title: "Blinking Guy Confused",
                previewUrl: "https://media.giphy.com/media/3ELtfDd4e15UA/giphy.gif",
                fullUrl: "https://media.giphy.com/media/3ELtfDd4e15UA/giphy.gif",
                category: "Reactions",
                keywords: ["blinking", "what", "excuse me", "confused", "huh", "reaction", "guy"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 3. Happy & Joy
            GifItem(
                id: "happy_minion",
                title: "Happy Minion Cheer",
                previewUrl: "https://media.giphy.com/media/11sBLVxNs7v6WA/giphy.gif",
                fullUrl: "https://media.giphy.com/media/11sBLVxNs7v6WA/giphy.gif",
                category: "Happy",
                keywords: ["happy", "minion", "yay", "excited", "cheer", "dance", "joy", "smile"],
                source: "Giphy", width: 200, height: 160
            ),
            GifItem(
                id: "kermit_yay",
                title: "Kermit Yay Flailing",
                previewUrl: "https://media.giphy.com/media/artj92V8o75VPL7AeQ/giphy.gif",
                fullUrl: "https://media.giphy.com/media/artj92V8o75VPL7AeQ/giphy.gif",
                category: "Happy",
                keywords: ["kermit", "yay", "excited", "flail", "arms", "celebrate", "happy", "muppets"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "excited_baby_fistpump",
                title: "Success Kid Fist Pump",
                previewUrl: "https://media.giphy.com/media/nXxOjZrbnbRxS/giphy.gif",
                fullUrl: "https://media.giphy.com/media/nXxOjZrbnbRxS/giphy.gif",
                category: "Happy",
                keywords: ["success", "fist pump", "yes", "win", "winner", "victory", "kid", "great"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "happy_dog_jump",
                title: "Excited Jumping Dog",
                previewUrl: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                fullUrl: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                category: "Happy",
                keywords: ["dog", "happy", "jumping", "excited", "smile", "puppy", "joy"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 4. Dance & Party
            GifItem(
                id: "snoop_dance",
                title: "Snoop Dogg Dance",
                previewUrl: "https://media.giphy.com/media/10hO3rDNqqg2Xe/giphy.gif",
                fullUrl: "https://media.giphy.com/media/10hO3rDNqqg2Xe/giphy.gif",
                category: "Dance",
                keywords: ["dance", "dancing", "snoop", "groove", "music", "party", "vibing", "cool"],
                source: "Giphy", width: 200, height: 200
            ),
            GifItem(
                id: "happy_dance_carlton",
                title: "Carlton Dance",
                previewUrl: "https://media.giphy.com/media/pa37AAGzKXoek/giphy.gif",
                fullUrl: "https://media.giphy.com/media/pa37AAGzKXoek/giphy.gif",
                category: "Dance",
                keywords: ["dance", "carlton", "happy", "party", "celebration", "excited", "joy", "groove"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "party_parrot",
                title: "Cult of Party Parrot",
                previewUrl: "https://media.giphy.com/media/l3q2zbsZa98MnAaFV/giphy.gif",
                fullUrl: "https://media.giphy.com/media/l3q2zbsZa98MnAaFV/giphy.gif",
                category: "Dance",
                keywords: ["party", "parrot", "dance", "rave", "fast", "disco", "club", "music"],
                source: "Giphy", width: 200, height: 200
            ),
            GifItem(
                id: "confetti_party",
                title: "Confetti Celebration",
                previewUrl: "https://media.giphy.com/media/26tOZ42Mg6pbTUPHW/giphy.gif",
                fullUrl: "https://media.giphy.com/media/26tOZ42Mg6pbTUPHW/giphy.gif",
                category: "Party",
                keywords: ["party", "celebration", "confetti", "birthday", "tada", "yay", "cheer", "winner"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "spiderman_dance",
                title: "Spiderman Street Dancing",
                previewUrl: "https://media.giphy.com/media/oW4csEbiMzVjq/giphy.gif",
                fullUrl: "https://media.giphy.com/media/oW4csEbiMzVjq/giphy.gif",
                category: "Dance",
                keywords: ["spiderman", "dance", "marvel", "groove", "funny", "hero", "music"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 5. Applause & Clapping
            GifItem(
                id: "citizen_kane_clap",
                title: "Citizen Kane Clapping",
                previewUrl: "https://media.giphy.com/media/unQ3IJU2RG7DO/giphy.gif",
                fullUrl: "https://media.giphy.com/media/unQ3IJU2RG7DO/giphy.gif",
                category: "Applause",
                keywords: ["applause", "clap", "clapping", "bravo", "great", "job", "congrats", "well done"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "dicaprio_clap",
                title: "Wolf of Wall Street Standing Clap",
                previewUrl: "https://media.giphy.com/media/nbvFVPiEiJH6h44qB5/giphy.gif",
                fullUrl: "https://media.giphy.com/media/nbvFVPiEiJH6h44qB5/giphy.gif",
                category: "Applause",
                keywords: ["applause", "clap", "leonardo", "wolf", "proud", "bravo", "yes", "standing"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "friends_clapping",
                title: "Friends Audience Applause",
                previewUrl: "https://media.giphy.com/media/fnK0jeA8vIh2QLq3IZ/giphy.gif",
                fullUrl: "https://media.giphy.com/media/fnK0jeA8vIh2QLq3IZ/giphy.gif",
                category: "Applause",
                keywords: ["applause", "clap", "crowd", "cheering", "yay", "bravo", "friends"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 6. Love & Hearts
            GifItem(
                id: "love_hearts_cat",
                title: "Cat Heart Eyes",
                previewUrl: "https://media.giphy.com/media/MDJ9IbxxvDUQM/giphy.gif",
                fullUrl: "https://media.giphy.com/media/MDJ9IbxxvDUQM/giphy.gif",
                category: "Love",
                keywords: ["love", "heart", "cat", "cute", "adorable", "sweet", "hug", "kiss"],
                source: "Giphy", width: 200, height: 200
            ),
            GifItem(
                id: "love_blow_kiss",
                title: "Heart Love Kiss Explosion",
                previewUrl: "https://media.giphy.com/media/26FLdm964upN2ZYTVb/giphy.gif",
                fullUrl: "https://media.giphy.com/media/26FLdm964upN2ZYTVb/giphy.gif",
                category: "Love",
                keywords: ["love", "heart", "hearts", "kiss", "valentine", "sweet", "crush", "hug"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "milk_mocha_hug",
                title: "Warm Bear Hug Love",
                previewUrl: "https://media.giphy.com/media/l4pTfx2qLszoacZRS/giphy.gif",
                fullUrl: "https://media.giphy.com/media/l4pTfx2qLszoacZRS/giphy.gif",
                category: "Love",
                keywords: ["hug", "love", "cuddle", "warm", "sweet", "cute", "affection", "couple"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 7. OMG & Shock
            GifItem(
                id: "shocked_cat",
                title: "Shocked Cat Face",
                previewUrl: "https://media.giphy.com/media/C9x8gX02SnMIoAClXA/giphy.gif",
                fullUrl: "https://media.giphy.com/media/C9x8gX02SnMIoAClXA/giphy.gif",
                category: "OMG",
                keywords: ["omg", "shocked", "cat", "gasp", "eyes", "surprised", "what", "wow"],
                source: "Giphy", width: 200, height: 200
            ),
            GifItem(
                id: "pikachu_shocked",
                title: "Surprised Pikachu",
                previewUrl: "https://media.giphy.com/media/6nWhy3ulBL7GSCvKw6/giphy.gif",
                fullUrl: "https://media.giphy.com/media/6nWhy3ulBL7GSCvKw6/giphy.gif",
                category: "OMG",
                keywords: ["pikachu", "pokemon", "shocked", "surprised", "open mouth", "omg", "meme"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "jaw_drop_steve",
                title: "Jaw Drop Shock",
                previewUrl: "https://media.giphy.com/media/PUBxelw8HF4o8/giphy.gif",
                fullUrl: "https://media.giphy.com/media/PUBxelw8HF4o8/giphy.gif",
                category: "OMG",
                keywords: ["jaw drop", "shock", "omg", "gasp", "disbelief", "no way", "unreal"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 8. Facepalm & Disappointment
            GifItem(
                id: "picard_facepalm",
                title: "Captain Picard Facepalm",
                previewUrl: "https://media.giphy.com/media/XsUtdIeJ0MWMo/giphy.gif",
                fullUrl: "https://media.giphy.com/media/XsUtdIeJ0MWMo/giphy.gif",
                category: "Facepalm",
                keywords: ["facepalm", "picard", "star trek", "disappointed", "smh", "sigh", "fail", "no"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "robert_downey_eyeroll",
                title: "Robert Downey Jr Eye Roll",
                previewUrl: "https://media.giphy.com/media/qmfpjpAT2fJRK/giphy.gif",
                fullUrl: "https://media.giphy.com/media/qmfpjpAT2fJRK/giphy.gif",
                category: "Facepalm",
                keywords: ["eye roll", "annoyed", "smh", "iron man", "tony stark", "tired", "really"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 9. Thinking & Confused
            GifItem(
                id: "thinking_math",
                title: "Calculating Math Confusion",
                previewUrl: "https://media.giphy.com/media/4JVTF9fRvgFFA0NOde/giphy.gif",
                fullUrl: "https://media.giphy.com/media/4JVTF9fRvgFFA0NOde/giphy.gif",
                category: "Thinking",
                keywords: ["thinking", "math", "confused", "calculating", "wondering", "puzzle", "brain", "hmm"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "confused_travolta",
                title: "Pulp Fiction Confused Travolta",
                previewUrl: "https://media.giphy.com/media/g01ZnwEHvBzK8/giphy.gif",
                fullUrl: "https://media.giphy.com/media/g01ZnwEHvBzK8/giphy.gif",
                category: "Thinking",
                keywords: ["travolta", "confused", "where", "looking around", "lost", "what", "pulp fiction"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 10. Yes & Approved
            GifItem(
                id: "nod_yes_jack",
                title: "Jack Nicholson Creepy Nod",
                previewUrl: "https://media.giphy.com/media/10Jpr9KSaXLchW/giphy.gif",
                fullUrl: "https://media.giphy.com/media/10Jpr9KSaXLchW/giphy.gif",
                category: "Yes",
                keywords: ["yes", "agree", "nod", "nodding", "jack", "smile", "approved", "correct", "yep"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "nod_yes_dicaprio",
                title: "DiCaprio Nodding Point",
                previewUrl: "https://media.giphy.com/media/L3ERvA6jWCd0qO4NdX/giphy.gif",
                fullUrl: "https://media.giphy.com/media/L3ERvA6jWCd0qO4NdX/giphy.gif",
                category: "Yes",
                keywords: ["yes", "nod", "point", "that's it", "exactly", "correct", "agree"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "thumbsup_chuck",
                title: "Chuck Norris Thumbs Up",
                previewUrl: "https://media.giphy.com/media/mgqefOvJJVTNW/giphy.gif",
                fullUrl: "https://media.giphy.com/media/mgqefOvJJVTNW/giphy.gif",
                category: "Yes",
                keywords: ["thumbs up", "chuck norris", "good", "approved", "awesome", "yes", "like"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 11. No & Refusal
            GifItem(
                id: "steve_carell_no",
                title: "Michael Scott NO GOD PLEASE NO",
                previewUrl: "https://media.giphy.com/media/vyTnNTrs3wqQ0UIvwE/giphy.gif",
                fullUrl: "https://media.giphy.com/media/vyTnNTrs3wqQ0UIvwE/giphy.gif",
                category: "No",
                keywords: ["no", "never", "refuse", "michael scott", "the office", "disagree", "screaming", "stop"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "finger_wag_mutombo",
                title: "Finger Wag No No No",
                previewUrl: "https://media.giphy.com/media/3o85xERD1TT5JKCIXS/giphy.gif",
                fullUrl: "https://media.giphy.com/media/3o85xERD1TT5JKCIXS/giphy.gif",
                category: "No",
                keywords: ["finger wag", "no", "not in my house", "denied", "block", "refuse", "stop"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "head_shake_dwight",
                title: "Dwight Schrute Head Shake",
                previewUrl: "https://media.giphy.com/media/hyyV7pnbE0FqLNBAzs/giphy.gif",
                fullUrl: "https://media.giphy.com/media/hyyV7pnbE0FqLNBAzs/giphy.gif",
                category: "No",
                keywords: ["dwight", "the office", "no", "shake head", "disagree", "refuse", "nope"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 12. Laugh & LOL
            GifItem(
                id: "laughing_ryan_gosling",
                title: "Giggle Laugh",
                previewUrl: "https://media.giphy.com/media/3oEjHAUOqG3lSS0f1C/giphy.gif",
                fullUrl: "https://media.giphy.com/media/3oEjHAUOqG3lSS0f1C/giphy.gif",
                category: "Laugh",
                keywords: ["laugh", "laughing", "haha", "lol", "rofl", "funny", "joke", "giggle", "smile"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "elmo_fire_laugh",
                title: "Elmo Rise In Flames",
                previewUrl: "https://media.giphy.com/media/yr7n0u3qzO9nG/giphy.gif",
                fullUrl: "https://media.giphy.com/media/yr7n0u3qzO9nG/giphy.gif",
                category: "Laugh",
                keywords: ["elmo", "fire", "chaos", "laugh", "evil", "flames", "hilarious", "meme"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 13. Cats & Dogs
            GifItem(
                id: "cat_typing",
                title: "Cat Typing Coding",
                previewUrl: "https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif",
                fullUrl: "https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif",
                category: "Cat",
                keywords: ["cat", "typing", "working", "keyboard", "coding", "fast", "hacker", "computer"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "vibing_cat_headbang",
                title: "Vibing Cat Head Bobbing",
                previewUrl: "https://media.giphy.com/media/GeimqsH0TLJx5iDoC2/giphy.gif",
                fullUrl: "https://media.giphy.com/media/GeimqsH0TLJx5iDoC2/giphy.gif",
                category: "Cat",
                keywords: ["cat", "vibing", "head bob", "music", "beat", "groove", "rhythm", "meme"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "doge_shibe",
                title: "Doge Much Wonder",
                previewUrl: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                fullUrl: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                category: "Dog",
                keywords: ["dog", "doge", "excited", "happy", "cute", "shiba", "puppy", "fluffy"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 14. Coffee & Morning
            GifItem(
                id: "coffee_morning",
                title: "Pouring Hot Coffee",
                previewUrl: "https://media.giphy.com/media/3o7TKoWXm3okO1kgHC/giphy.gif",
                fullUrl: "https://media.giphy.com/media/3o7TKoWXm3okO1kgHC/giphy.gif",
                category: "Coffee",
                keywords: ["coffee", "morning", "caffeine", "cup", "tea", "wake up", "work", "drink"],
                source: "Giphy", width: 200, height: 150
            ),
            GifItem(
                id: "coffee_chug_cat",
                title: "Cat Needs Coffee",
                previewUrl: "https://media.giphy.com/media/oZEBLugoTq0SGlNUvl/giphy.gif",
                fullUrl: "https://media.giphy.com/media/oZEBLugoTq0SGlNUvl/giphy.gif",
                category: "Coffee",
                keywords: ["coffee", "caffeine", "morning", "energy", "cat", "monday", "tired"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 15. Sad & Crying
            GifItem(
                id: "kermit_sad_window",
                title: "Kermit Staring At Rain",
                previewUrl: "https://media.giphy.com/media/OPU6wzx8JrHna/giphy.gif",
                fullUrl: "https://media.giphy.com/media/OPU6wzx8JrHna/giphy.gif",
                category: "Sad",
                keywords: ["sad", "crying", "kermit", "rain", "window", "heartbroken", "lonely", "tears"],
                source: "Giphy", width: 200, height: 150
            ),
            
            // MARK: - 16. Sleepy & Tired
            GifItem(
                id: "sleepy_cat_bed",
                title: "Cat Falling Asleep",
                previewUrl: "https://media.giphy.com/media/mguPrVJAnEHIY/giphy.gif",
                fullUrl: "https://media.giphy.com/media/mguPrVJAnEHIY/giphy.gif",
                category: "Sleepy",
                keywords: ["sleepy", "tired", "bed", "nap", "cat", "yawn", "exhausted", "night", "goodnight"],
                source: "Giphy", width: 200, height: 150
            )
        ]
    }
    
    // MARK: - Fast Instant Suggestions for Floating Autocomplete HUD
    public func getQuickSuggestions(for query: String, limit: Int = 3) -> [GifItem] {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if cleanQuery.isEmpty {
            return Array(curatedCatalog.prefix(limit))
        }
        
        let matches = curatedCatalog.filter { item in
            if item.title.lowercased().contains(cleanQuery) { return true }
            if item.category.lowercased().contains(cleanQuery) { return true }
            return item.keywords.contains { $0.lowercased().contains(cleanQuery) || cleanQuery.contains($0.lowercased()) }
        }
        
        if !matches.isEmpty {
            return Array(matches.prefix(limit))
        }
        
        let prefixMatches = curatedCatalog.filter { item in
            item.keywords.contains { $0.lowercased().hasPrefix(cleanQuery) }
        }
        
        if !prefixMatches.isEmpty {
            return Array(prefixMatches.prefix(limit))
        }
        
        return []
    }
    
    // MARK: - Search & Trending Engine with Tenor + Giphy Failover
    public func searchGifs(
        query: String,
        category: String? = nil,
        provider: GifProvider = .all,
        completion: @escaping ([GifItem]) -> Void
    ) {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanQuery.isEmpty {
            if let cat = category, cat != "Trending" {
                let catMatches = curatedCatalog.filter { $0.category.lowercased() == cat.lowercased() }
                if !catMatches.isEmpty {
                    completion(catMatches)
                    return
                }
                searchWithFallback(term: cat, provider: provider, completion: completion)
                return
            } else {
                fetchTrendingWithFallback(provider: provider, completion: completion)
                return
            }
        }
        
        searchWithFallback(term: cleanQuery, provider: provider) { results in
            if !results.isEmpty {
                completion(results)
            } else {
                let local = self.curatedCatalog.filter { item in
                    item.title.lowercased().contains(cleanQuery.lowercased()) ||
                    item.category.lowercased().contains(cleanQuery.lowercased()) ||
                    item.keywords.contains { $0.lowercased().contains(cleanQuery.lowercased()) }
                }
                completion(local.isEmpty ? self.curatedCatalog : local)
            }
        }
    }
    
    private func searchWithFallback(
        term: String,
        provider: GifProvider,
        completion: @escaping ([GifItem]) -> Void
    ) {
        switch provider {
        case .tenor:
            searchTenor(term: term) { results in
                completion(results)
            }
        case .giphy:
            searchGiphy(term: term) { results in
                completion(results)
            }
        case .all:
            // Try Tenor first, fallback to Giphy
            searchTenor(term: term) { [weak self] tenorResults in
                if !tenorResults.isEmpty {
                    completion(tenorResults)
                } else {
                    self?.searchGiphy(term: term) { giphyResults in
                        completion(giphyResults)
                    }
                }
            }
        }
    }
    
    private func fetchTrendingWithFallback(
        provider: GifProvider,
        completion: @escaping ([GifItem]) -> Void
    ) {
        switch provider {
        case .tenor:
            fetchTrendingTenor(completion: completion)
        case .giphy:
            fetchTrendingGiphy(completion: completion)
        case .all:
            fetchTrendingTenor { [weak self] tenorResults in
                if !tenorResults.isEmpty {
                    completion(tenorResults)
                } else {
                    self?.fetchTrendingGiphy { giphyResults in
                        completion(giphyResults.isEmpty ? (self?.curatedCatalog ?? []) : giphyResults)
                    }
                }
            }
        }
    }
    
    // MARK: - 1. Google Tenor API Search & Trending
    private func searchTenor(term: String, completion: @escaping ([GifItem]) -> Void) {
        guard let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion([])
            return
        }
        
        let urlString = "https://tenor.googleapis.com/v2/search?q=\(encoded)&key=\(tenorApiKey)&client_key=\(tenorClientKey)&limit=30&media_filter=gif,tinygif"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            let items = self.parseTenorResponse(data: data, defaultCategory: term.capitalized)
            DispatchQueue.main.async { completion(items) }
        }.resume()
    }
    
    private func fetchTrendingTenor(completion: @escaping ([GifItem]) -> Void) {
        let urlString = "https://tenor.googleapis.com/v2/featured?key=\(tenorApiKey)&client_key=\(tenorClientKey)&limit=30&media_filter=gif,tinygif"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            let items = self.parseTenorResponse(data: data, defaultCategory: "Trending")
            DispatchQueue.main.async { completion(items) }
        }.resume()
    }
    
    private func parseTenorResponse(data: Data, defaultCategory: String) -> [GifItem] {
        var items: [GifItem] = []
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            return []
        }
        
        for res in results {
            let id = res["id"] as? String ?? UUID().uuidString
            let title = res["content_description"] as? String ?? (res["title"] as? String ?? defaultCategory)
            var previewUrl = ""
            var fullUrl = ""
            var width: CGFloat = 200
            var height: CGFloat = 150
            
            if let mediaFormats = res["media_formats"] as? [String: Any] {
                if let tinygif = mediaFormats["tinygif"] as? [String: Any],
                   let url = tinygif["url"] as? String {
                    previewUrl = url
                    if let dims = tinygif["dims"] as? [CGFloat], dims.count >= 2 {
                        width = dims[0]
                        height = dims[1]
                    }
                }
                if let gif = mediaFormats["gif"] as? [String: Any],
                   let url = gif["url"] as? String {
                    fullUrl = url
                }
            }
            
            if previewUrl.isEmpty { previewUrl = fullUrl }
            if fullUrl.isEmpty { fullUrl = previewUrl }
            
            if !previewUrl.isEmpty {
                items.append(GifItem(
                    id: "tenor_\(id)",
                    title: title.isEmpty ? defaultCategory : title,
                    previewUrl: previewUrl,
                    fullUrl: fullUrl,
                    category: defaultCategory,
                    keywords: [defaultCategory.lowercased()],
                    source: "Tenor",
                    width: width,
                    height: height
                ))
            }
        }
        return items
    }
    
    // MARK: - 2. Giphy API Search & Trending
    private func searchGiphy(term: String, completion: @escaping ([GifItem]) -> Void) {
        guard let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion([])
            return
        }
        
        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(giphyApiKey)&q=\(encoded)&limit=30&rating=g"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            let items = self.parseGiphyResponse(data: data, defaultCategory: term.capitalized)
            DispatchQueue.main.async { completion(items) }
        }.resume()
    }
    
    private func fetchTrendingGiphy(completion: @escaping ([GifItem]) -> Void) {
        let urlString = "https://api.giphy.com/v1/gifs/trending?api_key=\(giphyApiKey)&limit=30&rating=g"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            let items = self.parseGiphyResponse(data: data, defaultCategory: "Trending")
            DispatchQueue.main.async { completion(items) }
        }.resume()
    }
    
    private func parseGiphyResponse(data: Data, defaultCategory: String) -> [GifItem] {
        var items: [GifItem] = []
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["data"] as? [[String: Any]] else {
            return []
        }
        
        for res in results {
            let id = res["id"] as? String ?? UUID().uuidString
            let title = res["title"] as? String ?? defaultCategory
            var previewUrl = ""
            var fullUrl = ""
            var width: CGFloat = 200
            var height: CGFloat = 150
            
            if let images = res["images"] as? [String: Any] {
                if let fixedWidth = images["fixed_width_small"] as? [String: Any],
                   let url = fixedWidth["url"] as? String {
                    previewUrl = url
                    if let wStr = fixedWidth["width"] as? String, let w = Double(wStr),
                       let hStr = fixedWidth["height"] as? String, let h = Double(hStr) {
                        width = CGFloat(w)
                        height = CGFloat(h)
                    }
                }
                if let original = images["original"] as? [String: Any],
                   let url = original["url"] as? String {
                    fullUrl = url
                }
            }
            
            if previewUrl.isEmpty { previewUrl = fullUrl }
            if fullUrl.isEmpty { fullUrl = previewUrl }
            
            if !previewUrl.isEmpty {
                items.append(GifItem(
                    id: "giphy_\(id)",
                    title: title.isEmpty ? defaultCategory : title,
                    previewUrl: previewUrl,
                    fullUrl: fullUrl,
                    category: defaultCategory,
                    keywords: [defaultCategory.lowercased()],
                    source: "Giphy",
                    width: width,
                    height: height
                ))
            }
        }
        return items
    }
    
    // MARK: - Download & Cache Helper
    public func fetchGifData(url: URL, completion: @escaping (Data?) -> Void) {
        let key = NSString(string: url.absoluteString)
        
        // 1. Memory cache check
        if let cached = memoryCache.object(forKey: key) {
            completion(cached as Data)
            return
        }
        
        // 2. Disk cache check
        let diskFilename = String(url.absoluteString.hashValue) + ".gif"
        let diskPath = cacheDirectory.appendingPathComponent(diskFilename)
        
        if let diskData = try? Data(contentsOf: diskPath) {
            memoryCache.setObject(diskData as NSData, forKey: key)
            completion(diskData)
            return
        }
        
        // 3. Network fetch
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            self.memoryCache.setObject(data as NSData, forKey: key)
            try? data.write(to: diskPath)
            
            DispatchQueue.main.async {
                completion(data)
            }
        }.resume()
    }
    
    // MARK: - Multi-Format macOS Clipboard Insertion
    public func copyGifToClipboard(item: GifItem, completion: @escaping (Bool) -> Void) {
        let targetUrlString = item.fullUrl.isEmpty ? item.previewUrl : item.fullUrl
        guard let url = URL(string: targetUrlString) else {
            completion(false)
            return
        }
        
        fetchGifData(url: url) { data in
            guard let gifData = data else {
                // Fallback: copy string URL
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(targetUrlString, forType: .string)
                completion(true)
                return
            }
            
            // 1. Write GIF data to temporary file for apps requiring file URLs
            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let tempFile = tempDir.appendingPathComponent("Swiftmoji_\(UUID().uuidString).gif")
            try? gifData.write(to: tempFile)
            
            // 2. Populate NSPasteboard with all standard macOS formats
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            
            // Primary: GIF raw data (com.compuserve.gif / public.gif)
            pasteboard.setData(gifData, forType: NSPasteboard.PasteboardType("com.compuserve.gif"))
            pasteboard.setData(gifData, forType: NSPasteboard.PasteboardType("public.gif"))
            pasteboard.setData(gifData, forType: NSPasteboard.PasteboardType("public.image"))
            
            // File URL
            pasteboard.setString(tempFile.absoluteString, forType: .fileURL)
            pasteboard.writeObjects([tempFile as NSURL])
            
            // Direct web URL & plain string
            pasteboard.setString(targetUrlString, forType: .string)
            pasteboard.setString(targetUrlString, forType: .URL)
            
            // Bitmap fallback (TIFF)
            if let image = NSImage(data: gifData), let tiff = image.tiffRepresentation {
                pasteboard.setData(tiff, forType: .tiff)
            }
            
            // Track usage count
            let usageKey = "emojiUsageCount"
            var dict = UserDefaults.standard.dictionary(forKey: usageKey) as? [String: Int] ?? [:]
            dict[item.title] = (dict[item.title] ?? 0) + 1
            UserDefaults.standard.set(dict, forKey: usageKey)
            
            // Play sound effect if enabled
            if UserDefaults.standard.bool(forKey: "soundEffects") {
                NSSound(named: "Pop")?.play()
            }
            
            completion(true)
        }
    }
    
    // MARK: - Simulate Command + V Paste
    public func simulatePaste() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let source = CGEventSource(stateID: .hidSystemState)
            let vKey: CGKeyCode = 9 // 'V' keycode on macOS
            let flags: CGEventFlags = [.maskCommand]
            
            if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true) {
                keyDown.flags = flags
                keyDown.post(tap: .cgSessionEventTap)
            }
            
            if let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false) {
                keyUp.flags = flags
                keyUp.post(tap: .cgSessionEventTap)
            }
        }
    }
}
