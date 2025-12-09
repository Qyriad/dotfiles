#include <print>
#include <ranges>
#include <string>
#include <vector>

int main(int argc, char *argv[])
{
	std::vector<std::string> args(&argv[0], &argv[argc]);

	for (auto const & [i, arg] : std::views::enumerate(args)) {
		std::println("Arg {}: {}", i, arg);
	}
}
