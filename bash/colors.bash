
function color256()
{
	# $1 is string
	# $2 is the color
	echo -e "\e[38;5;$2m$1\e[0m"
}

function switch256
{
	# $1 is the color
	echo -e "\e[38;5;$1m"
}

function resetcolor
{
	echo -e "\e[0m"
}

