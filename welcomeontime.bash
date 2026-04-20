#! /bin/bash/

function welcomeontime()
{
## Here's one way to display your total uptime!
ontime=$(uptime | sed 's/^[^u]*up  *\([^,]*\),.*/\1/')

echo -e "$(bold 2)Uptime =$(reset)$(color 8) $ontime"
}
