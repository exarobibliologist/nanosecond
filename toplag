#!/bin/bash

function toplag()
{
	ps -eo size,cputime,vsz,comm,pid --sort=-size,-cputime,-vsz,+comm,+pid | column -t | expand | head --lines=20
}
