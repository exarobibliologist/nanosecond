#!/bin/bash

trade_tycoon() {
    # --- Initialize Local Game Variables ---
    local money=10000
    local week=1
    local unlock_cost=1000000
    local unlocked_count=0
    local current_event=""

    # Expanded DnD Active Items (From your custom list)
    local active_items=(
        "Wood" "Iron" "Wheat" "Cloth" "Leather"
        "Coal" "Copper" "Stone" "Salt" "Glass"
        "Beer" "Rations" "Torches" "Herbs" "Arrows"
    )

    # Expanded DnD Locked Items (From your custom list)
    local locked_items=(
        "Tobacco" "Silver" "Gold" "Gems" "Potions" "Scrolls"
        "Holy Water" "Mithril" "Adamantine" "Elven Silk"
        "Dragon Scales" "Magic Wands" "Spellbooks"
        "Troll Blood" "Phoenix Feathers" "Unicorn Horns" "Superman's Cape"
        "Vorpal Blades" "Philosopher Stones" "Crystal Balls" "Bags of Holding"
        "Invisibility Cloak" "Lucky Dice" "Everlasting Gobstopper" "Romulan Ale"
        "Lightsabers" "Political Favors" "Cryptocurrency" "Time Machine"
    )

    # Local associative arrays
    local -A inventory
    local -A market_prices
    local -A average_cost
    local -a current_market
    local -a sorted_inventory_keys

    # Local loop and input variables
    local item price qty cost revenue action new_item item_idx max_qty
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

        if [ $roll -lt 30 ]; then
            # 30% chance of nothing happening
            return

        elif [ $roll -lt 40 ]; then
            # 10% chance: GRAND MARKET DAY (Every unlocked item is available!)
            current_market=()
            market_prices=()

            local random_range=$(( 20 + (unlocked_count * 5) ))
            local base_price=$(( 10 + (unlocked_count * 5) ))

            for item in "${active_items[@]}"; do
                current_market+=("$item")
                market_prices["$item"]=$(( (RANDOM % random_range) + base_price ))
            done

            mapfile -t current_market < <(printf "%s\n" "${current_market[@]}" | sort)
            current_event="GRAND MARKET DAY! Merchants from all realms have gathered. Everything is available!"

        elif [ $roll -lt 60 ]; then
            # 20% chance of prices skyrocketing
            local idx=$(( RANDOM % ${#current_market[@]} ))
            local e_item="${current_market[$idx]}"
            market_prices["$e_item"]=$(( market_prices["$e_item"] * "$week" ))
            current_event="MARKET BOOM! A local lord is hoarding $e_item. Prices are sky high!"

        elif [ $roll -lt 80 ]; then
            # 20% chance of prices bottoming out
            local idx=$(( RANDOM % ${#current_market[@]} ))
            local e_item="${current_market[$idx]}"
            market_prices["$e_item"]=$(( (market_prices["$e_item"] / "$week") + 1 ))
            current_event="MARKET CRASH! A massive surplus of $e_item has flooded the streets!"

        elif [ $roll -lt 95 ]; then
            # 15% chance of finding either gold or free inventory
            if [ $(( RANDOM % 2 )) -eq 0 ]; then
                local found=$(( (RANDOM % 500) + "$week" + (unlocked_count * 200) ))
                money=$(( money + found ))
                current_event="FORTUNE! You found a discarded coin purse containing $found GP on the trail."
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

                current_event="FORTUNE! You discovered an overturned wagon and salvaged $f_qty $f_item!"
            fi

        else
            # 5% of robbers stealing some money
            local lost=$(( (RANDOM % 300) + 100 + (unlocked_count * 200) ))
            if [ "$money" -lt "$lost" ]; then
                lost=$money
            fi
            money=$(( money - lost ))
            current_event="AMBUSH! Highwaymen raided your camp in the night. You lost $lost GP."
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

        if [ -n "$current_event" ]; then
            echo " *** $current_event ***"
            echo "========================================="
        fi

        # Make large numbers easier to read
        printf " Gold Pieces: %'d GP\n" "$money"
        echo "-----------------------------------------"
        echo " YOUR WAGON (Inventory):"
        local has_items=0

        # Sort the wagon inventory alphabetically
        mapfile -t sorted_inventory_keys < <(printf "%s\n" "${!inventory[@]}" | sort)

        for item in "${sorted_inventory_keys[@]}"; do
            if [ "${inventory[$item]}" -gt 0 ]; then
                printf "  - %s: %'d (Avg Paid: %'d GP)\n" "$item" "${inventory[$item]}" "${average_cost[$item]}"
                has_items=1
            fi
        done
        if [ $has_items -eq 0 ]; then
            echo "  (Empty)"
        fi
        echo "-----------------------------------------"
        echo " THIS WEEK'S LOCAL MARKET:"
        local i=1
        for item in "${current_market[@]}"; do
            printf "  [%d] %s: %'d GP\n" "$i" "$item" "${market_prices[$item]}"
            ((i++))
        done
        echo "========================================="

        # Format the unlock cost so it has commas (e.g. 1,000,000)
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
                        read -p "How many? (Max: $max_qty): " qty

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
                        read -p "How many? (Max: $max_qty): " qty

                        if [[ "$qty" =~ ^[0-9]+$ ]] && [ "$qty" -gt 0 ]; then
                            if [ "$qty" -le "$max_qty" ]; then
                                revenue=$(( price * qty ))
                                money=$(( money + revenue ))
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
                        unlock_cost=$(( unlock_cost * 2 ))

                        echo "GUILD PERMIT SECURED: $new_item added to market rotation!"
                        echo "The Kingdom's economy grows more volatile..."
                        sleep 2
                    else
                        echo "You have already unlocked all the realm's items!"
                        sleep 1
                    fi
                else
                    echo "You need $unlock_cost GP to unlock a new item!"
                    sleep 1
                fi
                ;;
            q)
                echo "Safe travels, Merchant!"
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
