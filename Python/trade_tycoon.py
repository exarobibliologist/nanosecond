import random
import os
import time

class Colors:
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    GRAY = '\033[38;5;236m'
    RESET = '\033[0m'

class TradeTycoon:
    def __init__(self):
        # --- Initialize Local Game Variables ---
        self.money = 1000
        self.week = 1
        self.unlock_cost = 1000000
        self.unlocked_count = 0
        self.total_score = 0
        self.current_events = []

        self.active_items = ["Wood", "Iron", "Wheat", "Flour", "Cloth", "Leather", "Coal", "Copper", "Stone", "Salt", "Glass", "Waterskin", "Rope", "Beer", "Rations", "Torches", "Herbs", "Arrows", "Silver", "Gold", "Flint"]
        
        self.locked_items = [
            "Cheese", "Toxin Vials", "Antitoxin Vials", "Fire Arrows", "Shortbows", "Longbows", "Daggers", "Shortswords", "Longswords", "Chain Mail", "Plate Armor", "Tobacco", "Gems", "Potions", "Scrolls", "Holy Water", "Mithril", "Adamantine",
            "Elven Silk", "Dragon Scales", "Shadow Lanterns", "Whisperwind Cloaks", "Compass of True North", "Troll Blood", "Phoenix Feathers", "Unicorn Horns", "Superman's Cape", "Vorpal Blades", "Philosopher Stones", "Bags of Holding",
            "Invisibility Cloak", "Lucky Dice", "Everlasting Gobstoppers", "Romulan Ale", "Lightsabers", "Safety Deposit Boxes", "Political Favors", "Cryptocurrency", "Crown Jewels", "Time Machines"
        ]

        self.inventory = {item: 0 for item in self.active_items}
        self.average_cost = {item: 0 for item in self.active_items}
        self.current_market = []
        self.market_prices = {}
        
        # --- Market Anchors ---
        self.current_low_items = []
        self.current_high_items = []

    def clear_screen(self):
        os.system('cls' if os.name == 'nt' else 'clear')

    def apply_market_anchors(self):
        """Applies guaranteed high and low prices to multiple items dynamically."""
        self.current_low_items = []
        self.current_high_items = []
        
        # Scale anchors based on market size (e.g., 2 to 4 anchors of each type)
        num_anchors = max(1, min(4, len(self.current_market) // 4))

        if len(self.current_market) >= (num_anchors * 2):
            anchor_pool = random.sample(self.current_market, num_anchors * 2)
            self.current_low_items = anchor_pool[:num_anchors]
            self.current_high_items = anchor_pool[num_anchors:]
            
            # Apply Low pricing math
            for low_item in self.current_low_items:
                low_random_range = 2 + (self.unlocked_count * 2)
                low_base_price = 1 + (self.unlocked_count * 2)
                self.market_prices[low_item] = random.randint(0, low_random_range - 1) + low_base_price
            
            # Apply High pricing math
            for high_item in self.current_high_items:
                high_random_range = 40 + (self.unlocked_count * 10)
                high_base_price = 20 + (self.unlocked_count * 10)
                self.market_prices[high_item] = random.randint(30, high_random_range - 1) + high_base_price

    def generate_market(self):
        self.current_market = []
        self.market_prices = {}

        shuffled = random.sample(self.active_items, len(self.active_items))
        
        std_random_range = 20 + (self.unlocked_count * 5)
        std_base_price = 10 + (self.unlocked_count * 5)

        market_size = random.randint(8, 15) 
        
        if market_size > len(self.active_items):
            market_size = len(self.active_items)

        for i in range(market_size):
            item = shuffled[i]
            self.current_market.append(item)
            self.market_prices[item] = random.randint(0, std_random_range - 1) + std_base_price

        self.apply_market_anchors()
        self.current_market.sort()

    def trigger_event(self):
        self.current_events = []
        
        # 25% chance of a completely quiet week (0 events)
        num_events = random.randint(0, 3)
        if num_events == 0:
            return 

        for _ in range(num_events):
            # Roll exclusively within the event range (50-99) to guarantee an event
            roll = random.randint(50, 99)

            if roll < 57:
                # GRAND MARKET DAY
                self.current_market = []
                self.market_prices = {}
                random_range = 20 + (self.unlocked_count * 5)
                base_price = 10 + (self.unlocked_count * 5)

                for item in self.active_items:
                    self.current_market.append(item)
                    self.market_prices[item] = random.randint(0, random_range - 1) + base_price
                
                self.apply_market_anchors()
                self.current_market.sort()

                grand_msgs = [
                    "GRAND MARKET DAY! Merchants from all realms have gathered. Everything is available!",
                    "FESTIVAL OF COINS! The King declared a tax-free holiday! All goods are trading today!",
                    "TRADE FLEET ARRIVES! Hundreds of ships just docked. The market is completely flooded with goods!"
                ]
                self.current_events.append(random.choice(grand_msgs))
                break # Prevents subsequent events from overriding the grand market this week

            elif roll < 64:
                e_item = random.choice(self.current_market)
                self.market_prices[e_item] *= self.week

                boom_msgs = [
                    f"MARKET BOOM! A local lord is hoarding {e_item}. Prices are sky high!",
                    f"MARKET BOOM! 'Castle's Got Talent' bought all the {e_item}! Prices are sky high!",
                    f"MARKET BOOM! Doomsday predictions caused a sudden shortage of {e_item}! Prices are sky high!"
                ]
                self.current_events.append(random.choice(boom_msgs))

            elif roll < 71:
                e_item = random.choice(self.current_market)
                self.market_prices[e_item] = (self.market_prices[e_item] // self.week) + 1

                crash_msgs = [
                    f"MARKET CRASH! A massive surplus of {e_item} has flooded the streets!",
                    f"MARKET CRASH! The King suddenly outlawed {e_item}! Merchants are dumping their stock!",
                    f"MARKET CRASH! Someone found a cheaper substitute for {e_item}. Prices plummeted!"
                ]
                self.current_events.append(random.choice(crash_msgs))

            elif roll < 79:
                if random.randint(0, 1) == 0:
                    found = (random.randint(10, 499) * self.week) + (self.unlocked_count * 200)
                    self.money += found

                    gold_msgs = [
                        f"FORTUNE! You found a discarded coin purse containing {found} GP on the floor of your store.",
                        f"FORTUNE! A grateful noble tipped you {found} GP for giving them directions.",
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
                        f"FORTUNE! A retiring merchant gifted you {f_qty} {f_item} for good luck!",
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
                    f"BONUS! You rubbed a strange lamp and you got {f_qty} {f_item}!",
                    f"BONUS! A man handed you a glowing satchel containing {f_qty} {f_item}."
                ]
                self.current_events.append(random.choice(magic_msgs))

            elif roll < 95:
                if self.locked_items:
                    if random.randint(0, 99) < 60:
                        self.unlock_cost = self.unlock_cost // 3
                        if self.unlock_cost < 10000:
                            self.unlock_cost = 10000
                        
                        guild_good_msgs = [
                            "GUILD SUBSIDY! The Merchant's Guild is subsidizing permits. Unlock costs reduced!",
                            "ROYAL DECREE! The King wants more trade! Guild permit fees are slashed!",
                            "CORRUPTION EXPOSED! A corrupt guild leader was arrested. Permit costs have plummeted!"
                        ]
                        self.current_events.append(random.choice(guild_good_msgs))
                    else:
                        self.unlock_cost *= 2
                        guild_bad_msgs = [
                            "GUILD MONOPOLY! The Merchant's Guild has restricted trade. Unlock costs have surged!",
                            "GREEDY LORDS! The local lords are demanding a larger cut. Permit fees have skyrocketed!",
                            "INFLATION! A poor harvest has driven up the price of everything, including guild permits!"
                        ]
                        self.current_events.append(random.choice(guild_bad_msgs))
                else:
                    self.current_events.append("The Guild has no more items to offer you...")

            else:
                owned_items = [item for item, qty in self.inventory.items() if qty > 0]
                
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
                        f"AMBUSH! A corrupt toll inspector confiscated {lost_qty} {s_item} from your shop.",
                        f"AMBUSH! Rats got into your supplies and ruined {lost_qty} {s_item}!"
                    ]
                    self.current_events.append(random.choice(item_ambush_msgs))
                else:
                    lost = random.randint(0, 299) + 100 + (self.unlocked_count * 200)
                    if self.money < lost:
                        lost = self.money
                    
                    self.money -= lost
                    
                    gold_ambush_msgs = [
                        f"AMBUSH! Highwaymen raided your camp in the night. You lost {lost} GP.",
                        f"AMBUSH! A corrupt town guard fined you for a fake infraction. You paid {lost} GP.",
                        f"AMBUSH! Pickpockets swarmed you in the crowded town square! You lost {lost} GP."
                    ]
                    self.current_events.append(random.choice(gold_ambush_msgs))

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

    def run(self):
        self.generate_market()

        while True:
            total_inv_value = sum(self.inventory[item] * self.average_cost[item] for item in self.inventory if self.inventory[item] > 0)
            overall_total = self.money + total_inv_value

            self.clear_screen()
            print("=" * 150)
            
            print(f"   MEDIEVAL MERCHANT - Week {self.week}")
            if self.current_events:
                for event in self.current_events:
                    print(f"   {Colors.YELLOW}( *** {event} *** ){Colors.RESET}")
                
            if self.current_low_items and self.current_high_items:
                lows_str = ", ".join(self.current_low_items)
                highs_str = ", ".join(self.current_high_items)
                print(f"   MARKET ANCHORS: {Colors.RED}[ LOW: {lows_str} ] --- [ HIGH: {highs_str} ]{Colors.RESET}")
                
            print("=" * 150)

            print(f" Current Money: {Colors.YELLOW}{self.money:,} GP{Colors.RESET}    ||    Inventory Value: {total_inv_value:,} GP    ||    Total Value: {overall_total:,} GP    ||    Current Score: {self.total_score:,}")
            print("=" * 150)
            print(" YOUR SHOP:")

            owned_items = sorted([item for item in self.inventory.keys() if self.inventory[item] > 0])
            
            def format_inventory(idx, item):
                color = Colors.GRAY if item not in self.market_prices else ""
                end_color = Colors.RESET if item not in self.market_prices else ""
                raw_str = f"- {self.inventory[item]:,} {item} (Avg: {self.average_cost[item]:,} GP)"
                return f"{color}{raw_str:<45}{end_color}"

            self.print_3_columns(owned_items, format_inventory)

            print("-" * 150)
            print(" THIS WEEK'S LOCAL MARKET:")

            def format_market(idx, item):
                color = ""
                end_color = ""
                if self.inventory.get(item, 0) > 0:
                    avg = self.average_cost[item]
                    m_price = self.market_prices[item]
                    if avg < m_price:
                        color, end_color = Colors.GREEN, Colors.RESET
                    elif avg > m_price:
                        color, end_color = Colors.RED, Colors.RESET
                    else:
                        color, end_color = Colors.YELLOW, Colors.RESET
                
                raw_str = f"[{idx + 1}] {item}: {self.market_prices[item]:,} GP"
                return f"{color}{raw_str:<45}{end_color}"

            self.print_3_columns(self.current_market, format_market)

            print("=" * 150)
            print(f"Actions: [B]uy | [S]ell | [N]ext Week | [U]nlock Item ({self.unlock_cost:,} GP/Score) | [Q]uit")
            action = input("What would you like to do? ").strip().lower()

            if action == 'b':
                try:
                    item_idx = int(input(f"Enter market item number to buy (1-{len(self.current_market)}): ")) - 1
                    if 0 <= item_idx < len(self.current_market):
                        item = self.current_market[item_idx]
                        price = self.market_prices[item]
                        max_qty = self.money // price

                        if max_qty > 0:
                            input_qty = input(f"How many {Colors.RED}{item}{Colors.RESET} would you like to buy? (Max: {max_qty}, [A]ll/[H]alf/[Q]uarter): ")
                            qty = self.parse_qty(input_qty, max_qty)

                            if 0 < qty <= max_qty:
                                cost = price * qty
                                current_qty = self.inventory[item]
                                current_avg = self.average_cost[item]
                                new_qty = current_qty + qty
                                
                                new_total_value = (current_qty * current_avg) + cost
                                self.average_cost[item] = new_total_value // new_qty
                                
                                self.money -= cost
                                self.inventory[item] = new_qty
                                print(f"Bought {qty} {item} for {cost} GP!")
                                time.sleep(1)
                            else:
                                print("Invalid quantity or not enough Gold Pieces!")
                                time.sleep(1)
                        else:
                            print(f"You can't even afford one {item}!")
                            time.sleep(1)
                    else:
                        print("Invalid item number!")
                        time.sleep(1)
                except ValueError:
                    print("Invalid input!")
                    time.sleep(1)

            elif action == 's':
                try:
                    item_idx = int(input(f"Enter market item number to sell (1-{len(self.current_market)}): ")) - 1
                    if 0 <= item_idx < len(self.current_market):
                        item = self.current_market[item_idx]
                        price = self.market_prices[item]
                        max_qty = self.inventory.get(item, 0)

                        if max_qty > 0:
                            input_qty = input(f"How many {Colors.RED}{item}{Colors.RESET} would you like to sell? (Max: {max_qty}, [A]ll/[H]alf/[Q]uarter): ")
                            qty = self.parse_qty(input_qty, max_qty)

                            if 0 < qty <= max_qty:
                                revenue = price * qty
                                self.money += revenue
                                self.total_score += revenue
                                self.inventory[item] -= qty

                                if self.inventory[item] == 0:
                                    self.average_cost[item] = 0

                                print(f"Sold {Colors.RED}{qty} {item}{Colors.RESET} for {revenue} GP!")
                                time.sleep(1)
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
                    print("Invalid input!")
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

                        self.inventory[new_item] = 0
                        self.average_cost[new_item] = 0
                        self.unlocked_count += 1
                        
                        self.unlock_cost = self.unlock_cost + (self.unlock_cost // 2)

                        self.current_market.append(new_item)
                        random_range = 20 + (self.unlocked_count * 5)
                        base_price = 10 + (self.unlocked_count * 5)

                        for m_item in self.current_market:
                            self.market_prices[m_item] = random.randint(0, random_range - 1) + base_price
                        
                        self.apply_market_anchors()
                        self.current_market.sort()
                        
                        self.current_events.append(f"GUILD PERMIT SECURED: {new_item} (Paid with {paid_with}) - The Kingdom's economy grows more volatile...")
                    else:
                        print(f"You need {self.unlock_cost:,} GP or Score to unlock a new item!")
                        time.sleep(2)
                else:
                    print("You have already unlocked all the realm's items!")
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