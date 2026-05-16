#!/bin/bash

trade_tycoon() {
    # --- Initialize Local Game Variables ---
    local money=1000
    local week=1
    local unlock_cost=1000000
    local unlocked_count=0
    local total_score=0 # Tracks total revenue from sold items
    local current_event=""

    # Expanded DnD Active Items
    local active_items=( "Wood" "Iron" "Wheat" "Flour" "Cloth" "Leather" "Coal" "Copper" "Stone" "Salt" "Glass" "Waterskin" "Rope" "Beer" "Rations" "Torches" "Herbs" "Arrows" "Silver" "Gold" "Flint" )

    # Expanded DnD Locked Items
    local locked_items=( "Cheese" "Toxin Vials" "Antitoxin Vials" "Fire Arrows" "Shortbows" "Longbows" "Daggers" "Shortswords" "Longswords" "Chain Mail" "Plate Armor" "Tobacco" "Gems" "Potions" "Scrolls" "Holy Water" "Mithril" "Adamantine"
            "Elven Silk" "Dragon Scales" "Shadow Lanterns" "Whisperwind Cloaks" "Compass of True North" "Troll Blood" "Phoenix Feathers" "Unicorn Horns" "Superman's Cape" "Vorpal Blades" "Philosopher Stones" "Bags of Holding"
            "Invisibility Cloak" "Lucky Dice" "Everlasting Gobstoppers" "Romulan Ale" "Lightsabers" "Political Favors" "Cryptocurrency" "Time Machines"
    )

    # Local associative arrays and arrays
    local -A inventory
    local -A market_prices
    local -A average_cost
    local -a current_market
    local -a sorted_inventory_keys
    local -a owned_items # New array for filtering the inventory

    # Local loop and input variables
    local item price qty cost revenue action new_item item_idx max_qty input_qty
    local -a shuffled

    # Populate starting inventory and average cost with 0
    for item in "${active_items[@]}"; do
        inventory["$item"]=0
        average_cost["$item"]=0
    done

    # Helper function to generate the dynamic market
    __tycoon_generate_market() {
        current_market=()
        market_prices=()

        # Use mapfile to handle items with spaces
        mapfile -t shuffled < <(shuf -e "${active_items[@]}")

        local i
        local random_range=$(( 20 + (unlocked_count * 5) ))
        local base_price=$(( 10 + (unlocked_count * 5) ))

        # --- DYNAMIC MARKET SIZE (5 to 12 items) ---
        local market_size=$(( (RANDOM % 8) + 5 ))

        # Safety check: Don't try to pull more items than exist in the active pool
        if [ "$market_size" -gt "${#active_items[@]}" ]; then
            market_size="${#active_items[@]}"
        fi

        # Generate the random items for the week
        for (( i=0; i<market_size; i++ )); do
            item="${shuffled[$i]}"
            current_market+=("$item")
            price=$(( (RANDOM % random_range) + base_price ))
            market_prices["$item"]=$price
        done

        # Sort the market alphabetically
        mapfile -t current_market < <(printf "%s\n" "${current_market[@]}" | sort)
    }

    # Helper function to trigger wildcard events
    __tycoon_trigger_event() {
        current_event=""
        local roll=$(( RANDOM % 100 ))

        if [ $roll -lt 50 ]; then
            # 50% chance of nothing happening
            return

        elif [ $roll -lt 59 ]; then
            # 9% chance: GRAND MARKET DAY
            current_market=()
            market_prices=()

            local random_range=$(( 20 + (unlocked_count * 5) ))
            local base_price=$(( 10 + (unlocked_count * 5) ))

            for item in "${active_items[@]}"; do
                current_market+=("$item")
                market_prices["$item"]=$(( (RANDOM % random_range) + base_price ))
            done

            mapfile -t current_market < <(printf "%s\n" "${current_market[@]}" | sort)

            # --- RANDOMIZED GRAND MARKET FLAVOR TEXT ---
            local grand_msgs=(
                "GRAND MARKET DAY! Merchants from all realms have gathered. Everything is available!"
                "FESTIVAL OF COINS! The King declared a tax-free holiday! All goods are trading today!"
                "TRADE FLEET ARRIVES! Hundreds of ships just docked. The market is completely flooded with goods!"
            )
            current_event="${grand_msgs[$(( RANDOM % ${#grand_msgs[@]} ))]}"

        elif [ $roll -lt 68 ]; then
            # 9% chance of prices skyrocketing
            local idx=$(( RANDOM % ${#current_market[@]} ))
            local e_item="${current_market[$idx]}"
            market_prices["$e_item"]=$(( market_prices["$e_item"] * "$week" ))

            # --- RANDOMIZED BOOM FLAVOR TEXT ---
            local boom_msgs=(
                "MARKET BOOM! A local lord is hoarding $e_item. Prices are sky high!"
                "MARKET BOOM! 'Castle's Got Talent' bought all the $e_item! Prices are sky high!"
                "MARKET BOOM! Doomsday predictions caused a sudden shortage of $e_item! Prices are sky high!"
            )
            current_event="${boom_msgs[$(( RANDOM % ${#boom_msgs[@]} ))]}"

        elif [ $roll -lt 76 ]; then
            # 8% chance of prices bottoming out
            local idx=$(( RANDOM % ${#current_market[@]} ))
            local e_item="${current_market[$idx]}"
            market_prices["$e_item"]=$(( (market_prices["$e_item"] / "$week") + 1 ))

            # --- RANDOMIZED CRASH FLAVOR TEXT ---
            local crash_msgs=(
                "MARKET CRASH! A massive surplus of $e_item has flooded the streets!"
                "MARKET CRASH! The King suddenly outlawed $e_item! Merchants are dumping their stock!"
                "MARKET CRASH! Someone found a cheaper substitute for $e_item. Prices plummeted!"
            )
            current_event="${crash_msgs[$(( RANDOM % ${#crash_msgs[@]} ))]}"

        elif [ $roll -lt 87 ]; then
            # 9% chance of finding either gold or free active inventory
            if [ $(( RANDOM % 2 )) -eq 0 ]; then
                local found=$(( (RANDOM % 500) * "$week" + (unlocked_count * 200) ))
                money=$(( money + found ))

                # --- RANDOMIZED GOLD FORTUNE FLAVOR TEXT ---
                local gold_msgs=(
                    "FORTUNE! You found a discarded coin purse containing $found GP on the floor of your store."
                    "FORTUNE! A grateful noble tipped you $found GP for giving them directions."
                    "FORTUNE! A grateful noble tipped you $found GP for giving them good financial advice."
                    "FORTUNE! You won a tavern bet against a drunken knight and walked away with $found GP!"
                )
                current_event="${gold_msgs[$(( RANDOM % ${#gold_msgs[@]} ))]}"
            else
                local idx=$(( RANDOM % ${#active_items[@]} ))
                local f_item="${active_items[$idx]}"
                local f_qty=$(( (RANDOM % 30) + "$week" + (unlocked_count * 5) ))

                local current_qty=${inventory["$f_item"]}
                local current_avg=${average_cost["$f_item"]}

                local current_total_value=$(( current_qty * current_avg ))
                local new_qty=$(( current_qty + f_qty ))

                average_cost["$f_item"]=$(( current_total_value / new_qty ))
                inventory["$f_item"]=$new_qty

                # --- RANDOMIZED ITEM FORTUNE FLAVOR TEXT ---
                local item_msgs=(
                    "FORTUNE! You discovered an overturned wagon and salvaged $f_qty $f_item!"
                    "FORTUNE! A retiring merchant gifted you $f_qty $f_item for good luck!"
                    "FORTUNE! You found a hidden smuggler's cache containing $f_qty $f_item!"
                )
                current_event="${item_msgs[$(( RANDOM % ${#item_msgs[@]} ))]}"
            fi

        elif [ $roll -lt 95 ]; then
            # 8% chance: MAGIC (Fairy gives you locked/untradeable items)
            local f_item=""
            if [ ${#locked_items[@]} -gt 0 ]; then
                local idx=$(( RANDOM % ${#locked_items[@]} ))
                f_item="${locked_items[$idx]}"
            else
                local idx=$(( RANDOM % ${#active_items[@]} ))
                f_item="${active_items[$idx]}"
            fi

            local f_qty=$(( (RANDOM % 15) + "$week" + (unlocked_count * 2) ))

            if [ -z "${inventory["$f_item"]}" ]; then
                inventory["$f_item"]=0
                average_cost["$f_item"]=0
            fi

            local current_qty=${inventory["$f_item"]}
            local current_avg=${average_cost["$f_item"]}

            local current_total_value=$(( current_qty * current_avg ))
            local new_qty=$(( current_qty + f_qty ))

            average_cost["$f_item"]=$(( current_total_value / new_qty ))
            inventory["$f_item"]=$new_qty

            # --- RANDOMIZED MAGIC FLAVOR TEXT ---
            local magic_msgs=(
                "MAGIC! A mischievous forest fairy gifted you $f_qty $f_item... but you can't sell them here!"
                "MAGIC! You rubbed a strange lamp and a Djinn granted you $f_qty $f_item!"
                "MAGIC! A dying wizard handed you a glowing satchel containing $f_qty $f_item."
            )
            current_event="${magic_msgs[$(( RANDOM % ${#magic_msgs[@]} ))]}"

        else
            # 5% chance: AMBUSH (50% chance to lose Gold, 50% chance to lose Items)

            # First, compile a list of items the player actually owns
            local -a owned_items=()
            for item in "${!inventory[@]}"; do
                if [ "${inventory[$item]}" -gt 0 ]; then
                    owned_items+=("$item")
                fi
            done

            # If they own items AND the 50/50 coin toss hits tails, steal items!
            if [ ${#owned_items[@]} -gt 0 ] && [ $(( RANDOM % 2 )) -eq 1 ]; then
                local idx=$(( RANDOM % ${#owned_items[@]} ))
                local s_item="${owned_items[$idx]}"
                local current_qty=${inventory["$s_item"]}

                # Scale the theft amount slightly so it stings, but cap it at whatever they currently own
                local lost_qty=$(( (RANDOM % 50) + "$week" + (unlocked_count * 10) ))
                if [ "$lost_qty" -gt "$current_qty" ]; then
                    lost_qty=$current_qty
                fi

                inventory["$s_item"]=$(( current_qty - lost_qty ))

                # If they were wiped clean of that item, reset average cost
                if [ "${inventory["$s_item"]}" -eq 0 ]; then
                    average_cost["$s_item"]=0
                fi

                # --- RANDOMIZED ITEM AMBUSH FLAVOR TEXT ---
                local item_ambush_msgs=(
                    "AMBUSH! Bandits raided your shop and made off with $lost_qty $s_item!"
                    "AMBUSH! A corrupt toll inspector confiscated $lost_qty $s_item from your shop."
                    "AMBUSH! Rats got into your supplies and ruined $lost_qty $s_item!"
                )
                current_event="${item_ambush_msgs[$(( RANDOM % ${#item_ambush_msgs[@]} ))]}"

            else
                # Steal Gold (Fallback if they have no items, or if the coin toss lands heads)
                local lost=$(( (RANDOM % 300) + 100 + (unlocked_count * 200) ))
                if [ "$money" -lt "$lost" ]; then
                    lost=$money
                fi
                money=$(( money - lost ))

                # --- RANDOMIZED GOLD AMBUSH FLAVOR TEXT ---
                local gold_ambush_msgs=(
                    "AMBUSH! Highwaymen raided your camp in the night. You lost $lost GP."
                    "AMBUSH! A corrupt town guard fined you for a fake infraction. You paid $lost GP."
                    "AMBUSH! Pickpockets swarmed you in the crowded town square! You lost $lost GP."
                )
                current_event="${gold_ambush_msgs[$(( RANDOM % ${#gold_ambush_msgs[@]} ))]}"
            fi
        fi
    }

    # Initialize the first week's market
    __tycoon_generate_market

    # --- Main Game Loop ---
    while true; do
        clear
        echo "========================================="
        echo "   MEDIEVAL MERCHANT - Week $week        "
        echo "========================================="
        printf "   SCORE: %'d\n" "$total_score"
        echo "========================================="

        if [ -n "$current_event" ]; then
            echo " *** $current_event ***"
            echo "========================================="
        fi

        # Make large numbers easier to read
        printf " Money: %'d GP\n" "$money"
        echo "-----------------------------------------"

        # Calculate total invested value
        local total_inv_value=0

        for item in "${!inventory[@]}"; do
            if [ "${inventory[$item]}" -gt 0 ]; then
                total_inv_value=$(( total_inv_value + (inventory[$item] * average_cost[$item]) ))
            fi
        done

        printf " YOUR SHOP (Total Value: %'d GP):\n" "$total_inv_value"

        # Sort the wagon inventory alphabetically
        mapfile -t sorted_inventory_keys < <(printf "%s\n" "${!inventory[@]}" | sort)

        # Filter out items we don't own to prep for column math
        owned_items=()
        for item in "${sorted_inventory_keys[@]}"; do
            if [ "${inventory[$item]}" -gt 0 ]; then
                owned_items+=("$item")
            fi
        done

        local num_owned=${#owned_items[@]}
        if [ "$num_owned" -eq 0 ]; then
            echo "  (Empty)"
        else
            # --- DOWN-THEN-OVER SHOP INVENTORY UI ---
            local inv_rows=$(( (num_owned + 1) / 2 ))

            for (( r=0; r<inv_rows; r++ )); do
                # Left Column Item
                local idx1=$r
                local item1="${owned_items[$idx1]}"

                local c1_start="" c1_end=""
                if [ -z "${market_prices[$item1]}" ]; then
                    c1_start="\033[38;5;236m" # Even Darker Gray (ANSI 256-color)
                    c1_end="\033[0m"
                fi

                local raw1=$(printf -- "- %'d %s (Avg: %'d GP)" "${inventory[$item1]}" "$item1" "${average_cost[$item1]}")
                local pad1=$(printf "%-50s" "$raw1")
                local str1="${c1_start}${pad1}${c1_end}"

                # Right Column Item
                local idx2=$(( r + inv_rows ))
                if [ $idx2 -lt $num_owned ]; then
                    local item2="${owned_items[$idx2]}"

                    local c2_start="" c2_end=""
                    if [ -z "${market_prices[$item2]}" ]; then
                        c2_start="\033[38;5;236m" # Even Darker Gray (ANSI 256-color)
                        c2_end="\033[0m"
                    fi

                    local raw2=$(printf -- "- %'d %s (Avg: %'d GP)" "${inventory[$item2]}" "$item2" "${average_cost[$item2]}")
                    local str2="${c2_start}${raw2}${c2_end}"

                    # Print both columns.
                    printf "  %b %b\n" "$str1" "$str2"
                else
                    # Print only the left column
                    printf "  %b\n" "$str1"
                fi
            done
        fi

        echo "-----------------------------------------"
        echo " THIS WEEK'S LOCAL MARKET:"

        # --- DOWN-THEN-OVER MARKET UI WITH COLOR CODING ---
        local num_items=${#current_market[@]}
        local rows=$(( (num_items + 1) / 2 ))

        for (( r=0; r<rows; r++ )); do
            # Left Column Item
            local idx1=$r
            local i1=$(( idx1 + 1 ))
            local item1="${current_market[$idx1]}"

            # Left Column Color Logic
            local c1_start="" c1_end=""
            if [ "${inventory[$item1]}" -gt 0 ]; then
                if [ "${average_cost[$item1]}" -lt "${market_prices[$item1]}" ]; then
                    c1_start="\033[32m" # Green
                    c1_end="\033[0m"
                elif [ "${average_cost[$item1]}" -gt "${market_prices[$item1]}" ]; then
                    c1_start="\033[31m" # Red
                    c1_end="\033[0m"
                elif [ "${average_cost[$item1]}" -eq "${market_prices[$item1]}" ]; then
                    c1_start="\033[33m" # Yellow
                    c1_end="\033[0m"
                fi
            fi

            # Format raw string, pad it, THEN apply color
            local raw1=$(printf "[%d] %s: %'d GP" "$i1" "$item1" "${market_prices[$item1]}")
            local pad1=$(printf "%-50s" "$raw1")
            local str1="${c1_start}${pad1}${c1_end}"

            # Right Column Item
            local idx2=$(( r + rows ))
            if [ $idx2 -lt $num_items ]; then
                local i2=$(( idx2 + 1 ))
                local item2="${current_market[$idx2]}"

                # Right Column Color Logic
                local c2_start="" c2_end=""
                if [ "${inventory[$item2]}" -gt 0 ]; then
                    if [ "${average_cost[$item2]}" -lt "${market_prices[$item2]}" ]; then
                        c2_start="\033[32m" # Green
                        c2_end="\033[0m"
                    elif [ "${average_cost[$item2]}" -gt "${market_prices[$item2]}" ]; then
                        c2_start="\033[31m" # Red
                        c2_end="\033[0m"
                    elif [ "${average_cost[$item2]}" -eq "${market_prices[$item2]}" ]; then
                        c2_start="\033[33m" # Yellow
                        c2_end="\033[0m"
                    fi
                fi

                local raw2=$(printf "[%d] %s: %'d GP" "$i2" "$item2" "${market_prices[$item2]}")
                local str2="${c2_start}${raw2}${c2_end}"

                # Print both columns
                printf "  %b%b\n" "$str1" "$str2"
            else
                # Print only the left column
                printf "  %b\n" "$str1"
            fi
        done

        echo "========================================="

        # Format the unlock cost so it has commas
        printf "Actions: [B]uy | [S]ell | [N]ext Week | [U]nlock Item (%'d GP) | [Q]uit\n" "$unlock_cost"
        read -p "What would you like to do? " action

        case ${action,,} in
            b)
                read -p "Enter market item number to buy (1-${#current_market[@]}): " item_idx

                if [[ "$item_idx" =~ ^[0-9]+$ ]] && [ "$item_idx" -ge 1 ] && [ "$item_idx" -le "${#current_market[@]}" ]; then
                    item="${current_market[$((item_idx-1))]}"
                    price=${market_prices[$item]}
                    max_qty=$(( money / price ))

                    if [ "$max_qty" -gt 0 ]; then
                        read -p "How many ($item) would you like to buy? (Max: $max_qty, [A]ll/[H]alf/[Q]uarter): " input_qty

                        # --- QUICK SELECT PARSER ---
                        case ${input_qty,,} in
                            a|all) qty=$max_qty ;;
                            h|half) qty=$(( max_qty / 2 )) ;;
                            q|quarter) qty=$(( max_qty / 4 )) ;;
                            *) qty="$input_qty" ;;
                        esac

                        if [[ "$qty" =~ ^[0-9]+$ ]] && [ "$qty" -gt 0 ]; then
                            if [ "$qty" -le "$max_qty" ]; then
                                cost=$(( price * qty ))

                                local current_qty=${inventory["$item"]}
                                local current_avg=${average_cost["$item"]}
                                local current_total_value=$(( current_qty * current_avg ))
                                local new_total_value=$(( current_total_value + cost ))

                                local new_qty=$(( current_qty + qty ))

                                average_cost["$item"]=$(( new_total_value / new_qty ))

                                money=$(( money - cost ))

                                inventory["$item"]=$new_qty
                                echo "Bought $qty $item for $cost GP!"
                                sleep 1
                            else
                                echo "You don't have enough Gold Pieces for that many!"
                                sleep 1
                            fi
                        else
                            echo "Invalid quantity."
                            sleep 1
                        fi
                    else
                        echo "You can't even afford one $item!"
                        sleep 1
                    fi
                else
                    echo "Invalid item number!"
                    sleep 1
                fi
                ;;
            s)
                read -p "Enter market item number to sell (1-${#current_market[@]}): " item_idx

                if [[ "$item_idx" =~ ^[0-9]+$ ]] && [ "$item_idx" -ge 1 ] && [ "$item_idx" -le "${#current_market[@]}" ]; then
                    item="${current_market[$((item_idx-1))]}"
                    price=${market_prices[$item]}
                    max_qty=${inventory["$item"]}

                    if [ "$max_qty" -gt 0 ]; then
                        read -p "How many ($item) would you like to sell? (Max: $max_qty, [A]ll/[H]alf/[Q]uarter): " input_qty

                        # --- QUICK SELECT PARSER ---
                        case ${input_qty,,} in
                            a|all) qty=$max_qty ;;
                            h|half) qty=$(( max_qty / 2 )) ;;
                            q|quarter) qty=$(( max_qty / 4 )) ;;
                            *) qty="$input_qty" ;;
                        esac

                        if [[ "$qty" =~ ^[0-9]+$ ]] && [ "$qty" -gt 0 ]; then
                            if [ "$qty" -le "$max_qty" ]; then
                                revenue=$(( price * qty ))
                                money=$(( money + revenue ))

                                # --- ADD TO TOTAL SCORE ---
                                total_score=$(( total_score + revenue ))

                                inventory["$item"]=$(( inventory["$item"] - qty ))

                                if [ "${inventory["$item"]}" -eq 0 ]; then
                                    average_cost["$item"]=0
                                fi

                                echo "Sold $qty $item for $revenue GP!"
                                sleep 1
                            else
                                echo "You only have $max_qty $item in your wagon!"
                                sleep 1
                            fi
                        else
                            echo "Invalid quantity."
                            sleep 1
                        fi
                    else
                        echo "You don't have any $item to sell!"
                        sleep 1
                    fi
                else
                    echo "Invalid item number!"
                    sleep 1
                fi
                ;;
            n)
                week=$(( week + 1 ))
                __tycoon_generate_market
                __tycoon_trigger_event
                ;;
            u)
                if [ "$money" -ge "$unlock_cost" ]; then
                    if [ ${#locked_items[@]} -gt 0 ]; then
                        money=$(( money - unlock_cost ))

                        new_item="${locked_items[0]}"
                        active_items+=("$new_item")

                        inventory["$new_item"]=0
                        average_cost["$new_item"]=0
                        locked_items=("${locked_items[@]:1}")

                        unlocked_count=$(( unlocked_count + 1 ))

                        # --- EXΡΟΝΕΝΤIAL INFLATION ---
                        unlock_cost=$(( unlock_cost + (unlock_cost / 2) ))

                        echo "GUILD PERMIT SECURED: $new_item added to market rotation!"
                        echo "The Kingdom's economy grows more volatile..."

                        # --- NEW: IMMEDIATE MARKET SHOCKWAVE ---
                        current_market+=("$new_item")

                        local random_range=$(( 20 + (unlocked_count * 5) ))
                        local base_price=$(( 10 + (unlocked_count * 5) ))

                        for m_item in "${current_market[@]}"; do
                            market_prices["$m_item"]=$(( (RANDOM % random_range) + base_price ))
                        done

                        # Re-sort the market so the new item falls into the correct alphabetical slot
                        mapfile -t current_market < <(printf "%s\n" "${current_market[@]}" | sort)

                        sleep 3
                    else
                        echo "You have already unlocked all the realm's items!"
                        sleep 2
                    fi
                else
                    echo "You need $unlock_cost GP to unlock a new item!"
                    sleep 2
                fi
                ;;
            q)
                printf "\nSafe travels, Merchant! Your score for this game was %'d\n" "$total_score"
                unset -f __tycoon_generate_market
                unset -f __tycoon_trigger_event
                return 0
                ;;
            *)
                echo "Invalid option."
                sleep 1
                ;;
        esac
    done
}
