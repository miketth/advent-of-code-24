#include <algorithm>
#include <fstream>
#include <iostream>
#include <limits.h>
#include <map>
#include <queue>
#include <vector>

using std::string;
using std::vector;

vector<string> read_file(const string& filename) {
    auto file = std::ifstream(filename);
    if (!file) {
        throw std::runtime_error("Couldn't open file");
    }

    vector<string> lines;
    string line;
    while (std::getline(file, line)) {
        lines.push_back(line);
    }

    file.close();
    return lines;
}

const std::vector<std::vector<char>> numpad = {
    { '7', '8', '9' },
    { '4', '5', '6' },
    { '1', '2', '3' },
    { '\0', '0', 'A' }
};

const std::vector<std::vector<char>> dirpad = {
    { '\0', '^', 'A' },
    { '<', 'v', '>' },
};

[[nodiscard]] std::pair<int, int> keypad_idx(const vector<vector<char>>& keypad, const char& c) {
    for (int y = 0; y < keypad.size(); y++) {
        for (int x = 0; x < keypad[y].size(); x++) {
            if (keypad[y][x] == c) {
                return { x, y };
            }
        }
    }

    throw std::runtime_error("key not found");
}


vector<string> paths(const char& from, const char& to, bool is_numpad) {
    auto keypad_p = &dirpad;
    if (is_numpad) {
        keypad_p = &numpad;
    }

    const auto& keypad = *keypad_p;

    const auto [from_x, from_y] = keypad_idx(keypad, from);
    const auto [to_x, to_y] = keypad_idx(keypad, to);

    const auto x_diff = to_x - from_x;
    const auto y_diff = to_y - from_y;

    auto horiz_char = '>';
    if (x_diff < 0) {
        horiz_char = '<';
    }
    const auto horizontal = string(abs(x_diff), horiz_char);

    auto vert_char = 'v';
    if (y_diff < 0) {
        vert_char = '^';
    }
    const auto vertical = string(abs(y_diff), vert_char);


    if (x_diff == 0 || y_diff == 0) {
        return { horizontal + vertical };
    }

    vector<string> possible;

    // if horizontal->vertical possible
    if (keypad[from_y][to_x] != '\0') {
        possible.push_back(horizontal + vertical);
    }

    // if vertical->horizontal possible
    if (keypad[to_y][from_x] != '\0') {
        possible.push_back(vertical + horizontal);
    }

    return possible;
}

vector<string> paths(const string& combination, bool is_numpad) {
    vector<string> ret = {""};
    char prev = 'A';
    for (const auto& next: combination) {
        vector<string> next_ret;
        auto paths_here = paths(prev, next, is_numpad);
        for (const auto& r: ret) {
            for (const auto& p: paths_here) {
                next_ret.push_back(r+p+'A');
            }
        }
        prev = next;
        ret = next_ret;
    }
    return ret;
}

vector<string> paths(const vector<string>& combinations) {
    vector<string> ret;
    for (const auto& c: combinations) {
        auto paths_for_c = paths(c, false);
        ret.insert(ret.end(), paths_for_c.begin(), paths_for_c.end());
    }
    return ret;
}

// const string filename = "input_sample.txt";
const string filename = "input.txt";

int main() {
    const auto codes = read_file(filename);

    unsigned long int sum = 0;

    for (const auto& code: codes) {
        vector<string> final_paths;

        auto paths_for_code = paths(code, true);
        for (int i = 0; i < 2; i++) {
            paths_for_code = paths(paths_for_code);
        }

        auto shortest_path = *std::ranges::min_element(paths_for_code, [](const string& s1, const string& s2) {
            return s1.length() < s2.length();
        });

        std::cout << code << ": " << shortest_path << std::endl;
        sum += shortest_path.length() * stoi(code);
    }

    std::cout << sum << std::endl;

    return 0;
}