import Foundation

struct EmojiItem: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let shortcode: String
}

class EmojiDatabase {
    static let shared = EmojiDatabase()
    
    let allEmojis: [EmojiItem]
    
    private init() {
        var items: [EmojiItem] = []
        
        // Smileys & Emotion
        let smileys = [
            ("😀", "grinning"), ("😃", "smiley"), ("😄", "smile"), ("😁", "grin"),
            ("😆", "laughing"), ("😅", "sweat_smile"), ("🤣", "rofl"), ("😂", "joy"),
            ("🙂", "slight_smile"), ("🙃", "upside_down"), ("😉", "wink"), ("😊", "blush"),
            ("😇", "innocent"), ("🥰", "smiling_face_with_three_hearts"), ("😍", "heart_eyes"), ("🤩", "star_eyes"),
            ("😘", "kissing_heart"), ("😗", "kissing"), ("☺️", "relaxed"), ("😚", "kissing_closed_eyes"),
            ("😙", "kissing_smiling_eyes"), ("😋", "yum"), ("😛", "stuck_out_tongue"), ("😜", "stuck_out_tongue_winking_eye"),
            ("🤪", "zany"), ("😝", "stuck_out_tongue_closed_eyes"), ("🤑", "money_mouth"), ("🤗", "hugging"),
            ("🤭", "hand_over_mouth"), ("🤫", "shush"), ("🤔", "thinking"), ("🤐", "zipper_mouth"),
            ("🤨", "raised_eyebrow"), ("😐", "neutral_face"), ("😑", "expressionless"), ("😶", "no_mouth"),
            ("😏", "smirk"), ("😒", "unamused"), ("🙄", "roll_eyes"), ("😬", "grimacing"),
            ("🤥", "lying_face"), ("😌", "relieved"), ("😔", "pensive"), ("😪", "sleepy"),
            ("🤤", "drooling_face"), ("😴", "sleeping"), ("😷", "masked"), ("🤒", "face_with_thermometer"),
            ("🤕", "face_with_head_bandage"), ("🤢", "nauseated_face"), ("🤮", "vomiting"), ("🤧", "sneezing_face"),
            ("🥵", "hot_face"), ("🥶", "cold_face"), ("🥴", "woozy_face"), ("😵", "dizzy_face"),
            ("🤯", "exploding_head"), ("🤠", "cowboy"), ("🥳", "party_face"), ("😎", "sunglasses"),
            ("🤓", "nerd_face"), ("🧐", "monocle"), ("😕", "confused"), ("😟", "worried"),
            ("🙁", "slight_frown"), ("☹️", "frown"), ("😮", "open_mouth"), ("😯", "hushed"),
            ("😲", "astonished"), ("😳", "flushed"), ("🥺", "pleading"), ("😦", "frowning"),
            ("😧", "anguished"), ("😨", "fearful"), ("😰", "cold_sweat"), ("😢", "sad"),
            ("😭", "sob"), ("😱", "screaming"), ("😖", "confounded"), ("😣", "persevere"),
            ("😞", "disappointed"), ("😓", "sweat"), ("😩", "weary"), ("😫", "tired_face"),
            ("🥱", "yawning_face"), ("😤", "triumph"), ("😡", "rage"), ("😠", "angry"),
            ("🤬", "cursing"), ("😈", "smiling_imp"), ("👿", "imp"), ("💀", "skull"),
            ("☠️", "skull_and_crossbones"), ("💩", "poop"), ("🤡", "clown"), ("👹", "ogre"),
            ("👺", "goblin"), ("👻", "ghost"), ("👽", "alien"), ("🤖", "robot"),
            ("👾", "space_invader"), ("😺", "smiley_cat"), ("😸", "smile_cat"), ("😹", "joy_cat"),
            ("😻", "heart_eyes_cat"), ("😼", "smirk_cat"), ("😽", "kissing_cat"), ("🙀", "scream_cat"),
            ("😿", "crying_cat"), ("😾", "angry_cat"), ("🙈", "see_no_evil"), ("🙉", "hear_no_evil"),
            ("🙊", "speak_no_evil"), ("💋", "kiss"), ("💌", "love_letter"), ("💘", "heart_with_arrow"),
            ("💝", "heart_with_ribbon"), ("💖", "sparkling_heart"), ("💗", "growing_heart"), ("💓", "beating_heart"),
            ("💞", "revolving_hearts"), ("💕", "two_hearts"), ("💟", "heart_decoration"), ("❣️", "heart_exclamation"),
            ("💔", "broken_heart"), ("❤️", "heart"), ("🧡", "orange_heart"), ("💛", "yellow_heart"),
            ("💚", "green_heart"), ("💙", "blue_heart"), ("💜", "purple_heart"), ("🖤", "black_heart"),
            ("🤍", "white_heart"), ("🤎", "brown_heart")
        ]
        
        // Hand Gestures & People
        let gestures = [
            ("👋", "wave"), ("🤚", "raised_back_of_hand"), ("🖐️", "raised_hand_with_fingers_splayed"), ("✋", "hand"),
            ("🖖", "vulcan_salute"), ("👌", "ok_hand"), ("🤌", "pinched_fingers"), ("🤏", "pinching_hand"),
            ("✌️", "v"), ("🤞", "crossed_fingers"), ("🤟", "love_you"), ("🤘", "metal"),
            ("🤙", "call_me"), ("👈", "point_left"), ("👉", "point_right"), ("👆", "point_up"),
            ("🖕", "middle_finger"), ("👇", "point_down"), ("☝️", "point_up_2"), ("👍", "thumbsup"),
            ("👎", "thumbsdown"), ("✊", "fist"), ("👊", "punch"), ("🤛", "left_fist"),
            ("🤜", "right_fist"), ("👏", "clap"), ("🙌", "raised_hands"), ("👐", "open_hands"),
            ("🤲", "palms_up"), ("🤝", "handshake"), ("🙏", "pray"), ("✍️", "writing_hand"),
            ("💅", "nail_care"), ("🤳", "selfie"), ("💪", "muscle"), ("🦾", "mechanical_arm"),
            ("🦿", "mechanical_leg"), ("🧠", "brain"), ("🦷", "tooth"), ("👀", "eyes"),
            ("👁️", "eye"), ("👅", "tongue"), ("👄", "mouth"), ("👃", "nose"),
            ("👂", "ear"), ("👣", "footprints"), ("👤", "bust_in_silhouette"), ("👥", "busts_in_silhouette"),
            ("🗣️", "speaking_head")
        ]
        
        // Animals & Nature
        let animalsAndNature = [
            ("🐵", "monkey_face"), ("🐒", "monkey"), ("🦍", "gorilla"), ("🦧", "orangutan"),
            ("🐶", "dog"), ("🐕", "dog2"), ("🦮", "guide_dog"), ("🐩", "poodle"),
            ("🐺", "wolf"), ("🦊", "fox_face"), ("🦝", "raccoon"), ("🐱", "cat"),
            ("🐈", "cat2"), ("🦁", "lion"), ("🐯", "tiger"), ("🐅", "tiger2"),
            ("🐆", "leopard"), ("🐴", "horse"), ("🐎", "racehorse"), ("🦄", "unicorn"),
            ("🦓", "zebra"), ("🦌", "deer"), ("🦬", "bison"), ("🐮", "cow"),
            ("🐂", "ox"), ("🐃", "water_buffalo"), ("🐄", "cow2"), ("🐷", "pig"),
            ("🐖", "pig2"), ("🐗", "boar"), ("🐽", "pig_nose"), ("🐑", "sheep"),
            ("🐐", "goat"), ("🐪", "camel"), ("🐫", "dromedary_camel"), ("🦙", "llama"),
            ("🦒", "giraffe"), ("🐘", "elephant"), ("🦣", "mammoth"), ("🦏", "rhinoceros"),
            ("🦛", "hippopotamus"), ("🐭", "mouse"), ("🐀", "rat"), ("🐹", "hamster"),
            ("🐰", "rabbit"), ("🐇", "rabbit2"), ("🐿️", "chipmunk"), ("🦫", "beaver"),
            ("🦔", "hedgehog"), ("🦇", "bat"), ("🐻", "bear"), ("🐨", "koala"),
            ("🐼", "panda"), ("🦥", "sloth"), ("🦦", "otter"), ("🦨", "skunk"),
            ("🦘", "kangaroo"), ("🦡", "badger"), ("🐾", "paw_prints"), ("🦃", "turkey"),
            ("🐔", "chicken"), ("🐓", "rooster"), ("🐣", "hatching_chick"), ("🐤", "baby_chick"),
            ("🐥", "hatched_chick"), ("🐦", "bird"), ("🐧", "penguin"), ("🕊️", "dove"),
            ("🦅", "eagle"), ("🦆", "duck"), ("🦢", "swan"), ("🦉", "owl"),
            ("🦤", "dodo"), ("🦩", "flamingo"), ("🦚", "peacock"), ("🦜", "parrot"),
            ("🐸", "frog"), ("🐊", "crocodile"), ("🐢", "turtle"), ("🦎", "lizard"),
            ("🐍", "snake"), ("🐲", "dragon_face"), ("🐉", "dragon"), ("🦕", "sauropod"),
            ("🦖", "t-rex"), ("🐳", "whale"), ("🐋", "whale2"), ("🐬", "dolphin"),
            ("🦭", "seal"), ("🐟", "fish"), ("🐠", "tropical_fish"), ("🐡", "blowfish"),
            ("🦈", "shark"), ("🐙", "octopus"), ("🐚", "shell"), ("🐌", "snail"),
            ("🦋", "butterfly"), ("🐛", "bug"), ("🐜", "ant"), ("🐝", "bee"),
            ("🪲", "beetle"), ("🐞", "ladybug"), ("🦗", "cricket"), ("🪳", "cockroach"),
            ("🕷️", "spider"), ("🕸️", "spider_web"), ("Scorpion", "🦂"), (" Mosquito", "🦟"), // Wait, fix syntax here
            ("🦟", "mosquito"), ("🪰", "fly"), ("🪱", "worm"), ("🦠", "microbe"),
            ("💐", "bouquet"), ("🌸", "cherry_blossom"), ("💮", "white_flower"), ("🏵️", "rosette"),
            ("🌹", "rose"), ("🥀", "wilted_flower"), ("🌺", "hibiscus"), ("🌻", "sunflower"),
            ("🌼", "blossom"), ("🌷", "tulip"), ("🌱", "seedling"), ("🪴", "potted_plant"),
            ("🌲", "evergreen_tree"), ("🌳", "deciduous_tree"), ("🌴", "palm_tree"), ("🌵", "cactus"),
            ("🌾", "sheaf_of_rice"), ("🌿", "herb"), ("☘️", "shamrock"), ("🍀", "clover"),
            ("🍁", "maple_leaf"), ("🍂", "fallen_leaf"), ("🍃", "leaves")
        ]
        
        // Food & Drink
        let foodAndDrink = [
            ("🍇", "grapes"), ("🍈", "melon"), ("🍉", "watermelon"), ("🍊", "tangerine"),
            ("🍋", "lemon"), ("🍌", "banana"), ("🍍", "pineapple"), ("🥭", "mango"),
            ("🍎", "apple"), ("🍏", "green_apple"), ("🍐", "pear"), ("🍑", "peach"),
            ("🍒", "cherries"), ("🍓", "strawberry"), ("🫐", "blueberries"), ("🥝", "kiwi"),
            ("🍅", "tomato"), ("🫒", "olive"), ("🥥", "coconut"), ("🥑", "advocado"),
            ("🍆", "eggplant"), ("🥔", "potato"), ("🥕", "carrot"), ("🌽", "corn"),
            ("🌶️", "hot_pepper"), ("🫑", "bell_pepper"), ("🥒", "cucumber"), ("🥬", "leafy_green"),
            ("🥦", "broccoli"), ("🧄", "garlic"), ("🧅", "onion"), ("🍄", "mushroom"),
            ("🥜", "peanut"), ("🌰", "chestnut"), ("🍞", "bread"), ("🥐", "croissant"),
            ("🥖", "baguette_bread"), ("🫓", "flatbread"), ("🥨", "pretzel"), ("🥯", "bagel"),
            ("🥞", "pancakes"), ("🧇", "waffle"), ("🧀", "cheese"), ("🍖", "meat_on_bone"),
            ("🍗", "poultry_leg"), ("🥩", "cut_of_meat"), ("🥓", "bacon"), ("🍔", "hamburger"),
            ("🍟", "fries"), ("🍕", "pizza"), ("🌭", "hotdog"), ("🥪", "sandwich"),
            ("🌮", "taco"), ("🌯", "burrito"), ("🫔", "tamale"), ("🥙", "stuffed_flatbread"),
            ("🧆", "falafel"), ("🍳", "egg"), ("🥘", "shallow_pan_of_food"), ("🍲", "stew"),
            ("🫕", "fondue"), ("🥣", "bowl_with_spoon"), ("🥗", "green_salad"), ("🍿", "popcorn"),
            ("🧈", "butter"), ("🧂", "salt"), ("🥫", "canned_food"), ("🍱", "bento"),
            ("🍘", "rice_cracker"), ("🍙", "rice_ball"), ("🍚", "rice"), ("🍛", "curry"),
            ("🍜", "ramen"), ("🍝", "spaghetti"), ("🍠", "sweet_potato"), ("🍢", "oden"),
            ("🍣", "sushi"), ("🍤", "fried_shrimp"), ("🍥", "fish_cake"), ("🥮", "moon_cake"),
            ("🍡", "dango"), ("🥟", "dumpling"), ("🥠", "fortune_cookie"), ("🥡", "takeout_box"),
            ("🦀", "crab"), ("🦞", "lobster"), ("🦐", "shrimp"), ("🦑", "squid"),
            ("🦪", "oyster"), ("🍦", "icecream"), ("🍧", "shaved_ice"), ("🍨", "ice_cream"),
            ("🍩", "donut"), ("🍪", "cookie"), ("🎂", "cake"), ("🍰", "birthday"),
            ("🧁", "cupcake"), ("🥧", "pie"), ("🍫", "chocolate_bar"), ("🍬", "candy"),
            ("🍭", "lollipop"), ("🍮", "custard"), ("🍯", "honey_pot"), ("🍼", "baby_bottle"),
            ("🥛", "milk_glass"), ("☕", "coffee"), ("🫖", "teapot"), ("🍵", "tea"),
            ("🍶", "sake"), ("🍾", "champagne"), ("🍷", "wine_glass"), ("🍸", "cocktail"),
            ("🍹", "tropical_drink"), ("🍺", "beer"), ("🍻", "beers"), ("🥂", "clinking_glasses"),
            ("🥃", "tumbler_glass"), ("🥤", "cup_with_straw"), ("🧋", "bubble_tea"), ("🧃", "beverage_box"),
            ("🧉", "mate"), ("🧊", "ice")
        ]
        
        // Travel, Places & Objects
        let travelAndObjects = [
            ("🚗", "car"), ("🚕", "taxi"), ("🚙", "blue_car"), ("🚌", "bus"),
            ("🚎", "trolleybus"), ("🏎️", "race_car"), ("🚓", "police_car"), ("%5C", "ambulance"), // Wait, fix escape
            ("🚑", "ambulance"), ("🚒", "fire_engine"), ("🚐", "minibus"), ("🛻", "pickup_truck"),
            ("🚚", "truck"), ("🚛", "articulated_lorry"), ("🚜", "tractor"), ("🏍️", "motorcycle"),
            ("🛵", "motor_scooter"), ("🦽", "manual_wheelchair"), ("🦼", "motorized_wheelchair"), ("🛺", "auto_rickshaw"),
            ("🚲", "bike"), ("🛴", "kick_scooter"), ("🛹", "skateboard"), ("🛼", "roller_skate"),
            ("🚏", "bus_stop"), ("🛣️", "motorway"), ("🛤️", "railway_track"), ("🛢️", "oil_drum"),
            ("⛽", "fuelpump"), ("🚨", "rotating_light"), ("🚥", "horizontal_traffic_light"), ("🚦", "vertical_traffic_light"),
            ("🛑", "octagonal_sign"), ("🚧", "construction"), ("⚓", "anchor"), ("🛟", "ring_buoy"),
            ("⛵", "sailboat"), ("🛶", "canoe"), ("🚤", "speedboat"), ("🛳️", "passenger_ship"),
            ("⛴️", "ferry"), ("🛥️", "motor_boat"), ("🚢", "ship"), ("✈️", "airplane"),
            ("🛩️", "small_airplane"), ("🛫", "airplane_departure"), ("🛬", "airplane_arrival"), ("🪂", "parachute"),
            ("💺", "seat"), ("🚁", "helicopter"), ("🚟", "suspension_railway"), ("🚠", "mountain_cableway"),
            ("🚡", "aerial_tramway"), ("🛰️", "satellite"), ("🚀", "rocket"), ("🛸", "flying_saucer"),
            ("🛎️", "bellhop_bell"), ("🧳", "luggage"), ("⌛", "hourglass"), ("⏳", "hourglass_flowing_sand"),
            ("⌚", "watch"), ("⏰", "alarm_clock"), ("⏱️", "stopwatch"), ("⏲️", "timer"),
            ("🕵️", "detective"), ("🕶️", "sunglasses_2"), ("👓", "glasses"), ("👔", "shirt"),
            ("👕", "tshirt"), ("👖", "jeans"), ("🧣", "scarf"), ("🧤", "gloves"),
            ("🧥", "coat"), ("🧦", "socks"), ("👗", "dress"), ("👘", "kimono"),
            ("👙", "bikini"), ("👜", "handbag"), ("👛", "purse"), ("🎒", "backpack"),
            ("👞", "shoe"), ("👟", "athletic_shoe"), ("👠", "high_heel"), ("👡", "sandal"),
            ("👢", "boot"), ("👑", "crown"), ("👒", "hat"), ("🎩", "tophat"),
            ("🎓", "graduation_cap"), ("🧢", "billed_cap"), ("💄", "lipstick"), ("💍", "ring"),
            ("💼", "briefcase"), ("🩸", "drop_of_blood"), ("🩹", "adhesive_bandage"), ("🩺", "stethoscope")
        ]
        
        // Technology, Work, Symbols, Weather & Miscellaneous
        let techAndSymbols = [
            ("💻", "computer"), ("🖥️", "monitor"), ("🖨️", "printer"), ("⌨️", "keyboard"),
            ("🖱️", "mouse_tech"), ("🖲️", "trackball"), ("🕹️", "joystick"), ("🗜️", "clamp"),
            ("💾", "floppy_disk"), ("💿", "cd"), ("📀", "dvd"), ("🧮", "abacus"),
            ("🎥", "movie_camera"), ("🎞️", "film_frames"), ("📽️", "film_projector"), ("🎬", "clapperboard"),
            ("📺", "tv"), ("📷", "camera"), ("📸", "camera_flash"), ("📹", "video_camera"),
            ("📼", "vhs"), ("🔍", "magnifying_glass_left"), ("🔎", "magnifying_glass_right"), ("🕯️", "candle"),
            ("💡", "lightbulb"), ("🔦", "flashlight"), ("🏮", "red_paper_lantern"), ("🪔", "diya_lamp"),
            ("📔", "notebook_with_decorative_cover"), ("📕", "closed_book"), ("📖", "open_book"), ("📗", "green_book"),
            ("📘", "blue_book"), ("📙", "orange_book"), ("📚", "books"), ("📓", "notebook"),
            ("📒", "ledger"), ("📝", "pencil"), ("📝", "memo"), ("📝", "writing"),
            ("📁", "folder"), ("📂", "open_folder"), ("🗂️", "card_index_dividers"), ("📅", "calendar"),
            ("📆", "tear_off_calendar"), ("🗒️", "spiral_notepad"), ("🗓️", "spiral_calendar"), ("📇", "card_index"),
            ("📈", "chart_with_upwards_trend"), ("📉", "chart_with_downwards_trend"), ("📊", "bar_chart"), ("📋", "clipboard"),
            ("📌", "pushpin"), ("📍", "round_pushpin"), ("📎", "paperclip"), ("🖇️", "linked_paperclips"),
            ("📏", "straight_ruler"), ("📐", "triangular_ruler"), ("✂️", "scissors"), ("🗃️", "card_file_box"),
            ("🗄️", "file_cabinet"), ("🗑️", "wastebasket"), ("🔒", "lock"), ("🔓", "unlock"),
            ("🔏", "lock_with_ink_pen"), ("🔐", "closed_lock_with_key"), ("🔑", "key"), ("🗝️", "old_key"),
            ("🔨", "hammer"), ("🪓", "axe"), ("⛏️", "pick"), ("⚒️", "hammer_and_pick"),
            ("🛠️", "hammer_and_wrench"), ("🗡️", "dagger"), ("⚔️", "crossed_swords"), ("🔫", "gun"),
            ("🛡️", "shield"), ("🔧", "wrench"), ("🪛", "screwdriver"), ("🔩", "nut_and_bolt"),
            ("⚙️", "gear"), ("🗜️", "vise"), ("⚖️", "balance_scale"), ("🦯", "white_cane"),
            ("🔗", "link"), ("⛓️", "chains"), ("🪝", "hook"), ("🧰", "toolbox"),
            ("🧲", "magnet"), ("🪜", "ladder"), ("🧪", "test_tube"), ("🧫", "petri_dish"),
            ("🧬", "dna"), ("🔬", "microscope"), ("🔭", "telescope"), ("📡", "satellite_antenna"),
            ("💉", "syringe"), ("🩸", "drop_of_blood_2"), ("💊", "pill"), ("🩹", "bandage"),
            ("✨", "sparkles"), ("🔥", "fire"), ("⭐️", "star"), ("🌟", "star2"),
            ("💫", "dizzy"), ("💥", "collision"), ("💥", "boom"), ("🌀", "cyclone"),
            ("🌈", "rainbow"), ("☀️", "sunny"), ("🌤️", "sun_behind_small_cloud"), ("⛅", "partly_sunny"),
            ("🌥️", "sun_behind_large_cloud"), ("🌦️", "sun_behind_rain_cloud"), ("🌧️", "rain"), ("🌨️", "snow"),
            ("🌩️", "lightning"), ("🌪️", "tornado"), ("🌫️", "fog"), ("💨", "wind"),
            ("🌊", "ocean"), ("💧", "droplet"), ("💦", "sweat_drops"), ("☔", "umbrella"),
            ("💯", "100"), ("✅", "check"), ("✔️", "check_mark"), ("❌", "cross"),
            ("⚠️", "warning"), ("ℹ️", "info"), ("❓", "question"), ("❔", "grey_question"),
            ("❕", "grey_exclamation"), ("❗️", "exclamation"), ("🎉", "tada"), ("🎉", "party"),
            ("🎊", "confetti_ball"), ("🎈", "balloon"), ("🎁", "gift"), ("🍀", "four_leaf_clover")
        ]
        
        let allGroups = [smileys, gestures, animalsAndNature, foodAndDrink, travelAndObjects, techAndSymbols]
        
        for group in allGroups {
            for (emoji, shortcode) in group {
                let cleanEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanShortcode = shortcode.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleanEmoji.isEmpty && !cleanShortcode.isEmpty {
                    items.append(EmojiItem(emoji: cleanEmoji, shortcode: cleanShortcode))
                }
            }
        }
        
        // Remove duplicates if any
        var uniqueItems: [EmojiItem] = []
        var seenShortcodes = Set<String>()
        for item in items {
            if !seenShortcodes.contains(item.shortcode) {
                seenShortcodes.insert(item.shortcode)
                uniqueItems.append(item)
            }
        }
        
        self.allEmojis = uniqueItems
    }
}
