#include <algorithm>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <vector>

using std::string;
using std::vector;
using std::shared_ptr;

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

class CacheKey {
    bool is_combo = false;
    std::pair<char, char> simple = { '\0', '\0' };
    string combo;

public:
    CacheKey(const string& combo) {
        this->is_combo = true;
        this->combo = combo;
    }

    CacheKey(const std::pair<char, char>& simple) {
        this->is_combo = false;
        this->simple = simple;
    }

    auto operator<=>(const CacheKey& rhs) const {
        if (is_combo != rhs.is_combo) {
            return std::strong_ordering::less;
        }
        if (is_combo) {
            return combo <=> rhs.combo;
        }
        return simple <=> rhs.simple;
    }

    auto operator==(const CacheKey& rhs) const {
        if (is_combo != rhs.is_combo) {
            return false;
        }
        if (is_combo) {
            return combo == rhs.combo;
        }
        return simple == rhs.simple;
    }
};

string best_path(const char& from, const char& to, std::map<CacheKey, string>& cache, const bool is_numpad = false) {
    const std::pair simple_cache_key = { from, to };
    const CacheKey cache_key = simple_cache_key;
    if (cache.contains(cache_key)) {
        return cache[cache_key];
    }

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
        auto solution = horizontal + vertical;
        cache[cache_key] = solution ;
        return solution;
    }

    // if horizontal->vertical isn't possible
    if (keypad[from_y][to_x] == '\0') {
        auto solution = vertical + horizontal;
        cache[cache_key] = solution;
        return solution;
    }

    // if vertical->horizontal isn't possible
    if (keypad[to_y][from_x] == '\0') {
        auto solution = horizontal + vertical;
        cache[cache_key] = solution;
        return solution;
    }

    // if left: horiz->vert is better
    if (x_diff < 0) {
        auto solution = horizontal + vertical;
        cache[cache_key] = solution;
        return solution;
    }

    // if right: vert->horiz is better
    auto solution = vertical + horizontal;
    cache[cache_key] = solution;
    return solution;
}

string best_path(const string& combination, std::map<CacheKey, string>& cache, const bool is_numpad = false) {
    string ret;
    char prev = 'A';
    for (const auto& next: combination) {
        auto path_here = best_path(prev, next, cache, is_numpad);
        ret += path_here + 'A';
        prev = next;
    }

    return ret;
}


// const string filename = "input_sample.txt";
const string filename = "input.txt";

int main() {
    const auto codes = read_file(filename);

    unsigned long int sum = 0;

    std::map<CacheKey, string> numpad_cache;
    std::map<CacheKey, string> dirpad_cache;
    for (const auto& code: codes) {
        vector<string> final_paths;

        auto path = best_path(code, numpad_cache, true);
        for (int i = 0; i < 2; i++) {
            path = best_path(path, dirpad_cache);
        }

        sum += path.length() * stoi(code);
    }

    std::cout << sum << std::endl;

    return 0;
}