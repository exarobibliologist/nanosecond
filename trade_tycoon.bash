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
            "Invisibility Cloak" "Lucky Dice" "Everlasting Gobstoppers" "Romulan Ale" "Lightsabers" "Safety Deposit Boxes" "Political Favors" "Cryptocurrency" "Crown Jewels" "Time Machines"
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

        # --- DYNAMIC MARKET SIZE (8 to 16 items) ---
        local market_size=$(( (RANDOM % 8) + 8 ))

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

        elif [ $roll -lt 57 ]; then
            # 7% chance: GRAND MARKET DAY
            current_market=()
            market_prices=()

            local random_range=$(( 20 + (unlocked_count * 5) ))
            local base_price=$(( 10 + (unlocked_count * 5) ))

            for item in "${active_items[@]}"; do
                current_market+=("$item")
                market_prices["$item"]=$(( (RANDOM % random_range) + base_price ))
            done

            mapfile -t current_market < <(printf "%s\n" "${current_market[@]}" | sort)

            local grand_msgs=(
                "GRAND MARKET DAY! Merchants from all realms have gathered. Everything is available!"
                "FESTIVAL OF COINS! The King declared a tax-free holiday! All goods are trading today!"
                "TRADE FLEET ARRIVES! Hundreds of ships just docked. The market is completely flooded with goods!"
            )
            current_event="${grand_msgs[$(( RANDOM % ${#grand_msgs[@]} ))]}"

        elif [ $roll -lt 64 ]; then
            # 7% chance of prices skyrocketing
            local idx=$(( RANDOM % ${#current_market[@]} ))
            local e_item="${current_market[$idx]}"
            market_prices["$e_item"]=$(( market_prices["$e_item"] * "$week" ))

            local boom_msgs=(
                "MARKET BOOM! A local lord is hoarding $e_item. Prices are sky high!"
                "MARKET BOOM! 'Castle's Got Talent' bought all the $e_item! Prices are sky high!"
                "MARKET BOOM! Doomsday predictions caused a sudden shortage of $e_item! Prices are sky high!"
            )
            current_event="${boom_msgs[$(( RANDOM % ${#boom_msgs[@]} ))]}"

        elif [ $roll -lt 71 ]; then
            # 7% chance of prices bottoming out
            local idx=$(( RANDOM % ${#current_market[@]} ))
            local e_item="${current_market[$idx]}"
            market_prices["$e_item"]=$(( (market_prices["$e_item"] / "$week") + 1 ))

            local crash_msgs=(
                "MARKET CRASH! A massive surplus of $e_item has flooded the streets!"
                "MARKET CRASH! The King suddenly outlawed $e_item! Merchants are dumping their stock!"
                "MARKET CRASH! Someone found a cheaper substitute for $e_item. Prices plummeted!"
            )
            current_event="${crash_msgs[$(( RANDOM % ${#crash_msgs[@]} ))]}"

        elif [ $roll -lt 79 ]; then
            # 8% chance of finding either gold or free active inventory
            if [ $(( RANDOM % 2 )) -eq 0 ]; then
                local found=$(( (RANDOM % 500) * "$week" + (unlocked_count * 200) ))
                money=$(( money + found ))

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
                local f_qty=$(( (RANDOM % 30) * "$week" + (unlocked_count * 5) ))

                local current_qty=${inventory["$f_item"]}
                local current_avg=${average_cost["$f_item"]}

                local current_total_value=$(( current_qty * current_avg ))
                local new_qty=$(( current_qty + f_qty ))

                average_cost["$f_item"]=$(( current_total_value / new_qty ))
                inventory["$f_item"]=$new_qty

                local item_msgs=(
                    "FORTUNE! You discovered an overturned wagon and salvaged $f_qty $f_item!"
                    "FORTUNE! A retiring merchant gifted you $f_qty $f_item for good luck!"
                    "FORTUNE! You found a hidden smuggler's cache containing $f_qty $f_item!"
                )
                current_event="${item_msgs[$(( RANDOM % ${#item_msgs[@]} ))]}"
            fi

        elif [ $roll -lt 86 ]; then
            # 7% chance: MAGIC (Fairy gives you locked/untradeable items)
            local f_item=""
            if [ ${#locked_items[@]} -gt 0 ]; then
                local idx=$(( RANDOM % ${#locked_items[@]} ))
                f_item="${locked_items[$idx]}"
            else
                local idx=$(( RANDOM % ${#active_items[@]} ))
                f_item="${active_items[$idx]}"
            fi

            local f_qty=$(( (RANDOM % 15) * "$week" + (unlocked_count * 2) ))

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

            local magic_msgs=(
                "MAGIC! A mischievous forest fairy gifted you $f_qty $f_item... but you can't sell them here!"
                "MAGIC! You rubbed a strange lamp and a Djinn granted you $f_qty $f_item!"
                "MAGIC! A dying wizard handed you a glowing satchel containing $f_qty $f_item."
            )
            current_event="${magic_msgs[$(( RANDOM % ${#magic_msgs[@]} ))]}"

        elif [ $roll -lt 95 ]; then
            # 9% chance: NEW GUILD EVENT (Halves or increases unlock_cost)
            if [ ${#locked_items[@]} -gt 0 ]; then
                if [ $(( RANDOM % 100 )) -lt 60 ]; then
                    # 60% chance to Reduce Cost to 1/3
                    unlock_cost=$(( unlock_cost / 3 ))
                    if [ "$unlock_cost" -lt 10000 ]; then
                        unlock_cost=10000 # Minimum safety floor
                    fi
                    local guild_good_msgs=(
                        "GUILD SUBSIDY! The Merchant's Guild is subsidizing permits. Unlock costs reduced!"
                        "ROYAL DECREE! The King wants more trade! Guild permit fees are slashed!"
                        "CORRUPTION EXPOSED! A corrupt guild leader was arrested. Permit costs have plummeted!"
                    )
                    current_event="${guild_good_msgs[$(( RANDOM % ${#guild_good_msgs[@]} ))]}"
                else
                    # 40% chance to Double Cost
                    unlock_cost=$(( unlock_cost * 2 ))
                    local guild_bad_msgs=(
                        "GUILD MONOPOLY! The Merchant's Guild has restricted trade. Unlock costs have surged!"
                        "GREEDY LORDS! The local lords are demanding a larger cut. Permit fees have skyrocketed!"
                        "INFLATION! A poor harvest has driven up the price of everything, including guild permits!"
                    )
                    current_event="${guild_bad_msgs[$(( RANDOM % ${#guild_bad_msgs[@]} ))]}"
                fi
            else
                # If they already unlocked everything, default to Ambush so the turn isn't wasted
                current_event="The Guild has no more items to offer you..."
            fi

        else
            # 5% chance: AMBUSH (50% chance to lose Gold, 50% chance to lose Items)
            local -a owned_items=()
            for item in "${!inventory[@]}"; do
                if [ "${inventory[$item]}" -gt 0 ]; then
                    owned_items+=("$item")
                fi
            done

            if [ ${#owned_items[@]} -gt 0 ] && [ $(( RANDOM % 2 )) -eq 1 ]; then
                local idx=$(( RANDOM % ${#owned_items[@]} ))
                local s_item="${owned_items[$idx]}"
                local current_qty=${inventory["$s_item"]}

                local lost_qty=$(( (RANDOM % 50) + "$week" + (unlocked_count * 10) ))
                if [ "$lost_qty" -gt "$current_qty" ]; then
                    lost_qty=$current_qty
                fi

                inventory["$s_item"]=$(( current_qty - lost_qty ))

                if [ "${inventory["$s_item"]}" -eq 0 ]; then
                    average_cost["$s_item"]=0
                fi

                local item_ambush_msgs=(
                    "AMBUSH! Bandits raided your shop and made off with $lost_qty $s_item!"
                    "AMBUSH! A corrupt toll inspector confiscated $lost_qty $s_item from your shop."
                    "AMBUSH! Rats got into your supplies and ruined $lost_qty $s_item!"
                )
                current_event="${item_ambush_msgs[$(( RANDOM % ${#item_ambush_msgs[@]} ))]}"

            else
                local lost=$(( (RANDOM % 300) + 100 + (unlocked_count * 200) ))
                if [ "$money" -lt "$lost" ]; then
                    lost=$money
                fi
                money=$(( money - lost ))

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

        # Calculate total invested value FIRST so it can be pushed to the top UI header
        local total_inv_value=0
        for item in "${!inventory[@]}"; do
            if [ "${inventory[$item]}" -gt 0 ]; then
                total_inv_value=$(( total_inv_value + (inventory[$item] * average_cost[$item]) ))
            fi
        done

        # Calculate Grand Total (Money + Invested)
        local overall_total=$(( money + total_inv_value ))

        clear
        echo "=========================================================================================================================================="
        if [ -n "$current_event" ]; then
            echo -e "   MEDIEVAL MERCHANT - Week $week  \033[33m( *** $current_event *** )\033[0m"
        else
            echo "   MEDIEVAL MERCHANT - Week $week"
        fi
        echo "=========================================================================================================================================="

        # NEW CONSOLIDATED UI HEADER WITH YELLOW HIGHLIGHT
        printf " Current Money: \033[33m%'d GP\033[0m    ||    Inventory Value: %'d GP    ||    Total Value: %'d GP    ||    Current Score: %'d\n" "$money" "$total_inv_value" "$overall_total" "$total_score"

        echo "=========================================================================================================================================="

        echo " YOUR SHOP:"

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
            # --- 3-COLUMN DOWN-THEN-OVER SHOP INVENTORY UI ---
            local inv_rows=$(( (num_owned + 2) / 3 ))

            for (( r=0; r<inv_rows; r++ )); do
                # Left Column (Column 1)
                local idx1=$r
                local item1="${owned_items[$idx1]}"
                local c1_start="" c1_end=""
                local str1=""

                if [ -n "$item1" ]; then
                    if [ -z "${market_prices[$item1]}" ]; then
                        c1_start="\033[38;5;236m" # Even Darker Gray (ANSI 256-color)
                        c1_end="\033[0m"
                    fi
                    local raw1=$(printf -- "- %'d %s (Avg: %'d GP)" "${inventory[$item1]}" "$item1" "${average_cost[$item1]}")
                    local pad1=$(printf "%-50s" "$raw1")
                    str1="${c1_start}${pad1}${c1_end}"
                fi

                # Middle Column (Column 2)
                local idx2=$(( r + inv_rows ))
                local item2="${owned_items[$idx2]}"
                local c2_start="" c2_end=""
                local str2=""

                if [ -n "$item2" ]; then
                    if [ -z "${market_prices[$item2]}" ]; then
                        c2_start="\033[38;5;236m"
                        c2_end="\033[0m"
                    fi
                    local raw2=$(printf -- "- %'d %s (Avg: %'d GP)" "${inventory[$item2]}" "$item2" "${average_cost[$item2]}")
                    local pad2=$(printf "%-50s" "$raw2")
                    str2="${c2_start}${pad2}${c2_end}"
                fi

                # Right Column (Column 3)
                local idx3=$(( r + (inv_rows * 2) ))
                local item3="${owned_items[$idx3]}"
                local c3_start="" c3_end=""
                local str3=""

                if [ -n "$item3" ]; then
                    if [ -z "${market_prices[$item3]}" ]; then
                        c3_start="\033[38;5;236m"
                        c3_end="\033[0m"
                    fi
                    local raw3=$(printf -- "- %'d %s (Avg: %'d GP)" "${inventory[$item3]}" "$item3" "${average_cost[$item3]}")
                    str3="${c3_start}${raw3}${c3_end}"
                fi

                # Print Row Layout
                if [ -n "$item3" ]; then
                    printf "  %b %b %b\n" "$str1" "$str2" "$str3"
                elif [ -n "$item2" ]; then
                    printf "  %b %b\n" "$str1" "$str2"
                else
                    printf "  %b\n" "$str1"
                fi
            done
        fi

        echo "------------------------------------------------------------------------------------------------------------------------------------------"
        echo " THIS WEEK'S LOCAL MARKET:"

        # --- 3-COLUMN DOWN-THEN-OVER MARKET UI WITH COLOR CODING ---
        local num_items=${#current_market[@]}
        local rows=$(( (num_items + 2) / 3 ))

        for (( r=0; r<rows; r++ )); do
            # Left Column (Column 1)
            local idx1=$r
            local i1=$(( idx1 + 1 ))
            local item1="${current_market[$idx1]}"
            local str1=""

            if [ -n "$item1" ]; then
                local c1_start="" c1_end=""
                if [ "${inventory[$item1]}" -gt 0 ]; then
                    if [ "${average_cost[$item1]}" -lt "${market_prices[$item1]}" ]; then
                        c1_start="\033[32m"; c1_end="\033[0m" # Green
                    elif [ "${average_cost[$item1]}" -gt "${market_prices[$item1]}" ]; then
                        c1_start="\033[31m"; c1_end="\033[0m" # Red
                    elif [ "${average_cost[$item1]}" -eq "${market_prices[$item1]}" ]; then
                        c1_start="\033[33m"; c1_end="\033[0m" # Yellow
                    fi
                fi
                local raw1=$(printf "[%d] %s: %'d GP" "$i1" "$item1" "${market_prices[$item1]}")
                local pad1=$(printf "%-50s" "$raw1")
                str1="${c1_start}${pad1}${c1_end}"
            fi

            # Middle Column (Column 2)
            local idx2=$(( r + rows ))
            local i2=$(( idx2 + 1 ))
            local item2="${current_market[$idx2]}"
            local str2=""

            if [ -n "$item2" ]; then
                local c2_start="" c2_end=""
                if [ "${inventory[$item2]}" -gt 0 ]; then
                    if [ "${average_cost[$item2]}" -lt "${market_prices[$item2]}" ]; then
                        c2_start="\033[32m"; c2_end="\033[0m"
                    elif [ "${average_cost[$item2]}" -gt "${market_prices[$item2]}" ]; then
                        c2_start="\033[31m"; c2_end="\033[0m"
                    elif [ "${average_cost[$item2]}" -eq "${market_prices[$item2]}" ]; then
                        c2_start="\033[33m"; c2_end="\033[0m"
                    fi
                fi
                local raw2=$(printf "[%d] %s: %'d GP" "$i2" "$item2" "${market_prices[$item2]}")
                local pad2=$(printf "%-50s" "$raw2")
                str2="${c2_start}${pad2}${c2_end}"
            fi

            # Right Column (Column 3)
            local idx3=$(( r + (rows * 2) ))
            local i3=$(( idx3 + 1 ))
            local item3="${current_market[$idx3]}"
            local str3=""

            if [ -n "$item3" ]; then
                local c3_start="" c3_end=""
                if [ "${inventory[$item3]}" -gt 0 ]; then
                    if [ "${average_cost[$item3]}" -lt "${market_prices[$item3]}" ]; then
                        c3_start="\033[32m"; c3_end="\033[0m"
                    elif [ "${average_cost[$item3]}" -gt "${market_prices[$item3]}" ]; then
                        c3_start="\033[31m"; c3_end="\033[0m"
                    elif [ "${average_cost[$item3]}" -eq "${market_prices[$item3]}" ]; then
                        c3_start="\033[33m"; c3_end="\033[0m"
                    fi
                fi
                local raw3=$(printf "[%d] %s: %'d GP" "$i3" "$item3" "${market_prices[$item3]}")
                str3="${c3_start}${raw3}${c3_end}"
            fi

            # Print Row Layout
            if [ -n "$item3" ]; then
                printf "  %b %b %b\n" "$str1" "$str2" "$str3"
            elif [ -n "$item2" ]; then
                printf "  %b %b\n" "$str1" "$str2"
            else
                printf "  %b\n" "$str1"
            fi
        done

        echo "=========================================================================================================================================="

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

                        # --- NEW: IMMEDIATE MARKET SHOCKWAVE ---
                        current_market+=("$new_item")

                        local random_range=$(( 20 + (unlocked_count * 5) ))
                        local base_price=$(( 10 + (unlocked_count * 5) ))

                        for m_item in "${current_market[@]}"; do
                            market_prices["$m_item"]=$(( (RANDOM % random_range) + base_price ))
                        done

                        # Re-sort the market so the new item falls into the correct alphabetical slot
                        mapfile -t current_market < <(printf "%s\n" "${current_market[@]}" | sort)

                        current_event="GUILD PERMIT SECURED: $new_item - The Kingdom's economy grows more volatile..."
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
