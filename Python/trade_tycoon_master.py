import random
import os
import time
import hashlib
import sys
import json

class Colors:
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    MAGENTA = '\033[35m' # Legendary Artifact Color
    GRAY = '\033[38;5;239m'
    RESET = '\033[0m'

class TradeTycoon:
    def __init__(self):
        # Trigger the initial state on load with default values
        self.reset_game_state()

    def reset_game_state(self, bonus_gp=0, kept_artifact=None, kept_qty=0):
        # --- Single Source of Truth for Game Variables ---
        self.run_id = random.randint(100000, 999999)
        self.money = 10000 + bonus_gp
        self.week = 1
        self.unlock_cost = 500000
        self.unlocked_count = 0
        self.total_score = 0
        self.current_events = []

        self.active_items = ["Wood", "Fish", "Wheat", "Flour", "Mirrors",
                             "Candles", "Cloth", "Leather", "Slaves", "Blankets",
                             "Coal", "Stone", "Salt", "Glass", "Waterskin",
                             "Beer", "Rations", "Torches", "Herbs", "Arrows"]

        self.locked_items = [
            "Pork", "Beef", "Lamb", "Gunpowder", "Cheese", "Honey", "Beeswax", "Olives", "Olive Oil",
            "Pepper", "Cinnamon", "Paprika", "Coffee", "Cocoa", "Tobacco",
            "Flint & Steel", "Iron", "Silver", "Gold", "Tin", "Lead", "Glowcopper", "Mercury", "Obsidian", "Meteorite", "Mithril", "Adamantine", "Lavastone", "Orichalum", "Palladium", "Titanium", "Chlorophyte",
            "Daggers", "Swords", "Armor", "Antitoxin", "Poison", "Pottery", "Rope",
            "Amber", "Topaz", "Sapphire", "Amethyst", "Emerald", "Ivory", "Ruby", "Sunstone", "Diamond", "Potions", "Frankincense", "Myrrh", "Indigo",
            "Scrolls", "Silk", "Dragon Scales", "Shadow Lantern", "Whisperwind Cloak", "Compass of True North",
            "Dream Dust", "Glitterstim", "Phoenix Feather", "Parchment", "Cat Memes", "Vorpal Blades",
            "Philosopher Stones", "Sleeper Agents", "Bag of Holding", "Invisibility Cloak", "Lucky Dice", "Nanites",
            "Dimensional Pinball Machine", "Everlasting Gobstopper", "Romulan Ale", "Lightsaber", "Safety Deposit Box",
            "Cryptocurrency", "Crown Jewel", "Time Machine"
        ]

        self.artifacts = ["Smuggler's Writ", "Black Swan Catalyst", "Political Favors"]
        self.current_hash = ""
        self.artifact_stock = {}

        self.inventory = {item: 0 for item in self.active_items}
        self.average_cost = {item: 0 for item in self.active_items}

        for art in self.artifacts:
            self.inventory[art] = 0
            self.average_cost[art] = 0

        # Inject the hoarded stack if Prestige arguments were passed
        if kept_artifact and kept_qty > 0:
            self.inventory[kept_artifact] = kept_qty

        self.current_market = []
        self.market_prices = {}

    def clear_screen(self):
        os.system('cls' if os.name == 'nt' else 'clear')

    def get_price_color(self, price):
        max_price = 255 + (self.unlocked_count * 5)
        halfway = max_price / 2.0

        p = min(max(int(price), 1), max_price)

        if p <= halfway:
            r = int((p / halfway) * 255)
            g = 255
        else:
            r = 255
            g = int(255 - (((p - halfway) / (max_price - halfway)) * 255))

        b = 0
        return f"\033[38;2;{r};{g};{b}m"

    def get_market_hash(self, seed_string, seed_string_two):
        hash1 = hashlib.sha512(seed_string.encode()).hexdigest()
        hash2 = hashlib.sha512(seed_string_two.encode()).hexdigest()
        hash3 = hashlib.sha512((seed_string + "_expansion").encode()).hexdigest()
        hash4 = hashlib.sha512((seed_string_two + "_expansion").encode()).hexdigest()
        return hash1 + hash2 + hash3 + hash4

    def roll_for_artifact(self, market_hash, is_grand_market=False):
        # --- SEED-LOCKED ARTIFACT GENERATION ---
        if int(market_hash[0:2], 16) < 48:
            spawned_artifact = random.choice(self.artifacts)
            artifact_price = sum(self.market_prices.values())

            self.current_market.append(spawned_artifact)
            self.market_prices[spawned_artifact] = artifact_price
            self.artifact_stock[spawned_artifact] = 10

            market_type = "GRAND MARKET" if is_grand_market else "MARKET"
            self.current_events.append(f"A LEGENDARY ARTIFACT HAS APPEARED IN THE {market_type}: {spawned_artifact}")

    def generate_market(self):
        self.current_events = []

        self.current_market = []
        self.market_prices = {}
        self.artifact_stock = {}

        seed_string = f"run_{self.run_id}_week_{self.week}_score_{self.total_score}_unlocked_{self.unlocked_count}"
        seed_string_two = f"money_{self.money}_week_{self.week}_score_{self.total_score}_unlocked_{self.unlocked_count}_run_{self.run_id}"

        # Pass BOTH strings into the function
        market_hash = self.get_market_hash(seed_string, seed_string_two)

        self.current_hash = market_hash

        shuffled = random.sample(self.active_items, len(self.active_items))
        market_size = random.randint(8, 15)
        if market_size > len(self.active_items):
            market_size = len(self.active_items)

        for i in range(market_size):
            item = shuffled[i]
            self.current_market.append(item)
            hex_pair = market_hash[i*2 : (i*2)+2]
            raw_hash_price = int(hex_pair, 16)
            scaling_bonus = self.unlocked_count * 5
            self.market_prices[item] = max(1, raw_hash_price + scaling_bonus)

        self.roll_for_artifact(market_hash)
        self.current_market.sort()

    def trigger_event(self):
        num_events = random.randint(0, 3)
        if num_events == 0:
            return

        rolls = sorted([random.randint(50, 99) for _ in range(num_events)])

        for roll in rolls:
            if roll < 57:
                missing_items = [item for item in self.active_items if item not in self.current_market]
                normal_item_count = len([m for m in self.current_market if m not in self.artifacts])

                seed_string = f"run_{self.run_id}_week_{self.week}_score_{self.total_score}_unlocked_{self.unlocked_count}"
                seed_string_two = f"money_{self.money}_week_{self.week}_score_{self.total_score}_unlocked_{self.unlocked_count}_run_{self.run_id}"
                market_hash = self.get_market_hash(seed_string)

                self.current_hash = market_hash

                for item in missing_items:
                    self.current_market.append(item)
                    hex_pair = self.current_hash[normal_item_count*2 : (normal_item_count*2)+2]
                    raw_hash_price = int(hex_pair, 16)
                    scaling_bonus = self.unlocked_count * 5
                    self.market_prices[item] = max(1, raw_hash_price + scaling_bonus)
                    normal_item_count += 1

                self.roll_for_artifact(market_hash, is_grand_market=True)

                self.current_market.sort()
                grand_msgs = [
                    	"GRAND MARKET DAY! Merchants from all realms have gathered. Everything is available!",
                    	"FESTIVAL OF COINS! The King declared a tax-free holiday! All goods are trading today!",
                    	"TRADE FLEET ARRIVES! Hundreds of ships just docked. The market is completely flooded with goods!"
                	]
                self.current_events.append(random.choice(grand_msgs))

            elif roll < 64:
                targets = [m for m in self.current_market if m not in self.artifacts]
                if targets:
                    e_item = random.choice(targets)
                    self.market_prices[e_item] *= self.week
                    boom_msgs = [
                        f"MARKET BOOM! A local lord is hoarding {e_item}. Prices are sky high!",
                        f"MARKET BOOM! 'Castle's Got Talent' bought all the {e_item}! Prices are sky high!",
                        f"MARKET BOOM! Doomsday predictions caused a sudden shortage of {e_item}! Prices are sky high!"
                    ]
                    self.current_events.append(random.choice(boom_msgs))

            elif roll < 71:
                targets = [m for m in self.current_market if m not in self.artifacts]
                if targets:
                    e_item = random.choice(targets)
                    self.market_prices[e_item] = (self.market_prices[e_item] // self.week) + 1
                    crash_msgs = [
                        f"MARKET CRASH! A massive surplus of {e_item} has flooded the market!",
                        f"MARKET CRASH! The King suddenly outlawed {e_item}! Merchants are dumping their stock!",
                        f"MARKET CRASH! Someone claimed Sand can be used in place of {e_item}. The {e_item} market crashes during this idiotic time."
                    ]
                    self.current_events.append(random.choice(crash_msgs))

            elif roll < 79:
                if random.randint(0, 1) == 0:
                    found = (random.randint(10, 1499) * self.week) + (self.unlocked_count * 200)
                    self.money += found
                    gold_msgs = [
                        f"FORTUNE! You found a discarded coin purse containing {found} GP on the floor of your store.",
                        f"FORTUNE! A grateful noble tipped you {found} GP for giving them good financial advice.",
                        f"FORTUNE! You won a tavern bet against a drunken knight and walked away with {found} GP!"
                    ]
                    self.current_events.append(random.choice(gold_msgs))
                else:
                    f_item = random.choice(self.active_items)
                    f_qty = (random.randint(10, 20) * self.week) + (self.unlocked_count * 5)
                    current_qty = self.inventory[f_item]
                    current_avg = self.average_cost[f_item]
                    current_total_value = current_qty * current_avg
                    new_qty = current_qty + f_qty
                    self.average_cost[f_item] = current_total_value // new_qty if new_qty > 0 else 0
                    self.inventory[f_item] = new_qty
                    item_msgs = [
                        f"FORTUNE! You discovered an overturned wagon and salvaged {f_qty} {f_item}!",
                        f"FORTUNE! You found a hidden smuggler's cache containing {f_qty} {f_item}!"
                    ]
                    self.current_events.append(random.choice(item_msgs))

            elif roll < 86:
                if self.locked_items:
                    f_item = random.choice(self.locked_items)
                else:
                    f_item = random.choice(self.active_items)

                f_qty = (random.randint(10, 14) * self.week) + (self.unlocked_count * 2)
                if f_item not in self.inventory:
                    self.inventory[f_item] = 0
                    self.average_cost[f_item] = 0

                current_qty = self.inventory.get(f_item, 0)
                current_avg = self.average_cost.get(f_item, 0)
                current_total_value = current_qty * current_avg
                new_qty = current_qty + f_qty
                self.average_cost[f_item] = current_total_value // new_qty if new_qty > 0 else 0
                self.inventory[f_item] = new_qty
                magic_msgs = [
                    f"BONUS! A mischievous forest fairy gifted you {f_qty} {f_item}!",
                    f"BONUS! You rubbed a strange lamp and you got {f_qty} {f_item}!"
                ]
                self.current_events.append(random.choice(magic_msgs))

            elif roll < 95:
                if self.locked_items:
                    if random.randint(0, 99) < 60:
                        self.unlock_cost = self.unlock_cost // 5
                        if self.unlock_cost < 10000:
                            self.unlock_cost = 10000
                        guild_good_msgs = [
                            "GUILD SUBSIDY! The Merchant's Guild is subsidizing permits. Unlock costs reduced!",
                            "ROYAL DECREE! The King wants more trade! Unlock fees are slashed!"
                        ]
                        self.current_events.append(random.choice(guild_good_msgs))
                    else:
                        self.unlock_cost *= 2
                        guild_bad_msgs = [
                            "GUILD MONOPOLY! The Merchant's Guild has restricted trade. Unlock costs have surged!",
                            "INFLATION! A poor harvest has driven up the price of everything, including unlock fees!"
                        ]
                        self.current_events.append(random.choice(guild_bad_msgs))
                else:
                    self.current_events.append("The Guild has no more items to offer you...")

            else:
                owned_items = [item for item, qty in self.inventory.items() if qty > 0 and item not in self.artifacts]
                if owned_items and random.randint(0, 1) == 1:
                    s_item = random.choice(owned_items)
                    current_qty = self.inventory[s_item]
                    lost_qty = random.randint(0, 49) + self.week + (self.unlocked_count * 10)
                    if lost_qty > current_qty:
                        lost_qty = current_qty
                    self.inventory[s_item] -= lost_qty
                    if self.inventory[s_item] == 0:
                        self.average_cost[s_item] = 0
                    item_ambush_msgs = [
                        f"AMBUSH! Bandits raided your shop and made off with {lost_qty} {s_item}!",
                        f"AMBUSH! Rats got into your supplies and ruined {lost_qty} {s_item}!"
                    ]
                    self.current_events.append(random.choice(item_ambush_msgs))
                else:
                    lost = random.randint(0, 299) + 100 + (self.unlocked_count * 200)
                    if self.money < lost:
                        lost = self.money
                    self.money -= lost
                    gold_ambush_msgs = [
                        f"AMBUSH! Bandits raided your shop in the night. You lost {lost} GP.",
                        f"AMBUSH! Pickpockets swarmed you in the crowded town square! You lost {lost} GP."
                    ]
                    self.current_events.append(random.choice(gold_ambush_msgs))

    def print_2_columns(self, items, formatter):
        num_items = len(items)
        if num_items == 0:
            print("  (Empty)")
            return
        rows = (num_items + 1) // 2
        for r in range(rows):
            line = "  "
            for col in range(2):
                idx = r + (col * rows)
                if idx < num_items:
                    line += formatter(idx, items[idx]) + "    "
            print(line.rstrip())

    def print_3_columns(self, items, formatter):
        num_items = len(items)
        if num_items == 0:
            print("  (Empty)")
            return
        rows = (num_items + 2) // 3
        for r in range(rows):
            line = "  "
            for col in range(3):
                idx = r + (col * rows)
                if idx < num_items:
                    line += formatter(idx, items[idx]) + " "
            print(line.rstrip())

    def parse_qty(self, user_input, max_qty):
        val = user_input.lower().strip()
        if val in ['a', 'all']: return max_qty
        if val in ['h', 'half']: return max_qty // 2
        if val in ['q', 'quarter']: return max_qty // 4
        try:
            qty = int(val)
            return qty if qty > 0 else 0
        except ValueError:
            return 0

    # --- SAVE / LOAD METHODS ---
    def save_game(self):
        save_data = {
            "run_id": self.run_id,
            "money": self.money,
            "week": self.week,
            "unlock_cost": self.unlock_cost,
            "unlocked_count": self.unlocked_count,
            "total_score": self.total_score,
            # Removed the active/locked items lists from here. Going to attempt to make the game saves forward-compatible
            "inventory": self.inventory,
            "average_cost": self.average_cost,
            "artifact_stock": self.artifact_stock,
            "current_market": self.current_market,
            "market_prices": self.market_prices,
            "current_hash": self.current_hash,
            "current_events": self.current_events
        }
        try:
            with open("trade_tycoon_save.json", "w") as f:
                json.dump(save_data, f, indent=4)
            self.current_events.append("GAME SAVED SUCCESSFULLY!")
        except Exception as e:
            self.current_events.append(f"ERROR SAVING GAME: {e}")

    def load_game(self):
        try:
            with open("trade_tycoon_save.json", "r") as f:
                save_data = json.load(f)

            # 1. Load the base numerical variables
            self.run_id = save_data.get("run_id", random.randint(100000, 999999))
            self.money = save_data.get("money", self.money)
            self.week = save_data.get("week", self.week)
            self.unlock_cost = save_data.get("unlock_cost", self.unlock_cost)
            self.total_score = save_data.get("total_score", self.total_score)

            # 2. Reconstruct the active/locked lists dynamically based on the unlocked count
            saved_unlocked_count = save_data.get("unlocked_count", 0)

            # Safeguard: Ensure we don't try to unlock more items than exist in the script
            actual_unlocks = min(saved_unlocked_count, len(self.locked_items))
            self.unlocked_count = actual_unlocks

            for _ in range(actual_unlocks):
                new_item = self.locked_items.pop(0)
                self.active_items.append(new_item)

            # 3. Load the dictionaries and market state
            self.inventory = save_data.get("inventory", self.inventory)
            self.average_cost = save_data.get("average_cost", self.average_cost)
            self.artifact_stock = save_data.get("artifact_stock", self.artifact_stock)
            self.current_market = save_data.get("current_market", self.current_market)
            self.market_prices = save_data.get("market_prices", self.market_prices)
            self.current_hash = save_data.get("current_hash", self.current_hash)
            self.current_events = save_data.get("current_events", [])

            # 4. FORWARD COMPATIBILITY SWEEP!
            # If the script has brand new items that were not in the old save inventory dictionary, safely initialize them to 0.
            for item in self.active_items + self.artifacts:
                if item not in self.inventory:
                    self.inventory[item] = 0
                    self.average_cost[item] = 0

            self.current_events.append("GAME LOADED SUCCESSFULLY!")
            return True
        except Exception as e:
            print(f"Error loading game: {e}")
            time.sleep(2)
            return False

    def run(self):
        self.generate_market()

        while True:
            total_inv_value = sum(self.inventory[item] * self.average_cost[item] for item in self.inventory if self.inventory[item] > 0)
            overall_total = self.money + total_inv_value

            self.clear_screen()
            print("=" * 200)

            print(f"   MEDIEVAL MERCHANT - Week {self.week}")
            if self.current_events:
                for event in self.current_events:
                    if event.startswith("BOUGHT") or event.startswith("SOLD"):
                        print(f"   {Colors.GREEN}( {event} ){Colors.RESET}")
                    elif event.startswith("GUILD PERMIT"):
                        print(f"   {Colors.GREEN}( +++ {event} +++ ){Colors.RESET}")
                    elif event.startswith("A LEGENDARY") or event.startswith("ARTIFACT") or event.startswith("PRESTIGE"):
                        print(f"   {Colors.MAGENTA}( !!! {event} !!! ){Colors.RESET}")
                    elif event.startswith("MARKET UPDATE:"):
                        print(f"   {Colors.RED}( {event} ){Colors.RESET}")
                    elif event.startswith("GAME SAVED") or event.startswith("GAME LOADED"):
                        print(f"   {Colors.MAGENTA}( *** {event} *** ){Colors.RESET}")
                    else:
                        print(f"   {Colors.YELLOW}( *** {event} *** ){Colors.RESET}")

            print("=" * 200)

            print(f" Current Money: {Colors.YELLOW}{self.money:,} GP{Colors.RESET}    ||    Inventory Value: {total_inv_value:,} GP    ||    Total Value: {overall_total:,} GP    ||    Current Score: {self.total_score:,}")
            # --- TEMPORARY DEBUG HASH DISPLAY ---
            print(f" Active Hash: {Colors.GRAY}{self.current_hash}{Colors.RESET}")

            print("=" * 200)
            print(" COMBINED DASHBOARD (Inventory & Local Market):")

            display_items = sorted(list(set(self.active_items + [item for item, qty in self.inventory.items() if qty > 0] + self.current_market)))

            def format_combined(idx, item):
                qty = self.inventory.get(item, 0)
                avg = self.average_cost.get(item, 0)

                if item in self.market_prices:
                    m_price = self.market_prices[item]
                    mkt_str = f"[Market: {m_price:,} GP]"

                    if item in self.artifacts:
                        mkt_color = Colors.MAGENTA
                        if qty > 0:
                            inv_color = Colors.MAGENTA
                            idx_color = Colors.MAGENTA
                        else:
                            inv_color = Colors.GRAY
                            idx_color = Colors.RESET
                    else:
                        mkt_color = self.get_price_color(m_price)
                        if qty > 0:
                            inv_color = self.get_price_color(avg)
                            idx_color = inv_color
                        else:
                            inv_color = Colors.GRAY
                            idx_color = Colors.RESET
                else:
                    mkt_color = Colors.GRAY
                    mkt_str = "[Market: N/A]"

                    if item in self.artifacts:
                        inv_color = Colors.MAGENTA
                        idx_color = Colors.MAGENTA
                    else:
                        inv_color = Colors.GRAY
                        idx_color = Colors.GRAY

                raw_inv_str = f"[{idx + 1:<2}] {item}: ({qty:,} @ {avg:,} GP)"
                visible_text = f"{raw_inv_str} --- {mkt_str}"
                visible_len = len(visible_text)

                padding = " " * max(0, 80 - visible_len)

                colored_inv_str = f"{idx_color}[{idx + 1:<2}]{Colors.RESET} {inv_color}{item}: ({qty:,} @ {avg:,} GP){Colors.RESET}"
                return f"{colored_inv_str} {Colors.GRAY}---{Colors.RESET} {mkt_color}{mkt_str}{Colors.RESET}{padding}"

            self.print_2_columns(display_items, format_combined)

            print("=" * 200)

            if self.locked_items:
                gp_text = f"{Colors.RED}GP{Colors.RESET}" if self.money >= self.unlock_cost else "GP"
                score_text = f"{Colors.RED}Score{Colors.RESET}" if self.total_score >= self.unlock_cost else "Score"
                unlock_prompt = f"[{Colors.YELLOW}U{Colors.RESET}]nlock Item ({self.unlock_cost:,} {gp_text}/{score_text})"
            else:
                unlock_prompt = f"{Colors.MAGENTA}*** YOU WON! Everything Is Unlocked! [{Colors.YELLOW}P{Colors.MAGENTA}]restige? ***{Colors.RESET}"

            print(f"Actions: [{Colors.YELLOW}B{Colors.RESET}]uy | [{Colors.YELLOW}S{Colors.RESET}]ell/Use | [{Colors.YELLOW}N{Colors.RESET}]ext Week | {unlock_prompt} | [{Colors.YELLOW}W{Colors.RESET}]rite Save | [{Colors.YELLOW}L{Colors.RESET}]oad | [{Colors.YELLOW}Q{Colors.RESET}]uit")
            action = input("What would you like to do? ").strip().lower()

            if action == 'b':
                try:
                    item_idx = int(input(f"Enter item number to buy (1-{len(display_items)}): ")) - 1
                    if 0 <= item_idx < len(display_items):
                        item = display_items[item_idx]

                        if item not in self.market_prices:
                            print(f"ERROR: {item} is not being traded in the market this week!")
                            time.sleep(1)
                        else:
                            price = self.market_prices[item]
                            max_qty = self.money // price

                            if item in self.artifacts:
                                stock = self.artifact_stock.get(item, 10)
                                if max_qty > stock:
                                    max_qty = stock

                            if max_qty > 0:
                                input_qty = input(f"How many {item} would you like to buy? (Max: {max_qty}, [A]ll/[H]alf/[Q]uarter): ")
                                qty = self.parse_qty(input_qty, max_qty)

                                if 0 < qty <= max_qty:
                                    cost = price * qty
                                    current_qty = self.inventory.get(item, 0)
                                    current_avg = self.average_cost.get(item, 0)
                                    new_qty = current_qty + qty

                                    new_total_value = (current_qty * current_avg) + cost
                                    self.average_cost[item] = new_total_value // new_qty

                                    self.money -= cost
                                    self.inventory[item] = new_qty
                                    self.current_events.append(f"BOUGHT: {qty:,} {item} for {cost:,} GP")

                                    if item in self.artifacts:
                                        self.artifact_stock[item] -= qty
                                        if self.artifact_stock[item] <= 0:
                                            self.current_market.remove(item)
                                            del self.market_prices[item]
                                            self.current_events.append(f"MARKET UPDATE: The market has sold out of {item} for this week!")

                                else:
                                    print("Invalid quantity or not enough Gold Pieces!")
                                    time.sleep(1)
                            else:
                                if item in self.artifacts and self.artifact_stock.get(item, 10) <= 0:
                                    print(f"The market is sold out of {item}!")
                                else:
                                    print(f"You can't even afford one {item}!")
                                time.sleep(1)
                    else:
                        print("Invalid item number!")
                        time.sleep(1)
                except ValueError:
                    print("Invalid input! Please enter a number.")
                    time.sleep(1)

            elif action == 's':
                try:
                    item_idx = int(input(f"Enter item number to sell/use (1-{len(display_items)}): ")) - 1
                    if 0 <= item_idx < len(display_items):
                        item = display_items[item_idx]

                        if item in self.artifacts:
                            if self.inventory.get(item, 0) > 0:
                                print(f"\n{Colors.MAGENTA}*** ARTIFACT SELECTED: {item} ***{Colors.RESET}")
                                if item == "Smuggler's Writ":
                                    print("POWER: Bypass local tariffs and force the market to accept ANY item from your inventory!")
                                elif item == "Black Swan Catalyst":
                                    print("POWER: Triggers a geopolitical crisis! (Crashes 1/4 of the market commodities, skyrockets another 1/4)")
                                elif item == "Political Favors":
                                    print("POWER: Call in a massive favor from the Crown! Instantly receive 10,000 of ANY item (even locked ones) for free!")

                                confirm = input(f"Do you want to invoke this artifact? (Y/N): ").strip().lower()
                                if confirm == 'y':
                                    if item == "Smuggler's Writ":
                                        try:
                                            smuggle_idx = int(input(f"Enter the dashboard number of the item you want to smuggle: ")) - 1
                                            if 0 <= smuggle_idx < len(display_items):
                                                smuggle_item = display_items[smuggle_idx]
                                                max_qty = self.inventory.get(smuggle_item, 0)

                                                if max_qty > 0 and smuggle_item not in self.artifacts:
                                                    sell_price = self.average_cost.get(smuggle_item, 1)
                                                    if sell_price <= 0:
                                                        sell_price = 1

                                                    input_qty = input(f"How many {smuggle_item} would you like to smuggle? (Max: {max_qty}, [A]ll/[H]alf/[Q]uarter): ")
                                                    qty = self.parse_qty(input_qty, max_qty)

                                                    if 0 < qty <= max_qty:
                                                        self.inventory[item] -= 1
                                                        if self.inventory[item] == 0:
                                                            self.average_cost[item] = 0

                                                        revenue = sell_price * qty
                                                        self.money += revenue
                                                        self.total_score += revenue
                                                        self.inventory[smuggle_item] -= qty

                                                        if self.inventory[smuggle_item] == 0:
                                                            self.average_cost[smuggle_item] = 0

                                                        if smuggle_item not in self.market_prices:
                                                            self.current_market.append(smuggle_item)
                                                            self.market_prices[smuggle_item] = sell_price
                                                            self.current_market.sort()
                                                            self.current_events.append(f"ARTIFACT INVOKED: Sold {qty:,} {smuggle_item} for {revenue:,} GP. The market now accepts {smuggle_item}!")
                                                        else:
                                                            self.current_events.append(f"ARTIFACT INVOKED: Sold {qty:,} {smuggle_item} for {revenue:,} GP.")
                                                    else:
                                                        print("Invalid quantity. Invocation cancelled.")
                                                        time.sleep(1)
                                                else:
                                                    print("You cannot smuggle that item. Invocation cancelled.")
                                                    time.sleep(1)
                                            else:
                                                print("Invalid item number. Invocation cancelled.")
                                                time.sleep(1)
                                        except ValueError:
                                            print("Invalid input. Invocation cancelled.")
                                            time.sleep(1)

                                    elif item == "Black Swan Catalyst":
                                        self.inventory[item] -= 1
                                        if self.inventory[item] == 0:
                                            self.average_cost[item] = 0

                                        targets = [m for m in self.current_market if m not in self.artifacts]
                                        impact_qty = len(targets) // 4

                                        if impact_qty < 1 and len(targets) >= 2:
                                            impact_qty = 1

                                        if impact_qty >= 1 and len(targets) >= (impact_qty * 2):
                                            affected = random.sample(targets, impact_qty * 2)
                                            moons = affected[:impact_qty]
                                            crashes = affected[impact_qty:]

                                            for moon in moons:
                                                multiplier = random.randint(5, 20)
                                                baseline = 100 + (self.unlocked_count * 10)
                                                self.market_prices[moon] = (self.market_prices[moon] * multiplier) + baseline

                                            for crash in crashes:
                                                self.market_prices[crash] = 1

                                            moon_str = ", ".join(moons)
                                            crash_str = ", ".join(crashes)

                                            self.current_events.append(f"ARTIFACT INVOKED: {item} - {moon_str} skyrocketed while {crash_str} collapsed!")
                                        else:
                                            self.current_events.append(f"ARTIFACT INVOKED: {item} - The market was too small for a crisis.")

                                    elif item == "Political Favors":
                                        all_possible = sorted(self.active_items + self.locked_items)
                                        self.clear_screen()
                                        print("=" * 200)
                                        print(f"   {Colors.MAGENTA}*** ROYAL ARMORY (Political Favors) ***{Colors.RESET}")
                                        print("=" * 200)

                                        def format_armory(idx, it):
                                            return f"[{idx + 1:<2}] {it:<25}"

                                        self.print_3_columns(all_possible, format_armory)
                                        print("=" * 200)

                                        try:
                                            fav_idx = int(input(f"Enter the number of the item you want 10,000 of (1-{len(all_possible)}): ")) - 1
                                            if 0 <= fav_idx < len(all_possible):
                                                target_item = all_possible[fav_idx]

                                                self.inventory[item] -= 1
                                                if self.inventory[item] == 0:
                                                    self.average_cost[item] = 0

                                                if target_item not in self.inventory:
                                                    self.inventory[target_item] = 0
                                                    self.average_cost[target_item] = 0

                                                current_qty = self.inventory.get(target_item, 0)
                                                current_avg = self.average_cost.get(target_item, 0)
                                                current_total_value = current_qty * current_avg
                                                new_qty = current_qty + 10000

                                                self.average_cost[target_item] = current_total_value // new_qty if new_qty > 0 else 0
                                                self.inventory[target_item] = new_qty

                                                self.current_events.append(f"ARTIFACT INVOKED: Political Favors - The Crown granted you 10,000 {target_item}!")
                                            else:
                                                print("Invalid selection. Invocation cancelled.")
                                                time.sleep(1)
                                        except ValueError:
                                            print("Invalid input. Invocation cancelled.")
                                            time.sleep(1)
                                else:
                                    print("Artifact invocation cancelled.")
                                    time.sleep(1)
                            else:
                                print(f"You don't possess a {item} to use!")
                                time.sleep(1)

                        else:
                            if item not in self.market_prices:
                                print(f"ERROR: No merchants are buying {item} this week!")
                                time.sleep(1)
                            else:
                                price = self.market_prices[item]
                                max_qty = self.inventory.get(item, 0)

                                if max_qty > 0:
                                    input_qty = input(f"How many {item} would you like to sell? (Max: {max_qty}, [A]ll/[H]alf/[Q]uarter): ")
                                    qty = self.parse_qty(input_qty, max_qty)

                                    if 0 < qty <= max_qty:
                                        revenue = price * qty
                                        self.money += revenue
                                        self.total_score += revenue
                                        self.inventory[item] -= qty

                                        if self.inventory[item] == 0:
                                            self.average_cost[item] = 0

                                        self.current_events.append(f"SOLD: {qty:,} {item} for {revenue:,} GP")
                                    else:
                                        print(f"Invalid quantity or you don't have that many {item}!")
                                        time.sleep(1)
                                else:
                                    print(f"You don't have any {item} to sell!")
                                    time.sleep(1)
                    else:
                        print("Invalid item number!")
                        time.sleep(1)
                except ValueError:
                    print("Invalid input! Please enter a number.")
                    time.sleep(1)

            elif action == 'n':
                self.week += 1
                self.generate_market()
                self.trigger_event()

            elif action == 'u':
                if self.locked_items:
                    can_unlock = False
                    paid_with = ""

                    if self.money >= self.unlock_cost:
                        self.money -= self.unlock_cost
                        can_unlock = True
                        paid_with = "Gold"
                    elif self.total_score >= self.unlock_cost:
                        self.total_score -= self.unlock_cost
                        can_unlock = True
                        paid_with = "Score"

                    if can_unlock:
                        new_item = self.locked_items.pop(0)
                        self.active_items.append(new_item)

                        if new_item not in self.inventory:
                            self.inventory[new_item] = 0
                            self.average_cost[new_item] = 0

                        self.unlocked_count += 1
                        self.unlock_cost = self.unlock_cost + (self.unlock_cost // 2)
                        self.current_market.append(new_item)

                        seed_string = f"run_{self.run_id}_week_{self.week}_score_{self.total_score}_unlocked_{self.unlocked_count}"
                        seed_string_two = f"money_{self.money}_week_{self.week}_score_{self.total_score}_unlocked_{self.unlocked_count}_run_{self.run_id}"
                        market_hash = self.get_market_hash(seed_string, seed_string_two)

                        self.current_hash = market_hash

                        for i, m_item in enumerate(self.current_market):
                            if m_item in self.artifacts:
                                continue
                            hex_pair = market_hash[i*2 : (i*2)+2]
                            raw_hash_price = int(hex_pair, 16)
                            scaling_bonus = self.unlocked_count * 5
                            self.market_prices[m_item] = max(1, raw_hash_price + scaling_bonus)

                        self.current_market.sort()
                        self.current_events.append(f"GUILD PERMIT SECURED: {new_item} (Paid with {paid_with}). The market fluctuates immediately!")
                    else:
                        print(f"You need {self.unlock_cost:,} GP or Score to unlock a new item!")
                        time.sleep(2)
                else:
                    print("You have already unlocked all the realm's items!")
                    time.sleep(2)

            elif action == 'w':
                self.save_game()

            elif action == 'l':
                if os.path.exists("trade_tycoon_save.json"):
                    confirm = input(" Are you sure you want to load? Any unsaved progress will be lost! (Y/N): ").strip().lower()
                    if confirm == 'y':
                        self.load_game()
                    else:
                        print(" Load cancelled.")
                        time.sleep(1)
                else:
                    print(" No save file found!")
                    time.sleep(1)

            elif action == 'p':
                if not self.locked_items:
                    self.clear_screen()
                    print("=" * 200)
                    print(f"   {Colors.MAGENTA}*** PRESTIGE ***{Colors.RESET}")
                    print("=" * 200)

                    bonus_gp = int(self.total_score ** (1/3.0))

                    print(f" You have cornered the market and unlocked every good in the realm!")
                    print(f" If you Prestige, your empire will reset, but you will retain the following perks:")
                    print(f"   - {Colors.YELLOW}Extra Starting Wealth:{Colors.RESET} +{bonus_gp:,} GP (Cube root of your {self.total_score:,} final score)")
                    print(f"   - {Colors.MAGENTA}Legendary Heirloom:{Colors.RESET} Keep your entire collected stack of 1 Artifact type (minimum 1)")
                    print("\n Are you ready to pass the torch to the next generation?")

                    confirm = input("\n (Y/N): ").strip().lower()
                    if confirm == 'y':
                        print("\n Which artifact would you like to keep?")
                        for idx, art in enumerate(self.artifacts):
                            print(f" [{idx + 1}] {art}")

                        try:
                            art_choice = int(input(" Enter number (1-3): ")) - 1
                            if 0 <= art_choice < len(self.artifacts):
                                chosen_art = self.artifacts[art_choice]
                            else:
                                print(" Invalid selection. The Guild assigns you a Smuggler's Writ.")
                                chosen_art = self.artifacts[0]
                                time.sleep(1)
                        except ValueError:
                            print(" Invalid input. The Guild assigns you a Smuggler's Writ.")
                            chosen_art = self.artifacts[0]
                            time.sleep(1)

                        kept_qty = max(1, self.inventory.get(chosen_art, 0))

                        # --- RESET THE GAME STATE USING THE NEW HELPER FUNCTION ---
                        self.reset_game_state(bonus_gp=bonus_gp, kept_artifact=chosen_art, kept_qty=kept_qty)

                        self.generate_market()
                        self.current_events = [f"PRESTIGE SECURED! You start anew with {bonus_gp:,} extra GP and {kept_qty:,}x {chosen_art}."]

                    else:
                        print(" Prestige cancelled.")
                        time.sleep(1)
                else:
                    print(" ERROR: You must unlock every item in the realm before you can Prestige!")
                    time.sleep(2)

            elif action == 'q':
                print(f"\nSafe travels, Merchant! Your score for this game was {self.total_score:,}\n")
                break

            else:
                print("Invalid option.")
                time.sleep(1)

if __name__ == "__main__":
    game = TradeTycoon()
    game.run()
