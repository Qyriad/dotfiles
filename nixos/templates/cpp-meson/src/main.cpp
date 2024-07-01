#include <cstddef>
#include <string>
#include <vector>

#include <fmt/core.h>

using fmt::println;

int main(int argc, char *argv[])
{
	std::vector<std::string> args(&argv[0], &argv[argc]);

	for (std::size_t i = 0; auto const & arg : args) {
		println("Arg {}: {}", i, arg);
		i += 1;
	}
}
